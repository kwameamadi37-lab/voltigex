import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class CreateConversationAndSendMessageUseCase {
  final MessagesRepository repository;

  CreateConversationAndSendMessageUseCase(this.repository);

  Future<Map<String, dynamic>> call({
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
  }) {
    return repository.createConversationAndSendMessage(
      recipientUserId: recipientUserId,
      type: type,
      content: content,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      mediaWidth: mediaWidth,
      mediaHeight: mediaHeight,
      blurhash: blurhash,
      metadata: metadata,
      clientId: clientId,
    );
  }
}
