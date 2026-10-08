import 'package:flutter/material.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';

/// Préférez [CustomUserAvatar] dans le nouveau code.
///
/// [imageUrl] ou [profilePhotoUrl] : URL brute ou vide ; [participantRole] pour le fallback admin (image support).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.profilePhotoUrl,
    this.imageUrl,
    this.participantRole,
    required this.radius,
  });

  final String? profilePhotoUrl;
  final String? imageUrl;
  final String? participantRole;
  final double radius;

  String? get _raw {
    final a = profilePhotoUrl?.trim();
    if (a != null && a.isNotEmpty) return profilePhotoUrl;
    final b = imageUrl?.trim();
    if (b != null && b.isNotEmpty) return imageUrl;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomUserAvatar(
      profilePhotoUrl: _raw,
      role: participantRole,
      radius: radius,
    );
  }
}
