/// Valeur sentinelle pour [MessageEntity.copyWith] : permet de passer explicitement `null` à [isSaved].
const Object _copyWithIsSavedUnset = Object();

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;    // null si le message est un media
  final String type;  // MEDIA ou TEXT
  final String? mediaName;   // null si le message est du text
  final String? mediaUrl;   // null si le message est du text
  final String? mediaType;   // null si le message est du text, VIDEO/IMAGE
  final int? mediaWidth;
  final int? mediaHeight;
  final String? mediaBlurhash;
  final String? thumbnailUrl; // ex: preview pour vidéo, null si le message est du text,
  final Map<String, dynamic>? metadata;   // null si le message est du text,
  final String createdAt;
  /// Horodatage serveur de dernière modification (ISO 8601). Vide si inconnu (cache ancien).
  final String updatedAt;
  final int isRead;
  final int isPinned;
  final int? isSaved;
  final String clientId;  // l'id du message du côté client

  /// Chemin local pour prévisualisation avant chargement réseau (`metadata['localFilePath']`).
  String? get localFilePath =>
      metadata?['localFilePath']?.toString().trim();

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    required this.type,
    this.mediaName,
    this.mediaUrl,
    this.mediaType,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaBlurhash,
    this.thumbnailUrl,
    this.metadata,
    required this.createdAt,
    this.updatedAt = '',
    required this.isRead,
    required this.isPinned,
    required this.isSaved,
    required this.clientId,
  });

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? type,
    String? mediaName,
    String? mediaUrl,
    String? mediaType,
    int? mediaWidth,
    int? mediaHeight,
    String? mediaBlurhash,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    String? createdAt,
    String? updatedAt,
    int? isRead,
    int? isPinned,
    Object? isSaved = _copyWithIsSavedUnset,
    String? clientId
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaName: mediaName ?? this.mediaName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      mediaBlurhash: mediaBlurhash ?? this.mediaBlurhash,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      isSaved: identical(isSaved, _copyWithIsSavedUnset)
          ? this.isSaved
          : isSaved as int?,
      clientId: clientId ?? this.clientId
    );
  }
}