import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/features/chatting/chat/data/local/message_cache_codec.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/chat_message.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Cache local des fils de discussion par [conversationId].
class ChatMessagesCache {
  ChatMessagesCache._();

  static const _boxName = 'chat_messages_v1';
  static const _writeDebounceMs = 320;
  static Box<String>? _box;
  static Timer? _writeDebounceTimer;

  static Future<void> ensureReady() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<List<MessageEntity>> read(String conversationId) async {
    await ensureReady();
    final raw = _box!.get(conversationId);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => messageEntityFromCacheMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> write(String conversationId, List<MessageEntity> messages) async {
    await ensureReady();
    final encoded = jsonEncode(messages.map(messageEntityToCacheMap).toList());
    await _box!.put(conversationId, encoded);
  }

  /// Annule une écriture différée en attente.
  static void cancelScheduledWrite() {
    _writeDebounceTimer?.cancel();
    _writeDebounceTimer = null;
  }

  /// Regroupe les écritures rapides (envoi multiple, mises à jour UI) : le snapshot est lu à l’exécution du timer.
  static void scheduleWrite(
    String conversationId,
    List<MessageEntity> Function() snapshot,
  ) {
    _writeDebounceTimer?.cancel();
    _writeDebounceTimer = Timer(const Duration(milliseconds: _writeDebounceMs), () {
      _writeDebounceTimer = null;
      unawaited(write(conversationId, snapshot()));
    });
  }

  /// Enregistre un message entrant (Pusher) sans réécrire tout le fil : lecture + merge + écriture.
  static Future<void> upsertMessage(String conversationId, MessageEntity message) async {
    final existing = await read(conversationId);
    final merged = _mergeUpsert(existing, message);
    await write(conversationId, merged);
  }

  static List<MessageEntity> _mergeUpsert(List<MessageEntity> list, MessageEntity incoming) {
    if (incoming.id.isNotEmpty) {
      final i = list.indexWhere((m) => m.id == incoming.id);
      if (i != -1) {
        final copy = List<MessageEntity>.from(list);
        copy[i] = _preferIncoming(copy[i], incoming);
        return _sortByTime(copy);
      }
    }
    if (incoming.clientId.isNotEmpty) {
      final i = list.indexWhere((m) => m.clientId == incoming.clientId);
      if (i != -1) {
        final copy = List<MessageEntity>.from(list);
        copy[i] = _preferIncoming(copy[i], incoming);
        return _sortByTime(copy);
      }
    }
    final copy = List<MessageEntity>.from(list)..add(incoming);
    return _sortByTime(copy);
  }

  static const String _kMetaLocalFilePath = 'localFilePath';

  static MessageEntity _preferIncoming(MessageEntity old, MessageEntity incoming) {
    return old.copyWith(
      id: incoming.id.isNotEmpty ? incoming.id : old.id,
      content: incoming.content ?? old.content,
      mediaName: incoming.mediaName ?? old.mediaName,
      mediaUrl: incoming.mediaUrl ?? old.mediaUrl,
      mediaType: incoming.mediaType ?? old.mediaType,
      mediaWidth: incoming.mediaWidth ?? old.mediaWidth,
      mediaHeight: incoming.mediaHeight ?? old.mediaHeight,
      mediaBlurhash: incoming.mediaBlurhash ?? old.mediaBlurhash,
      isRead: incoming.isRead,
      isSaved: incoming.isSaved ?? old.isSaved,
      metadata: _mergeMetadataPreservingLocalPath(old, incoming.metadata),
    );
  }

  /// Même règle que le bloc : ne pas perdre [localFilePath] au swap local → serveur.
  static Map<String, dynamic>? _mergeMetadataPreservingLocalPath(
    MessageEntity old,
    Map<String, dynamic>? incomingMeta,
  ) {
    final merged = <String, dynamic>{};
    if (old.metadata != null) merged.addAll(old.metadata!);
    if (incomingMeta != null) merged.addAll(incomingMeta);
    final oldPath = old.metadata?[_kMetaLocalFilePath]?.toString().trim();
    if (oldPath != null && oldPath.isNotEmpty) {
      merged[_kMetaLocalFilePath] = oldPath;
    } else {
      final preserved = _preservedLocalPathForMerge(old);
      if (preserved != null && preserved.isNotEmpty) {
        merged[_kMetaLocalFilePath] = preserved;
      } else {
        final v = merged[_kMetaLocalFilePath];
        if (v == null || (v is String && v.trim().isEmpty)) {
          merged.remove(_kMetaLocalFilePath);
        }
      }
    }
    return merged.isEmpty ? null : merged;
  }

  static String? _preservedLocalPathForMerge(MessageEntity old) {
    final fromMeta = old.metadata?[_kMetaLocalFilePath]?.toString().trim();
    if (fromMeta != null && fromMeta.isNotEmpty) return fromMeta;
    final m = old.mediaUrl?.trim() ?? '';
    if (m.isEmpty) return null;
    if (m.toLowerCase().startsWith('content://')) return m;
    if (MediaPathUtils.isLocalMediaPath(m)) return m;
    return null;
  }

  static List<MessageEntity> _sortByTime(List<MessageEntity> list) {
    list.sort(compareChatMessagesChronological);
    return list;
  }
}
