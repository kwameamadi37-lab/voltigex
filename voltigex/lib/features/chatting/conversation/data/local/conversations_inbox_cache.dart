import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:voltigex/features/chatting/conversation/data/models/conversation_model.dart';

/// Cache Hive de la liste inbox (JSON fusionné par id).
class ConversationsInboxCache {
  ConversationsInboxCache._();

  static final ConversationsInboxCache instance = ConversationsInboxCache._();

  static const _boxName = 'conversations_inbox_v1';
  static const _keyList = 'conversations_json';
  static Box<String>? _box;

  static Future<void> ensureReady() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<List<ConversationModel>> readList() async {
    await ensureReady();
    final raw = _box!.get(_keyList);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> writeList(List<ConversationModel> list) async {
    await ensureReady();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _box!.put(_keyList, encoded);
  }

  /// Vide entièrement la box `conversations_inbox_v1` (déconnexion, changement d’utilisateur).
  Future<void> clear() async {
    await ensureReady();
    await _box!.clear();
  }
}
