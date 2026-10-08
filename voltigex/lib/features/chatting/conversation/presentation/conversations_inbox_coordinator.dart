import 'dart:convert';

import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_event.dart';

/// Point d’accès pour que [ChatBloc] notifie l’inbox sans dépendance circulaire au niveau DI.
class ConversationsInboxCoordinator {
  ConversationsInboxCoordinator._();

  static ConversationsBloc? _bloc;

  /// Si le chat est ouvert sur cette conversation, injecte le payload Pusher inbox dans le fil.
  static void Function(Map<String, dynamic> payload)? deliverInboxPayloadToOpenChat;

  static void attach(ConversationsBloc bloc) {
    _bloc = bloc;
  }

  static void detach(ConversationsBloc bloc) {
    if (_bloc == bloc) {
      _bloc = null;
    }
  }

  static void onInboxPusherData(dynamic data) {
    try {
      Map<String, dynamic>? map;
      if (data is String) {
        map = Map<String, dynamic>.from(
          (jsonDecode(data) as Map).map((k, v) => MapEntry(k.toString(), v)),
        );
      } else if (data is Map) {
        map = Map<String, dynamic>.from(data);
      }
      if (map != null && map.isNotEmpty) {
        deliverInboxPayloadToOpenChat?.call(map);
      }
    } catch (_) {}

    _bloc?.add(InboxPusherPatchEvent(data));
  }

  static void onPresenceSnapshot(Set<String> userIds) {
    _bloc?.add(PresenceMembersSnapshotEvent(userIds));
  }

  static void onPresenceUserJoined(String userId) {
    if (userId.isEmpty) return;
    _bloc?.add(PresenceUserJoinedEvent(userId));
  }

  static void onPresenceUserLeft(String userId) {
    if (userId.isEmpty) return;
    _bloc?.add(PresenceUserLeftEvent(userId));
  }

  static void onRemoteTyping(String conversationId) {
    if (conversationId.isEmpty) return;
    _bloc?.add(RemoteTypingPingEvent(conversationId));
  }

  /// À appeler quand l’utilisateur quitte le chat : dernier message local → liste + cache.
  static void notifyChatClosed(String conversationId, List<MessageEntity> messages) {
    if (_bloc == null || conversationId.isEmpty || messages.isEmpty) {
      return;
    }
    MessageEntity? newest;
    DateTime? newestAt;
    for (final m in messages) {
      final t = DateTime.tryParse(m.createdAt);
      if (t == null) continue;
      if (newestAt == null || t.isAfter(newestAt)) {
        newestAt = t;
        newest = m;
      }
    }
    if (newest == null) return;
    _bloc!.add(
      SyncConversationPreviewFromChatEvent(
        conversationId: conversationId,
        lastMessage: newest,
      ),
    );
  }
}
