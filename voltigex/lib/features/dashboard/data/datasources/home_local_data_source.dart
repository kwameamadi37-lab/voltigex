import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:voltigex/features/dashboard/data/models/transaction_model.dart';
import 'package:voltigex/features/dashboard/data/models/user_profile_model.dart';

const _kHomeBox = 'home_dashboard_cache_v1';
const _kProfile = 'profile_json';
const _kTransactions = 'transactions_json';

/// Cache **hors solde** : profil + transactions pour démarrage offline-first.
///
/// L’historique paginé (liste complète) n’utilise **pas** ce cache : appel API
/// dédié sans lecture/écriture Hive.
class HomeLocalDataSource {
  HomeLocalDataSource();

  Box<dynamic> get _box => Hive.box<dynamic>(_kHomeBox);

  static Future<void> registerAdapterAndOpen() async {
    if (!Hive.isBoxOpen(_kHomeBox)) {
      await Hive.openBox<dynamic>(_kHomeBox);
    }
  }

  Future<UserProfileModel?> readProfile() async {
    final raw = _box.get(_kProfile) as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfileModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> writeProfile(UserProfileModel model) async {
    await _box.put(_kProfile, jsonEncode(model.toJson()));
  }

  Future<List<TransactionModel>?> readTransactions() async {
    final raw = _box.get(_kTransactions) as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> writeTransactions(List<TransactionModel> list) async {
    await _box.put(
      _kTransactions,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
