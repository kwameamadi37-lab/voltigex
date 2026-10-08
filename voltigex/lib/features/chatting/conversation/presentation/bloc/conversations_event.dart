import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
abstract class ConversationsEvent {}

class FetchConversationsEvent extends ConversationsEvent {
  /// Ignore le cache `since` et recharge toute la liste (pull-to-refresh).
  final bool forceFullSync;

  FetchConversationsEvent({this.forceFullSync = false});
}

/// Recherche serveur sur les participants (debounce 500 ms dans le bloc).
class SearchConversationsEvent extends ConversationsEvent {
  final String query;

  SearchConversationsEvent(this.query);
}

/// Après ouverture d’une conversation depuis la recherche : revient à la liste principale.
class ResetUserSearchUiEvent extends ConversationsEvent {}

/// Payload brut Pusher canal inbox (ex. [MessageSent]).
class InboxPusherPatchEvent extends ConversationsEvent {
  final dynamic rawData;

  InboxPusherPatchEvent(this.rawData);
}

/// Après fermeture du chat : applique le dernier message localement (tri + Hive).
class SyncConversationPreviewFromChatEvent extends ConversationsEvent {
  final String conversationId;
  final MessageEntity lastMessage;

  SyncConversationPreviewFromChatEvent({
    required this.conversationId,
    required this.lastMessage,
  });
}

/// Snapshot complet des membres présents (canal `presence-app`).
class PresenceMembersSnapshotEvent extends ConversationsEvent {
  final Set<String> userIds;

  PresenceMembersSnapshotEvent(this.userIds);
}

class PresenceUserJoinedEvent extends ConversationsEvent {
  final String userId;

  PresenceUserJoinedEvent(this.userId);
}

class PresenceUserLeftEvent extends ConversationsEvent {
  final String userId;

  PresenceUserLeftEvent(this.userId);
}

/// `client-typing` reçu sur `private-chat.{conversationId}` (autre participant).
class RemoteTypingPingEvent extends ConversationsEvent {
  final String conversationId;

  RemoteTypingPingEvent(this.conversationId);
}

class TypingIndicatorTimeoutEvent extends ConversationsEvent {
  final String conversationId;

  TypingIndicatorTimeoutEvent(this.conversationId);
}
