// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ペラペラ';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguageTitle => 'Lingua';

  @override
  String get settingsLanguageSubtitle => 'Scegli la lingua dell\'app.';

  @override
  String get languageSystem => 'Lingua del dispositivo';

  @override
  String get languageSystemSubtitle => 'Usa la lingua del dispositivo.';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get reportProblemTitle => 'Segnala un problema';

  @override
  String get reportProblemSubtitle => 'Apri il modulo di feedback.';

  @override
  String get reportProblemError => 'Impossibile aprire il link.';

  @override
  String get resetStatsTitle => 'Azzera le statistiche';

  @override
  String get resetStatsSubtitle =>
      'Elimina tutti i dati di precisione salvati.';

  @override
  String get resetStatsConfirmTitle => 'Azzerare le statistiche?';

  @override
  String get resetStatsConfirmBody =>
      'Questa azione elimina definitivamente i progressi di tutte le regole.';

  @override
  String get resetStatsConfirmButton => 'Azzera';

  @override
  String get resetStatsCancelButton => 'Annulla';

  @override
  String get resetStatsDone => 'Statistiche azzerate.';

  @override
  String get chooseRuleTitle => 'Scegli la regola';

  @override
  String get chooseRuleSubtitle => 'Seleziona una regola e avvia la sessione.';

  @override
  String get chooseRuleHint => 'Scegli una regola';

  @override
  String get chooseRuleUnavailableHint =>
      'Seleziona una regola disponibile per iniziare.';

  @override
  String get startSession => 'Inizia';

  @override
  String get exitSession => 'Esci';

  @override
  String get backButton => 'Indietro';

  @override
  String get showSolutionButton => 'Mostra soluzione';

  @override
  String get nextButton => 'Avanti';

  @override
  String get answerHint =>
      'Tocca \"Mostra soluzione\" e poi scegli \"Corretto\" o \"Sbagliato\".';

  @override
  String get preparingFirstQuestion => 'Sto preparando la prima domanda.';

  @override
  String get selectRuleToBegin => 'Seleziona una regola per iniziare.';

  @override
  String get statsButton => 'Statistiche';

  @override
  String get statsTitle => 'Progresso';

  @override
  String get statsRangeWeek => 'Settimana';

  @override
  String get statsRangeMonth => 'Mese';

  @override
  String get statsThisWeek => 'Questa settimana';

  @override
  String get statsLastWeek => 'Settimana scorsa';

  @override
  String get statsThisMonth => 'Questo mese';

  @override
  String get statsLastMonth => 'Mese scorso';

  @override
  String get statsAccuracyLabel => 'Precisione';

  @override
  String get statsLast30Days => 'Ultimi 30 giorni';

  @override
  String statsCorrectOfTotal(Object correct, Object total) {
    return 'Corrette: $correct/$total';
  }

  @override
  String get statsNoData => 'Nessun dato disponibile';

  @override
  String get statsTrendTitle => 'Andamento';

  @override
  String get statsTierS => 'TIER S';

  @override
  String get statsTierA => 'TIER A';

  @override
  String get statsTierB => 'TIER B';

  @override
  String get statsTierC => 'TIER C';

  @override
  String get statsTierD => 'TIER D';

  @override
  String get statsTierFail => 'FAIL';

  @override
  String get answerCorrectButton => 'Corretto';

  @override
  String get answerWrongButton => 'Sbagliato';

  @override
  String get proPill => 'Passa a Pro';

  @override
  String get proBannerText => 'Pro: sblocca le regole bloccate e nuovi verbi.';

  @override
  String get proBannerCta => 'Passa a Pro';

  @override
  String get proUpsellSnackbar =>
      'Passa a Pro per sbloccare le regole bloccate e nuovi verbi.';

  @override
  String get proBenefitsTitle => 'Vantaggi Pro';

  @override
  String get proBenefitRules => 'Sblocca tutte le regole bloccate.';

  @override
  String get proBenefitVerbs => 'Sblocca tutti i verbi premium.';

  @override
  String get proBenefitSupport => 'Supporta lo sviluppo di PeraPera.';

  @override
  String get proRulesTitle => 'Regole premium';

  @override
  String get proVerbsTitle => 'Verbi premium';

  @override
  String get proOneTimeLabel => 'Acquisto una tantum';

  @override
  String get proRestoreButton => 'Ripristina acquisti';

  @override
  String get proStoreUnavailable => 'Store non disponibile. Riprova più tardi.';

  @override
  String get proPurchaseInProgress => 'Acquisto in corso...';

  @override
  String get proPurchaseError => 'Impossibile completare l\'acquisto.';

  @override
  String get proAlreadyUnlocked => 'Pro è già attivo su questo dispositivo.';

  @override
  String get tutorialTitle => 'Mini guida';

  @override
  String get tutorialLine1 => 'Scegli una regola grammaticale e esercitati.';

  @override
  String get tutorialLine2 =>
      'Pensa alla risposta, poi tocca \"Mostra soluzione\" e valuta la risposta.';

  @override
  String get tutorialButton => 'Ok, iniziamo';

  @override
  String get badgeFree => 'GRATIS';

  @override
  String get badgePro => 'PRO';

  @override
  String get modeTe => 'forma ~te';

  @override
  String get modeTa => 'forma ~ta';

  @override
  String get modeNai => 'forma ~nai';

  @override
  String get modeMasu => 'forma ~masu';

  @override
  String get modePotential => 'forma potenziale';

  @override
  String get modeMix => 'mix casuale';

  @override
  String get modeKamo => 'forma ~kamo';

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
  String get ruleCausative => 'Causativo';

  @override
  String get ruleCausativeGiveReceive => 'Causativo + te ageru/kureru/morau';

  @override
  String get ruleNasai => '-nasai';

  @override
  String get ruleTara => '~tara';

  @override
  String get ruleNumberMoShika => 'number + mo / shika';

  @override
  String get ruleVolitional => 'Forma volitiva';

  @override
  String get ruleVolitionalToOmotte => 'Volitivo + to omotte';

  @override
  String get ruleTeOku => '~te oku';

  @override
  String get ruleRelative => 'Frase relativa';

  @override
  String get ruleNagara => '~nagara';

  @override
  String get ruleBaForm => 'Forma ba';

  @override
  String get customDeckTitle => 'Personalizzata';

  @override
  String get customDeckSubtitle => 'Scegli le regole che vuoi esercitare.';

  @override
  String get customDeckConfigure => 'Configura';

  @override
  String customDeckSelectedCount(Object count) {
    return 'Selezionate: $count';
  }

  @override
  String get customDeckEmptyHint => 'Seleziona almeno una regola per iniziare.';

  @override
  String get customDeckModesTitle => 'Forme di base';

  @override
  String get customDeckRulesTitle => 'Regole';

  @override
  String get customDeckSave => 'Salva';
}
