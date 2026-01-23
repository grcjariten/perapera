// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ペラペラ';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language.';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageSystemSubtitle => 'Use your device language.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageFrench => 'French';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get reportProblemTitle => 'Report a problem';

  @override
  String get reportProblemSubtitle => 'Open the feedback form.';

  @override
  String get reportProblemError => 'Couldn\'t open the link.';

  @override
  String get chooseRuleTitle => 'Choose a rule';

  @override
  String get chooseRuleSubtitle => 'Select a rule and start the session.';

  @override
  String get chooseRuleHint => 'Choose a rule';

  @override
  String get chooseRuleUnavailableHint => 'Select an available rule to start.';

  @override
  String get startSession => 'Start';

  @override
  String get exitSession => 'Exit';

  @override
  String get backButton => 'Back';

  @override
  String get showSolutionButton => 'Show solution';

  @override
  String get nextButton => 'Next';

  @override
  String get answerHint =>
      'Tap \"Show solution\" and then \"Next\" to continue.';

  @override
  String get preparingFirstQuestion => 'Preparing the first question.';

  @override
  String get selectRuleToBegin => 'Select a rule to begin.';

  @override
  String get proPill => 'Go Pro';

  @override
  String get proBannerText => 'Pro: unlock locked rules and new verbs.';

  @override
  String get proBannerCta => 'Go Pro';

  @override
  String get proUpsellSnackbar =>
      'Go Pro to unlock locked rules and new verbs.';

  @override
  String get proBenefitsTitle => 'Pro benefits';

  @override
  String get proBenefitRules => 'Unlock all locked rules.';

  @override
  String get proBenefitVerbs => 'Get the full premium verb list.';

  @override
  String get proBenefitSupport => 'Support the development of PeraPera.';

  @override
  String get proRulesTitle => 'Pro rules';

  @override
  String get proVerbsTitle => 'Premium verbs';

  @override
  String get proOneTimeLabel => 'One-time purchase';

  @override
  String get proRestoreButton => 'Restore purchases';

  @override
  String get proStoreUnavailable => 'Store unavailable. Try again later.';

  @override
  String get proPurchaseInProgress => 'Purchase in progress...';

  @override
  String get proPurchaseError => 'Unable to complete the purchase.';

  @override
  String get proAlreadyUnlocked => 'Pro is already active on this device.';

  @override
  String get tutorialTitle => 'Quick guide';

  @override
  String get tutorialLine1 => 'Choose a grammar rule and practice.';

  @override
  String get tutorialLine2 =>
      'Think of the answer, then tap \"Show solution\".';

  @override
  String get tutorialButton => 'Ok, let\'s go';

  @override
  String get badgeFree => 'FREE';

  @override
  String get badgePro => 'PRO';

  @override
  String get modeTe => '~te form';

  @override
  String get modeTa => '~ta form';

  @override
  String get modeNai => '~nai form';

  @override
  String get modeMasu => '~masu form';

  @override
  String get modePotential => '~potential form';

  @override
  String get modeMix => 'random mix';

  @override
  String get modeKamo => '~kamo form';

  @override
  String get ruleShi => '~shi';

  @override
  String get ruleSouDesu => '~sou desu';

  @override
  String get ruleTeMiru => '~te miru';

  @override
  String get ruleNara => 'Nara';

  @override
  String get ruleHoshi => 'hoshi';

  @override
  String get ruleAgeruKureruMorau => 'ageru/kureru/morau';

  @override
  String get ruleTara => '~tara';

  @override
  String get ruleNumberMoShika => 'number + mo / shika';

  @override
  String get ruleVolitional => 'Volitional';

  @override
  String get ruleVolitionalToOmotte => 'Volitional + to omotte';

  @override
  String get ruleTeOku => '~te oku';

  @override
  String get ruleRelative => 'Relative clause';

  @override
  String get ruleNagara => '~nagara';

  @override
  String get ruleBaForm => 'Ba form';

  @override
  String get customDeckTitle => 'Custom';

  @override
  String get customDeckSubtitle => 'Pick the rules you want to practice.';

  @override
  String get customDeckConfigure => 'Configure';

  @override
  String customDeckSelectedCount(Object count) {
    return 'Selected: $count';
  }

  @override
  String get customDeckEmptyHint => 'Select at least one rule to start.';

  @override
  String get customDeckModesTitle => 'Base forms';

  @override
  String get customDeckRulesTitle => 'Rules';

  @override
  String get customDeckSave => 'Save';
}
