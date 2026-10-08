import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('it'),
    Locale('fr'),
    Locale('en'),
    Locale('es'),
    Locale('de'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Wori App'**
  String get appTitle;

  /// No description provided for @errorTitle.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get errorTitle;

  /// No description provided for @buttonOk.
  ///
  /// In it, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get buttonCancel;

  /// No description provided for @buttonRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get buttonRetry;

  /// No description provided for @adminWebOnlyTitle.
  ///
  /// In it, this message translates to:
  /// **'Area admin sul web'**
  String get adminWebOnlyTitle;

  /// No description provided for @adminWebOnlyBody.
  ///
  /// In it, this message translates to:
  /// **'La chat di supporto clienti è disponibile solo sul portale admin web. Usa un browser sul computer per rispondere ai messaggi.'**
  String get adminWebOnlyBody;

  /// No description provided for @languageUpdatedSuccess.
  ///
  /// In it, this message translates to:
  /// **'Lingua aggiornata con successo'**
  String get languageUpdatedSuccess;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get languageSelectionTitle;

  /// No description provided for @languageNameFr.
  ///
  /// In it, this message translates to:
  /// **'Francese'**
  String get languageNameFr;

  /// No description provided for @languageNameEn.
  ///
  /// In it, this message translates to:
  /// **'Inglese'**
  String get languageNameEn;

  /// No description provided for @languageNameEs.
  ///
  /// In it, this message translates to:
  /// **'Spagnolo'**
  String get languageNameEs;

  /// No description provided for @languageNameDe.
  ///
  /// In it, this message translates to:
  /// **'Tedesco'**
  String get languageNameDe;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguage;

  /// No description provided for @settingsDocumentsSection.
  ///
  /// In it, this message translates to:
  /// **'Documenti'**
  String get settingsDocumentsSection;

  /// No description provided for @settingsMenuDocuments.
  ///
  /// In it, this message translates to:
  /// **'Documenti'**
  String get settingsMenuDocuments;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In it, this message translates to:
  /// **'Generale'**
  String get settingsGeneralSection;

  /// No description provided for @settingsMenuProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get settingsMenuProfile;

  /// No description provided for @settingsMenuContact.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get settingsMenuContact;

  /// No description provided for @settingsMenuReportProblem.
  ///
  /// In it, this message translates to:
  /// **'Segnala un problema'**
  String get settingsMenuReportProblem;

  /// No description provided for @settingsMenuCardsHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico carte'**
  String get settingsMenuCardsHistory;

  /// No description provided for @settingsMenuLegal.
  ///
  /// In it, this message translates to:
  /// **'Documentazione legale'**
  String get settingsMenuLegal;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In it, this message translates to:
  /// **'Sicurezza'**
  String get settingsSecuritySection;

  /// No description provided for @settingsMenuPassword.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna password'**
  String get settingsMenuPassword;

  /// No description provided for @settingsAccountSection.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsMenuLogout.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get settingsMenuLogout;

  /// No description provided for @birthDateHelp.
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get birthDateHelp;

  /// No description provided for @profilePageTitle.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profilePageTitle;

  /// No description provided for @profileIdentitySection.
  ///
  /// In it, this message translates to:
  /// **'Identita'**
  String get profileIdentitySection;

  /// No description provided for @errorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Problema di connessione alla rete.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In it, this message translates to:
  /// **'Si e verificato un errore.'**
  String get errorGeneric;

  /// No description provided for @errorValidation.
  ///
  /// In it, this message translates to:
  /// **'Dati non validi.'**
  String get errorValidation;

  /// No description provided for @noticeTitle.
  ///
  /// In it, this message translates to:
  /// **'Avviso'**
  String get noticeTitle;

  /// No description provided for @successTitle.
  ///
  /// In it, this message translates to:
  /// **'Successo'**
  String get successTitle;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In it, this message translates to:
  /// **'Il tuo profilo e stato aggiornato.'**
  String get profileUpdatedSuccess;

  /// No description provided for @loginTitle.
  ///
  /// In it, this message translates to:
  /// **'Accesso'**
  String get loginTitle;

  /// No description provided for @loginHintEmail.
  ///
  /// In it, this message translates to:
  /// **'E-mail'**
  String get loginHintEmail;

  /// No description provided for @loginHintPassword.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get loginHintPassword;

  /// No description provided for @loginButton.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginButton;

  /// No description provided for @loginErrorSnackbarTitle.
  ///
  /// In it, this message translates to:
  /// **'Accesso'**
  String get loginErrorSnackbarTitle;

  /// No description provided for @loginRegisterPromptTitle.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? '**
  String get loginRegisterPromptTitle;

  /// No description provided for @loginRegisterPromptSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tocca qui per crearne uno.'**
  String get loginRegisterPromptSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get loginForgotPassword;

  /// No description provided for @registerHintUsername.
  ///
  /// In it, this message translates to:
  /// **'Nome utente'**
  String get registerHintUsername;

  /// No description provided for @registerHintEmail.
  ///
  /// In it, this message translates to:
  /// **'E-mail'**
  String get registerHintEmail;

  /// No description provided for @registerHintPassword.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get registerHintPassword;

  /// No description provided for @registerButton.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get registerButton;

  /// No description provided for @registerErrorSnackbarTitle.
  ///
  /// In it, this message translates to:
  /// **'Registrazione'**
  String get registerErrorSnackbarTitle;

  /// No description provided for @registerLoginPromptTitle.
  ///
  /// In it, this message translates to:
  /// **'Hai gia un account? '**
  String get registerLoginPromptTitle;

  /// No description provided for @registerLoginPromptSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tocca qui per accedere.'**
  String get registerLoginPromptSubtitle;

  /// No description provided for @addressVerificationTitle.
  ///
  /// In it, this message translates to:
  /// **'Verifica dell\'indirizzo'**
  String get addressVerificationTitle;

  /// No description provided for @addressSavedSnackbarTitle.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo salvato'**
  String get addressSavedSnackbarTitle;

  /// No description provided for @addressSavedSnackbarBody.
  ///
  /// In it, this message translates to:
  /// **'Le tue informazioni sono state salvate.'**
  String get addressSavedSnackbarBody;

  /// No description provided for @fieldCountry.
  ///
  /// In it, this message translates to:
  /// **'Paese'**
  String get fieldCountry;

  /// No description provided for @fieldCity.
  ///
  /// In it, this message translates to:
  /// **'Citta'**
  String get fieldCity;

  /// No description provided for @fieldStreet.
  ///
  /// In it, this message translates to:
  /// **'Via e numero civico'**
  String get fieldStreet;

  /// No description provided for @fieldPostalCode.
  ///
  /// In it, this message translates to:
  /// **'CAP'**
  String get fieldPostalCode;

  /// No description provided for @formValidatorRequired.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get formValidatorRequired;

  /// No description provided for @formValidatorFillField.
  ///
  /// In it, this message translates to:
  /// **'Compila questo campo'**
  String get formValidatorFillField;

  /// No description provided for @formValidatorEmailInvalid.
  ///
  /// In it, this message translates to:
  /// **'E-mail non valida'**
  String get formValidatorEmailInvalid;

  /// No description provided for @formButtonSaving.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio…'**
  String get formButtonSaving;

  /// No description provided for @formButtonSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get formButtonSave;

  /// No description provided for @formButtonUpdating.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento…'**
  String get formButtonUpdating;

  /// No description provided for @formButtonUpdate.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get formButtonUpdate;

  /// No description provided for @personalDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get personalDataTitle;

  /// No description provided for @personalDataContactsSection.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get personalDataContactsSection;

  /// No description provided for @personalDataPhoneLabel.
  ///
  /// In it, this message translates to:
  /// **'Numero di telefono'**
  String get personalDataPhoneLabel;

  /// No description provided for @personalDataEmailLabel.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo e-mail'**
  String get personalDataEmailLabel;

  /// No description provided for @personalDataUpdatedSnackbarBody.
  ///
  /// In it, this message translates to:
  /// **'I tuoi contatti sono stati aggiornati.'**
  String get personalDataUpdatedSnackbarBody;

  /// No description provided for @securityPasswordTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna password'**
  String get securityPasswordTitle;

  /// No description provided for @securityPasswordCurrentLabel.
  ///
  /// In it, this message translates to:
  /// **'Password attuale'**
  String get securityPasswordCurrentLabel;

  /// No description provided for @securityPasswordNewLabel.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get securityPasswordNewLabel;

  /// No description provided for @securityPasswordConfirmLabel.
  ///
  /// In it, this message translates to:
  /// **'Conferma nuova password'**
  String get securityPasswordConfirmLabel;

  /// No description provided for @securityPasswordSuccessSnackbarTitle.
  ///
  /// In it, this message translates to:
  /// **'Password aggiornata'**
  String get securityPasswordSuccessSnackbarTitle;

  /// No description provided for @securityPasswordSuccessSnackbarBody.
  ///
  /// In it, this message translates to:
  /// **'La tua password e stata aggiornata con successo.'**
  String get securityPasswordSuccessSnackbarBody;

  /// No description provided for @securityPasswordUpdateButton.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna password'**
  String get securityPasswordUpdateButton;

  /// No description provided for @profileFieldLastName.
  ///
  /// In it, this message translates to:
  /// **'Cognome'**
  String get profileFieldLastName;

  /// No description provided for @profileFieldFirstName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get profileFieldFirstName;

  /// No description provided for @profileFieldBirthDate.
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get profileFieldBirthDate;

  /// No description provided for @profileBirthDateHint.
  ///
  /// In it, this message translates to:
  /// **'GG-MM-AAAA'**
  String get profileBirthDateHint;

  /// No description provided for @profileFieldNationality.
  ///
  /// In it, this message translates to:
  /// **'Nazionalita'**
  String get profileFieldNationality;

  /// No description provided for @profileFieldIdNumber.
  ///
  /// In it, this message translates to:
  /// **'N. identificativo'**
  String get profileFieldIdNumber;

  /// No description provided for @profileBirthDateFormatError.
  ///
  /// In it, this message translates to:
  /// **'Formato previsto GG-MM-AAAA'**
  String get profileBirthDateFormatError;

  /// No description provided for @homeAvailableBalance.
  ///
  /// In it, this message translates to:
  /// **'Saldo disponibile'**
  String get homeAvailableBalance;

  /// No description provided for @homeWhatToday.
  ///
  /// In it, this message translates to:
  /// **'Cosa vuoi fare oggi?'**
  String get homeWhatToday;

  /// No description provided for @homeTransactionsSection.
  ///
  /// In it, this message translates to:
  /// **'Transazioni'**
  String get homeTransactionsSection;

  /// No description provided for @homeSeeAll.
  ///
  /// In it, this message translates to:
  /// **'Vedi tutto'**
  String get homeSeeAll;

  /// No description provided for @homeEmptyTransactions.
  ///
  /// In it, this message translates to:
  /// **'Le tue transazioni appariranno qui'**
  String get homeEmptyTransactions;

  /// No description provided for @homeSuggestedForYou.
  ///
  /// In it, this message translates to:
  /// **'Suggeriti per te'**
  String get homeSuggestedForYou;

  /// No description provided for @homeFraudAlertTitle.
  ///
  /// In it, this message translates to:
  /// **'La tua sicurezza al primo posto'**
  String get homeFraudAlertTitle;

  /// No description provided for @homeFraudAlertIntro.
  ///
  /// In it, this message translates to:
  /// **'In Voltigex, la tua sicurezza è la nostra priorità assoluta. Utilizziamo metodi avanzati e tecnologie all\'avanguardia per garantire qualità, sicurezza e protezione delle tue transazioni.'**
  String get homeFraudAlertIntro;

  /// No description provided for @homeFraudAlertFeature1Title.
  ///
  /// In it, this message translates to:
  /// **'Rilevamento avanzato delle frodi'**
  String get homeFraudAlertFeature1Title;

  /// No description provided for @homeFraudAlertFeature1Body.
  ///
  /// In it, this message translates to:
  /// **'Il nostro sistema di intelligenza artificiale analizza in tempo reale tutte le transazioni per individuare e prevenire tentativi di truffa prima che si verifichino.'**
  String get homeFraudAlertFeature1Body;

  /// No description provided for @homeFraudAlertFeature2Title.
  ///
  /// In it, this message translates to:
  /// **'Crittografia di livello bancario'**
  String get homeFraudAlertFeature2Title;

  /// No description provided for @homeFraudAlertFeature2Body.
  ///
  /// In it, this message translates to:
  /// **'Tutti i tuoi dati sono protetti con crittografia AES-256, lo stesso standard usato dalle istituzioni finanziarie più sicure al mondo.'**
  String get homeFraudAlertFeature2Body;

  /// No description provided for @homeFraudAlertFeature3Title.
  ///
  /// In it, this message translates to:
  /// **'Sorveglianza 24/7'**
  String get homeFraudAlertFeature3Title;

  /// No description provided for @homeFraudAlertFeature3Body.
  ///
  /// In it, this message translates to:
  /// **'Il nostro team di sicurezza monitora il tuo conto 24 ore su 24, 7 giorni su 7, per rilevare attività sospette e proteggerti dalle frodi.'**
  String get homeFraudAlertFeature3Body;

  /// No description provided for @homeFraudAlertCta.
  ///
  /// In it, this message translates to:
  /// **'Contatta l\'assistenza'**
  String get homeFraudAlertCta;

  /// No description provided for @homeFraudAlertBadge.
  ///
  /// In it, this message translates to:
  /// **'Sicurezza'**
  String get homeFraudAlertBadge;

  /// No description provided for @homePromoTitle.
  ///
  /// In it, this message translates to:
  /// **'Voltigex Days!'**
  String get homePromoTitle;

  /// No description provided for @homePromoSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Approfitta delle nostre offerte speciali'**
  String get homePromoSubtitle;

  /// No description provided for @homeTooltipChat.
  ///
  /// In it, this message translates to:
  /// **'Chat'**
  String get homeTooltipChat;

  /// No description provided for @homeTooltipNotifications.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get homeTooltipNotifications;

  /// No description provided for @homeServiceDepositTitle.
  ///
  /// In it, this message translates to:
  /// **'Deposito'**
  String get homeServiceDepositTitle;

  /// No description provided for @homeServiceDepositDescription.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi denaro al tuo conto'**
  String get homeServiceDepositDescription;

  /// No description provided for @homeServiceTransferTitle.
  ///
  /// In it, this message translates to:
  /// **'Bonifico'**
  String get homeServiceTransferTitle;

  /// No description provided for @homeServiceTransferDescription.
  ///
  /// In it, this message translates to:
  /// **'Invia denaro dal tuo conto'**
  String get homeServiceTransferDescription;

  /// No description provided for @homeServiceCardsTitle.
  ///
  /// In it, this message translates to:
  /// **'Carte'**
  String get homeServiceCardsTitle;

  /// No description provided for @homeServiceCardsDescription.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le tue carte di credito e debito'**
  String get homeServiceCardsDescription;

  /// No description provided for @homeServiceSettingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get homeServiceSettingsTitle;

  /// No description provided for @homeServiceSettingsDescription.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le tue impostazioni'**
  String get homeServiceSettingsDescription;

  /// No description provided for @homeSuggestionInsurance.
  ///
  /// In it, this message translates to:
  /// **'Assicurazioni'**
  String get homeSuggestionInsurance;

  /// No description provided for @homeSuggestionCredits.
  ///
  /// In it, this message translates to:
  /// **'Prestiti'**
  String get homeSuggestionCredits;

  /// No description provided for @homeSuggestionSavings.
  ///
  /// In it, this message translates to:
  /// **'Risparmi'**
  String get homeSuggestionSavings;

  /// No description provided for @homeSuggestionInvestments.
  ///
  /// In it, this message translates to:
  /// **'Investimenti'**
  String get homeSuggestionInvestments;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCards.
  ///
  /// In it, this message translates to:
  /// **'Carte'**
  String get navCards;

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

  /// No description provided for @navSettingsTooltip.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettingsTooltip;

  /// No description provided for @navSupport.
  ///
  /// In it, this message translates to:
  /// **'Supporto'**
  String get navSupport;

  /// No description provided for @chatTabPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Apri una conversazione dalla home, dall\'aiuto bonifico o dai messaggi.'**
  String get chatTabPlaceholder;

  /// No description provided for @settingsNamePlaceholder.
  ///
  /// In it, this message translates to:
  /// **'…'**
  String get settingsNamePlaceholder;

  /// No description provided for @notificationsPageTitle.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notificationsPageTitle;

  /// No description provided for @notificationsAllCaughtUp.
  ///
  /// In it, this message translates to:
  /// **'Sei aggiornato'**
  String get notificationsAllCaughtUp;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Quando riceverai avvisi o messaggi importanti, appariranno qui.'**
  String get notificationsEmptyHint;

  /// No description provided for @transfersHistoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico transazioni'**
  String get transfersHistoryTitle;

  /// No description provided for @transfersHistoryEmpty.
  ///
  /// In it, this message translates to:
  /// **'Le tue transazioni appariranno qui una volta completate'**
  String get transfersHistoryEmpty;

  /// No description provided for @transferSeeMore.
  ///
  /// In it, this message translates to:
  /// **'Vedi altro'**
  String get transferSeeMore;

  /// No description provided for @transferPageTitle.
  ///
  /// In it, this message translates to:
  /// **'Bonifici'**
  String get transferPageTitle;

  /// No description provided for @transferDoTransfer.
  ///
  /// In it, this message translates to:
  /// **'Esegui un bonifico'**
  String get transferDoTransfer;

  /// No description provided for @transferHistoryMenu.
  ///
  /// In it, this message translates to:
  /// **'Storico bonifici'**
  String get transferHistoryMenu;

  /// No description provided for @cardsHistoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico carte'**
  String get cardsHistoryTitle;

  /// No description provided for @cardsHistoryEmpty.
  ///
  /// In it, this message translates to:
  /// **'Tutte le transazioni della carta verranno mostrate qui'**
  String get cardsHistoryEmpty;

  /// No description provided for @legalPageTitle.
  ///
  /// In it, this message translates to:
  /// **'Documentazione legale'**
  String get legalPageTitle;

  /// No description provided for @legalSectionBrand.
  ///
  /// In it, this message translates to:
  /// **'Voltigex'**
  String get legalSectionBrand;

  /// No description provided for @legalRowTermsOfUse.
  ///
  /// In it, this message translates to:
  /// **'Termini di utilizzo'**
  String get legalRowTermsOfUse;

  /// No description provided for @legalRowSecurityPolicy.
  ///
  /// In it, this message translates to:
  /// **'Politica di sicurezza'**
  String get legalRowSecurityPolicy;

  /// No description provided for @legalRowPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get legalRowPrivacy;

  /// No description provided for @legalWebLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare il documento. Controlla la connessione.'**
  String get legalWebLoadError;

  /// No description provided for @legalWebLoadErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Documento'**
  String get legalWebLoadErrorTitle;

  /// No description provided for @legalAppVersionLine.
  ///
  /// In it, this message translates to:
  /// **'Versione dell\'app\n{version}'**
  String legalAppVersionLine(String version);

  /// No description provided for @contactsPageTitle.
  ///
  /// In it, this message translates to:
  /// **'Contatti'**
  String get contactsPageTitle;

  /// No description provided for @contactsEmptySearch.
  ///
  /// In it, this message translates to:
  /// **'Nessun contatto trovato'**
  String get contactsEmptySearch;

  /// No description provided for @contactsEmptyState.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora contatti.\nTocca il pulsante in basso per aggiungerne uno.'**
  String get contactsEmptyState;

  /// No description provided for @contactsAddTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi contatto'**
  String get contactsAddTitle;

  /// No description provided for @contactsEmailHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci l\'e-mail del contatto'**
  String get contactsEmailHint;

  /// No description provided for @contactsAddButton.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get contactsAddButton;

  /// No description provided for @conversationsSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca un contatto…'**
  String get conversationsSearchHint;

  /// No description provided for @conversationsClearTooltip.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get conversationsClearTooltip;

  /// No description provided for @conversationsTitleSupport.
  ///
  /// In it, this message translates to:
  /// **'Supporto'**
  String get conversationsTitleSupport;

  /// No description provided for @conversationsTitleMessages.
  ///
  /// In it, this message translates to:
  /// **'Messaggi'**
  String get conversationsTitleMessages;

  /// No description provided for @conversationsLogoutSemantics.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get conversationsLogoutSemantics;

  /// No description provided for @conversationsNoUserFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun utente trovato.'**
  String get conversationsNoUserFound;

  /// No description provided for @conversationsEmptyAdmin.
  ///
  /// In it, this message translates to:
  /// **'Nessuna conversazione al momento. Le chat con i tuoi clienti appariranno qui.'**
  String get conversationsEmptyAdmin;

  /// No description provided for @conversationsEmptyClient.
  ///
  /// In it, this message translates to:
  /// **'Nessuna conversazione al momento.'**
  String get conversationsEmptyClient;

  /// No description provided for @conversationsContactSupport.
  ///
  /// In it, this message translates to:
  /// **'Contatta il supporto'**
  String get conversationsContactSupport;

  /// No description provided for @conversationsSupportError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile contattare il supporto.'**
  String get conversationsSupportError;

  /// No description provided for @conversationsSupportSnackTitle.
  ///
  /// In it, this message translates to:
  /// **'Supporto'**
  String get conversationsSupportSnackTitle;

  /// No description provided for @conversationsNoSearchResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato per questa ricerca.'**
  String get conversationsNoSearchResults;

  /// No description provided for @messagePreviewImage.
  ///
  /// In it, this message translates to:
  /// **'Immagine…'**
  String get messagePreviewImage;

  /// No description provided for @messagePreviewAudio.
  ///
  /// In it, this message translates to:
  /// **'Audio…'**
  String get messagePreviewAudio;

  /// No description provided for @messagePreviewVideo.
  ///
  /// In it, this message translates to:
  /// **'Video…'**
  String get messagePreviewVideo;

  /// No description provided for @messagePreviewDocument.
  ///
  /// In it, this message translates to:
  /// **'Documento…'**
  String get messagePreviewDocument;

  /// No description provided for @messagePreviewMedia.
  ///
  /// In it, this message translates to:
  /// **'Media…'**
  String get messagePreviewMedia;

  /// No description provided for @chatFileSnackTitle.
  ///
  /// In it, this message translates to:
  /// **'File'**
  String get chatFileSnackTitle;

  /// No description provided for @chatFileOpenError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il file.'**
  String get chatFileOpenError;

  /// No description provided for @chatNetworkSnackTitle.
  ///
  /// In it, this message translates to:
  /// **'Rete'**
  String get chatNetworkSnackTitle;

  /// No description provided for @chatNetworkErrorBody.
  ///
  /// In it, this message translates to:
  /// **'Controlla la connessione di rete.'**
  String get chatNetworkErrorBody;

  /// No description provided for @transferProgressTitle.
  ///
  /// In it, this message translates to:
  /// **'Bonifico in elaborazione'**
  String get transferProgressTitle;

  /// No description provided for @transferProgressSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo bonifico e in elaborazione...'**
  String get transferProgressSubtitle;

  /// No description provided for @transferProgressWait.
  ///
  /// In it, this message translates to:
  /// **'Attendi, non chiudere questa finestra.'**
  String get transferProgressWait;

  /// No description provided for @transferTabRecent.
  ///
  /// In it, this message translates to:
  /// **'Recenti'**
  String get transferTabRecent;

  /// No description provided for @transferTabNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo bonifico'**
  String get transferTabNew;

  /// No description provided for @transferUsefulInfoTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni utili'**
  String get transferUsefulInfoTitle;

  /// No description provided for @transferInfoDelay.
  ///
  /// In it, this message translates to:
  /// **'I bonifici vengono generalmente elaborati entro 24-48 ore lavorative.'**
  String get transferInfoDelay;

  /// No description provided for @transferInfoScheduled.
  ///
  /// In it, this message translates to:
  /// **'Per i bonifici programmati, assicurati di avere fondi disponibili alla data prevista.'**
  String get transferInfoScheduled;

  /// No description provided for @transferInfoIban.
  ///
  /// In it, this message translates to:
  /// **'Verifica sempre l\'IBAN del beneficiario prima di confermare il bonifico.'**
  String get transferInfoIban;

  /// No description provided for @transferInfoReceipt.
  ///
  /// In it, this message translates to:
  /// **'Una ricevuta del bonifico sara disponibile via e-mail.'**
  String get transferInfoReceipt;

  /// No description provided for @transferHelpTitle.
  ///
  /// In it, this message translates to:
  /// **'Hai bisogno di aiuto per questo bonifico?'**
  String get transferHelpTitle;

  /// No description provided for @transferHelpBody.
  ///
  /// In it, this message translates to:
  /// **'Il nostro servizio clienti e disponibile dal lunedi al venerdi, dalle 9:00 alle 18:00. Tocca per aprire la chat.'**
  String get transferHelpBody;

  /// No description provided for @transferInsufficientTitle.
  ///
  /// In it, this message translates to:
  /// **'Saldo insufficiente'**
  String get transferInsufficientTitle;

  /// No description provided for @transferInsufficientBody.
  ///
  /// In it, this message translates to:
  /// **'Questo bonifico supera il tuo saldo disponibile. Riduci l\'importo o aggiungi fondi prima di riprovare.'**
  String get transferInsufficientBody;

  /// No description provided for @transferSupportTitle.
  ///
  /// In it, this message translates to:
  /// **'Contatta il supporto'**
  String get transferSupportTitle;

  /// No description provided for @transferFailureBodyNoCode.
  ///
  /// In it, this message translates to:
  /// **'Si e verificato un problema e il tuo bonifico non e stato completato. Contatta l\'amministratore descrivendo la situazione: potra sbloccare la pratica.'**
  String get transferFailureBodyNoCode;

  /// No description provided for @transferFailureBodyWithCode.
  ///
  /// In it, this message translates to:
  /// **'Si e verificato un problema e il tuo bonifico non e stato completato. Comunica il codice {code} al tuo amministratore per una risoluzione rapida.'**
  String transferFailureBodyWithCode(String code);

  /// No description provided for @transferModalClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get transferModalClose;

  /// No description provided for @transferCopyCode.
  ///
  /// In it, this message translates to:
  /// **'Copia codice'**
  String get transferCopyCode;

  /// No description provided for @transferSnackTitle.
  ///
  /// In it, this message translates to:
  /// **'Bonifico'**
  String get transferSnackTitle;

  /// No description provided for @transferSwitchTabForForm.
  ///
  /// In it, this message translates to:
  /// **'Passa alla scheda «{tabName}» per inserire o completare il bonifico.'**
  String transferSwitchTabForForm(String tabName);

  /// No description provided for @transferInvalidAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo non valido'**
  String get transferInvalidAmount;

  /// No description provided for @transferRetryInvalid.
  ///
  /// In it, this message translates to:
  /// **'Tentativo non valido, riapri dalla lista.'**
  String get transferRetryInvalid;

  /// No description provided for @transferFinalize.
  ///
  /// In it, this message translates to:
  /// **'Finalizza'**
  String get transferFinalize;

  /// No description provided for @transferNoRecentRecipients.
  ///
  /// In it, this message translates to:
  /// **'Nessun beneficiario recente. Usa «{tabName}» per un bonifico SEPA.'**
  String transferNoRecentRecipients(String tabName);

  /// No description provided for @transferFieldLastName.
  ///
  /// In it, this message translates to:
  /// **'Cognome'**
  String get transferFieldLastName;

  /// No description provided for @transferHintLastName.
  ///
  /// In it, this message translates to:
  /// **'Cognome del beneficiario'**
  String get transferHintLastName;

  /// No description provided for @transferFieldFirstName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get transferFieldFirstName;

  /// No description provided for @transferHintFirstName.
  ///
  /// In it, this message translates to:
  /// **'Nome del beneficiario'**
  String get transferHintFirstName;

  /// No description provided for @transferFieldBankName.
  ///
  /// In it, this message translates to:
  /// **'Nome banca'**
  String get transferFieldBankName;

  /// No description provided for @transferHintBankName.
  ///
  /// In it, this message translates to:
  /// **'Nome banca'**
  String get transferHintBankName;

  /// No description provided for @transferFieldIban.
  ///
  /// In it, this message translates to:
  /// **'IBAN'**
  String get transferFieldIban;

  /// No description provided for @transferHintIban.
  ///
  /// In it, this message translates to:
  /// **'FR76 XXXX XXXX XXXX XXXX XXXX XXX'**
  String get transferHintIban;

  /// No description provided for @transferIbanInvalid.
  ///
  /// In it, this message translates to:
  /// **'IBAN non valido'**
  String get transferIbanInvalid;

  /// No description provided for @transferFieldBic.
  ///
  /// In it, this message translates to:
  /// **'BIC / SWIFT'**
  String get transferFieldBic;

  /// No description provided for @transferHintBic.
  ///
  /// In it, this message translates to:
  /// **'BNPAFRPPXXX (opzionale)'**
  String get transferHintBic;

  /// No description provided for @transferFieldAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get transferFieldAmount;

  /// No description provided for @transferHintAmount.
  ///
  /// In it, this message translates to:
  /// **'0.00'**
  String get transferHintAmount;

  /// No description provided for @transferFieldValidationCode.
  ///
  /// In it, this message translates to:
  /// **'Codice di validazione'**
  String get transferFieldValidationCode;

  /// No description provided for @transferHintValidationCode.
  ///
  /// In it, this message translates to:
  /// **'Codice ricevuto'**
  String get transferHintValidationCode;

  /// No description provided for @transferValidationCodeError.
  ///
  /// In it, this message translates to:
  /// **'Verifica il codice inserito'**
  String get transferValidationCodeError;

  /// No description provided for @transferSending.
  ///
  /// In it, this message translates to:
  /// **'Invio in corso…'**
  String get transferSending;

  /// No description provided for @transferFinalizeButton.
  ///
  /// In it, this message translates to:
  /// **'Completa bonifico'**
  String get transferFinalizeButton;

  /// No description provided for @transferSubmitButton.
  ///
  /// In it, this message translates to:
  /// **'Invia bonifico'**
  String get transferSubmitButton;

  /// No description provided for @transferPageHeading.
  ///
  /// In it, this message translates to:
  /// **'Esegui un bonifico'**
  String get transferPageHeading;

  /// No description provided for @transferResetAll.
  ///
  /// In it, this message translates to:
  /// **'Reimposta tutto'**
  String get transferResetAll;

  /// No description provided for @cardsSnackTitle.
  ///
  /// In it, this message translates to:
  /// **'Carta'**
  String get cardsSnackTitle;

  /// No description provided for @cardsCopiedTitle.
  ///
  /// In it, this message translates to:
  /// **'Copiato'**
  String get cardsCopiedTitle;

  /// No description provided for @cardsCopiedBody.
  ///
  /// In it, this message translates to:
  /// **'{fieldName} copiato'**
  String cardsCopiedBody(String fieldName);

  /// No description provided for @cardsAddMoneyTitle.
  ///
  /// In it, this message translates to:
  /// **'Prima di aggiungere denaro'**
  String get cardsAddMoneyTitle;

  /// No description provided for @cardsAddMoneyBody.
  ///
  /// In it, this message translates to:
  /// **'I fondi sulla carta possono, in alcuni casi, essere prelevati o inviati a un altro conto. Dipende dalle normative e dalle leggi vigenti nel tuo paese o regione.'**
  String get cardsAddMoneyBody;

  /// No description provided for @cardsUnderstood.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get cardsUnderstood;

  /// No description provided for @cardsDetailsTitle.
  ///
  /// In it, this message translates to:
  /// **'Dettagli carta'**
  String get cardsDetailsTitle;

  /// No description provided for @cardsFieldNumber.
  ///
  /// In it, this message translates to:
  /// **'Numero carta'**
  String get cardsFieldNumber;

  /// No description provided for @cardsFieldCvc.
  ///
  /// In it, this message translates to:
  /// **'CVC'**
  String get cardsFieldCvc;

  /// No description provided for @cardsFieldExpiry.
  ///
  /// In it, this message translates to:
  /// **'Data di scadenza'**
  String get cardsFieldExpiry;

  /// No description provided for @cardsCopyTooltip.
  ///
  /// In it, this message translates to:
  /// **'Copia'**
  String get cardsCopyTooltip;

  /// No description provided for @cardsUnfreeze.
  ///
  /// In it, this message translates to:
  /// **'Sblocca carta'**
  String get cardsUnfreeze;

  /// No description provided for @cardsFreeze.
  ///
  /// In it, this message translates to:
  /// **'Blocca carta'**
  String get cardsFreeze;

  /// No description provided for @cardsActivateDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Attiva la tua carta'**
  String get cardsActivateDialogTitle;

  /// No description provided for @cardsActivateTypeLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo di carta'**
  String get cardsActivateTypeLabel;

  /// No description provided for @cardsActivateTypeRequired.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un tipo di carta.'**
  String get cardsActivateTypeRequired;

  /// No description provided for @cardsActivateAmountLabel.
  ///
  /// In it, this message translates to:
  /// **'Importo associato'**
  String get cardsActivateAmountLabel;

  /// No description provided for @cardsHolderLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome titolare'**
  String get cardsHolderLabel;

  /// No description provided for @cardsHolderHint.
  ///
  /// In it, this message translates to:
  /// **'JEAN DUPONT'**
  String get cardsHolderHint;

  /// No description provided for @cardsNumberLabel.
  ///
  /// In it, this message translates to:
  /// **'Numero della carta'**
  String get cardsNumberLabel;

  /// No description provided for @cardsNumberHint.
  ///
  /// In it, this message translates to:
  /// **'4810 0012 3456 7840'**
  String get cardsNumberHint;

  /// No description provided for @cardsFieldMandatory.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get cardsFieldMandatory;

  /// No description provided for @cardsNumberInvalid.
  ///
  /// In it, this message translates to:
  /// **'Numero non valido'**
  String get cardsNumberInvalid;

  /// No description provided for @cardsExpiryLabel.
  ///
  /// In it, this message translates to:
  /// **'Data di scadenza'**
  String get cardsExpiryLabel;

  /// No description provided for @cardsExpiryHint.
  ///
  /// In it, this message translates to:
  /// **'MM/AA'**
  String get cardsExpiryHint;

  /// No description provided for @cardsCvvLabel.
  ///
  /// In it, this message translates to:
  /// **'CVV'**
  String get cardsCvvLabel;

  /// No description provided for @cardsCvvHint.
  ///
  /// In it, this message translates to:
  /// **'123'**
  String get cardsCvvHint;

  /// No description provided for @cardsActivateButton.
  ///
  /// In it, this message translates to:
  /// **'Attiva carta'**
  String get cardsActivateButton;

  /// No description provided for @cardsNone.
  ///
  /// In it, this message translates to:
  /// **'Nessuna carta'**
  String get cardsNone;

  /// No description provided for @cardsBalanceLabel.
  ///
  /// In it, this message translates to:
  /// **'Saldo carta'**
  String get cardsBalanceLabel;

  /// No description provided for @cardsInfoTooltip.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get cardsInfoTooltip;

  /// No description provided for @cardsTransactionsTitle.
  ///
  /// In it, this message translates to:
  /// **'Transazioni carta'**
  String get cardsTransactionsTitle;

  /// No description provided for @cardsTransactionsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Tutte le transazioni della carta appariranno qui'**
  String get cardsTransactionsEmpty;

  /// No description provided for @cardsBrandVoltigex.
  ///
  /// In it, this message translates to:
  /// **'VOLTIGEX'**
  String get cardsBrandVoltigex;

  /// No description provided for @cardsTierGold.
  ///
  /// In it, this message translates to:
  /// **'Gold'**
  String get cardsTierGold;

  /// No description provided for @cardsTierDiamond.
  ///
  /// In it, this message translates to:
  /// **'Diamond'**
  String get cardsTierDiamond;

  /// No description provided for @cardsTierPlatinum.
  ///
  /// In it, this message translates to:
  /// **'Platinum'**
  String get cardsTierPlatinum;

  /// No description provided for @cardsActionAddMoney.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi denaro'**
  String get cardsActionAddMoney;

  /// No description provided for @cardsActionSeeDetails.
  ///
  /// In it, this message translates to:
  /// **'Vedi dettagli'**
  String get cardsActionSeeDetails;

  /// No description provided for @cardsActivationDemandSuccessMessage.
  ///
  /// In it, this message translates to:
  /// **'Richiesta di attivazione inviata.'**
  String get cardsActivationDemandSuccessMessage;

  /// No description provided for @cardsActivationDemandErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Anfrage fehlgeschlagen. Bitte überprüfen Sie die eingegebenen Informationen und versuchen Sie es erneut.'**
  String get cardsActivationDemandErrorMessage;

  /// No description provided for @cardsUnfreezeForDetails.
  ///
  /// In it, this message translates to:
  /// **'Sblocca la carta per vedere i dettagli'**
  String get cardsUnfreezeForDetails;

  /// No description provided for @cardsMore.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get cardsMore;

  /// No description provided for @notificationChannelMessagesTitle.
  ///
  /// In it, this message translates to:
  /// **'Messaggi'**
  String get notificationChannelMessagesTitle;

  /// No description provided for @notificationChannelMessagesDescription.
  ///
  /// In it, this message translates to:
  /// **'Notifiche per messaggi privati'**
  String get notificationChannelMessagesDescription;

  /// No description provided for @chatMessageInputHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi il tuo messaggio'**
  String get chatMessageInputHint;

  /// No description provided for @chatJumpToLatestTooltip.
  ///
  /// In it, this message translates to:
  /// **'Vai all\'ultimo messaggio'**
  String get chatJumpToLatestTooltip;

  /// No description provided for @chatSyncInProgress.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione in corso...'**
  String get chatSyncInProgress;

  /// No description provided for @chatSyncNoInternet.
  ///
  /// In it, this message translates to:
  /// **'Sembra che tu non sia connesso a internet'**
  String get chatSyncNoInternet;

  /// No description provided for @chatSyncUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione non disponibile'**
  String get chatSyncUnavailable;

  /// No description provided for @chatFirstMessagePrompt.
  ///
  /// In it, this message translates to:
  /// **'Pronto per il tuo primo messaggio?'**
  String get chatFirstMessagePrompt;

  /// No description provided for @chatNoDataAvailable.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato disponibile'**
  String get chatNoDataAvailable;

  /// No description provided for @chatDateToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get chatDateToday;

  /// No description provided for @chatDateYesterday.
  ///
  /// In it, this message translates to:
  /// **'Ieri'**
  String get chatDateYesterday;

  /// No description provided for @chatDailyQuestionPrefix.
  ///
  /// In it, this message translates to:
  /// **'Domanda del giorno:'**
  String get chatDailyQuestionPrefix;

  /// No description provided for @chatOfflineBanner.
  ///
  /// In it, this message translates to:
  /// **'Sei offline - I dati potrebbero non essere aggiornati'**
  String get chatOfflineBanner;

  /// No description provided for @chatPdfFileSemantics.
  ///
  /// In it, this message translates to:
  /// **'File PDF'**
  String get chatPdfFileSemantics;

  /// No description provided for @chatSendRetryTooltip.
  ///
  /// In it, this message translates to:
  /// **'Riprova invio'**
  String get chatSendRetryTooltip;

  /// No description provided for @chatMediaCamera.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera'**
  String get chatMediaCamera;

  /// No description provided for @chatMediaImage.
  ///
  /// In it, this message translates to:
  /// **'Immagine'**
  String get chatMediaImage;

  /// No description provided for @chatMediaGallery.
  ///
  /// In it, this message translates to:
  /// **'Galleria'**
  String get chatMediaGallery;

  /// No description provided for @chatMediaDocument.
  ///
  /// In it, this message translates to:
  /// **'Documento'**
  String get chatMediaDocument;

  /// No description provided for @chatMediaCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get chatMediaCancel;

  /// No description provided for @chatErrorNoAppFound.
  ///
  /// In it, this message translates to:
  /// **'Nessuna app disponibile per aprire questo file.'**
  String get chatErrorNoAppFound;

  /// No description provided for @chatErrorUnsupportedFormat.
  ///
  /// In it, this message translates to:
  /// **'Questo formato di file non e supportato.'**
  String get chatErrorUnsupportedFormat;

  /// No description provided for @authErrorRegisterFailed.
  ///
  /// In it, this message translates to:
  /// **'Creazione account non riuscita'**
  String get authErrorRegisterFailed;

  /// No description provided for @authErrorLoginFailed.
  ///
  /// In it, this message translates to:
  /// **'Accesso non riuscito'**
  String get authErrorLoginFailed;

  /// No description provided for @authErrorLogoutFailed.
  ///
  /// In it, this message translates to:
  /// **'Disconnessione non riuscita'**
  String get authErrorLogoutFailed;

  /// No description provided for @profileErrorContactRequired.
  ///
  /// In it, this message translates to:
  /// **'Tutti i campi sono obbligatori.'**
  String get profileErrorContactRequired;

  /// No description provided for @profileErrorInvalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Indirizzo e-mail non valido.'**
  String get profileErrorInvalidEmail;

  /// No description provided for @profileErrorIdentityRequired.
  ///
  /// In it, this message translates to:
  /// **'Nome e cognome sono obbligatori.'**
  String get profileErrorIdentityRequired;

  /// No description provided for @profileErrorPasswordsMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono.'**
  String get profileErrorPasswordsMismatch;

  /// No description provided for @profileErrorPasswordWeak.
  ///
  /// In it, this message translates to:
  /// **'La password deve contenere almeno 8 caratteri, con maiuscola, minuscola, numero e carattere speciale.'**
  String get profileErrorPasswordWeak;

  /// No description provided for @chatErrorLoadFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare i messaggi'**
  String get chatErrorLoadFailed;

  /// No description provided for @chatErrorReadUpdateFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare i messaggi letti'**
  String get chatErrorReadUpdateFailed;

  /// No description provided for @profileErrorAddressRequired.
  ///
  /// In it, this message translates to:
  /// **'Compila tutti i campi dell\'indirizzo.'**
  String get profileErrorAddressRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
