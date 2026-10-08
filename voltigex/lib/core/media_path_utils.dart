import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/profile_image_utils.dart';

/// Chemins médias chat : stockage **relatif** côté API (`storage/...`) dans les entités,
/// reconstruction de l’URL complète avec [Constants.baseUrl] uniquement à l’affichage / téléchargement.
class MediaPathUtils {
  MediaPathUtils._();

  /// Chemins issus de `Storage::disk('public')->store('documents/...')` en base : servis sous `/storage/documents/...`
  /// (symlink `public/storage`), pas sous `/documents/...`.
  static String ensureLaravelPublicStoragePath(String path) {
    var p = path.trim().replaceFirst(RegExp(r'^/+'), '');
    if (p.isEmpty) return path.trim();
    final lower = p.toLowerCase();
    if (lower.startsWith('storage/')) return p;
    if (p.startsWith('documents/') || p.startsWith('chat_medias/')) {
      return 'storage/$p';
    }
    return p;
  }

  static String _fixHttpPathForLaravelPublicDisk(String absoluteUrl) {
    try {
      final uri = Uri.parse(absoluteUrl.trim());
      if (uri.scheme != 'http' && uri.scheme != 'https') return absoluteUrl;
      var path = uri.path;
      if (path.startsWith('/documents/') && !path.startsWith('/storage/')) {
        path = '/storage$path';
        return uri.replace(path: path).toString();
      }
    } catch (_) {}
    return absoluteUrl;
  }

  /// Identifiant client pour corrélation envoi / réponse — rejette les chaînes qui ressemblent à un chemin ou une URL.
  static String safeClientId(dynamic value) {
    if (value == null) return '';
    final s = value.toString().trim();
    if (s.isEmpty) return '';
    if (s.startsWith('/') ||
        s.startsWith(r'\\') ||
        s.startsWith('file://') ||
        s.toLowerCase().startsWith('http')) {
      return '';
    }
    return s;
  }

  /// `true` si [value] est un chemin fichier local (upload en cours, cache), pas une clé API.
  /// Les chemins relatifs `storage/...` (Laravel) ne sont pas locaux.
  static bool isLocalMediaPath(String value) {
    final t = value.trim();
    if (t.isEmpty) return false;
    if (t.startsWith('file://')) return true;
    if (t.length >= 3 && t[1] == ':' && (t[2] == r'\' || t[2] == '/')) {
      return true;
    }
    // Racine web Laravel `/storage/...` (fichier distant), pas le volume Android.
    if (t.startsWith('/storage/') && !t.startsWith('/storage/emulated')) {
      return false;
    }
    if (t.startsWith('storage/')) {
      return false;
    }
    if (t.startsWith('/')) return true;
    return false;
  }

  /// Retire `http(s)://hôte` et normalise en chemin relatif (`storage/...`).
  /// Laisse inchangés les chemins locaux (file picker, cache).
  static String? normalizeStoredMediaPath(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;

    if (isLocalMediaPath(t)) {
      return t;
    }

    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      try {
        final uri = Uri.parse(t);
        var path = uri.path;
        if (path.startsWith('/')) path = path.substring(1);
        return path.isEmpty ? null : path;
      } catch (_) {
        return t;
      }
    }

    // Chemin absolu style Laravel `/storage/...` (sans domaine) — pas les volumes Android `/storage/emulated/`.
    if (t.startsWith('/storage/') && !t.startsWith('/storage/emulated')) {
      return t.substring(1);
    }

    return t;
  }

  /// URL HTTP(S) complète pour affichage réseau ([CachedNetworkImage], téléchargement).
  /// Accepte un chemin relatif API, une URL absolue héritée, ou renvoie tel quel un chemin local.
  static String resolveApiMediaUrlForDisplay(String mediaUrl) {
    final t = mediaUrl.trim();
    if (t.isEmpty) return t;
    if (isLocalMediaPath(t)) {
      return t;
    }
    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return ProfileImage.rebaseToBackendHost(_fixHttpPathForLaravelPublicDisk(t));
    }
    var base = Constants.baseUrl.trim();
    if (!base.endsWith('/')) {
      base = '$base/';
    }
    final path = ensureLaravelPublicStoragePath(t.replaceFirst(RegExp(r'^/+'), ''));
    return Uri.parse(base).resolve(path).toString();
  }

  /// Chemin ou nom de fichier pour dériver l’extension (URL absolue ou relative).
  static String pathForExtension(String mediaUrl) {
    final t = mediaUrl.trim();
    if (t.isEmpty) return t;
    final lower = t.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      try {
        return Uri.parse(t).path;
      } catch (_) {
        return t;
      }
    }
    return t;
  }
}
