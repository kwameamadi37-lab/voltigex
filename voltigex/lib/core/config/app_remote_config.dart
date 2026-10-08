import 'dart:convert';

import 'package:http/http.dart' as http;
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

  static AppRemoteConfig? _cached;

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
      );
      return _cached!;
    } catch (_) {
      _cached = fallback;
      return _cached!;
    }
  }
}
