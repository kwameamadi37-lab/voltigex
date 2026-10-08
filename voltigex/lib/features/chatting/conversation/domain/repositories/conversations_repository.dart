import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';

abstract class ConversationsRepository {
  /// [since] : conversations avec `updated_at` > since (delta). Ignoré si [fullSync].
  Future<List<ConversationEntity>> fetchConversations({
    DateTime? since,
    bool fullSync = false,
  });

  /// Contacts éligibles pour la barre horizontale ([GET /api/chat/users/contacts]).
  Future<List<UserSearchResultItem>> fetchChatContacts();

  /// Recherche d'utilisateurs ([GET /api/chat/users/search]) avec [conversation_id] optionnel.
  Future<List<UserSearchResultItem>> searchUsers({required String query});

  Future<String> checkOrCreateConversation({required String contactId});

  Future<String> getOrCreateConversationWithUser(String clientUserId);
}