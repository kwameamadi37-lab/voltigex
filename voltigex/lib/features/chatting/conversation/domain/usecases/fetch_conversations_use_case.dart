import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';

class FetchConversationsUseCase {
  final ConversationsRepository repository;

  FetchConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call({
    DateTime? since,
    bool forceFullSync = false,
  }) async {
    return repository.fetchConversations(
      since: since,
      fullSync: forceFullSync,
    );
  }
}