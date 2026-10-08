import 'package:voltigex/core/profile_image_utils.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required super.id,
    required super.participantName,
    super.participantUserId,
    super.participantFirstName,
    super.participantJoinedAt,
    super.participantProfilePhotoUrl,
    super.participantRole,
    required super.lastMessageType,
    super.lastMessageContent,
    super.lastMessageMediaType,
    required super.lastMessageTime,
    required super.unreadCount,
    super.updatedAt,
  });

  /// Parse ISO 8601 renvoyé par l’API en [DateTime] UTC (évite les décalages si la chaîne est sans fuseau).
  static DateTime? _parseUtcIso(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    var normalized = s;
    final hasExplicitTz = normalized.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(normalized) ||
        RegExp(r'[+-]\d{4}$').hasMatch(normalized);
    if (!hasExplicitTz) {
      normalized = '${normalized}Z';
    }
    return DateTime.tryParse(normalized)?.toUtc();
  }

  static DateTime _epochUtc() => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// `last_message` / `latest_message` ou champs à la racine (`last_content`, `content`, etc.).
  static Map<String, dynamic>? _coerceLastMessageMap(Map<String, dynamic> json) {
    for (final key in ['last_message', 'latest_message']) {
      final v = json[key];
      if (v is Map) {
        return Map<String, dynamic>.from(v);
      }
    }

    final rootContent = json['last_content'] ?? json['content'];
    final rootMedia = json['last_message_media_type'] ?? json['media_type'];
    final rootType = json['last_message_type'] ?? json['message_type'];
    final rootTime =
        json['last_message_at'] ?? json['last_message_created_at'] ?? json['updated_at'];

    final hasText = rootContent != null && rootContent.toString().trim().isNotEmpty;
    final hasMedia = rootMedia != null && rootMedia.toString().trim().isNotEmpty;
    if (!hasText && !hasMedia) {
      return null;
    }

    return {
      'type': (rootType ?? (hasMedia ? 'media' : 'text')).toString(),
      'content': hasText ? rootContent : null,
      'media_type': hasMedia ? rootMedia : null,
      'created_at': rootTime,
    };
  }

  /// Texte d’aperçu liste : si [rawContent] vide mais message média, libellé de substitution.
  static String? _previewContentForList({
    required String? rawContent,
    required String messageType,
    required String? mediaType,
  }) {
    final c = rawContent?.trim();
    if (c != null && c.isNotEmpty) return c;
    final t = messageType.toUpperCase();
    final m = (mediaType ?? '').toUpperCase();
    if (t == 'MEDIA' || m.isNotEmpty) {
      if (m.contains('IMAGE') ||
          const {'JPG', 'JPEG', 'PNG', 'GIF', 'WEBP', 'IMAGE'}.contains(m)) {
        return ' [Image] ';
      }
      if (m.contains('VIDEO') || m == 'VIDEO' || m.contains('MP4') || m.contains('MOV')) {
        return ' [Vidéo] ';
      }
      if (m.contains('AUDIO') || m == 'AUDIO' || m.contains('MP3') || m.contains('WAV')) {
        return ' [Audio] ';
      }
      return ' [Fichier] ';
    }
    return null;
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>?;
    final lastMessage = _coerceLastMessageMap(json);

    final DateTime? rowUpdatedUtc = _parseUtcIso(json['updated_at']);

    late final String lastMessageType;
    late final String? lastMessageContent;
    late final String? lastMessageMediaType;
    late final DateTime lastMessageTimeUtc;

    if (lastMessage != null) {
      lastMessageType = (lastMessage['type'] ?? 'text').toString();
      lastMessageMediaType = lastMessage['media_type'] as String?;
      lastMessageContent = _previewContentForList(
        rawContent: lastMessage['content'] as String?,
        messageType: lastMessageType,
        mediaType: lastMessageMediaType,
      );
      lastMessageTimeUtc = _parseUtcIso(lastMessage['created_at']) ??
          rowUpdatedUtc ??
          _epochUtc();
    } else {
      lastMessageType = 'text';
      lastMessageContent = null;
      lastMessageMediaType = null;
      lastMessageTimeUtc = rowUpdatedUtc ?? _epochUtc();
    }

    final photoUrl = participant != null
        ? ProfileImage.firstUrlFromJson(participant, [
            'profile_photo_url',
            'profile_image',
            'avatar',
            'photo',
          ])
        : null;

    final roleRaw = participant?['role']?.toString().trim();
    final participantRole =
        roleRaw != null && roleRaw.isNotEmpty ? roleRaw : null;

    final prenom = (participant?['prenom'] ?? '').toString().trim();
    DateTime? joinedAt = _parseUtcIso(participant?['created_at']);

    return ConversationModel(
      id: (json['id'] ?? '').toString(),
      participantName: (participant?['display_name'] ?? participant?['alias'] ?? participant?['email'] ?? 'Support').toString(),
      participantUserId: participant?['id'] != null ? participant!['id'].toString() : null,
      participantFirstName: prenom.isNotEmpty ? prenom : null,
      participantJoinedAt: joinedAt,
      participantProfilePhotoUrl: photoUrl,
      participantRole: participantRole,
      lastMessageType: lastMessageType,
      lastMessageContent: lastMessageContent,
      lastMessageMediaType: lastMessageMediaType,
      lastMessageTime: lastMessageTimeUtc,
      unreadCount: (json['unread_count'] is int)
          ? (json['unread_count'] as int)
          : int.tryParse((json['unread_count'] ?? '0').toString()) ?? 0,
      updatedAt: rowUpdatedUtc ?? lastMessageTimeUtc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'unread_count': unreadCount,
      'participant': {
        'id': participantUserId,
        'prenom': participantFirstName,
        'created_at': participantJoinedAt?.toUtc().toIso8601String(),
        'display_name': participantName,
        'role': participantRole,
        'profile_photo_url': participantProfilePhotoUrl,
        'profile_image': participantProfilePhotoUrl,
      },
      'last_message': {
        'type': lastMessageType,
        'content': lastMessageContent,
        'media_type': lastMessageMediaType,
        'created_at': lastMessageTime.toUtc().toIso8601String(),
      },
    };
  }

  ConversationModel copyWithModel({
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
    return ConversationModel(
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
