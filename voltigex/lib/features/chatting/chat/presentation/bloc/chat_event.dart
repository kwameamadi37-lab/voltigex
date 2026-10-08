import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/selected_file.dart';

abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String conversationId;
  /// Si renseigné (ex. [SessionController.instance.userId]), évite une lecture storage dans le bloc.
  final String? currentUserId;
  /// Destinataire si [conversationId] vide (nouvelle conversation avant premier envoi).
  final String? recipientUserId;

  LoadMessagesEvent(
    this.conversationId, {
    this.currentUserId,
    this.recipientUserId,
  });
}

/// Hive + abonnement Pusher uniquement (pas d’appel API). Utilisé pour l’onglet Chat dans [IndexedStack].
class HydrateChatFromCacheEvent extends ChatEvent {
  final String conversationId;
  final String? currentUserId;

  HydrateChatFromCacheEvent(
    this.conversationId, {
    this.currentUserId,
  });
}

/// La page chat a été fermée : levée de la suppression inbox Pusher pour cette conversation.
class ChatConversationUiClosedEvent extends ChatEvent {}

/// Charger une page de messages plus anciens (scroll vers le haut).
class LoadOlderMessagesEvent extends ChatEvent {
  final String conversationId;

  LoadOlderMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent{
  final String conversationId;
  final String? recipientUserId;
  final String content;
  final List<SelectedMedia> mediaFiles;

  SendMessageEvent(this.content, this.mediaFiles, {required this.conversationId, this.recipientUserId});
}

/// Réessaie l’envoi d’un message en échec (`isSaved == 0`) en conservant [MessageEntity.clientId] et les métadonnées.
class RetrySendMessageEvent extends ChatEvent {
  final MessageEntity message;

  RetrySendMessageEvent(this.message);
}

class UploadMediaMessageEvent extends ChatEvent{
  final String filePath;

  UploadMediaMessageEvent(this.filePath);
}

class ReceiveMessageEvent extends ChatEvent {
  final Map<String, dynamic> message;
  ReceiveMessageEvent(this.message);
}

class FailMessageEvent extends ChatEvent {
  // l'id du message côté client
  final String messageClientId;

  FailMessageEvent(this.messageClientId);
}

class UpdateReadStatusEvent extends ChatEvent {
  final String conversationId;
  final List<String> messageIds; // les IDs des messages à marquer comme lus

  UpdateReadStatusEvent(this.conversationId, this.messageIds);
}

/// Marque des messages comme lus (ex. payload Pusher dédié).
class MessageReadEvent extends ChatEvent {
  final List<String> messageIds;

  MessageReadEvent(this.messageIds);
}


class LoadDailyQuestionEvent extends ChatEvent {
  final String conversationId;

  LoadDailyQuestionEvent(this.conversationId);
}

/// Ping Pusher `client-typing` sur `private-chat.{conversationId}` (liste + partenaire).
class ChatTypingPingEvent extends ChatEvent {
  final String conversationId;

  ChatTypingPingEvent(this.conversationId);
}

/// Intention de saisie depuis l’UI chat (émission socket, debounce côté page).
class ChatTypingEvent extends ChatEvent {
  final String conversationId;
  final bool isTyping;

  ChatTypingEvent({
    required this.conversationId,
    required this.isTyping,
  });
}

/// Timeout interne : masque l’indicateur “en train d’écrire”.
class PartnerTypingTimeoutEvent extends ChatEvent {}