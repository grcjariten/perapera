// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ペラペラ';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageSubtitle =>
      'Choisissez la langue de l\'application.';

  @override
  String get languageSystem => 'Langue de l\'appareil';

  @override
  String get languageSystemSubtitle => 'Utiliser la langue de l\'appareil.';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get reportProblemTitle => 'Signaler un problème';

  @override
  String get reportProblemSubtitle => 'Ouvrir le formulaire de feedback.';

  @override
  String get reportProblemError => 'Impossible d\'ouvrir le lien.';

  @override
  String get chooseRuleTitle => 'Choisir une règle';

  @override
  String get chooseRuleSubtitle =>
      'Sélectionnez une règle puis démarrez la session.';

  @override
  String get chooseRuleHint => 'Choisir une règle';

  @override
  String get chooseRuleUnavailableHint =>
      'Sélectionnez une règle disponible pour commencer.';

  @override
  String get startSession => 'Démarrer';

  @override
  String get exitSession => 'Quitter';

  @override
  String get backButton => 'Retour';

  @override
  String get showSolutionButton => 'Afficher la solution';

  @override
  String get nextButton => 'Suivant';

  @override
  String get answerHint =>
      'Touchez \"Afficher la solution\" puis \"Suivant\" pour continuer.';

  @override
  String get preparingFirstQuestion => 'Préparation de la première question.';

  @override
  String get selectRuleToBegin => 'Sélectionnez une règle pour commencer.';

  @override
  String get proPill => 'Passer en Pro';

  @override
  String get proBannerText =>
      'Pro : débloquez les règles verrouillées et de nouveaux verbes.';

  @override
  String get proBannerCta => 'Passer en Pro';

  @override
  String get proUpsellSnackbar =>
      'Passez en Pro pour débloquer les règles verrouillées et de nouveaux verbes.';

  @override
  String get proBenefitsTitle => 'Avantages Pro';

  @override
  String get proBenefitRules => 'Débloquez toutes les règles verrouillées.';

  @override
  String get proBenefitVerbs => 'Accédez à tous les verbes premium.';

  @override
  String get proBenefitSupport => 'Soutenez le développement de PeraPera.';

  @override
  String get proRulesTitle => 'Règles Pro';

  @override
  String get proVerbsTitle => 'Verbes premium';

  @override
  String get proOneTimeLabel => 'Achat unique';

  @override
  String get proRestoreButton => 'Restaurer les achats';

  @override
  String get proStoreUnavailable =>
      'Boutique indisponible. Réessayez plus tard.';

  @override
  String get proPurchaseInProgress => 'Achat en cours...';

  @override
  String get proPurchaseError => 'Impossible de finaliser l\'achat.';

  @override
  String get proAlreadyUnlocked => 'Pro est déjà actif sur cet appareil.';

  @override
  String get tutorialTitle => 'Guide rapide';

  @override
  String get tutorialLine1 =>
      'Choisissez une règle de grammaire et entraînez-vous.';

  @override
  String get tutorialLine2 =>
      'Pensez à la réponse puis touchez \"Afficher la solution\".';

  @override
  String get tutorialButton => 'OK, c\'est parti';

  @override
  String get badgeFree => 'GRATUIT';

  @override
  String get badgePro => 'PRO';

  @override
  String get modeTe => 'forme en ~te';

  @override
  String get modeTa => 'forme en ~ta';

  @override
  String get modeNai => 'forme en ~nai';

  @override
  String get modeMasu => 'forme en ~masu';

  @override
  String get modePotential => 'forme ~potentielle';

  @override
  String get modeMix => 'mix aléatoire';

  @override
  String get modeKamo => 'forme ~kamo';

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
  String get ruleVolitional => 'Volitive';

  @override
  String get ruleVolitionalToOmotte => 'Volitif + to omotte';

  @override
  String get ruleTeOku => '~te oku';

  @override
  String get ruleRelative => 'Relative';

  @override
  String get ruleNagara => '~nagara';

  @override
  String get ruleBaForm => 'Forme ba';

  @override
  String get customDeckTitle => 'Personnalisee';

  @override
  String get customDeckSubtitle => 'Choisissez les regles a pratiquer.';

  @override
  String get customDeckConfigure => 'Configurer';

  @override
  String customDeckSelectedCount(Object count) {
    return 'Selectionnees: $count';
  }

  @override
  String get customDeckEmptyHint =>
      'Selectionnez au moins une regle pour commencer.';

  @override
  String get customDeckModesTitle => 'Formes de base';

  @override
  String get customDeckRulesTitle => 'Regles';

  @override
  String get customDeckSave => 'Enregistrer';
}
