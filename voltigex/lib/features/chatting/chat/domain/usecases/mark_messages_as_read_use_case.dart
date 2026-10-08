import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class MarkMessagesAsReadUseCase {
  final MessagesRepository messagesRepository;

  MarkMessagesAsReadUseCase({required this.messagesRepository});

  Future<void> call(String conversationId, List<String> messageIds) async {
    await messagesRepository.markMessagesAsRead(conversationId, messageIds);
  }
}