import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class CheckOrCreateConversationUseCase {
  final ConversationsRepository conversationsRepository;

  CheckOrCreateConversationUseCase({required this.conversationsRepository});

  Future<String> call({required String contactId}) async {
    return conversationsRepository.checkOrCreateConversation(contactId: contactId);
  }

}