import 'package:voltigex/core/constants.dart';

/// Résolution des URLs d’avatar Laravel (relatives ou absolues).
/// Le fallback visuel (icône / support) est géré par [CustomUserAvatar].
class ProfileImage {
  ProfileImage._();

  /// Préfixe `storage/` pour les chemins `documents/...` du disque public Laravel.
  static String _ensureLaravelPublicStorageSegment(String path) {
    var p = path.trim().replaceFirst(RegExp(r'^/+'), '');
    if (p.isEmpty) return path.trim();
    if (p.toLowerCase().startsWith('storage/')) return p;
    if (p.startsWith('documents/')) return 'storage/$p';
    return p;
  }

  static String _fixHttpPathDocumentsToStorage(String absoluteUrl) {
    try {
      final uri = Uri.parse(absoluteUrl.trim());
      if (uri.scheme != 'http' && uri.scheme != 'https') return absoluteUrl;
      var path = uri.path;
      if (path.startsWith('/documents/') && !path.startsWith('/storage/')) {
        return uri.replace(path: '/storage$path').toString();
      }
    } catch (_) {}
    return absoluteUrl;
  }

  /// Réécrit l’origine (schéma + hôte + port) vers [Constants.backendServerAddress]
  /// pour les URLs Laravel `public` (`/storage/...`). Sans cela, les URLs générées
  /// avec `APP_URL=http://localhost:8000` ne sont pas joignables depuis un téléphone
  /// (localhost = l’appareil). Les URLs externes (hors `/storage/`) sont inchangées.
  static String rebaseToBackendHost(String absoluteUrl) {
    final t = _fixHttpPathDocumentsToStorage(absoluteUrl.trim());
    if (t.isEmpty) return t;
    late final Uri uri;
    try {
      uri = Uri.parse(t);
    } catch (_) {
      return t;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') return t;
    final path = uri.path;
    if (!path.startsWith('/storage/') && path != '/storage') {
      return t;
    }
    final baseStr = Constants.backendServerAddress.trim().replaceAll(RegExp(r'/$'), '');
    late final Uri backend;
    try {
      backend = Uri.parse(baseStr);
    } catch (_) {
      return t;
    }
    if (uri.origin == backend.origin) {
      return t;
    }
    return backend.replace(
      path: uri.path,
      query: uri.query.isEmpty ? null : uri.query,
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    ).toString();
  }

  /// URL absolue prête pour le réseau, ou `null` si pas d’image profil.
  static String? resolveOrNull(String? profilePhotoUrl) {
    if (profilePhotoUrl != null) {
      final u = profilePhotoUrl.trim();
      if (u.isNotEmpty) {
        if (u.startsWith('http://') || u.startsWith('https://')) {
          return rebaseToBackendHost(u);
        }
        final base = Constants.backendServerAddress.replaceAll(RegExp(r'/$'), '');
        final segment = _ensureLaravelPublicStorageSegment(
          u.startsWith('/') ? u.substring(1) : u,
        );
        final path = segment.startsWith('/') ? segment : '/$segment';
        return '$base$path';
      }
    }
    return null;
  }

  /// Comme [resolveOrNull] ; conservé pour les appels qui attendent une [String] optionnelle explicite.
  static String? resolve(String? profilePhotoUrl) => resolveOrNull(profilePhotoUrl);

  /// Premier champ non vide parmi [keys] dans [json].
  static String? firstUrlFromJson(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty) {
          return s;
        }
      }
    }
    return null;
  }
}
