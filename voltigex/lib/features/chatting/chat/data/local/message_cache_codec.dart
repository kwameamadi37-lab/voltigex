import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Sérialisation JSON pour le cache Hive (hors ligne, persistance Pusher).
Map<String, dynamic> messageEntityToCacheMap(MessageEntity e) {
  return {
    'id': e.id,
    'conversation_id': e.conversationId,
    'sender_id': e.senderId,
    'content': e.content,
    'type': e.type == 'MEDIA' ? 'media' : 'text',
    'media_name': e.mediaName,
    'media_url': e.mediaUrl,
    'media_type': e.mediaType,
    'media_width': e.mediaWidth,
    'media_height': e.mediaHeight,
    'blurhash': e.mediaBlurhash,
    'thumbnail_url': e.thumbnailUrl,
    'metadata': e.metadata,
    'created_at': e.createdAt,
    'updated_at': e.updatedAt.isNotEmpty ? e.updatedAt : e.createdAt,
    'is_read': e.isRead,
    'is_pinned': e.isPinned,
    'client_id': e.clientId,
    'pending': e.isSaved == null,
    'is_saved': e.isSaved,
    'failed': e.isSaved == 0,
  };
}

MessageEntity messageEntityFromCacheMap(Map<String, dynamic> m) {
  final pending = m['pending'] == true;
  final failed = m['failed'] == true;
  final int? isSaved = pending
      ? null
      : failed
          ? 0
          : ((m['is_saved'] as num?)?.toInt() ?? 1);

  final rawType = (m['type'] ?? 'text').toString().toLowerCase();
  return MessageEntity(
    id: (m['id'] ?? '').toString(),
    conversationId: (m['conversation_id'] ?? '').toString(),
    senderId: (m['sender_id'] ?? '').toString(),
    content: m['content'] as String?,
    type: rawType == 'media' ? 'MEDIA' : 'TEXT',
    mediaName: m['media_name'] as String? ??
        (m['metadata'] is Map ? (m['metadata'] as Map)['originalName'] as String? : null),
    mediaUrl: MediaPathUtils.normalizeStoredMediaPath(m['media_url']?.toString()),
    mediaType: m['media_type'] as String?,
    mediaWidth: (m['media_width'] as num?)?.toInt(),
    mediaHeight: (m['media_height'] as num?)?.toInt(),
    mediaBlurhash: m['blurhash'] as String?,
    thumbnailUrl: MediaPathUtils.normalizeStoredMediaPath(m['thumbnail_url']?.toString()),
    metadata: m['metadata'] != null ? Map<String, dynamic>.from(m['metadata'] as Map) : null,
    createdAt: (m['created_at'] ?? '').toString(),
    updatedAt: (m['updated_at'] ?? m['created_at'] ?? '').toString(),
    isRead: (m['is_read'] as num?)?.toInt() ?? 0,
    isPinned: (m['is_pinned'] as num?)?.toInt() ?? 0,
    isSaved: isSaved,
    clientId: MediaPathUtils.safeClientId(m['client_id']),
  );
}
