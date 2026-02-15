// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ペラペラ';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elige el idioma de la app.';

  @override
  String get languageSystem => 'Idioma del dispositivo';

  @override
  String get languageSystemSubtitle => 'Usa el idioma del dispositivo.';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get reportProblemTitle => 'Informar de un problema';

  @override
  String get reportProblemSubtitle => 'Abre el formulario de comentarios.';

  @override
  String get reportProblemError => 'No se pudo abrir el enlace.';

  @override
  String get resetStatsTitle => 'Restablecer estadísticas';

  @override
  String get resetStatsSubtitle =>
      'Elimina todos los datos de precisión guardados.';

  @override
  String get resetStatsConfirmTitle => '¿Restablecer estadísticas?';

  @override
  String get resetStatsConfirmBody =>
      'Esto eliminará de forma permanente tu progreso en todas las reglas.';

  @override
  String get resetStatsConfirmButton => 'Restablecer';

  @override
  String get resetStatsCancelButton => 'Cancelar';

  @override
  String get resetStatsDone => 'Estadísticas restablecidas.';

  @override
  String get chooseRuleTitle => 'Elige una regla';

  @override
  String get chooseRuleSubtitle =>
      'Selecciona una regla y luego inicia la sesión.';

  @override
  String get chooseRuleHint => 'Elige una regla';

  @override
  String get chooseRuleUnavailableHint =>
      'Selecciona una regla disponible para empezar.';

  @override
  String get startSession => 'Iniciar';

  @override
  String get exitSession => 'Salir';

  @override
  String get backButton => 'Atrás';

  @override
  String get showSolutionButton => 'Mostrar solución';

  @override
  String get nextButton => 'Siguiente';

  @override
  String get answerHint =>
      'Toca \"Mostrar solución\" y luego elige \"Correcto\" o \"Incorrecto\".';

  @override
  String get preparingFirstQuestion => 'Preparando la primera pregunta.';

  @override
  String get selectRuleToBegin => 'Selecciona una regla para empezar.';

  @override
  String get statsButton => 'Estadísticas';

  @override
  String get statsTitle => 'Progreso';

  @override
  String get statsRangeWeek => 'Semana';

  @override
  String get statsRangeMonth => 'Mes';

  @override
  String get statsThisWeek => 'Esta semana';

  @override
  String get statsLastWeek => 'La semana pasada';

  @override
  String get statsThisMonth => 'Este mes';

  @override
  String get statsLastMonth => 'El mes pasado';

  @override
  String get statsAccuracyLabel => 'Precisión';

  @override
  String get statsLast30Days => 'Últimos 30 días';

  @override
  String statsCorrectOfTotal(Object correct, Object total) {
    return 'Correctas: $correct/$total';
  }

  @override
  String get statsNoData => 'Aún no hay datos';

  @override
  String get statsTrendTitle => 'Tendencia';

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
  String get answerCorrectButton => 'Correcto';

  @override
  String get answerWrongButton => 'Incorrecto';

  @override
  String get proPill => 'Pasar a Pro';

  @override
  String get proBannerText =>
      'Pro: desbloquea las reglas bloqueadas y nuevos verbos.';

  @override
  String get proBannerCta => 'Pasar a Pro';

  @override
  String get proUpsellSnackbar =>
      'Pasa a Pro para desbloquear las reglas bloqueadas y nuevos verbos.';

  @override
  String get proBenefitsTitle => 'Ventajas Pro';

  @override
  String get proBenefitRules => 'Desbloquea todas las reglas bloqueadas.';

  @override
  String get proBenefitVerbs => 'Desbloquea todos los verbos premium.';

  @override
  String get proBenefitSupport => 'Apoya el desarrollo de PeraPera.';

  @override
  String get proRulesTitle => 'Reglas premium';

  @override
  String get proVerbsTitle => 'Verbos premium';

  @override
  String get proOneTimeLabel => 'Compra única';

  @override
  String get proRestoreButton => 'Restaurar compras';

  @override
  String get proStoreUnavailable =>
      'Tienda no disponible. Inténtalo más tarde.';

  @override
  String get proPurchaseInProgress => 'Compra en curso...';

  @override
  String get proPurchaseError => 'No se pudo completar la compra.';

  @override
  String get proAlreadyUnlocked => 'Pro ya está activo en este dispositivo.';

  @override
  String get tutorialTitle => 'Guía rápida';

  @override
  String get tutorialLine1 => 'Elige una regla gramatical y practica.';

  @override
  String get tutorialLine2 =>
      'Piensa la respuesta; luego toca \"Mostrar solución\" y evalúate.';

  @override
  String get tutorialButton => 'Vale, empecemos';

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
  String get modePotential => 'forma potencial';

  @override
  String get modeMix => 'mezcla aleatoria';

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
  String get customDeckTitle => 'Personalizada';

  @override
  String get customDeckSubtitle => 'Elige las reglas que quieres practicar.';

  @override
  String get customDeckConfigure => 'Configurar';

  @override
  String customDeckSelectedCount(Object count) {
    return 'Seleccionadas: $count';
  }

  @override
  String get customDeckEmptyHint =>
      'Selecciona al menos una regla para empezar.';

  @override
  String get customDeckModesTitle => 'Formas básicas';

  @override
  String get customDeckRulesTitle => 'Reglas';

  @override
  String get customDeckSave => 'Guardar';
}
