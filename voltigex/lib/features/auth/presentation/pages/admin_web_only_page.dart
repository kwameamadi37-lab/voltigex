import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_event.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Compte administrateur : le chat support est géré uniquement sur le portail web.
class AdminWebOnlyPage extends StatelessWidget {
  const AdminWebOnlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.computer_rounded,
                size: 72,
                color: DefaultColors.blueBackground.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.adminWebOnlyTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.adminWebOnlyBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: DefaultColors.blueBackground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.settingsMenuLogout,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
