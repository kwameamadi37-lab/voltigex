import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistance du choix de langue ([SharedPreferences]).
abstract final class AppLocaleStorage {
  static const _key = 'app_locale_v1';

  /// Repère une [Locale] supportée (IT, FR, EN, ES, DE).
  static Locale normalize(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'it':
        return const Locale('it', 'IT');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'en':
        return const Locale('en', 'US');
      case 'es':
        return const Locale('es', 'ES');
      case 'de':
        return const Locale('de', 'DE');
      default:
        return const Locale('it', 'IT');
    }
  }

  static Future<Locale> readInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key)?.trim();
    if (raw == null || raw.isEmpty) {
      final system = WidgetsBinding.instance.platformDispatcher.locale;
      return normalize(system);
    }
    final parts = raw.split('_');
    final lang = parts.isNotEmpty ? parts[0] : 'it';
    final country = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
    return normalize(Locale(lang, country));
  }

  static Future<void> save(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final n = normalize(locale);
    await prefs.setString(_key, '${n.languageCode}_${n.countryCode ?? ''}');
  }
}
