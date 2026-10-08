import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:voltigex/core/profile_image_utils.dart';

/// Rôle affiché comme « support » (photo locale [kSupportAvatarAsset]).
bool userRoleIsAdminLike(String? role) {
  final r = role?.trim().toLowerCase() ?? '';
  return r == 'admin';
}

/// Avatar unique : URL profil si présente, sinon image support si admin, sinon icône personne.
///
/// L’asset [kSupportAvatarAsset] doit exister sous `assets/images/` (déclaré via le dossier dans `pubspec.yaml`).
class CustomUserAvatar extends StatelessWidget {
  const CustomUserAvatar({
    super.key,
    this.profilePhotoUrl,
    this.role,
    this.radius = 30,
    this.backgroundColor,
  });

  /// URL brute ou chemin Laravel (voir [ProfileImage.resolveOrNull]).
  final String? profilePhotoUrl;
  final String? role;
  final double radius;
  final Color? backgroundColor;

  static const String kSupportAvatarAsset = 'assets/images/support.png';

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.grey.shade200;
    final size = radius * 2;
    final resolved = ProfileImage.resolveOrNull(profilePhotoUrl);

    if (resolved != null && resolved.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: resolved,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (_, __) => _personIcon(size, bg),
            errorWidget: (_, __, ___) => _roleFallback(size, bg),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: _roleFallback(size, bg),
    );
  }

  Widget _roleFallback(double size, Color bg) {
    if (userRoleIsAdminLike(role)) {
      return ClipOval(
        child: Image.asset(
          kSupportAvatarAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.support_agent_rounded,
            size: size * 0.55,
            color: Colors.blue.shade800,
          ),
        ),
      );
    }
    return _personIcon(size, bg);
  }

  Widget _personIcon(double size, Color bg) {
    return Container(
      width: size,
      height: size,
      color: bg,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: Colors.grey.shade600,
      ),
    );
  }
}
