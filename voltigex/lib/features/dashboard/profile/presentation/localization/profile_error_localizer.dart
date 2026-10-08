import 'package:voltigex/l10n/app_localizations.dart';

String localizeProfileError(AppLocalizations l10n, String codeOrMessage) {
  switch (codeOrMessage) {
    case 'profile.error.contactRequired':
      return l10n.profileErrorContactRequired;
    case 'profile.error.invalidEmail':
      return l10n.profileErrorInvalidEmail;
    case 'profile.error.identityRequired':
      return l10n.profileErrorIdentityRequired;
    case 'profile.error.passwordsMismatch':
      return l10n.profileErrorPasswordsMismatch;
    case 'profile.error.passwordWeak':
      return l10n.profileErrorPasswordWeak;
    case 'profile.error.addressRequired':
      return l10n.profileErrorAddressRequired;
    default:
      return codeOrMessage;
  }
}
