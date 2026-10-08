import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  final String serverAddress = Constants.backendServerAddress;

  static const String _presenceChannelName = 'presence-app';

  factory SocketService() => _instance;

  /// Alias du singleton (déconnexion explicite depuis [AuthBloc], etc.).
  static SocketService get instance => _instance;

  PusherChannelsFlutter? _pusher;
  String? _conversationChannelName;
  String? _globalConversationChannelName;
  final _storage = const FlutterSecureStorage();
  void Function(dynamic data)? _conversationHandler;
  void Function(dynamic data)? _globalHandler;
  String? _adminInboxChannelName;
  void Function(dynamic data)? _adminInboxHandler;
  String? _userInboxChannelName;
  void Function(dynamic data)? _userInboxHandler;

  /// Conversation dont le chat est ouvert : ignorer le rafraîchissement inbox (évite doublon avec le canal conversation).
  String? _userInboxSuppressFetchConversationId;

  String? _activeConversationId;

  bool _presenceSubscribed = false;
  final Set<String> _typingWatchIds = {};

  SocketService._internal();

  Future<void> reconnectIfNeeded() async {
    try {
      // Re-souscrire aux événements de présence
      await subscribePresenceApp();
    } catch (e) {
      debugPrint("Erreur lors de la reconnexion au Socket: $e");
    }
  }

  bool _isMessageSentEvent(String? name) {
    if (name == null || name.isEmpty) return false;
    final raw = name.trim().toLowerCase();
    if (raw == 'message.sent' || raw.endsWith('.message.sent')) return true;
    final normalized = _normalizeEventName(name);
    return normalized == 'messagesent' || normalized == 'messagesentevent';
  }

  bool _isMessageReadEvent(String? name) {
    final normalized = _normalizeEventName(name);
    return normalized == 'messageread' || normalized == 'conversationread';
  }

  bool _isTypingEvent(String? name) {
    final normalized = _normalizeEventName(name);
    return normalized == 'usertyping' || normalized == 'typing';
  }

  String _normalizeEventName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    var s = raw.trim();
    if (s.startsWith('.')) s = s.substring(1);
    // Laravel : `App\Events\MessageSent` (FQCN)
    while (s.contains('\\')) {
      s = s.split('\\').last;
    }
    if (s.contains(r'\\')) {
      s = s.split(r'\\').last;
    }
    // `message.sent` (broadcastAs) → messagesent — ne pas garder seulement « sent »
    s = s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return s;
  }

  /// Enveloppe les données du canal conversation pour que le [ChatBloc] connaisse le nom Pusher réel
  Map<String, dynamic> _conversationEnvelope(String? eventName, dynamic data) {
    Object? decoded = data;
    if (data is String) {
      try {
        decoded = jsonDecode(data);
      } catch (_) {
        return <String, dynamic>{
          '_socket_event': eventName ?? '',
          '_socket_event_normalized': _normalizeEventName(eventName),
        };
      }
    }
    if (decoded is! Map) {
      return <String, dynamic>{
        '_socket_event': eventName ?? '',
        '_socket_event_normalized': _normalizeEventName(eventName),
        if (decoded != null) '_raw': decoded,
      };
    }
    final m = Map<String, dynamic>.from(decoded);
    m['_socket_event'] = eventName ?? '';
    m['_socket_event_normalized'] = _normalizeEventName(eventName);
    return m;
  }

  void _handleClientTyping(PusherEvent event) {
    final ch = event.channelName;
    if (!ch.startsWith('private-chat.')) return;
    final convId = ch.replaceFirst('private-chat.', '');
    if (convId.isEmpty || convId.startsWith('admin.') || convId.startsWith('inbox.')) {
      return;
    }
    dynamic raw = event.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        raw = null;
      }
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final uid = m['user_id']?.toString() ?? m['userId']?.toString();
      final me = SessionController.instance.userId ?? '';
      if (uid != null && uid.isNotEmpty && me.isNotEmpty && uid == me) {
        return;
      }
      final convIdFromPayload =
          (m['conversation_id'] ?? m['conversationId'])?.toString() ?? '';
      if (convIdFromPayload.isNotEmpty && convIdFromPayload == _activeConversationId) {
        _conversationHandler?.call(<String, dynamic>{
          ...m,
          'event': 'user.typing',
          'type': 'user.typing',
          'conversation_id': convIdFromPayload,
        });
      }
    }
    ConversationsInboxCoordinator.onRemoteTyping(convId);
  }

  void _onPresenceSubscriptionSucceeded(String? channelName, dynamic data) {
    if (channelName != _presenceChannelName) return;
    final ids = <String>{};
    try {
      Object? decoded = data;
      if (data is String) {
        decoded = jsonDecode(data);
      }
      if (decoded is Map) {
        final hash = decoded['presence']?['hash'];
        if (hash is Map) {
          hash.forEach((k, _) => ids.add(k.toString()));
        }
      }
    } catch (_) {}
    ConversationsInboxCoordinator.onPresenceSnapshot(ids);
  }

  /// Canal privé Laravel `chat.admin.{id}` → souscription Pusher `private-chat.admin.{id}`.
  Future<void> subscribeAdminInbox(String adminId, void Function(dynamic data) onMessage) async {
    await initSocket();
    if (_pusher == null) return;
    await unsubscribeAdminInbox();
    _adminInboxHandler = onMessage;
    _adminInboxChannelName = 'private-chat.admin.$adminId';
    await _pusher!.subscribe(channelName: _adminInboxChannelName!);
  }

  Future<void> unsubscribeAdminInbox() async {
    if (_pusher != null && _adminInboxChannelName != null) {
      await _pusher!.unsubscribe(channelName: _adminInboxChannelName!);
    }
    _adminInboxChannelName = null;
    _adminInboxHandler = null;
  }

  /// Canal `private-chat.inbox.{userId}` : tout nouveau message dans une conversation
  Future<void> subscribeUserInbox(String userId, void Function(dynamic data) onMessage) async {
    await initSocket();
    if (_pusher == null) return;
    await unsubscribeUserInbox();
    _userInboxHandler = onMessage;
    _userInboxChannelName = 'private-chat.inbox.$userId';
    // debugPrint('📡 [SocketService] Souscription au canal Inbox : $_userInboxChannelName');
    await _pusher!.subscribe(channelName: _userInboxChannelName!);
  }

  Future<void> unsubscribeUserInbox() async {
    if (_pusher != null && _userInboxChannelName != null) {
      await _pusher!.unsubscribe(channelName: _userInboxChannelName!);
    }
    _userInboxChannelName = null;
    _userInboxHandler = null;
  }

  /// Pendant que [ChatPage] affiche cette conversation, les événements inbox pour le même id ne déclenchent pas le callback.
  void setUserInboxSuppressFetchForConversation(String? conversationId) {
    _userInboxSuppressFetchConversationId = conversationId;
    // debugPrint('🔒 [SocketService] Conversations masquées pour l\'ID : $conversationId');
  }

  /// Présence globale (liste conversations).
  Future<void> subscribePresenceApp() async {
    await initSocket();
    if (_pusher == null || _presenceSubscribed) return;
    await _pusher!.subscribe(channelName: _presenceChannelName);
    _presenceSubscribed = true;
  }

  Future<void> unsubscribePresenceApp() async {
    if (_pusher == null || !_presenceSubscribed) return;
    try {
      await _pusher!.unsubscribe(channelName: _presenceChannelName);
    } catch (_) {}
    _presenceSubscribed = false;
  }

  /// Abonnements légers aux canaux `private-chat.{conversationId}`.
  Future<void> setTypingWatchForConversations(Iterable<String> conversationIds) async {
    await initSocket();
    if (_pusher == null) return;
    final want = conversationIds.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toSet();
    final toRemove = _typingWatchIds.difference(want);
    final toAdd = want.difference(_typingWatchIds);
    _typingWatchIds
      ..clear()
      ..addAll(want);

    for (final id in toRemove) {
      final ch = 'private-chat.$id';
      if (_activeConversationId == id && _conversationChannelName == ch) continue;
      if (_pusher!.getChannel(ch) != null) {
        await _pusher!.unsubscribe(channelName: ch);
      }
    }
    for (final id in toAdd) {
      final ch = 'private-chat.$id';
      if (_pusher!.getChannel(ch) != null) continue;
      try {
        await _pusher!.subscribe(channelName: ch);
      } catch (_) {}
    }
  }

  Future<void> clearTypingWatchForConversations() async {
    await setTypingWatchForConversations({});
  }

  /// Frappe : Laravel diffuse sur le canal privé.
  Future<void> triggerClientTyping(String conversationId, {bool isTyping = true}) async {
    if (conversationId.isEmpty) return;
    final token = await _storage.read(key: 'token') ?? '';
    if (token.isEmpty) return;
    final uri = Uri.parse(
      '$serverAddress/api/chat/conversations/$conversationId/typing',
    );
    try {
      await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_typing': isTyping}),
      );
    } catch (_) {}
  }

  String? _conversationIdFromMessagePayload(dynamic data) {
    try {
      Object? decoded = data;
      if (data is String) {
        decoded = jsonDecode(data);
      }
      if (decoded is! Map) {
        return null;
      }
      final m = Map<String, dynamic>.from(decoded);
      final direct = m['conversation_id']?.toString() ?? m['conversationId']?.toString();
      if (direct != null && direct.isNotEmpty) {
        return direct;
      }
      final nested = m['message'];
      if (nested is Map) {
        final id = Map<String, dynamic>.from(nested)['conversation_id']?.toString() ??
            Map<String, dynamic>.from(nested)['conversationId']?.toString();
        if (id != null && id.isNotEmpty) {
          return id;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> reconnectAfterNetworkRestore() => initSocket(forceReconnect: true);

  Future<void> initSocket({bool forceReconnect = false}) async {
    if (forceReconnect) {
      await disconnect();
    }
    if (_pusher != null) {
      try {
        await _pusher!.connect();
      } catch (_) {}
      return;
    }

    _pusher = PusherChannelsFlutter.getInstance();
    await _pusher!.init(
      apiKey: Constants.pusherKey,
      cluster: Constants.pusherCluster,
      useTLS: true,
      onAuthorizer: (channelName, socketId, options) async {
        final token = await _storage.read(key: 'token') ?? '';
        final response = await http.post(
          Uri.parse('$serverAddress/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'socket_id': socketId,
            'channel_name': channelName,
          },
        );
        if (response.statusCode != 200) {
          throw Exception(
            'broadcasting/auth ${response.statusCode}:${response.body}',
          );
        }
        return jsonDecode(response.body);
      },
      onConnectionStateChange: (currentState, previousState) {
        // debugPrint('🔌 [SocketService] État connexion : $previousState ->$currentState');
      },
      onError: (message, code, exception) {
        // debugPrint('❌ [SocketService] Erreur Socket ($code):$message');
      },
      onSubscriptionSucceeded: _onPresenceSubscriptionSucceeded,
      onMemberAdded: (channelName, member) {
        if (channelName == _presenceChannelName) {
          ConversationsInboxCoordinator.onPresenceUserJoined(member.userId);
        }
      },
      onMemberRemoved: (channelName, member) {
        if (channelName == _presenceChannelName) {
          ConversationsInboxCoordinator.onPresenceUserLeft(member.userId);
        }
      },
      onEvent: (event) {
        // debugPrint('📩 [SocketService] Événement reçu : ${event.eventName} sur${event.channelName}');

        if (event.eventName == 'client-typing' || _isTypingEvent(event.eventName)) {
          _handleClientTyping(event);
          return;
        }

        final isReadEvent = _isMessageReadEvent(event.eventName);
        final isSent = _isMessageSentEvent(event.eventName);
        final activeConvChannel = _activeConversationId != null && _activeConversationId!.isNotEmpty
            ? 'private-chat.$_activeConversationId'
            : null;

        // 1. Vue chat ouverte : canal `private-chat.{conversationId}` (direct ou typing watch)
        if (activeConvChannel != null &&
            event.channelName == activeConvChannel &&
            (isSent || isReadEvent) &&
            _conversationHandler != null) {
          _conversationHandler!.call(
            _conversationEnvelope(event.eventName, event.data),
          );
          return;
        }

        // 2. Événements d'inbox
        if (_adminInboxChannelName != null && event.channelName == _adminInboxChannelName) {
          if (_isMessageSentEvent(event.eventName)) {
            _adminInboxHandler?.call(event.data);
          }
          return;
        }

        if (_userInboxChannelName != null && event.channelName == _userInboxChannelName) {
          final cid = _conversationIdFromMessagePayload(event.data);

          if (cid != null &&
              cid == _userInboxSuppressFetchConversationId &&
              cid == _activeConversationId &&
              isSent &&
              _conversationHandler != null) {
            _conversationHandler!.call(
              _conversationEnvelope(event.eventName, event.data),
            );
            return;
          }

          if (cid != null && cid == _userInboxSuppressFetchConversationId) {
            return;
          }

          if (isSent) {
            _userInboxHandler?.call(event.data);
          }
          return;
        }

        if (_globalChannelNameMatches(event.channelName)) {
          _globalHandler?.call(event.data);
        }
      },
    );

    await _pusher!.connect();
  }

  Future<void> joinConversation(String conversationId, void Function(dynamic data) onMessage) async {
    await initSocket();
    if (_pusher == null) return;

    final channelName = 'private-chat.$conversationId';

    if (_activeConversationId == conversationId && _conversationChannelName != null) {
      _conversationHandler = onMessage;
      return;
    }

    final previousName = _conversationChannelName;
    final previousId = _activeConversationId;

    if (previousName != null && previousName != channelName) {
      _conversationHandler = null;
      _conversationChannelName = null;
      _activeConversationId = null;
      final keepPrev = previousId != null && _typingWatchIds.contains(previousId);
      if (!keepPrev) {
        await _pusher!.unsubscribe(channelName: previousName);
      }
    }

    _activeConversationId = conversationId;
    _conversationHandler = onMessage;
    _conversationChannelName = channelName;

    if (_pusher!.getChannel(channelName) != null) {
      return;
    }

    try {
      await _pusher!.subscribe(channelName: channelName);
    } on PlatformException catch (e) {
      final msg = '${e.message ?? ''} ${e.details ?? ''}';
      if (msg.contains('Already subscribed')) {
        _conversationHandler = onMessage;
        return;
      }
      rethrow;
    }
  }

  Future<void> leaveConversation({bool forceUnsubscribe = false}) async {
    final name = _conversationChannelName;
    final id = _activeConversationId;
    _conversationChannelName = null;
    _conversationHandler = null;
    _activeConversationId = null;
    if (_pusher == null || name == null) return;
    final keepForTyping = !forceUnsubscribe && id != null && _typingWatchIds.contains(id);
    if (keepForTyping) {
      return;
    }
    await _pusher!.unsubscribe(channelName: name);
  }

  Future<void> onConversationUpdated(void Function(dynamic data) handler) async {
    if (_pusher == null) return;
    _globalHandler = handler;
    _globalConversationChannelName ??= 'private-chat.global';
    await _pusher!.subscribe(channelName: _globalConversationChannelName!);
  }

  Future<void> disconnect() async {
    final typingSnapshot = Set<String>.from(_typingWatchIds);
    _typingWatchIds.clear();
    _userInboxSuppressFetchConversationId = null;

    await leaveConversation(forceUnsubscribe: true);
    await unsubscribeAdminInbox();
    await unsubscribeUserInbox();

    final p = _pusher;
    if (p != null) {
      for (final id in typingSnapshot) {
        final ch = 'private-chat.$id';
        if (p.getChannel(ch) != null) {
          await p.unsubscribe(channelName: ch);
        }
      }
      await unsubscribePresenceApp();
      if (_globalConversationChannelName != null) {
        await p.unsubscribe(channelName: _globalConversationChannelName!);
      }
      await p.disconnect();
    }
    _pusher = null;
    _globalConversationChannelName = null;
    _globalHandler = null;
  }

  bool _globalChannelNameMatches(String? channelName) {
    return _globalConversationChannelName != null && channelName == _globalConversationChannelName;
  }

  /// Appelé à la fermeture de l'écran Chat pour réautoriser les notifications inbox
  void clearUserInboxSuppress() {
    // debugPrint('🔓 [SocketService] Libération du filtre Suppress Inbox.');
    _userInboxSuppressFetchConversationId = null;
  }
}