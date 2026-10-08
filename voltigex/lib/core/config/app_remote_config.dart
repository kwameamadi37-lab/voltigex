import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voltigex/core/config/card_catalog_entry.dart';
import 'package:voltigex/core/constants.dart';

/// Configuration publique (contact, légal, QR) depuis le backend.
class AppRemoteConfig {
  AppRemoteConfig._({
    required this.contactEmail,
    required this.contactPhone,
    required this.openingHours,
    required this.privacyWebUrl,
    required this.termsWebUrl,
    required this.securityWebUrl,
    required this.privacyPdfUrl,
    required this.termsPdfUrl,
    required this.securityPdfUrl,
    required this.cardCatalog,
  });

  final String? contactEmail;
  final String? contactPhone;
  final String? openingHours;
  final String? privacyWebUrl;
  final String? termsWebUrl;
  final String? securityWebUrl;
  final String? privacyPdfUrl;
  final String? termsPdfUrl;
  final String? securityPdfUrl;
  final List<CardCatalogEntry> cardCatalog;

  static AppRemoteConfig? _cached;

  static const List<CardCatalogEntry> _defaultCardCatalog = [
    CardCatalogEntry(key: 'gold', labels: {'fr': 'Gold', 'en': 'Gold'}, amount: 650),
    CardCatalogEntry(key: 'diamond', labels: {'fr': 'Diamond', 'en': 'Diamond'}, amount: 1500),
    CardCatalogEntry(key: 'platinum', labels: {'fr': 'Platinum', 'en': 'Platinum'}, amount: 3500),
  ];

  double? amountForCardTier(String tier) {
    final normalized = tier.toLowerCase().trim();
    for (final entry in enabledCardCatalog) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.amount;
      }
    }
    return null;
  }

  List<CardCatalogEntry> get enabledCardCatalog =>
      cardCatalog.isNotEmpty ? cardCatalog : _defaultCardCatalog;

  String? labelForCardTier(String tier, String languageCode) {
    final normalized = tier.toLowerCase().trim();
    for (final entry in enabledCardCatalog) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.labelForLocale(languageCode);
      }
    }
    return null;
  }

  String? imageUrlForCardTier(String tier) {
    final normalized = tier.toLowerCase().trim();
    for (final entry in enabledCardCatalog) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.imageUrl;
      }
    }
    return null;
  }

  static AppRemoteConfig get fallback => AppRemoteConfig._(
        contactEmail: null,
        contactPhone: null,
        openingHours: null,
        privacyWebUrl: '${Constants.backendServerAddress}/politique-confidentialite',
        termsWebUrl: '${Constants.backendServerAddress}/condition-utilisation',
        securityWebUrl: '${Constants.backendServerAddress}/politique-securite',
        privacyPdfUrl: null,
        termsPdfUrl: null,
        securityPdfUrl: null,
        cardCatalog: _defaultCardCatalog,
      );

  static Future<AppRemoteConfig> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;
    try {
      final uri = Uri.parse('${Constants.backendServerAddress}/api/public/app-config');
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        _cached = fallback;
        return _cached!;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>? ?? {};
      final legal = data['legal'] as Map<String, dynamic>? ?? {};
      String? legUrl(String key, String sub) {
        final block = legal[key] as Map<String, dynamic>?;
        final v = block?[sub]?.toString().trim();
        return (v == null || v.isEmpty) ? null : v;
      }
      final catalogRaw = data['card_catalog'];
      final catalog = <CardCatalogEntry>[];
      if (catalogRaw is List) {
        for (final item in catalogRaw) {
          if (item is Map<String, dynamic>) {
            catalog.add(CardCatalogEntry.fromJson(item));
          } else if (item is Map) {
            catalog.add(CardCatalogEntry.fromJson(item.cast<String, dynamic>()));
          }
        }
        catalog.sort((a, b) => a.sort.compareTo(b.sort));
      }
      _cached = AppRemoteConfig._(
        contactEmail: data['contact_email']?.toString(),
        contactPhone: data['contact_phone']?.toString(),
        openingHours: data['opening_hours']?.toString(),
        privacyWebUrl: legUrl('privacy', 'web_url'),
        termsWebUrl: legUrl('terms', 'web_url'),
        securityWebUrl: legUrl('security', 'web_url'),
        privacyPdfUrl: legUrl('privacy', 'pdf_url'),
        termsPdfUrl: legUrl('terms', 'pdf_url'),
        securityPdfUrl: legUrl('security', 'pdf_url'),
        cardCatalog: catalog.isNotEmpty ? catalog : _defaultCardCatalog,
      );
      return _cached!;
    } catch (_) {
      _cached = fallback;
      return _cached!;
    }
  }
}
