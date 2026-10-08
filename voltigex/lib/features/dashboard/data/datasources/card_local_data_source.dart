import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:voltigex/features/dashboard/data/models/card_model.dart';

const _kCardBox = 'card_details_cache_v1';
const _kCardJson = 'card_json';

/// Cache local des détails carte (affichage instantané à l’ouverture de l’onglet).
class CardLocalDataSource {
  CardLocalDataSource();

  Box<dynamic> get _box => Hive.box<dynamic>(_kCardBox);

  static Future<void> registerAndOpen() async {
    if (!Hive.isBoxOpen(_kCardBox)) {
      await Hive.openBox<dynamic>(_kCardBox);
    }
  }

  Future<CardModel?> read() async {
    final raw = _box.get(_kCardJson) as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      return CardModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(CardModel model) async {
    await _box.put(_kCardJson, jsonEncode(model.toJson()));
  }

  Future<void> clear() async {
    await _box.delete(_kCardJson);
  }
}
