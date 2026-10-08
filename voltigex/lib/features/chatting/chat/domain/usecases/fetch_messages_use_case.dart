import 'package:voltigex/features/chatting/chat/domain/entiies/chat_messages_fetch_result.dart';
import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class FetchMessagesUseCase {
  final MessagesRepository messagesRepository;

  FetchMessagesUseCase({required this.messagesRepository,});

  Future<ChatMessagesFetchResult> call(
    String conversationId, {
    String? afterMessageId,
    String? updatedAfter,
    String? beforeMessageId,
    int? limit,
  }) async {
    return messagesRepository.fetchMessages(
      conversationId,
      afterMessageId: afterMessageId,
      updatedAfter: updatedAfter,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }
}