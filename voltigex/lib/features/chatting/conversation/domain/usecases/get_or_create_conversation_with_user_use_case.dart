import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class GetOrCreateConversationWithUserUseCase {
  final ConversationsRepository conversationsRepository;

  GetOrCreateConversationWithUserUseCase({required this.conversationsRepository});

  Future<String> call(String clientUserId) {
    return conversationsRepository.getOrCreateConversationWithUser(clientUserId);
  }
}
