import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_event.dart';

/// Point d’accès pour que [ChatBloc] notifie l’inbox sans dépendance circulaire au niveau DI.
class ConversationsInboxCoordinator {
  ConversationsInboxCoordinator._();

  static ConversationsBloc? _bloc;

  static void attach(ConversationsBloc bloc) {
    _bloc = bloc;
  }

  static void detach(ConversationsBloc bloc) {
    if (_bloc == bloc) {
      _bloc = null;
    }
  }

  static void onInboxPusherData(dynamic data) {
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
