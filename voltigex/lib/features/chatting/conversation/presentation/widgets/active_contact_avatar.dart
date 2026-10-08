import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';

/// Avatar + prénom. Pastille uniquement si [presenceIndicatorColor] est non null (ex. vert / jaune).
class ActiveContactAvatar extends StatelessWidget {
  const ActiveContactAvatar({
    super.key,
    this.profilePhotoUrl,
    this.participantRole,
    required this.firstName,
    this.presenceIndicatorColor,
    this.size = 56,
  });

  final String? profilePhotoUrl;
  final String? participantRole;
  final String firstName;
  /// Vert (en ligne) ou jaune selon le parent ; `null` = aucune pastille.
  final Color? presenceIndicatorColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final r = size / 2;
    return SizedBox(
      width: size + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomUserAvatar(
                  profilePhotoUrl: profilePhotoUrl,
                  role: participantRole,
                  radius: r,
                ),
                if (presenceIndicatorColor != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: presenceIndicatorColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            firstName.isNotEmpty ? firstName : '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DefaultColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
