import 'package:flutter/material.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/legal_web_view_page.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Inscription identique au parcours web (`/sign-up`) : formulaire KYC multi-étapes.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LegalWebViewPage(
      url: '${Constants.backendServerAddress}/sign-up',
      title: l10n.registerButton,
    );
  }
}
