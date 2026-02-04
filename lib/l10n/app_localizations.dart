import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ペラペラ'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your device language.'**
  String get languageSystemSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblemTitle;

  /// No description provided for @reportProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the feedback form.'**
  String get reportProblemSubtitle;

  /// No description provided for @reportProblemError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get reportProblemError;

  /// No description provided for @resetStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics'**
  String get resetStatsTitle;

  /// No description provided for @resetStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved accuracy data.'**
  String get resetStatsSubtitle;

  /// No description provided for @resetStatsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics?'**
  String get resetStatsConfirmTitle;

  /// No description provided for @resetStatsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your progress for all rules.'**
  String get resetStatsConfirmBody;

  /// No description provided for @resetStatsConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetStatsConfirmButton;

  /// No description provided for @resetStatsCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetStatsCancelButton;

  /// No description provided for @resetStatsDone.
  ///
  /// In en, this message translates to:
  /// **'Statistics reset.'**
  String get resetStatsDone;

  /// No description provided for @chooseRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a rule'**
  String get chooseRuleTitle;

  /// No description provided for @chooseRuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a rule and start the session.'**
  String get chooseRuleSubtitle;

  /// No description provided for @chooseRuleHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a rule'**
  String get chooseRuleHint;

  /// No description provided for @chooseRuleUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Select an available rule to start.'**
  String get chooseRuleUnavailableHint;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startSession;

  /// No description provided for @exitSession.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitSession;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @showSolutionButton.
  ///
  /// In en, this message translates to:
  /// **'Show solution'**
  String get showSolutionButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Show solution\" and then choose \"Correct\" or \"Wrong\".'**
  String get answerHint;

  /// No description provided for @preparingFirstQuestion.
  ///
  /// In en, this message translates to:
  /// **'Preparing the first question.'**
  String get preparingFirstQuestion;

  /// No description provided for @selectRuleToBegin.
  ///
  /// In en, this message translates to:
  /// **'Select a rule to begin.'**
  String get selectRuleToBegin;

  /// No description provided for @statsButton.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsButton;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get statsTitle;

  /// No description provided for @statsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsRangeWeek;

  /// No description provided for @statsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsRangeMonth;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get statsLastWeek;

  /// No description provided for @statsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsThisMonth;

  /// No description provided for @statsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get statsLastMonth;

  /// No description provided for @statsAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsAccuracyLabel;

  /// No description provided for @statsLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get statsLast30Days;

  /// No description provided for @statsCorrectOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Correct: {correct}/{total}'**
  String statsCorrectOfTotal(Object correct, Object total);

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get statsNoData;

  /// No description provided for @statsTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress trend'**
  String get statsTrendTitle;

  /// No description provided for @statsTierS.
  ///
  /// In en, this message translates to:
  /// **'TIER S'**
  String get statsTierS;

  /// No description provided for @statsTierA.
  ///
  /// In en, this message translates to:
  /// **'TIER A'**
  String get statsTierA;

  /// No description provided for @statsTierB.
  ///
  /// In en, this message translates to:
  /// **'TIER B'**
  String get statsTierB;

  /// No description provided for @statsTierC.
  ///
  /// In en, this message translates to:
  /// **'TIER C'**
  String get statsTierC;

  /// No description provided for @statsTierD.
  ///
  /// In en, this message translates to:
  /// **'TIER D'**
  String get statsTierD;

  /// No description provided for @statsTierFail.
  ///
  /// In en, this message translates to:
  /// **'FAIL'**
  String get statsTierFail;

  /// No description provided for @answerCorrectButton.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get answerCorrectButton;

  /// No description provided for @answerWrongButton.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get answerWrongButton;

  /// No description provided for @proPill.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get proPill;

  /// No description provided for @proBannerText.
  ///
  /// In en, this message translates to:
  /// **'Pro: unlock locked rules and new verbs.'**
  String get proBannerText;

  /// No description provided for @proBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get proBannerCta;

  /// No description provided for @proUpsellSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Go Pro to unlock locked rules and new verbs.'**
  String get proUpsellSnackbar;

  /// No description provided for @proBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro benefits'**
  String get proBenefitsTitle;

  /// No description provided for @proBenefitRules.
  ///
  /// In en, this message translates to:
  /// **'Unlock all locked rules.'**
  String get proBenefitRules;

  /// No description provided for @proBenefitVerbs.
  ///
  /// In en, this message translates to:
  /// **'Get the full premium verb list.'**
  String get proBenefitVerbs;

  /// No description provided for @proBenefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Support the development of PeraPera.'**
  String get proBenefitSupport;

  /// No description provided for @proRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro rules'**
  String get proRulesTitle;

  /// No description provided for @proVerbsTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium verbs'**
  String get proVerbsTitle;

  /// No description provided for @proOneTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get proOneTimeLabel;

  /// No description provided for @proRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get proRestoreButton;

  /// No description provided for @proStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable. Try again later.'**
  String get proStoreUnavailable;

  /// No description provided for @proPurchaseInProgress.
  ///
  /// In en, this message translates to:
  /// **'Purchase in progress...'**
  String get proPurchaseInProgress;

  /// No description provided for @proPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the purchase.'**
  String get proPurchaseError;

  /// No description provided for @proAlreadyUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Pro is already active on this device.'**
  String get proAlreadyUnlocked;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick guide'**
  String get tutorialTitle;

  /// No description provided for @tutorialLine1.
  ///
  /// In en, this message translates to:
  /// **'Choose a grammar rule and practice.'**
  String get tutorialLine1;

  /// No description provided for @tutorialLine2.
  ///
  /// In en, this message translates to:
  /// **'Think of the answer, then tap \"Show solution\" and rate yourself.'**
  String get tutorialLine2;

  /// No description provided for @tutorialButton.
  ///
  /// In en, this message translates to:
  /// **'Ok, let\'s go'**
  String get tutorialButton;

  /// No description provided for @badgeFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get badgeFree;

  /// No description provided for @badgePro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get badgePro;

  /// No description provided for @modeTe.
  ///
  /// In en, this message translates to:
  /// **'~te form'**
  String get modeTe;

  /// No description provided for @modeTa.
  ///
  /// In en, this message translates to:
  /// **'~ta form'**
  String get modeTa;

  /// No description provided for @modeNai.
  ///
  /// In en, this message translates to:
  /// **'~nai form'**
  String get modeNai;

  /// No description provided for @modeMasu.
  ///
  /// In en, this message translates to:
  /// **'~masu form'**
  String get modeMasu;

  /// No description provided for @modePotential.
  ///
  /// In en, this message translates to:
  /// **'~potential form'**
  String get modePotential;

  /// No description provided for @modeMix.
  ///
  /// In en, this message translates to:
  /// **'random mix'**
  String get modeMix;

  /// No description provided for @modeKamo.
  ///
  /// In en, this message translates to:
  /// **'~kamo form'**
  String get modeKamo;

  /// No description provided for @ruleShi.
  ///
  /// In en, this message translates to:
  /// **'~shi'**
  String get ruleShi;

  /// No description provided for @ruleSouDesu.
  ///
  /// In en, this message translates to:
  /// **'~sou desu'**
  String get ruleSouDesu;

  /// No description provided for @ruleTeMiru.
  ///
  /// In en, this message translates to:
  /// **'~te miru'**
  String get ruleTeMiru;

  /// No description provided for @ruleNara.
  ///
  /// In en, this message translates to:
  /// **'Nara'**
  String get ruleNara;

  /// No description provided for @ruleHoshi.
  ///
  /// In en, this message translates to:
  /// **'hoshi'**
  String get ruleHoshi;

  /// No description provided for @ruleAgeruKureruMorau.
  ///
  /// In en, this message translates to:
  /// **'ageru/kureru/morau'**
  String get ruleAgeruKureruMorau;

  /// No description provided for @ruleTara.
  ///
  /// In en, this message translates to:
  /// **'~tara'**
  String get ruleTara;

  /// No description provided for @ruleNumberMoShika.
  ///
  /// In en, this message translates to:
  /// **'number + mo / shika'**
  String get ruleNumberMoShika;

  /// No description provided for @ruleVolitional.
  ///
  /// In en, this message translates to:
  /// **'Volitional'**
  String get ruleVolitional;

  /// No description provided for @ruleVolitionalToOmotte.
  ///
  /// In en, this message translates to:
  /// **'Volitional + to omotte'**
  String get ruleVolitionalToOmotte;

  /// No description provided for @ruleTeOku.
  ///
  /// In en, this message translates to:
  /// **'~te oku'**
  String get ruleTeOku;

  /// No description provided for @ruleRelative.
  ///
  /// In en, this message translates to:
  /// **'Relative clause'**
  String get ruleRelative;

  /// No description provided for @ruleNagara.
  ///
  /// In en, this message translates to:
  /// **'~nagara'**
  String get ruleNagara;

  /// No description provided for @ruleBaForm.
  ///
  /// In en, this message translates to:
  /// **'Ba form'**
  String get ruleBaForm;

  /// No description provided for @customDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDeckTitle;

  /// No description provided for @customDeckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the rules you want to practice.'**
  String get customDeckSubtitle;

  /// No description provided for @customDeckConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get customDeckConfigure;

  /// No description provided for @customDeckSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String customDeckSelectedCount(Object count);

  /// No description provided for @customDeckEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one rule to start.'**
  String get customDeckEmptyHint;

  /// No description provided for @customDeckModesTitle.
  ///
  /// In en, this message translates to:
  /// **'Base forms'**
  String get customDeckModesTitle;

  /// No description provided for @customDeckRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get customDeckRulesTitle;

  /// No description provided for @customDeckSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get customDeckSave;
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
      <String>['en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
      'that was used.');
}
