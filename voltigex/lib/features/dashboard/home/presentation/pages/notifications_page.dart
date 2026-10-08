import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/l10n/app_localizations.dart';


/// Liste des notifications (vide pour l’instant — pas de Bloc / API).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor:  DefaultColors.whiteText,
                  foregroundColor: DefaultColors.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.notificationsPageTitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: DefaultColors.blackColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20), 
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(28),
                    //   decoration: BoxDecoration(
                    //     color: Colors.transparent,
                    //     shape: BoxShape.circle,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withValues(alpha: 0.06),
                    //         blurRadius: 24,
                    //         offset: const Offset(0, 8),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Icon(
                    //     Icons.notifications_none_rounded,
                    //     size: 56,
                    //     color: DefaultColors.blueBackground.withValues(alpha: 0.85),
                    //   ),
                    // ),
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 56,
                      color: DefaultColors.blueBackground.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.notificationsAllCaughtUp,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: DefaultColors.blackColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.notificationsEmptyHint,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.45,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),)
          ]
        ),
      ),
    );
  }
}
