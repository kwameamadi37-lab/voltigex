import 'package:voltigex/features/chatting/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';
import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource conversationsRemoteDataSource;

  ConversationsRepositoryImpl({required this.conversationsRemoteDataSource});

  @override
  Future<List<ConversationEntity>> fetchConversations({
    DateTime? since,
    bool fullSync = false,
  }) async {
    return await conversationsRemoteDataSource.fetchConversations(
      since: since,
      fullSync: fullSync,
    );
  }

  @override
  Future<List<UserSearchResultItem>> fetchChatContacts() {
    return conversationsRemoteDataSource.fetchChatContacts();
  }

  @override
  Future<List<UserSearchResultItem>> searchUsers({required String query}) {
    return conversationsRemoteDataSource.searchUsers(query: query);
  }

  @override
  Future<String> checkOrCreateConversation({required String contactId}) async {
    return await conversationsRemoteDataSource.checkOrCreateConversation(contactId: contactId);
  }

  @override
  Future<String> getOrCreateConversationWithUser(String clientUserId) async {
    return conversationsRemoteDataSource.getOrCreateConversationWithUser(clientUserId);
  }
}
