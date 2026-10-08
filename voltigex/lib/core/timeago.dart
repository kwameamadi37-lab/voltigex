import 'package:timeago/timeago.dart' as timeago;

/// Code langue Flutter (`Locale.languageCode`) → clé enregistrée pour [timeago.format].
String appTimeagoLocaleForLanguageCode(String languageCode) {
  switch (languageCode) {
    case 'fr':
      return 'fr';
    case 'es':
      return 'es';
    case 'de':
      return 'de';
    case 'en':
    default:
      return 'en';
  }
}