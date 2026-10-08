/// Contact chat : [GET /api/chat/users/contacts] ou [GET /api/chat/users/search], avec [conversationId] optionnel.
class UserSearchResultItem {
  final String userId;
  final String displayName;
  final String? email;
  /// URL brute Laravel (peut être absente).
  final String? profilePhotoUrl;
  final String? participantRole;
  final String? conversationId;

  const UserSearchResultItem({
    required this.userId,
    required this.displayName,
    this.email,
    this.profilePhotoUrl,
    this.participantRole,
    this.conversationId,
  });
}
