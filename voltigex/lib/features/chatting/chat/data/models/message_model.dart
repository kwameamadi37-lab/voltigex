import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    String? content,
    required String type, // MEDIA ou TEXT
    String? mediaName,
    String? mediaUrl,
    String? mediaType,
    int? mediaWidth,
    int? mediaHeight,
    String? mediaBlurhash,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    required String createdAt,
    String updatedAt = '',
    required int isRead,
    required int isPinned,
    required int isSaved,
    required String clientId,
}) : super(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: content,
    type: type,
    mediaName: mediaName,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    mediaWidth: mediaWidth,
    mediaHeight: mediaHeight,
    mediaBlurhash: mediaBlurhash,
    thumbnailUrl: thumbnailUrl,
    metadata: metadata,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isRead: isRead,
    isPinned: isPinned,
    isSaved: isSaved,
    clientId: clientId
  );

  /// Anciens messages : URL absolue `http(s)://...`. Nouveaux : chemin relatif (`storage/...`) —
  /// résolution dynamique via [Constants.baseUrl] puis normalisation en chemin stocké.
  static String? _mediaUrlFromApiJson(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    final lower = t.toLowerCase();
    if (lower.startsWith('content://')) {
      return t;
    }
    if (MediaPathUtils.isLocalMediaPath(t)) {
      return t;
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return MediaPathUtils.resolveApiMediaUrlForDisplay(t);
    }
    final absolute = MediaPathUtils.resolveApiMediaUrlForDisplay(t);
    return absolute.isEmpty ? null : absolute;
  }

  /// API Laravel : `metadata` peut être `{}`, `null`, ou par erreur `[]` (liste vide JSON).
  static Map<String, dynamic>? metadataFromJson(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return map.isEmpty ? null : map;
    }
    if (raw is List && raw.isEmpty) return null;
    return null;
  }

  factory MessageModel.fromJson(Map<String, dynamic> json){
    final senderObj = json['sender'] as Map<String, dynamic>?;
    final rawType = (json['type'] ?? '').toString().toLowerCase();
    final normalizedType = rawType == 'media' ? 'MEDIA' : 'TEXT';
    final isReadRaw = json['is_read'];
    final isPinnedRaw = json['is_pinned'];

    final createdAtStr = (json['created_at'] ?? '').toString();
    final updatedAtStr =
        (json['updated_at'] ?? json['created_at'] ?? '').toString();

    var rawMediaUrl = json['media_url']?.toString();
    final rawThumb = json['thumbnail_url']?.toString();
    final contentStr = json['content']?.toString().trim();
    if (normalizedType == 'MEDIA' &&
        (rawMediaUrl == null || rawMediaUrl.trim().isEmpty) &&
        contentStr != null &&
        contentStr.isNotEmpty) {
      rawMediaUrl = contentStr;
    }

    final metaMap = metadataFromJson(json['metadata']);
    final rawClientId = json['client_id'] ?? metaMap?['client_id'];

    return MessageModel(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversation_id'] ?? '').toString(),
      senderId: (json['sender_id'] ?? senderObj?['id'] ?? '').toString(),
      content: json['content'] as String?,
      type: normalizedType,
      mediaName: metaMap != null ? metaMap['originalName'] as String? : null,
      mediaUrl: _mediaUrlFromApiJson(rawMediaUrl),
      mediaType: json['media_type'] as String?,
      mediaWidth: (json['media_width'] as num?)?.toInt(),
      mediaHeight: (json['media_height'] as num?)?.toInt(),
      mediaBlurhash: json['blurhash'] as String?,
      thumbnailUrl: _mediaUrlFromApiJson(rawThumb),
      metadata: metaMap,
      createdAt: createdAtStr,
      updatedAt: updatedAtStr,
      isRead: isReadRaw is bool ? (isReadRaw ? 1 : 0) : (isReadRaw as int? ?? 0),
      isPinned: isPinnedRaw is bool ? (isPinnedRaw ? 1 : 0) : (isPinnedRaw as int? ?? 0),
      isSaved: 1,  // toujours sauvegardé si ça vient du serveur
      clientId: MediaPathUtils.safeClientId(rawClientId),
    );
  }
}