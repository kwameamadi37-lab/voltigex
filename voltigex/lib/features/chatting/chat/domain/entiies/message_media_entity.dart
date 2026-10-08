class MessageMediaEntity {
  final String id;
  final String messageId;
  final String mediaType;     // "image", "video", "audio", "document"
  final String mediaUrl;
  final String? thumbnailUrl; // ex: preview pour vidéo
  final Map<String, dynamic>? metadata;

  MessageMediaEntity({
    required this.id,
    required this.messageId,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.metadata,
  });
}
