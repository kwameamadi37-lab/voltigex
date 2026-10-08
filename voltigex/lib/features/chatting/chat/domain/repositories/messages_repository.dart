import 'package:voltigex/features/chatting/chat/domain/entiies/chat_messages_fetch_result.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/daily_question_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

abstract class MessagesRepository {
  /// [afterMessageId] : id serveur du message le plus récent en cache → ne retourne que les suivants.
  Future<ChatMessagesFetchResult> fetchMessages(
    String conversationId, {
    String? afterMessageId,
    String? updatedAfter,
    String? beforeMessageId,
    int? limit,
  });
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds);
  Future<void> sendMessage(MessageEntity message);
  Future<Map<String, dynamic>> uploadMedia(
    String filePath, {
    String? originalFileName,
  });

  /// Crée la conversation + premier message ([POST /api/chat/messages/create-and-send]).
  Future<Map<String, dynamic>> createConversationAndSendMessage({
    required String recipientUserId,
    required String type,
    String? content,
    String? mediaType,
    String? mediaUrl,
    int? mediaWidth,
    int? mediaHeight,
    String? blurhash,
    Map<String, dynamic>? metadata,
    String? clientId,
  });
  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId);
}