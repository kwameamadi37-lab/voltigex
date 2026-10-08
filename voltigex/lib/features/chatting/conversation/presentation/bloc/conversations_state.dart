import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';

abstract class ConversationsState {}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationEntity> conversations;
  final Set<String> onlineUserIds;
  final Set<String> typingConversationIds;
  /// Requête API de recherche en cours (indicateur dans la barre de recherche).
  final bool isSearchLoading;
  /// Contacts pour la barre horizontale ([GET /api/chat/users/contacts]).
  final List<UserSearchResultItem> allContacts;
  /// Non null : résultats recherche serveur — affichés uniquement dans la liste verticale.
  final List<UserSearchResultItem>? userSearchResults;

  ConversationsLoaded(
    this.conversations, {
    this.onlineUserIds = const {},
    this.typingConversationIds = const {},
    this.isSearchLoading = false,
    this.allContacts = const [],
    this.userSearchResults,
  });
}

class ConversationUpdated extends ConversationsState{
  final ConversationEntity conversation;

  ConversationUpdated({required this.conversation});

}

class ConversationsError extends ConversationsState {
  final String message;
  ConversationsError(this.message);
}
