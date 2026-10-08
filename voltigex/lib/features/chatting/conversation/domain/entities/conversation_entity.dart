class ConversationEntity {
  final String id;
  final String participantName;
  /// Identifiant de l’autre participant (présence Pusher).
  final String? participantUserId;
  /// Prénom pour la barre de présence (fallback : premier mot du nom).
  final String? participantFirstName;
  /// Date d’inscription du participant (`users.created_at`) — tri barre horizontale.
  final DateTime? participantJoinedAt;
  /// URL brute renvoyée par Laravel pour l’autre participant (peut être relative).
  final String? participantProfilePhotoUrl;
  /// Rôle Laravel de l’autre participant (`user`, `admin`, …).
  final String? participantRole;
  final String lastMessageType;
  final String? lastMessageContent;
  final String? lastMessageMediaType;
  final DateTime lastMessageTime;
  final int unreadCount;
  /// Horodatage `conversations.updated_at` (tri + paramètre API `since`).
  final DateTime updatedAt;

  ConversationEntity({
    required this.id,
    required this.participantName,
    this.participantUserId,
    this.participantFirstName,
    this.participantJoinedAt,
    this.participantProfilePhotoUrl,
    this.participantRole,
    required this.lastMessageType,
    this.lastMessageContent,
    this.lastMessageMediaType,
    required this.lastMessageTime,
    required this.unreadCount,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? lastMessageTime;

  ConversationEntity copyWith({
    String? id,
    String? participantName,
    String? participantUserId,
    String? participantFirstName,
    DateTime? participantJoinedAt,
    String? participantProfilePhotoUrl,
    String? participantRole,
    String? lastMessageType,
    String? lastMessageContent,
    String? lastMessageMediaType,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      participantUserId: participantUserId ?? this.participantUserId,
      participantFirstName: participantFirstName ?? this.participantFirstName,
      participantJoinedAt: participantJoinedAt ?? this.participantJoinedAt,
      participantProfilePhotoUrl: participantProfilePhotoUrl ?? this.participantProfilePhotoUrl,
      participantRole: participantRole ?? this.participantRole,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageMediaType: lastMessageMediaType ?? this.lastMessageMediaType,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}