import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';
import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class SearchConversationsUseCase {
  final ConversationsRepository repository;

  SearchConversationsUseCase(this.repository);

  Future<List<UserSearchResultItem>> call(String query) {
    return repository.searchUsers(query: query);
  }
}
