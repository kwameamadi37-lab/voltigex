import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Réponse [GET /api/chat/conversations/{id}] : messages + repère de lecture du partenaire.
class ChatMessagesFetchResult {
  final List<MessageEntity> messages;
  /// Dernier message **que vous avez envoyé** que le partenaire a lu (id serveur), si fourni par l’API.
  final String? partnerLastSeenMessageId;

  const ChatMessagesFetchResult({
    required this.messages,
    this.partnerLastSeenMessageId,
  });
}
