import 'package:voltigex/l10n/app_localizations.dart';

String localizeAuthError(AppLocalizations l10n, String codeOrMessage) {
  switch (codeOrMessage) {
    case 'auth.error.registerFailed':
      return l10n.authErrorRegisterFailed;
    case 'auth.error.loginFailed':
      return l10n.authErrorLoginFailed;
    case 'auth.error.logoutFailed':
      return l10n.authErrorLogoutFailed;
    default:
      return codeOrMessage;
  }
}
