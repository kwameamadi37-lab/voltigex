import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/features/chatting/chat/data/local/chat_delta_sync.dart';
import 'package:voltigex/features/chatting/chat/data/local/chat_messages_cache.dart';
import 'package:voltigex/features/chatting/chat/data/models/message_model.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/chat_message.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/create_conversation_and_send_message_use_case.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/upload_message_media_use_case.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_event.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_state.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/mark_messages_as_read_use_case.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:blurhash_dart/blurhash_dart.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;
  final UploadMessageMediaUseCase uploadMessageMediaUseCase;
  final CreateConversationAndSendMessageUseCase createConversationAndSendMessageUseCase;
  final SocketService _socketService = SocketService();
  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();
  String? _activeConversationId;
  String? _pendingRecipientUserId;
  String _currentUserId = '';
  bool _deltaSyncInProgress = false;
  bool _syncFailed = false;
  bool _isLoadingOlderMessages = false;
  bool _olderMessagesFullyLoaded = false;
  static const int _olderMessagesPageLimit = 50;
  /// Dernier id message « moi » lu par le partenaire (API + recoupement local).
  String? _partnerLastSeenMessageId;
  static const String _kMetaLocalFilePath = 'localFilePath';
  /// Conservé sur les messages pending si la conversation n’existe pas encore (retry sans [_pendingRecipientUserId] perdu).
  static const String _kMetaPendingRecipientUserId = 'pendingRecipientUserId';
  /// Après upload réussi, avant POST : permet un retry sans re-upload si l’enregistrement du message a échoué.
  static const String _kMetaUploadedRelativeMediaUrl = 'uploadedRelativeMediaUrl';
  final Set<String> _retryingSendClientIds = <String>{};
  bool _isPartnerTyping = false;
  Timer? _partnerTypingResetTimer;
  /// Silence après le dernier `user.typing` avec `is_typing: true`. Doit dépasser l’intervalle des
  /// POST `true` côté composer (~3 s) pour ne pas couper l’indicateur pendant la frappe ; l’arrêt
  /// réel repose surtout sur `is_typing: false` (~1,5 s après la dernière touche).
  static const Duration _kPartnerTypingSilenceTimeout = Duration(milliseconds: 3500);

  String? _resolveRecipientForRetry(MessageEntity pending) {
    final fromBloc = _pendingRecipientUserId?.trim();
    if (fromBloc != null && fromBloc.isNotEmpty) return fromBloc;
    final fromMeta =
        pending.metadata?[_kMetaPendingRecipientUserId]?.toString().trim();
    if (fromMeta != null && fromMeta.isNotEmpty) return fromMeta;
    return null;
  }

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.uploadMessageMediaUseCase,
    required this.markMessagesAsReadUseCase,
    required this.createConversationAndSendMessageUseCase,
    String? initialUserId,
  })  : _currentUserId = initialUserId ?? '',
        super(ChatLoadingState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<HydrateChatFromCacheEvent>(_onHydrateChatFromCache);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<FailMessageEvent>(_onFailMessage);
    on<UpdateReadStatusEvent>(_onUpdateReadStatus);
    on<MessageReadEvent>(_onMessageRead);
    on<ChatConversationUiClosedEvent>(_onConversationUiClosed);
    on<LoadOlderMessagesEvent>(_onLoadOlderMessages);
    on<ChatTypingPingEvent>(_onTypingPing);
    on<ChatTypingEvent>(_onTyping);
    on<PartnerTypingTimeoutEvent>(_onPartnerTypingTimeout);
    on<RetrySendMessageEvent>(_onRetrySendMessage);
  }

  Future<void> _onTypingPing(ChatTypingPingEvent event, Emitter<ChatState> emit) async {
    if (event.conversationId.isEmpty) return;
    await _socketService.triggerClientTyping(event.conversationId);
  }

  Future<void> _onTyping(ChatTypingEvent event, Emitter<ChatState> emit) async {
    if (event.conversationId.isEmpty) return;
    await _socketService.triggerClientTyping(
      event.conversationId,
      isTyping: event.isTyping,
    );
  }

  void _onPartnerTypingTimeout(
    PartnerTypingTimeoutEvent event,
    Emitter<ChatState> emit,
  ) {
    if (!_isPartnerTyping) return;
    _isPartnerTyping = false;
    emit(_emitLoaded());
  }

  ChatLoadedState _emitLoaded() {
    final current = state;
    if (current is ChatLoadedState) {
      return current.copyWith(
        messages: List<MessageEntity>.from(_messages),
        currentUserId: _currentUserId,
        deltaSyncInProgress: _deltaSyncInProgress,
        syncFailed: _syncFailed,
        loadingOlderMessages: _isLoadingOlderMessages,
        partnerLastSeenMessageId: _partnerLastSeenMessageId,
        replacePartnerLastSeenMessageId: true,
        retryingSendClientIds: Set<String>.from(_retryingSendClientIds),
        isPartnerTyping: _isPartnerTyping,
      );
    }
    return ChatLoadedState(
      List<MessageEntity>.from(_messages),
      currentUserId: _currentUserId,
      deltaSyncInProgress: _deltaSyncInProgress,
      syncFailed: _syncFailed,
      loadingOlderMessages: _isLoadingOlderMessages,
      partnerLastSeenMessageId: _partnerLastSeenMessageId,
      retryingSendClientIds: Set<String>.from(_retryingSendClientIds),
      isPartnerTyping: _isPartnerTyping,
    );
  }

  String? _nonEmptyIdString(dynamic raw) {
    final s = raw?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  /// Événement socket **dédié** (ConversationRead / MessageRead) — pas MessageSent.
  Future<void> _handleSocketReadReceiptEvent(
    Emitter<ChatState> emit, {
    required Map<String, dynamic> dataSansMeta,
    required Map<String, dynamic> payload,
  }) async {
    final readPayload = dataSansMeta['read_message_ids'] ??
        dataSansMeta['marked_read_ids'] ??
        payload['read_message_ids'] ??
        payload['marked_read_ids'];

    final lastReadDirect = _nonEmptyIdString(dataSansMeta['last_read_message_id']) ??
        _nonEmptyIdString(payload['last_read_message_id']) ??
        _nonEmptyIdString(dataSansMeta['last_message_read_id']) ??
        _nonEmptyIdString(payload['last_message_read_id']);

    final ids = <String>[
      if (readPayload is List)
        ...readPayload.map((e) => e.toString()).where((s) => s.isNotEmpty),
      if (dataSansMeta['message_id'] != null)
        dataSansMeta['message_id'].toString(),
      if (payload['message_id'] != null) payload['message_id'].toString(),
      if (dataSansMeta['last_seen_message_id'] != null)
        dataSansMeta['last_seen_message_id'].toString(),
      if (payload['last_seen_message_id'] != null)
        payload['last_seen_message_id'].toString(),
      if (dataSansMeta['partner_last_seen_message_id'] != null)
        dataSansMeta['partner_last_seen_message_id'].toString(),
      if (payload['partner_last_seen_message_id'] != null)
        payload['partner_last_seen_message_id'].toString(),
      if (dataSansMeta['last_message_id'] != null)
        dataSansMeta['last_message_id'].toString(),
      if (payload['last_message_id'] != null)
        payload['last_message_id'].toString(),
    ].where((s) => s.isNotEmpty).toSet().toList();

    var changed = false;
    if (ids.isNotEmpty) {
      changed = _applyReadReceiptIds(ids);
    }

    if (lastReadDirect != null) {
      final prev = int.tryParse(_partnerLastSeenMessageId ?? '') ?? -1;
      final next = int.tryParse(lastReadDirect) ?? -1;
      if (next > prev) {
        _partnerLastSeenMessageId = lastReadDirect;
        changed = true;
      }
    }

    if (lastReadDirect == null && ids.isNotEmpty) {
      final me = _currentUserId.trim();
      if (me.isNotEmpty) {
        var maxVal = int.tryParse(_partnerLastSeenMessageId ?? '') ?? -1;
        String? maxIdStr;
        for (final s in ids) {
          final idx = _messages.indexWhere((m) => m.id == s);
          if (idx < 0) continue;
          if (_messages[idx].senderId != me) continue;
          final v = int.tryParse(s) ?? -1;
          if (v > maxVal) {
            maxVal = v;
            maxIdStr = s;
          }
        }
        if (maxIdStr != null && maxIdStr.isNotEmpty) {
          _partnerLastSeenMessageId = maxIdStr;
          changed = true;
        }
      }
    }

    final seenFromPayload = (dataSansMeta['partner_last_seen_message_id'] ??
            dataSansMeta['last_seen_message_id'] ??
            dataSansMeta['last_message_id'] ??
            payload['partner_last_seen_message_id'] ??
            payload['last_seen_message_id'] ??
            payload['last_message_id'])
        ?.toString()
        .trim();
    if (seenFromPayload != null &&
        seenFromPayload.isNotEmpty &&
        lastReadDirect == null) {
      final prev = int.tryParse(_partnerLastSeenMessageId ?? '') ?? -1;
      final next = int.tryParse(seenFromPayload) ?? -1;
      if (next > prev) {
        _partnerLastSeenMessageId = seenFromPayload;
        changed = true;
      }
    }

    final anchor = _partnerLastSeenMessageId;
    if (anchor != null && anchor.isNotEmpty) {
      if (_markOutgoingMessagesReadUpTo(anchor)) {
        changed = true;
      }
    }

    if (changed) {
      await _persistMessages(immediate: true);
    }
    emit(_emitLoaded());
  }

  void _reconcilePartnerLastSeenFromMessages() {
    var best = int.tryParse(_partnerLastSeenMessageId ?? '') ?? -1;
    for (final m in _messages) {
      if (m.senderId != _currentUserId) continue;
      if (m.isRead != 1) continue;
      if (m.id.isEmpty) continue;
      final n = int.tryParse(m.id) ?? -1;
      if (n > best) best = n;
    }
    if (best >= 0) {
      _partnerLastSeenMessageId = best.toString();
    }
  }

  /// Marque comme lus par le partenaire tous les messages **que vous avez envoyés** dont l’id ≤ [lastReadIdStr].
  bool _markOutgoingMessagesReadUpTo(String? lastReadIdStr) {
    final cap = int.tryParse(lastReadIdStr ?? '') ?? -1;
    if (cap < 0) return false;
    final me = _currentUserId.trim();
    if (me.isEmpty) return false;
    var any = false;
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.senderId != me) continue;
      final n = int.tryParse(m.id);
      if (n == null || n > cap) continue;
      if (m.isRead == 1) continue;
      _messages[i] = m.copyWith(
        isRead: 1,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );
      any = true;
    }
    return any;
  }

  void _onConversationUiClosed(
    ChatConversationUiClosedEvent event,
    Emitter<ChatState> emit,
  ) {
    final cid = _activeConversationId;
    if (cid != null && cid.isNotEmpty && _messages.isNotEmpty) {
      ConversationsInboxCoordinator.notifyChatClosed(cid, List<MessageEntity>.from(_messages));
    }
    _socketService.setUserInboxSuppressFetchForConversation(null);
  }

  List<MessageEntity> _sortByTime(List<MessageEntity> list) {
    final copy = List<MessageEntity>.from(list);
    copy.sort(compareChatMessagesChronological);
    return copy;
  }

  String? _extractLocalFilePath(MessageEntity message) {
    final fromMeta = message.metadata?[_kMetaLocalFilePath]?.toString().trim();
    if (fromMeta != null &&
        fromMeta.isNotEmpty &&
        MediaPathUtils.isLocalMediaPath(fromMeta)) {
      return fromMeta;
    }
    final media = message.mediaUrl?.trim();
    if (media != null && media.isNotEmpty && MediaPathUtils.isLocalMediaPath(media)) {
      return media;
    }
    return null;
  }

  /// Chemin de prévisualisation à conserver au merge (fichier, `file://`, `content://`).
  /// [MediaPathUtils.isLocalMediaPath] ignore `content://` : on les garde quand même si présents côté client.
  String? _preservedLocalFilePath(MessageEntity previous) {
    final extracted = _extractLocalFilePath(previous);
    if (extracted != null && extracted.isNotEmpty) {
      return extracted;
    }
    final rawMeta = previous.metadata?[_kMetaLocalFilePath]?.toString().trim();
    if (rawMeta != null && rawMeta.isNotEmpty) {
      return rawMeta;
    }
    final media = previous.mediaUrl?.trim();
    if (media != null &&
        media.isNotEmpty &&
        media.toLowerCase().startsWith('content://')) {
      return media;
    }
    return null;
  }

  Map<String, dynamic>? _mergeMetadataKeepingLocalPath(
    MessageEntity previous,
    Map<String, dynamic>? incomingMetadata,
  ) {
    final merged = <String, dynamic>{};
    final prevMeta = previous.metadata;
    if (prevMeta != null) {
      merged.addAll(prevMeta);
    }
    if (incomingMetadata != null) {
      merged.addAll(incomingMetadata);
    }
    // Priorité absolue : valeur déjà sur l’optimistic UI (swap id / réponse serveur).
    final oldPath = previous.metadata?[_kMetaLocalFilePath]?.toString().trim();
    if (oldPath != null && oldPath.isNotEmpty) {
      merged[_kMetaLocalFilePath] = oldPath;
    } else {
      final preserved = _preservedLocalFilePath(previous);
      if (preserved != null && preserved.isNotEmpty) {
        merged[_kMetaLocalFilePath] = preserved;
      } else {
        final v = merged[_kMetaLocalFilePath];
        if (v == null || (v is String && v.trim().isEmpty)) {
          merged.remove(_kMetaLocalFilePath);
        }
      }
    }
    return merged.isEmpty ? null : merged;
  }

  /// Delta sync : pour chaque message API avec un `id` non vide, ajoute ou remplace dans la liste locale.
  /// Si l’`id` existe déjà : remplacement **intégral** par la version serveur (aucune comparaison de date ni de champs).
  /// Le tri par date ne sert qu’à l’ordre d’affichage après fusion.
  List<MessageEntity> _mergeDeltaUpsert(List<MessageEntity> delta, List<MessageEntity> current) {
    final result = List<MessageEntity>.from(current);
    for (final d in delta) {
      if (d.id.isEmpty) continue;
      final idx = result.indexWhere((m) => m.id == d.id);
      if (idx >= 0) {
        result[idx] = _incomingMessageReplacingPrevious(result[idx], d);
      } else {
        result.add(d);
      }
    }
    return _sortByTime(result);
  }

  /// Fusionne la réponse API avec les brouillons / échecs locaux encore pertinents.
  List<MessageEntity> _mergeServerWithLocal(List<MessageEntity> server, List<MessageEntity> localSnapshot) {
    final result = _sortByTime(List<MessageEntity>.from(server));

    // Conserver les métadonnées locales (ex. localFilePath) lors du swap optimistic -> serveur.
    for (var i = 0; i < result.length; i++) {
      final incoming = result[i];
      MessageEntity? previous;
      for (final local in localSnapshot) {
        final sameId = incoming.id.isNotEmpty && local.id == incoming.id;
        final sameClientId =
            incoming.clientId.isNotEmpty && local.clientId == incoming.clientId;
        if (sameId || sameClientId) {
          previous = local;
          break;
        }
      }
      if (previous != null) {
        result[i] = _incomingMessageReplacingPrevious(previous, incoming);
      }
    }

    final pending = localSnapshot
        .where((m) => m.isSaved == null || m.isSaved == 0)
        .toList();
    for (final p in pending) {
      final merged = result.any((m) =>
          (p.clientId.isNotEmpty && m.clientId == p.clientId) ||
          (p.id.isNotEmpty && m.id == p.id));
      if (!merged) {
        result.add(p);
      }
    }
    return _sortByTime(result);
  }

  /// Fusionne une page de messages plus anciens (ids serveur uniques, tri chronologique).
  List<MessageEntity> _mergeOlderPage(List<MessageEntity> older, List<MessageEntity> current) {
    final existingIds = <String>{};
    for (final m in current) {
      if (m.id.isNotEmpty) {
        existingIds.add(m.id);
      }
    }
    final merged = List<MessageEntity>.from(current);
    for (final m in older) {
      if (m.id.isNotEmpty && existingIds.contains(m.id)) {
        continue;
      }
      if (m.id.isNotEmpty) {
        existingIds.add(m.id);
      }
      merged.add(m);
    }
    return _sortByTime(merged);
  }

  Future<void> _persistMessages({bool immediate = false}) async {
    final id = _activeConversationId;
    if (id == null || id.isEmpty) return;
    await ChatMessagesCache.ensureReady();
    if (immediate) {
      ChatMessagesCache.cancelScheduledWrite();
      await ChatMessagesCache.write(id, List<MessageEntity>.from(_messages));
    } else {
      ChatMessagesCache.scheduleWrite(id, () => List<MessageEntity>.from(_messages));
    }
  }

  @override
  Future<void> close() async {
    _partnerTypingResetTimer?.cancel();
    ChatMessagesCache.cancelScheduledWrite();
    final id = _activeConversationId;
    if (id != null && _messages.isNotEmpty) {
      await ChatMessagesCache.ensureReady();
      await ChatMessagesCache.write(id, List<MessageEntity>.from(_messages));
    }
    await super.close();
  }

  Future<void> _onLoadOlderMessages(
    LoadOlderMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.conversationId != _activeConversationId) {
      return;
    }
    if (_isLoadingOlderMessages || _olderMessagesFullyLoaded) {
      return;
    }
    final oldestId = ChatDeltaSync.oldestNumericServerMessageId(_messages);
    if (oldestId == null) {
      return;
    }

    _isLoadingOlderMessages = true;
    emit(_emitLoaded());

    try {
      final fetchResult = await fetchMessagesUseCase(
        event.conversationId,
        beforeMessageId: oldestId,
        limit: _olderMessagesPageLimit,
      );
      final batch = fetchResult.messages;
      if (fetchResult.partnerLastSeenMessageId != null &&
          fetchResult.partnerLastSeenMessageId!.isNotEmpty) {
        _partnerLastSeenMessageId = fetchResult.partnerLastSeenMessageId;
      }
      if (batch.isEmpty) {
        _olderMessagesFullyLoaded = true;
      } else {
        final previous = List<MessageEntity>.from(_messages);
        _messages
          ..clear()
          ..addAll(_mergeOlderPage(batch, previous));
        if (batch.length < _olderMessagesPageLimit) {
          _olderMessagesFullyLoaded = true;
        }
        _reconcilePartnerLastSeenFromMessages();
        await _persistMessages(immediate: true);
      }
    } catch (_) {
      // Conserver le fil ; pas de syncFailed pour ne pas confondre avec le delta initial.
    } finally {
      _isLoadingOlderMessages = false;
      emit(_emitLoaded());
    }
  }

  Future<void> _attachConversationSocket(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    await _socketService.joinConversation(conversationId, (messageData) {
      final dynamic decoded = messageData is String ? jsonDecode(messageData) : messageData;
      if (decoded is Map) {
        add(ReceiveMessageEvent(Map<String, dynamic>.from(decoded)));
      }
    });
  }

  Future<void> _onHydrateChatFromCache(
    HydrateChatFromCacheEvent event,
    Emitter<ChatState> emit,
  ) async {
    _activeConversationId = event.conversationId;
    _olderMessagesFullyLoaded = false;
    final fromEvent = event.currentUserId?.trim();
    _currentUserId = (fromEvent != null && fromEvent.isNotEmpty)
        ? fromEvent
        : (await _storage.read(key: 'userId') ?? '');

    _socketService.setUserInboxSuppressFetchForConversation(event.conversationId);

    _syncFailed = false;
    _deltaSyncInProgress = false;
    _isPartnerTyping = false;

    await ChatMessagesCache.ensureReady();
    final cached = await ChatMessagesCache.read(event.conversationId);

    _messages.clear();
    if (cached.isNotEmpty) {
      _messages.addAll(_sortByTime(cached));
      _reconcilePartnerLastSeenFromMessages();
      emit(_emitLoaded());
    } else {
      emit(ChatLoadingState());
    }

    await _attachConversationSocket(event.conversationId);
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    final previousCid = (_activeConversationId ?? '').trim();
    _activeConversationId = event.conversationId;
    if (event.conversationId.trim() != previousCid) {
      _partnerLastSeenMessageId = null;
      _isPartnerTyping = false;
    }
    _olderMessagesFullyLoaded = false;
    final fromEvent = event.currentUserId?.trim();
    _currentUserId = (fromEvent != null && fromEvent.isNotEmpty)
        ? fromEvent
        : (await _storage.read(key: 'userId') ?? '');

    if (event.conversationId.trim().isEmpty) {
      _pendingRecipientUserId = event.recipientUserId?.trim().isNotEmpty == true
          ? event.recipientUserId!.trim()
          : null;
      _olderMessagesFullyLoaded = true;
      _socketService.setUserInboxSuppressFetchForConversation(null);
      _syncFailed = false;
      _deltaSyncInProgress = false;
      _partnerLastSeenMessageId = null;
      _messages.clear();
      emit(_emitLoaded());
      return;
    }

    _pendingRecipientUserId = null;

    _socketService.setUserInboxSuppressFetchForConversation(event.conversationId);

    _syncFailed = false;
    await ChatMessagesCache.ensureReady();
    final cached = await ChatMessagesCache.read(event.conversationId);

    _messages.clear();
    if (cached.isNotEmpty) {
      _messages.addAll(_sortByTime(cached));
      _deltaSyncInProgress = true;
      emit(_emitLoaded());
    } else {
      _deltaSyncInProgress = false;
      emit(ChatLoadingState());
    }

    final hadCachedMessagesBeforeFetch = _messages.isNotEmpty;

    try {
      final localSnapshot = List<MessageEntity>.from(_messages);
      final afterId = ChatDeltaSync.newestNumericServerMessageId(localSnapshot);
      final updatedAfter = ChatDeltaSync.newestUpdatedAtIso(localSnapshot);

      final fetchResult = await fetchMessagesUseCase(
        event.conversationId,
        afterMessageId: afterId,
        updatedAfter: updatedAfter,
      );
      final apiMessages = fetchResult.messages;
      if (fetchResult.partnerLastSeenMessageId != null &&
          fetchResult.partnerLastSeenMessageId!.isNotEmpty) {
        _partnerLastSeenMessageId = fetchResult.partnerLastSeenMessageId;
      }

      final hasDeltaCursor = (afterId != null && afterId.isNotEmpty) ||
          (updatedAfter != null && updatedAfter.isNotEmpty);
      final List<MessageEntity> merged;
      if (localSnapshot.isNotEmpty && hasDeltaCursor) {
        merged = _mergeDeltaUpsert(apiMessages, localSnapshot);
      } else {
        merged = _mergeServerWithLocal(apiMessages, localSnapshot);
      }

      _messages
        ..clear()
        ..addAll(merged);
      _reconcilePartnerLastSeenFromMessages();
      await _persistMessages(immediate: true);
      _deltaSyncInProgress = false;
      _syncFailed = false;
      emit(_emitLoaded());

      await _attachConversationSocket(event.conversationId);
    } catch (error) {
      _deltaSyncInProgress = false;
      if (_messages.isNotEmpty) {
        _syncFailed = hadCachedMessagesBeforeFetch;
        emit(_emitLoaded());
      } else {
        emit(ChatErrorState('chat.error.loadFailed', error));
      }
    }
  }

  bool _applyReadReceiptIds(List<String> messageIds) {
    if (messageIds.isEmpty) return false;
    final idSet = messageIds.toSet();
    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      if (idSet.contains(_messages[i].id)) {
        _messages[i] = _messages[i].copyWith(
          isRead: 1,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );
        changed = true;
      }
    }
    if (changed) {
      _reconcilePartnerLastSeenFromMessages();
    }
    return changed;
  }

  Future<void> _onMessageRead(MessageReadEvent event, Emitter<ChatState> emit) async {
    if (_applyReadReceiptIds(event.messageIds)) {
      emit(_emitLoaded());
      await _persistMessages(immediate: true);
    }
  }

  Future<void> _onUpdateReadStatus(UpdateReadStatusEvent event, Emitter<ChatState> emit,) async {
    try {

      // Mise à jour locale dans _messages
      for (var i = 0; i < _messages.length; i++) {
        if (event.messageIds.contains(_messages[i].id)) {
          _messages[i] = _messages[i].copyWith(
            isRead: 1,
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          );
        }
      }

      // Réémettre l’état avec la liste mise à jour pour mettre à jour les messages sur l'écran
      emit(_emitLoaded());
      await _persistMessages();

      final dio = DioClient().createDio(baseUrl: Constants.baseUrl);
      await dio.patch('/api/chat/conversations/${event.conversationId}/read');

    } catch (error) {
      emit(ChatErrorState('chat.error.readUpdateFailed', error));
    }
  }

  /// Met à jour le message en attente avec la réponse Laravel (201). Indispensable car
  /// `broadcast(...)->toOthers()` n’envoie pas l’événement à l’expéditeur, et le payload
  /// Pusher ne contient pas `client_id` pour fusionner avec le pending.
  void _mergePendingFromPostResponse(String clientId, Object? rawData) {
    if (rawData is! Map) {
      return;
    }
    final data = Map<String, dynamic>.from(rawData);
    final metaMap = data['metadata'];
    final rawRespClientId = (data['client_id'] ??
            (metaMap is Map ? metaMap['client_id'] : null))
        ?.toString()
        .trim() ??
        '';
    if (rawRespClientId.isNotEmpty && rawRespClientId != clientId) {
      return;
    }
    final idx = _messages.indexWhere(
      (m) =>
          m.clientId == clientId &&
          (m.isSaved == null || m.isSaved == 0),
    );
    if (idx == -1) {
      return;
    }
    final pending = _messages[idx];
    final localPathToPreserve = pending.metadata?['localFilePath'];

    final serverMessage = MessageModel.fromJson(data);
    final suturedMessage = serverMessage.copyWith(
      clientId: pending.clientId,
      metadata: <String, dynamic>{
        ...?serverMessage.metadata,
        if (localPathToPreserve != null &&
            localPathToPreserve.toString().isNotEmpty)
          _kMetaLocalFilePath: localPathToPreserve,
      },
    );
    _messages[idx] = suturedMessage;

    final newConvId = data['conversation_id']?.toString();
    if (newConvId != null && newConvId.isNotEmpty) {
      _activeConversationId = newConvId;
      _pendingRecipientUserId = null;
      unawaited(_attachConversationSocket(newConvId));
    }
    _reconcilePartnerLastSeenFromMessages();
  }

  void _markPendingFailed(String clientId) {
    final idx = _messages.indexWhere(
      (m) =>
          m.clientId == clientId &&
          (m.isSaved == null || m.isSaved == 0),
    );
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(isSaved: 0);
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    String userId = _currentUserId.isNotEmpty
        ? _currentUserId
        : (await _storage.read(key: 'userId') ?? '');
    if (userId.isNotEmpty) {
      _currentUserId = userId;
    }

    var convForApi = (_activeConversationId ?? '').trim();
    if (convForApi.isEmpty) {
      convForApi = event.conversationId.trim();
    }
    final recipient = event.recipientUserId ?? _pendingRecipientUserId;
    var needCreate =
        convForApi.isEmpty && recipient != null && recipient.trim().isNotEmpty;

    final uuid = Uuid();
    final String textMessageClientId = uuid.v4();

    final List<MessageEntity> newPendingMediaMessages = [];

    if (event.mediaFiles.isNotEmpty) {
      for (final media in event.mediaFiles) {
        final mediaType = _detectMediaType(media.path!);
        final size = mediaType == 'image' ? await getImageDimensions(media.path!) : null;

        final message = MessageEntity(
          id: '',
          conversationId: convForApi,
          senderId: userId,
          type: 'MEDIA',
          mediaName: media.name,
          mediaType: mediaType,
          mediaUrl: media.path!,
          mediaWidth: size?['width'],
          mediaHeight: size?['height'],
          mediaBlurhash: null,
          metadata: <String, dynamic>{
            _kMetaLocalFilePath: media.path!,
            if (convForApi.isEmpty &&
                recipient != null &&
                recipient.trim().isNotEmpty)
              _kMetaPendingRecipientUserId: recipient.trim(),
          },
          createdAt: DateTime.now().toUtc().toString(),
          updatedAt: DateTime.now().toUtc().toString(),
          isRead: 0,
          isPinned: 0,
          isSaved: null,
          clientId: Uuid().v4(),
        );

        newPendingMediaMessages.add(message);
      }

      for (final e in newPendingMediaMessages) {
        _messages.add(e);
      }
      emit(_emitLoaded());
      await _persistMessages();
    }

    if (event.content.isNotEmpty) {
      final message = MessageEntity(
        id: '',
        conversationId: convForApi,
        senderId: userId,
        content: event.content,
        type: 'TEXT',
        createdAt: DateTime.now().toUtc().toString(),
        updatedAt: DateTime.now().toUtc().toString(),
        isRead: 0,
        isPinned: 0,
        isSaved: null,
        clientId: textMessageClientId,
        metadata: (convForApi.isEmpty &&
                recipient != null &&
                recipient.trim().isNotEmpty)
            ? <String, dynamic>{
                _kMetaPendingRecipientUserId: recipient.trim(),
              }
            : null,
      );

      _messages.add(message);
      emit(_emitLoaded());
      await _persistMessages();
    }

    final dio = DioClient().createDio(baseUrl: Constants.baseUrl);

    if (event.mediaFiles.isNotEmpty) {
      for (final pendingMedia in newPendingMediaMessages) {
        try {
          final uploadedMediaInfos = await uploadMessageMediaUseCase(
            pendingMedia.mediaUrl!,
            originalFileName: pendingMedia.mediaName,
          );
          final relativeFromApi =
              uploadedMediaInfos['relative_media_url']?.toString().trim();
          final serverMediaUrl = uploadedMediaInfos['url']?.toString().trim();
          if ((relativeFromApi == null || relativeFromApi.isEmpty) &&
              (serverMediaUrl == null || serverMediaUrl.isEmpty)) {
            _markPendingFailed(pendingMedia.clientId);
            emit(_emitLoaded());
            await _persistMessages();
            continue;
          }
          final relativeMediaUrl = (relativeFromApi != null &&
                  relativeFromApi.isNotEmpty)
              ? relativeFromApi
              : (MediaPathUtils.normalizeStoredMediaPath(serverMediaUrl!) ??
                  serverMediaUrl);
          final patchIdx =
              _messages.indexWhere((m) => m.clientId == pendingMedia.clientId);
          if (patchIdx >= 0) {
            final prev = _messages[patchIdx];
            _messages[patchIdx] = prev.copyWith(
              metadata: <String, dynamic>{
                ...?prev.metadata,
                _kMetaUploadedRelativeMediaUrl: relativeMediaUrl,
              },
            );
          }
          if (needCreate) {
            final response = await createConversationAndSendMessageUseCase(
              recipientUserId: recipient!.trim(),
              type: 'media',
              mediaType: uploadedMediaInfos['type']?.toString(),
              mediaUrl: relativeMediaUrl,
              mediaWidth: (uploadedMediaInfos['width'] as num?)?.toInt(),
              mediaHeight: (uploadedMediaInfos['height'] as num?)?.toInt(),
              blurhash: uploadedMediaInfos['blurhash']?.toString(),
              metadata: {
                'originalName': pendingMedia.mediaName,
                'size': uploadedMediaInfos['size'],
              },
              clientId: pendingMedia.clientId,
            );
            _mergePendingFromPostResponse(pendingMedia.clientId, response);
          } else {
            final response = await dio.post<Map<String, dynamic>>(
              '/api/chat/messages',
              data: {
                'conversation_id': convForApi,
                'type': 'media',
                'content': null,
                'media_type': uploadedMediaInfos['type'],
                'media_url': relativeMediaUrl,
                'media_width': uploadedMediaInfos['width'],
                'media_height': uploadedMediaInfos['height'],
                'blurhash': uploadedMediaInfos['blurhash'],
                'metadata': {
                  'originalName': pendingMedia.mediaName,
                  'size': uploadedMediaInfos['size'],
                },
                'client_id': pendingMedia.clientId,
              },
            );
            if (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300) {
              _mergePendingFromPostResponse(pendingMedia.clientId, response.data);
            } else {
              _markPendingFailed(pendingMedia.clientId);
            }
          }
        } catch (_) {
          _markPendingFailed(pendingMedia.clientId);
        }
        emit(_emitLoaded());
        await _persistMessages();
      }
    }

    if (event.content.isNotEmpty) {
      convForApi = (_activeConversationId ?? '').trim();
      if (convForApi.isEmpty) {
        convForApi = event.conversationId.trim();
      }
      needCreate =
          convForApi.isEmpty && recipient != null && recipient.trim().isNotEmpty;
      try {
        if (needCreate) {
          final response = await createConversationAndSendMessageUseCase(
            recipientUserId: recipient!.trim(),
            type: 'text',
            content: event.content,
            clientId: textMessageClientId,
          );
          _mergePendingFromPostResponse(textMessageClientId, response);
        } else {
          final response = await dio.post<Map<String, dynamic>>(
            '/api/chat/messages',
            data: {
              'conversation_id': convForApi,
              'type': 'text',
              'content': event.content,
              'client_id': textMessageClientId,
            },
          );
          if (response.statusCode != null &&
              response.statusCode! >= 200 &&
              response.statusCode! < 300) {
            _mergePendingFromPostResponse(textMessageClientId, response.data);
          } else {
            _markPendingFailed(textMessageClientId);
          }
        }
      } catch (_) {
        _markPendingFailed(textMessageClientId);
      }
      emit(_emitLoaded());
      await _persistMessages();
    }
  }

  Future<void> _onRetrySendMessage(
    RetrySendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final clientId = event.message.clientId.trim();
    if (clientId.isEmpty) return;
    if (_retryingSendClientIds.contains(clientId)) return;

    final idx = _messages.indexWhere((m) => m.clientId == clientId && m.isSaved == 0);
    if (idx == -1) return;

    _retryingSendClientIds.add(clientId);
    _messages[idx] = _messages[idx].copyWith(isSaved: null);
    emit(_emitLoaded());

    String userId = _currentUserId.isNotEmpty
        ? _currentUserId
        : (await _storage.read(key: 'userId') ?? '');
    if (userId.isNotEmpty) {
      _currentUserId = userId;
    }

    var convForApi = (_activeConversationId ?? '').trim();
    if (convForApi.isEmpty) {
      convForApi = _messages[idx].conversationId.trim();
    }

    final pendingForRouting = _messages[idx];
    final recipient = _resolveRecipientForRetry(pendingForRouting);
    var needCreate =
        convForApi.isEmpty && recipient != null && recipient.trim().isNotEmpty;

    if (convForApi.isEmpty && !needCreate) {
      _markPendingFailed(clientId);
      _retryingSendClientIds.remove(clientId);
      emit(_emitLoaded());
      await _persistMessages();
      return;
    }

    final dio = DioClient().createDio(baseUrl: Constants.baseUrl);

    try {
      final pending = _messages[idx];
      if (pending.type == 'TEXT') {
        final content = pending.content ?? '';
        if (content.isEmpty) {
          _markPendingFailed(clientId);
          return;
        }
        try {
          if (needCreate) {
            final response = await createConversationAndSendMessageUseCase(
              recipientUserId: recipient.trim(),
              type: 'text',
              content: content,
              clientId: clientId,
            );
            _mergePendingFromPostResponse(clientId, response);
          } else {
            final response = await dio.post<Map<String, dynamic>>(
              '/api/chat/messages',
              data: {
                'conversation_id': convForApi,
                'type': 'text',
                'content': content,
                'client_id': clientId,
              },
            );
            if (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300) {
              _mergePendingFromPostResponse(clientId, response.data);
            } else {
              _markPendingFailed(clientId);
            }
          }
        } on DioException catch (_) {
          _markPendingFailed(clientId);
        } catch (_) {
          _markPendingFailed(clientId);
        }
      } else if (pending.type == 'MEDIA') {
        late final Map<String, dynamic> uploadedMediaInfos;
        late final String relativeMediaUrl;

        final uploadedFromMeta = pending
            .metadata?[_kMetaUploadedRelativeMediaUrl]
            ?.toString()
            .trim();
        if (uploadedFromMeta != null && uploadedFromMeta.isNotEmpty) {
          relativeMediaUrl = uploadedFromMeta;
          uploadedMediaInfos = <String, dynamic>{
            'type': pending.mediaType,
            'width': pending.mediaWidth,
            'height': pending.mediaHeight,
            'blurhash': pending.mediaBlurhash,
            'size': pending.metadata?['size'],
          };
        } else {
          final localPath = _extractLocalFilePath(pending);
          if (localPath != null && localPath.isNotEmpty) {
            try {
              final uploadResult = await uploadMessageMediaUseCase(
                localPath,
                originalFileName: pending.mediaName,
              );
              final relativeFromApi =
                  uploadResult['relative_media_url']?.toString().trim();
              final serverMediaUrl = uploadResult['url']?.toString().trim();
              if ((relativeFromApi == null || relativeFromApi.isEmpty) &&
                  (serverMediaUrl == null || serverMediaUrl.isEmpty)) {
                _markPendingFailed(clientId);
                return;
              }
              uploadedMediaInfos = uploadResult;
              relativeMediaUrl = (relativeFromApi != null &&
                      relativeFromApi.isNotEmpty)
                  ? relativeFromApi
                  : (MediaPathUtils.normalizeStoredMediaPath(serverMediaUrl!) ??
                      serverMediaUrl);
              final patchIdx = _messages.indexWhere(
                (m) =>
                    m.clientId == clientId &&
                    (m.isSaved == null || m.isSaved == 0),
              );
              if (patchIdx >= 0) {
                final prev = _messages[patchIdx];
                _messages[patchIdx] = prev.copyWith(
                  metadata: <String, dynamic>{
                    ...?prev.metadata,
                    _kMetaUploadedRelativeMediaUrl: relativeMediaUrl,
                  },
                );
              }
            } on DioException catch (_) {
              _markPendingFailed(clientId);
              return;
            } catch (_) {
              _markPendingFailed(clientId);
              return;
            }
          } else {
            final raw = pending.mediaUrl?.trim();
            if (raw != null &&
                raw.isNotEmpty &&
                !MediaPathUtils.isLocalMediaPath(raw)) {
              relativeMediaUrl =
                  MediaPathUtils.normalizeStoredMediaPath(raw) ?? raw;
              uploadedMediaInfos = <String, dynamic>{
                'type': pending.mediaType,
                'width': pending.mediaWidth,
                'height': pending.mediaHeight,
                'blurhash': pending.mediaBlurhash,
                'size': pending.metadata?['size'],
              };
            } else {
              _markPendingFailed(clientId);
              return;
            }
          }
        }

        try {
          if (needCreate) {
            final response = await createConversationAndSendMessageUseCase(
              recipientUserId: recipient.trim(),
              type: 'media',
              mediaType: uploadedMediaInfos['type']?.toString(),
              mediaUrl: relativeMediaUrl,
              mediaWidth: (uploadedMediaInfos['width'] as num?)?.toInt(),
              mediaHeight: (uploadedMediaInfos['height'] as num?)?.toInt(),
              blurhash: uploadedMediaInfos['blurhash']?.toString(),
              metadata: {
                'originalName': pending.mediaName,
                'size': uploadedMediaInfos['size'],
              },
              clientId: clientId,
            );
            _mergePendingFromPostResponse(clientId, response);
          } else {
            final response = await dio.post<Map<String, dynamic>>(
              '/api/chat/messages',
              data: {
                'conversation_id': convForApi,
                'type': 'media',
                'content': null,
                'media_type': uploadedMediaInfos['type'],
                'media_url': relativeMediaUrl,
                'media_width': uploadedMediaInfos['width'],
                'media_height': uploadedMediaInfos['height'],
                'blurhash': uploadedMediaInfos['blurhash'],
                'metadata': {
                  'originalName': pending.mediaName,
                  'size': uploadedMediaInfos['size'],
                },
                'client_id': clientId,
              },
            );
            if (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300) {
              _mergePendingFromPostResponse(clientId, response.data);
            } else {
              _markPendingFailed(clientId);
            }
          }
        } on DioException catch (_) {
          _markPendingFailed(clientId);
        } catch (_) {
          _markPendingFailed(clientId);
        }
      }
    } catch (_) {
      _markPendingFailed(clientId);
    } finally {
      _retryingSendClientIds.remove(clientId);
      emit(_emitLoaded());
      await _persistMessages();
    }
  }

  Future<String?> generateBlurHash(File imageFile) async {
    try {
      // Lire les bytes de l'image
      final bytes = await imageFile.readAsBytes();

      // Décoder l'image en format utilisable
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Générer le blurhash (4x3 = qualité moyenne mais rapide)
      final blurHash = BlurHash.encode(image, numCompX: 4, numCompY: 3);

      return blurHash.hash;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, int>?> getImageDimensions(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      return {
        'width': decoded.width,
        'height': decoded.height,
      };
    } catch (_) {
      return null;
    }
  }

  String _detectMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return "image";
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return "video";
    if (['mp3', 'wav', 'aac'].contains(ext)) return "audio";
    return "document";
  }

  Future<void> _onFailMessage(FailMessageEvent event, Emitter<ChatState> emit) async {
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].isSaved == null && _messages[i].clientId == event.messageClientId) {
        _messages[i] = _messages[i].copyWith(isSaved: 0);
      }
    }

    emit(_emitLoaded());
    await _persistMessages();
  }

 Future<void> _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) async {
  final data = Map<String, dynamic>.from(event.message);
  
  // Normalisation du nom de l'événement socket
  final socketNorm = (data['_socket_event_normalized']?.toString() ?? '')
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
      .toLowerCase();

  final dataSansMeta = Map<String, dynamic>.from(data)
    ..remove('_socket_event')
    ..remove('_socket_event_normalized')
    ..remove('_raw');

  final payload = dataSansMeta['message'] is Map
      ? Map<String, dynamic>.from(dataSansMeta['message'] as Map)
      : dataSansMeta;

  final active = _activeConversationId;
  if (active == null || active.isEmpty) return;

  // 1. Vérification de la conversation (ID)
  final payloadCid = (payload['conversation_id'] ?? dataSansMeta['conversation_id'])?.toString() ?? '';
  if (payloadCid.isNotEmpty && payloadCid != active) return;

  final eventType = ((dataSansMeta['type'] ?? payload['type'])?.toString() ?? '').toLowerCase();
  final eventName = (dataSansMeta['event']?.toString() ?? '').toLowerCase();

  // 2. Gestion des événements de frappe (UserTyping)
  final isTypingEvent = eventType.contains('usertyping') || 
                        eventName.contains('usertyping') || 
                        socketNorm.contains('usertyping');

  if (isTypingEvent) {
    final t = data['is_typing'] ?? payload['is_typing'];
    if (t is bool && !t) {
      _isPartnerTyping = false;
      _partnerTypingResetTimer?.cancel();
      emit(_emitLoaded());
      return;
    }
    _isPartnerTyping = true;
    _partnerTypingResetTimer?.cancel();
    _partnerTypingResetTimer = Timer(_kPartnerTypingSilenceTimeout, () {
      add(PartnerTypingTimeoutEvent());
    });
    emit(_emitLoaded());
    return;
  }

  // 3. Identification explicite d'un Message Sent (Afin d'éviter qu'un Read Receipt le court-circuite)
  final socketRaw = (data['_socket_event']?.toString() ?? '').toLowerCase();
  final isMessageSentEvent = eventType.contains('messagesent') ||
      eventName.contains('messagesent') ||
      socketNorm.contains('messagesent') ||
      socketRaw.contains('message.sent') ||
      socketRaw.contains('messagesent');

  // 4. Gestion des accusés de lecture (Read Receipts)
  // On ne le traite comme ReadReceipt QUE SI ce n'est PAS un événement MessageSent
  final hasReadPayloadHint = _nonEmptyIdString(dataSansMeta['last_read_message_id']) != null ||
      _nonEmptyIdString(payload['last_read_message_id']) != null;

  final explicitReadBroadcast = !isMessageSentEvent && (
      eventType.contains('read') ||
      eventName.contains('read') ||
      socketNorm.contains('read') ||
      hasReadPayloadHint
  );

  if (explicitReadBroadcast) {
    await _handleSocketReadReceiptEvent(
      emit,
      dataSansMeta: dataSansMeta,
      payload: payload,
    );
    return;
  }

  // 5. Traitement et stockage du nouveau message
  final rawMediaUrl = payload['media_url']?.toString().trim();
  if (rawMediaUrl != null && rawMediaUrl.isNotEmpty) {
    payload['media_url'] = MediaPathUtils.resolveApiMediaUrlForDisplay(rawMediaUrl);
  }

  final rawThumbUrl = payload['thumbnail_url']?.toString().trim();
  if (rawThumbUrl != null && rawThumbUrl.isNotEmpty) {
    payload['thumbnail_url'] = MediaPathUtils.resolveApiMediaUrlForDisplay(rawThumbUrl);
  }

  try {
    final message = MessageModel.fromJson(payload);
    final msgCid = message.conversationId;
    if (msgCid.isNotEmpty && msgCid != active) return;

    final sid = message.senderId.trim();
    final me = _currentUserId.trim();
    if (sid.isNotEmpty && me.isNotEmpty && sid != me) {
      _isPartnerTyping = false;
      _partnerTypingResetTimer?.cancel();
    }

    // Sauvegarde en mémoire locale / Hive et mise à jour de la liste
    await _saveOrUpdateMessage(message);
    await _persistMessages(immediate: true);
    _syncFailed = false;
    _reconcilePartnerLastSeenFromMessages();

    // Re-émission forcée de l'état UI
    emit(_emitLoaded());
  } catch (e) {
    // Si la désérialisation échoue, journaliser pour éviter le silence

    print('❌ [ChatBloc] Payload reçu de l\'admin : $payload');
    print('❌ [ChatBloc] Erreur de cast : $e');
    // print('❌ [ChatBloc] StackTrace : $stackTrace');
  }
}

  /// Remplace l’entrée locale par [incoming] telle quelle (serveur gagne). Seul exception : si le payload
  /// ne fournit pas de [MessageEntity.clientId] non vide, on garde celui du message local (tracking / fusion).
  /// Ajouter ici d’autres champs 100 % locaux si le modèle en définit (ex. statut d’envoi UI-only).
  MessageEntity _incomingMessageReplacingPrevious(
    MessageEntity? previous,
    MessageEntity incoming,
  ) {
    if (previous == null) return incoming;
    final mergedMetadata = _mergeMetadataKeepingLocalPath(
      previous,
      incoming.metadata,
    );
    if (incoming.clientId.isNotEmpty) {
      return incoming.copyWith(metadata: mergedMetadata);
    }
    return incoming.copyWith(
      clientId: previous.clientId,
      metadata: mergedMetadata,
    );
  }

  /// Applique un message temps réel (Pusher, etc.) : même règle que le delta sync — remplacement total par
  /// la version reçue pour un [id] ou [clientId] déjà connu. L’appelant doit ensuite `emit(_emitLoaded())`
  /// (fait dans [_onReceiveMessage]).
  Future<void> _saveOrUpdateMessage(MessageEntity message) async {
    if (message.id.isNotEmpty) {
      final byId = _messages.indexWhere((msg) => msg.id == message.id);
      if (byId != -1) {
        _messages[byId] = _incomingMessageReplacingPrevious(_messages[byId], message);
        _messages.sort(compareChatMessagesChronological);
        return;
      }
    }

    final index = _messages.indexWhere(
      (msg) => msg.clientId.isNotEmpty && msg.clientId == message.clientId,
    );
    if (index != -1) {
      _messages[index] = _incomingMessageReplacingPrevious(_messages[index], message);
      _messages.sort(compareChatMessagesChronological);
      return;
    }

    _messages.add(message);
    _messages.sort(compareChatMessagesChronological);
  }
}