import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';
import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class FetchChatContactsUseCase {
  final ConversationsRepository repository;

  FetchChatContactsUseCase(this.repository);

  Future<List<UserSearchResultItem>> call() {
    return repository.fetchChatContacts();
  }
}
