import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/locale/locale_cubit.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Choix de la langue d’interface (IT, FR, EN, ES, DE).
///
/// Libellés affichés tels quels : Italiano, Français, English, Español, Deutsch (+ drapeaux).
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  static bool _sameLocale(Locale a, Locale b) =>
      a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');

  /// Libellés fixes (noms usuels), indépendants de la langue UI courante.
  static const List<({Locale locale, String flag, String label})> _languages = [
    (locale: Locale('it', 'IT'), flag: '🇮🇹', label: 'Italiano'),
    (locale: Locale('fr', 'FR'), flag: '🇫🇷', label: 'Français'),
    (locale: Locale('en', 'US'), flag: '🇬🇧', label: 'English'),
    (locale: Locale('es', 'ES'), flag: '🇪🇸', label: 'Español'),
    (locale: Locale('de', 'DE'), flag: '🇩🇪', label: 'Deutsch'),
  ];

  Future<void> _onSelect(BuildContext context, Locale selected) async {
    unawaited(context.read<LocaleCubit>().setLocale(selected));
    final msg = lookupAppLocalizations(selected).languageUpdatedSuccess;
    if (!context.mounted) return;
    TopSnackBar.show(
      context,
      msg,
      type: TopSnackBarType.success,
      durationSeconds: 2,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: DefaultColors.blackColor,
        title: Text(
          l10n.languageSelectionTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final row = _languages[index];
          final selected = _sameLocale(row.locale, current);
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: selected ? null : () => _onSelect(context, row.locale),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Text(row.flag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        row.label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: DefaultColors.blueBackground,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
