import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:perapera_trainer/l10n/app_localizations.dart';
import 'package:perapera_trainer/trainer_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/premium_flags.dart';

void main() {
  runApp(const TrainerApp());
}

const String _localeOverrideKey = 'perapera_locale_override';
const String _leftHandedModeKey = 'perapera_left_handed_mode';
const String _feedbackUrl = 'https://forms.gle/1e1KPDdEjx6XqkF1A';
const Locale _fallbackLocale = Locale('en');

Locale? _localeFromCode(String? code) {
  switch (code) {
    case 'en':
      return const Locale('en');
    case 'it':
      return const Locale('it');
    case 'fr':
      return const Locale('fr');
    case 'es':
      return const Locale('es');
    default:
      return null;
  }
}

class TrainerApp extends StatefulWidget {
  const TrainerApp({super.key});

  @override
  State<TrainerApp> createState() => _TrainerAppState();
}

class _TrainerAppState extends State<TrainerApp> {
  Locale? _localeOverride;

  @override
  void initState() {
    super.initState();
    _loadLocaleOverride();
  }

  Future<void> _loadLocaleOverride() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localeOverrideKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _localeOverride = _localeFromCode(stored);
    });
  }

  Future<void> _updateLocaleOverride(Locale? locale) async {
    setState(() {
      _localeOverride = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeOverrideKey);
    } else {
      await prefs.setString(_localeOverrideKey, locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'NotoSansJP';
    final ThemeData baseTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      useMaterial3: true,
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _accentWarm,
          secondary: _accentCool,
          tertiary: _accentCoral,
          surface: _bgCard,
        ),
        scaffoldBackgroundColor: _bgDeep,
        cardColor: _bgCard,
        appBarTheme: const AppBarTheme(
          backgroundColor: _bgDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: _bgCard,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _bgCardAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accentCool, width: 1.2),
          ),
        ),
      ),
      locale: _localeOverride,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return _fallbackLocale;
        }
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return _fallbackLocale;
      },
      home: TrainerHomePage(
        localeOverride: _localeOverride,
        onLocaleChanged: _updateLocaleOverride,
      ),
    );
  }
}

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({
    super.key,
    required this.localeOverride,
    required this.onLocaleChanged,
  });

  final Locale? localeOverride;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

enum DeckKind { verbs, topic, custom }

enum AppTier { free, pro }

enum _AppMenuAction { settings, stats }

const Color _bgDeep = Color(0xFF141517);
const Color _bgCard = Color(0xFF1F2227);
const Color _bgCardAlt = Color(0xFF232831);
const Color _accentWarm = Color(0xFFFFB74D);
const Color _accentCool = Color(0xFF4DD0E1);
const Color _accentCoral = Color(0xFFFF8A65);
const Color _proGold = Color(0xFFFFC857);
const Color _proPink = Color(0xFFFF5E91);
const int _sessionGoal = 20;
const String _tutorialSeenKey = 'perapera_tutorial_seen';
const String _proTierKey = 'perapera_tier_pro';
const String _proProductId = 'perapera_pro';
const String _proFallbackPrice = r'$4.78';
const String _customDeckId = 'custom_deck';
const String _customDeckSelectionKey = 'perapera_custom_deck_selection';
const String _ruleProgressKey = 'perapera_rule_progress';
const String _proEntitlementCheckKey = 'perapera_pro_entitlement_check';
const Duration _proEntitlementCheckCooldown = Duration(days: 7);
const Duration _proEntitlementCheckTimeout = Duration(seconds: 8);

const String _assetMascotte = 'assets/mascotte.png';
const String _assetTierS = 'assets/tierS.png';
const String _assetTierA = 'assets/tierA.png';
const String _assetTierB = 'assets/tierB.png';
const String _assetTierC = 'assets/tierC.png';
const String _assetTierD = 'assets/tierD.png';
const List<String> _mascotAssets = <String>[
  _assetMascotte,
  _assetTierS,
  _assetTierA,
  _assetTierB,
  _assetTierC,
  _assetTierD,
];

const double _tierThresholdS = 0.95;
const double _tierThresholdA = 0.9;
const double _tierThresholdB = 0.8;
const double _tierThresholdC = 0.7;
const double _tierThresholdD = 0.6;
const int _tierSnapshotMinimumTotal = 30;
const int _tierStatsMinimumTotal = 20;
const double _mascotBobAmplitude = 4.0;

class PracticeDeck {
  const PracticeDeck.verbs(this.mode)
      : kind = DeckKind.verbs,
        lesson = null,
        topic = null;

  const PracticeDeck.topic(this.lesson, this.topic)
      : kind = DeckKind.topic,
        mode = null;

  const PracticeDeck.custom()
      : kind = DeckKind.custom,
        mode = null,
        lesson = null,
        topic = null;

  final DeckKind kind;
  final TrainerMode? mode;
  final Lesson? lesson;
  final LessonTopic? topic;

  String get label {
    if (kind == DeckKind.verbs && mode != null) {
      return mode!.label;
    }
    if (kind == DeckKind.custom) {
      return '';
    }
    return topic?.title ?? '';
  }

  String get id {
    if (kind == DeckKind.verbs && mode != null) {
      return 'mode_${mode!.name}';
    }
    if (kind == DeckKind.custom) {
      return _customDeckId;
    }
    return 'topic_${topic?.title ?? ''}';
  }
}

enum _AnswerResult { ungraded, correct, wrong }

class _QuestionSnapshot {
  const _QuestionSnapshot({
    required this.number,
    required this.deck,
    required this.mode,
    required this.verb,
    required this.answer,
    required this.answerReading,
    required this.answerVisible,
    required this.result,
  });

  final int number;
  final PracticeDeck deck;
  final TrainerMode? mode;
  final VerbEntry verb;
  final String answer;
  final String answerReading;
  final bool answerVisible;
  final _AnswerResult result;

  _QuestionSnapshot copyWith({bool? answerVisible, _AnswerResult? result}) {
    return _QuestionSnapshot(
      number: number,
      deck: deck,
      mode: mode,
      verb: verb,
      answer: answer,
      answerReading: answerReading,
      answerVisible: answerVisible ?? this.answerVisible,
      result: result ?? this.result,
    );
  }
}

class _ProgressEntry {
  const _ProgressEntry({
    required this.correct,
    required this.total,
  });

  final int correct;
  final int total;

  _ProgressEntry copyWith({int? correct, int? total}) {
    return _ProgressEntry(
      correct: correct ?? this.correct,
      total: total ?? this.total,
    );
  }
}

class _ProgressSummary {
  const _ProgressSummary({
    required this.correct,
    required this.total,
  });

  final int correct;
  final int total;

  double get percent => total == 0 ? 0 : correct / total;
}

class _ProgressPoint {
  const _ProgressPoint({
    required this.date,
    required this.percent,
  });

  final DateTime date;
  final double? percent;
}

class _TierInfo {
  const _TierInfo({
    required this.label,
    required this.accent,
    required this.textColor,
    required this.icon,
    required this.assetPath,
  });

  final String label;
  final Color accent;
  final Color textColor;
  final IconData icon;
  final String assetPath;
}

class _TierPreview {
  const _TierPreview({
    required this.tier,
    required this.percent,
  });

  final _TierInfo tier;
  final double percent;

  int get total => 100;
  int get correct => (percent * total).round();
}

class _PatternStyle {
  const _PatternStyle({
    required this.color,
    this.gradientColors,
    this.glowColor,
    this.darkerEvery = 0,
    this.highlightEvery = 0,
    this.highlightColor,
    this.highlightGlowColor,
  });

  final Color color;
  final List<Color>? gradientColors;
  final Color? glowColor;
  final int darkerEvery;
  final int highlightEvery;
  final Color? highlightColor;
  final Color? highlightGlowColor;
}

bool _isTierPreviewEnabled() {
  final String key = tierPreviewOverride.trim().toUpperCase();
  return key.isNotEmpty && key != 'X';
}

_TierPreview? _tierPreviewOverrideInfo(AppLocalizations l10n) {
  final String key = tierPreviewOverride.trim().toUpperCase();
  if (key.isEmpty || key == 'X') {
    return null;
  }
  switch (key) {
    case 'S':
      return _TierPreview(
        tier: _tierInfoForPercent(0.97, l10n),
        percent: 0.97,
      );
    case 'A':
      return _TierPreview(
        tier: _tierInfoForPercent(0.92, l10n),
        percent: 0.92,
      );
    case 'B':
      return _TierPreview(
        tier: _tierInfoForPercent(0.85, l10n),
        percent: 0.85,
      );
    case 'C':
      return _TierPreview(
        tier: _tierInfoForPercent(0.74, l10n),
        percent: 0.74,
      );
    case 'D':
    case 'E':
      return _TierPreview(
        tier: _tierInfoForPercent(0.62, l10n),
        percent: 0.62,
      );
    case 'F':
    case 'FAIL':
      return _TierPreview(
        tier: _tierInfoForPercent(0.45, l10n),
        percent: 0.45,
      );
    default:
      return null;
  }
}

_PatternStyle _patternStyleForTier(_TierInfo? tier) {
  if (tier == null) {
    return _PatternStyle(
      color: Color.lerp(_bgCardAlt, Colors.black, 0.35) ?? _bgCardAlt,
      darkerEvery: 5,
    );
  }
  switch (tier.assetPath) {
    case _assetTierS:
      return const _PatternStyle(
        color: Color(0xFFFF3D95),
        highlightEvery: 7,
        highlightColor: Colors.white,
        highlightGlowColor: Color(0xFFFF3D95),
      );
    case _assetTierA:
      return const _PatternStyle(
        color: Color(0xFF3FE6FF),
        highlightEvery: 7,
        highlightColor: Colors.white,
        highlightGlowColor: Color(0xFF3FE6FF),
      );
    case _assetTierB:
      return const _PatternStyle(
        color: Color(0xFFFF4DA6),
        glowColor: Color(0xFFFF3B30),
        highlightEvery: 7,
        highlightColor: _proGold,
      );
    case _assetTierC:
      return _PatternStyle(
        color: Color.lerp(_bgCardAlt, Colors.black, 0.42) ?? _bgCardAlt,
        highlightEvery: 7,
        highlightColor: const Color(0xFF0B0D10),
      );
    case _assetTierD:
      return _PatternStyle(
        color: Color.lerp(_bgCardAlt, Colors.black, 0.3) ?? _bgCardAlt,
        darkerEvery: 5,
      );
    default:
      final Color base =
          Color.lerp(_bgCardAlt, Colors.black, 0.3) ?? _bgCardAlt;
      return _PatternStyle(
        color: base,
        gradientColors: [base, base],
      );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({
    required this.tier,
    this.compact = false,
  });

  final _TierInfo tier;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 14 : 18;
    final double fontSize = compact ? 12 : 16;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    final bool isTierS = tier.assetPath == _assetTierS;
    final List<Color> gradientColors = isTierS
        ? const [
            Color(0xFFFFB1E3),
            Color(0xFFFF4DA6),
            Color(0xFF8A4CFF),
          ]
        : [
            Color.lerp(tier.accent, Colors.white, 0.24) ?? tier.accent,
            tier.accent,
          ];
    final Color glowColor = isTierS ? const Color(0xFFFF4DA6) : tier.accent;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          if (isTierS)
            BoxShadow(
              color: const Color(0xFFFF5CD6).withValues(alpha: 0.9),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          if (isTierS)
            BoxShadow(
              color: const Color(0xFF8A4CFF).withValues(alpha: 0.65),
              blurRadius: 34,
              offset: const Offset(0, 10),
            ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier.icon,
            size: iconSize,
            color: isTierS ? Colors.white : tier.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            tier.label,
            style: TextStyle(
              color: isTierS ? Colors.white : tier.textColor,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: fontSize,
              shadows: isTierS
                  ? const [
                      Shadow(
                        color: Color(0xFFFF5CD6),
                        blurRadius: 12,
                      ),
                      Shadow(
                        color: Color(0xFF8A4CFF),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.style,
    this.strokeWidth = 2,
    this.strokeColor = Colors.black,
  });

  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}

class _ResolvedRule {
  const _ResolvedRule.mode(this.mode) : rule = null;
  const _ResolvedRule.rule(this.rule) : mode = null;

  final TrainerMode? mode;
  final _VerbRule? rule;
}

class _VerbRule {
  const _VerbRule({
    required this.title,
    required this.buildAnswer,
    required this.buildReading,
  });

  final String title;
  final String Function(VerbEntry verb) buildAnswer;
  final String Function(VerbEntry verb) buildReading;
}

DateTime _stripTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _dateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime? _dateFromKey(String key) {
  try {
    final parsed = DateTime.parse(key);
    return DateTime(parsed.year, parsed.month, parsed.day);
  } catch (_) {
    return null;
  }
}

_ProgressSummary _summarizeRange(
  Map<String, _ProgressEntry> entries,
  DateTime start,
  DateTime end,
) {
  int correct = 0;
  int total = 0;
  entries.forEach((dateKey, entry) {
    final date = _dateFromKey(dateKey);
    if (date == null) {
      return;
    }
    if (date.isBefore(start) || date.isAfter(end)) {
      return;
    }
    correct += entry.correct;
    total += entry.total;
  });
  return _ProgressSummary(correct: correct, total: total);
}

List<_ProgressPoint> _buildSeries(
  Map<String, _ProgressEntry> entries,
  DateTime start,
  int days,
) {
  final points = <_ProgressPoint>[];
  for (int i = 0; i < days; i++) {
    final date = start.add(Duration(days: i));
    final entry = entries[_dateKey(date)];
    final double? percent =
        entry == null || entry.total == 0 ? null : entry.correct / entry.total;
    points.add(_ProgressPoint(date: date, percent: percent));
  }
  return points;
}

_TierInfo _tierInfoForPercent(double percent, AppLocalizations l10n) {
  if (percent >= _tierThresholdS) {
    return _TierInfo(
      label: l10n.statsTierS,
      accent: _proGold,
      textColor: Colors.black,
      icon: Icons.star,
      assetPath: _assetTierS,
    );
  }
  if (percent >= _tierThresholdA) {
    return _TierInfo(
      label: l10n.statsTierA,
      accent: _accentCool,
      textColor: Colors.black,
      icon: Icons.grade,
      assetPath: _assetTierA,
    );
  }
  if (percent >= _tierThresholdB) {
    return _TierInfo(
      label: l10n.statsTierB,
      accent: _accentWarm,
      textColor: Colors.black,
      icon: Icons.flash_on,
      assetPath: _assetTierB,
    );
  }
  if (percent >= _tierThresholdC) {
    return _TierInfo(
      label: l10n.statsTierC,
      accent: _accentCoral,
      textColor: Colors.black,
      icon: Icons.whatshot,
      assetPath: _assetTierC,
    );
  }
  if (percent >= _tierThresholdD) {
    return _TierInfo(
      label: l10n.statsTierD,
      accent: Colors.white70,
      textColor: Colors.black,
      icon: Icons.check,
      assetPath: _assetTierD,
    );
  }
  return _TierInfo(
    label: l10n.statsTierFail,
    accent: Colors.redAccent,
    textColor: Colors.white,
    icon: Icons.close,
    assetPath: _assetMascotte,
  );
}

const Map<String, String> _godanIMap = <String, String>{
  '\u3046': '\u3044',
  '\u304F': '\u304D',
  '\u3050': '\u304E',
  '\u3059': '\u3057',
  '\u3064': '\u3061',
  '\u306C': '\u306B',
  '\u3076': '\u3073',
  '\u3080': '\u307F',
  '\u308B': '\u308A',
};

const Map<String, String> _godanOMap = <String, String>{
  '\u3046': '\u304A\u3046',
  '\u304F': '\u3053\u3046',
  '\u3050': '\u3054\u3046',
  '\u3059': '\u305D\u3046',
  '\u3064': '\u3068\u3046',
  '\u306C': '\u306E\u3046',
  '\u3076': '\u307C\u3046',
  '\u3080': '\u3082\u3046',
  '\u308B': '\u308D\u3046',
};

const Map<String, String> _godanEMap = <String, String>{
  '\u3046': '\u3048\u3070',
  '\u304F': '\u3051\u3070',
  '\u3050': '\u3052\u3070',
  '\u3059': '\u305B\u3070',
  '\u3064': '\u3066\u3070',
  '\u306C': '\u306D\u3070',
  '\u3076': '\u3079\u3070',
  '\u3080': '\u3081\u3070',
  '\u308B': '\u308C\u3070',
};

const Map<String, String> _godanAMap = <String, String>{
  '\u3046': '\u308F',
  '\u304F': '\u304B',
  '\u3050': '\u304C',
  '\u3059': '\u3055',
  '\u3064': '\u305F',
  '\u306C': '\u306A',
  '\u3076': '\u3070',
  '\u3080': '\u307E',
  '\u308B': '\u3089',
};

String _teSurface(VerbEntry verb) => verb.conjugationFor(TrainerMode.te).answer;
String _taSurface(VerbEntry verb) => verb.conjugationFor(TrainerMode.ta).answer;
String _naiSurface(VerbEntry verb) =>
    verb.conjugationFor(TrainerMode.nai).answer;

String _teReading(VerbEntry verb) => verb.readingFor(TrainerMode.te);
String _taReading(VerbEntry verb) => verb.readingFor(TrainerMode.ta);
String _naiReading(VerbEntry verb) => verb.readingFor(TrainerMode.nai);

String _ruToTe(String text) {
  if (text.endsWith('\u308B')) {
    return '${text.substring(0, text.length - 1)}\u3066';
  }
  return '$text\u3066';
}

String _causativeSurface(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem =
          verb.dictionary.substring(0, verb.dictionary.length - 1);
      final String ending =
          verb.dictionary.substring(verb.dictionary.length - 1);
      return '$stem${_godanAMap[ending] ?? ''}\u305B\u308B';
    case VerbClass.ichidan:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u3055\u305B\u308B';
    case VerbClass.suru:
      return '\u3055\u305B\u308B';
    case VerbClass.kuru:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u3055\u305B\u308B';
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '$prefix\u3055\u305B\u308B';
  }
}

String _causativeReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanAMap[ending] ?? ''}\u305B\u308B';
    case VerbClass.ichidan:
      return '${verb.reading.substring(0, verb.reading.length - 1)}\u3055\u305B\u308B';
    case VerbClass.suru:
      return '\u3055\u305B\u308B';
    case VerbClass.kuru:
      return '\u3053\u3055\u305B\u308B';
    case VerbClass.suruCompound:
      final String prefix = verb.reading.substring(0, verb.reading.length - 2);
      return '$prefix\u3055\u305B\u308B';
  }
}

String _causativeTeSurface(VerbEntry verb) => _ruToTe(_causativeSurface(verb));

String _causativeTeReading(VerbEntry verb) => _ruToTe(_causativeReading(verb));

String _masuStemSurface(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem =
          verb.dictionary.substring(0, verb.dictionary.length - 1);
      final String ending =
          verb.dictionary.substring(verb.dictionary.length - 1);
      return '$stem${_godanIMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return verb.dictionary.substring(0, verb.dictionary.length - 1);
    case VerbClass.suru:
      return '\u3057';
    case VerbClass.kuru:
      return verb.dictionary.substring(0, verb.dictionary.length - 1);
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '$prefix\u3057';
  }
}

String _masuStemReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanIMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return verb.reading.substring(0, verb.reading.length - 1);
    case VerbClass.suru:
      return '\u3057';
    case VerbClass.kuru:
      return '\u304D';
    case VerbClass.suruCompound:
      final String prefix = verb.reading.substring(0, verb.reading.length - 2);
      return '$prefix\u3057';
  }
}

String _volitionalSurface(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem =
          verb.dictionary.substring(0, verb.dictionary.length - 1);
      final String ending =
          verb.dictionary.substring(verb.dictionary.length - 1);
      return '$stem${_godanOMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u3088\u3046';
    case VerbClass.suru:
      return '\u3057\u3088\u3046';
    case VerbClass.kuru:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u3088\u3046';
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '$prefix\u3057\u3088\u3046';
  }
}

String _volitionalReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanOMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.reading.substring(0, verb.reading.length - 1)}\u3088\u3046';
    case VerbClass.suru:
      return '\u3057\u3088\u3046';
    case VerbClass.kuru:
      return '\u3053\u3088\u3046';
    case VerbClass.suruCompound:
      final String prefix = verb.reading.substring(0, verb.reading.length - 2);
      return '$prefix\u3057\u3088\u3046';
  }
}

String _baSurface(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem =
          verb.dictionary.substring(0, verb.dictionary.length - 1);
      final String ending =
          verb.dictionary.substring(verb.dictionary.length - 1);
      return '$stem${_godanEMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u308C\u3070';
    case VerbClass.suru:
      return '\u3059\u308C\u3070';
    case VerbClass.kuru:
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}\u308C\u3070';
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '$prefix\u3059\u308C\u3070';
  }
}

String _baReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanEMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.reading.substring(0, verb.reading.length - 1)}\u308C\u3070';
    case VerbClass.suru:
      return '\u3059\u308C\u3070';
    case VerbClass.kuru:
      return '${verb.reading.substring(0, verb.reading.length - 1)}\u308C\u3070';
    case VerbClass.suruCompound:
      final String prefix = verb.reading.substring(0, verb.reading.length - 2);
      return '$prefix\u3059\u308C\u3070';
  }
}

final Map<String, _VerbRule> _customRules = <String, _VerbRule>{
  '~shi': _VerbRule(
    title: '~shi',
    buildAnswer: (verb) => '${verb.dictionary}\u3057',
    buildReading: (verb) => '${verb.reading}\u3057',
  ),
  '~sou desu': _VerbRule(
    title: '~sou desu',
    buildAnswer: (verb) => '${_masuStemSurface(verb)}\u305D\u3046\u3067\u3059',
    buildReading: (verb) => '${_masuStemReading(verb)}\u305D\u3046\u3067\u3059',
  ),
  '~te miru': _VerbRule(
    title: '~te miru',
    buildAnswer: (verb) => '${_teSurface(verb)}\u307F\u307E\u3059',
    buildReading: (verb) => '${_teReading(verb)}\u307F\u307E\u3059',
  ),
  'Nara': _VerbRule(
    title: 'Nara',
    buildAnswer: (verb) => '${verb.dictionary}\u306A\u3089',
    buildReading: (verb) => '${verb.reading}\u306A\u3089',
  ),
  'hoshi': _VerbRule(
    title: 'hoshi',
    buildAnswer: (verb) => '${_teSurface(verb)}\u307B\u3057\u3044\u3067\u3059',
    buildReading: (verb) => '${_teReading(verb)}\u307B\u3057\u3044\u3067\u3059',
  ),
  'ageru/kureru/morau': _VerbRule(
    title: 'ageru/kureru/morau',
    buildAnswer: (verb) =>
        '${_teSurface(verb)}\u3042\u3052\u307E\u3059 / ${_teSurface(verb)}\u304F\u308C\u307E\u3059 / ${_teSurface(verb)}\u3082\u3089\u3044\u307E\u3059',
    buildReading: (verb) =>
        '${_teReading(verb)}\u3042\u3052\u307E\u3059 / ${_teReading(verb)}\u304F\u308C\u307E\u3059 / ${_teReading(verb)}\u3082\u3089\u3044\u307E\u3059',
  ),
  'Causativo': const _VerbRule(
    title: 'Causativo',
    buildAnswer: _causativeSurface,
    buildReading: _causativeReading,
  ),
  'Causativo + te ageru/kureru/morau': _VerbRule(
    title: 'Causativo + te ageru/kureru/morau',
    buildAnswer: (verb) =>
        '${_causativeTeSurface(verb)}\u3042\u3052\u307E\u3059 / ${_causativeTeSurface(verb)}\u304F\u308C\u307E\u3059 / ${_causativeTeSurface(verb)}\u3082\u3089\u3044\u307E\u3059',
    buildReading: (verb) =>
        '${_causativeTeReading(verb)}\u3042\u3052\u307E\u3059 / ${_causativeTeReading(verb)}\u304F\u308C\u307E\u3059 / ${_causativeTeReading(verb)}\u3082\u3089\u3044\u307E\u3059',
  ),
  '-nasai': _VerbRule(
    title: '-nasai',
    buildAnswer: (verb) => '${_masuStemSurface(verb)}\u306A\u3055\u3044',
    buildReading: (verb) => '${_masuStemReading(verb)}\u306A\u3055\u3044',
  ),
  '~tara': _VerbRule(
    title: '~tara',
    buildAnswer: (verb) => '${_taSurface(verb)}\u3089',
    buildReading: (verb) => '${_taReading(verb)}\u3089',
  ),
  'number + mo / shika': _VerbRule(
    title: 'number + mo / shika',
    buildAnswer: (verb) =>
        '\u301C\u3082${_naiSurface(verb)} / \u301C\u3057\u304B${_naiSurface(verb)}',
    buildReading: (verb) =>
        '\u301C\u3082${_naiReading(verb)} / \u301C\u3057\u304B${_naiReading(verb)}',
  ),
  'Volitiva': const _VerbRule(
    title: 'Volitiva',
    buildAnswer: _volitionalSurface,
    buildReading: _volitionalReading,
  ),
  'Volitivo + to omotte': _VerbRule(
    title: 'Volitivo + to omotte',
    buildAnswer: (verb) =>
        '${_volitionalSurface(verb)}\u3068\u601D\u3063\u3066\u3044\u307E\u3059',
    buildReading: (verb) =>
        '${_volitionalReading(verb)}\u3068\u304A\u3082\u3063\u3066\u3044\u307E\u3059',
  ),
  '~te oku': _VerbRule(
    title: '~te oku',
    buildAnswer: (verb) => '${_teSurface(verb)}\u304A\u304D\u307E\u3059',
    buildReading: (verb) => '${_teReading(verb)}\u304A\u304D\u307E\u3059',
  ),
  'Relative': _VerbRule(
    title: 'Relative',
    buildAnswer: (verb) => '${verb.dictionary}\u3068\u304D',
    buildReading: (verb) => '${verb.reading}\u3068\u304D',
  ),
  '~nagara': _VerbRule(
    title: '~nagara',
    buildAnswer: (verb) => '${_masuStemSurface(verb)}\u306A\u304C\u3089',
    buildReading: (verb) => '${_masuStemReading(verb)}\u306A\u304C\u3089',
  ),
  'Forma ba': const _VerbRule(
    title: 'Forma ba',
    buildAnswer: _baSurface,
    buildReading: _baReading,
  ),
};

const Set<TrainerMode> _freeVerbModes = <TrainerMode>{
  TrainerMode.te,
  TrainerMode.ta,
  TrainerMode.nai,
  TrainerMode.masu,
  TrainerMode.potential,
  TrainerMode.kamo,
};

const Set<String> _freeRuleTitles = <String>{
  'hoshi',
  '~shi',
  '~sou desu',
};

class _TrainerHomePageState extends State<TrainerHomePage>
    with SingleTickerProviderStateMixin {
  late TrainerEngine _engine;

  AppTier _tier = forceProTier ? AppTier.pro : AppTier.free;

  late final AnimationController _proPulseController;
  late final Animation<double> _proPulse;

  late List<PracticeDeck> _decks;
  PracticeDeck? _selectedDeck;
  PracticeDeck? _currentDeck;
  TrainerMode? _currentQuestionMode;
  VerbEntry? _currentVerb;
  String _currentAnswer = '';
  String _currentAnswerReading = '';
  Set<String> _customDeckIds = <String>{};
  final Random _customDeckRandom = Random();
  Map<String, Map<String, _ProgressEntry>> _progressByDeck =
      <String, Map<String, _ProgressEntry>>{};

  final List<_QuestionSnapshot> _questionHistory = <_QuestionSnapshot>[];
  int _historyIndex = -1;

  bool _sessionActive = false;
  bool _answerVisible = false;
  bool _leftHandedMode = false;
  int _questionCounter = 0;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _proProduct;
  bool _storeAvailable = false;
  bool _purchasePending = false;
  String? _storeError;
  String? _pendingDeckId;
  bool _proEntitlementCheckInProgress = false;
  Timer? _proEntitlementCheckTimer;
  bool _didPrecacheMascotAssets = false;

  @override
  void initState() {
    super.initState();
    _engine = _buildEngineForTier(_tier);
    _proPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _proPulse = CurvedAnimation(
      parent: _proPulseController,
      curve: Curves.easeInOut,
    );
    _decks = _buildDecks();
    _selectedDeck = _decks.isNotEmpty ? _decks.first : null;
    _loadCustomDeckSelection();
    _loadProgress();
    _loadLeftHandedMode();
    _maybeShowTutorial();
    _loadTier();
    _initInAppPurchase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheMascotAssets) {
      return;
    }
    _didPrecacheMascotAssets = true;
    for (final String asset in _mascotAssets) {
      unawaited(precacheImage(AssetImage(asset), context));
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _proPulseController.dispose();
    _proEntitlementCheckTimer?.cancel();
    super.dispose();
  }

  bool _canPracticeDeck(PracticeDeck? deck) {
    if (deck == null) {
      return false;
    }
    if (!_isDeckAvailable(deck)) {
      return false;
    }
    if (deck.kind == DeckKind.custom) {
      return _activeCustomDeckIds().isNotEmpty;
    }
    return true;
  }

  TrainerEngine _buildEngineForTier(AppTier tier) {
    final bool includePremiumVerbs = enablePremiumVerbs && tier == AppTier.pro;
    return TrainerEngine(
      verbs: includePremiumVerbs ? verbList : freeVerbList,
    );
  }

  void _initInAppPurchase() {
    if (kIsWeb) {
      setState(() {
        _storeAvailable = false;
        _storeError = 'web_not_supported';
      });
      return;
    }
    _purchaseSubscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _storeError = error.toString();
        });
      },
    );
    _loadStoreProducts();
  }

  Future<void> _loadStoreProducts() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!mounted) {
        return;
      }
      setState(() {
        _storeAvailable = available;
      });
      if (!available) {
        return;
      }
      final response = await _iap.queryProductDetails({_proProductId});
      if (!mounted) {
        return;
      }
      if (response.error != null) {
        setState(() {
          _storeError = response.error!.message;
        });
        return;
      }
      if (response.productDetails.isEmpty) {
        setState(() {
          _storeError = 'product_not_found';
        });
        return;
      }
      setState(() {
        _proProduct = response.productDetails.first;
        _storeError = null;
      });
      await _maybeSyncProEntitlement();
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _storeAvailable = false;
        _storeError = error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _storeAvailable = false;
        _storeError = error.toString();
      });
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    await _handleProEntitlementCheck(purchaseDetailsList);
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        if (mounted) {
          setState(() {
            _purchasePending = true;
          });
        }
        continue;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        if (mounted) {
          setState(() {
            _purchasePending = false;
          });
          _showPurchaseError();
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverPro();
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }

      if (mounted) {
        setState(() {
          _purchasePending = false;
        });
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return purchaseDetails.productID == _proProductId;
  }

  Future<void> _deliverPro() async {
    final String? pendingId = _pendingDeckId;
    _pendingDeckId = null;
    await _setTier(AppTier.pro, selectDeck: _findDeckById(pendingId));
  }

  Future<void> _buyPro() async {
    if (_purchasePending) {
      return;
    }
    if (!_storeAvailable || _proProduct == null) {
      _showStoreUnavailable();
      return;
    }
    setState(() {
      _purchasePending = true;
    });
    final purchaseParam = PurchaseParam(productDetails: _proProduct!);
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException {
      if (mounted) {
        setState(() {
          _purchasePending = false;
        });
        _showPurchaseError();
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (!_storeAvailable) {
      _showStoreUnavailable();
      return;
    }
    try {
      await _iap.restorePurchases();
    } on PlatformException {
      if (mounted) {
        _showPurchaseError();
      }
    }
  }

  Future<void> _loadCustomDeckSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_customDeckSelectionKey) ?? <String>[];
    if (!mounted) {
      return;
    }
    if (stored.isEmpty) {
      final defaults = _availableCustomDeckIds();
      setState(() {
        _customDeckIds = defaults;
      });
      if (defaults.isNotEmpty) {
        await prefs.setStringList(
          _customDeckSelectionKey,
          defaults.toList(),
        );
      }
      return;
    }
    setState(() {
      _customDeckIds = stored.toSet();
    });
  }

  Future<void> _saveCustomDeckSelection(Set<String> ids) async {
    setState(() {
      _customDeckIds = ids;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customDeckSelectionKey, ids.toList());
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ruleProgressKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return;
      }
      final parsed = <String, Map<String, _ProgressEntry>>{};
      decoded.forEach((deckId, value) {
        if (value is! Map) {
          return;
        }
        final entries = <String, _ProgressEntry>{};
        value.forEach((dateKey, entry) {
          if (entry is! Map) {
            return;
          }
          final dynamic correctRaw = entry['c'] ?? entry['correct'];
          final dynamic totalRaw = entry['t'] ?? entry['total'];
          if (correctRaw is! num || totalRaw is! num) {
            return;
          }
          entries[dateKey.toString()] = _ProgressEntry(
            correct: correctRaw.toInt(),
            total: totalRaw.toInt(),
          );
        });
        if (entries.isNotEmpty) {
          parsed[deckId.toString()] = entries;
        }
      });
      if (!mounted) {
        return;
      }
      setState(() {
        _progressByDeck = parsed;
      });
    } catch (_) {
      return;
    }
  }

  Future<void> _loadLeftHandedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_leftHandedModeKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      _leftHandedMode = enabled;
    });
  }

  void _updateLeftHandedMode(bool enabled) {
    if (_leftHandedMode == enabled) {
      return;
    }
    setState(() {
      _leftHandedMode = enabled;
    });
    unawaited(_saveLeftHandedMode(enabled));
  }

  Future<void> _saveLeftHandedMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_leftHandedModeKey, enabled);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = <String, dynamic>{};
    _progressByDeck.forEach((deckId, entries) {
      payload[deckId] = entries.map(
        (dateKey, entry) => MapEntry(
          dateKey,
          <String, int>{
            'c': entry.correct,
            't': entry.total,
          },
        ),
      );
    });
    await prefs.setString(_ruleProgressKey, jsonEncode(payload));
  }

  Map<String, _ProgressEntry> _progressForDeck(String deckId) {
    return _progressByDeck[deckId] ?? <String, _ProgressEntry>{};
  }

  bool _hasProgressForDeck(String deckId) {
    if (_isTierPreviewEnabled()) {
      return true;
    }
    final entries = _progressForDeck(deckId);
    return entries.values.any((entry) => entry.total > 0);
  }

  bool _hasRecentProgressForDeck(String deckId, {int days = 30}) {
    if (_isTierPreviewEnabled()) {
      return true;
    }
    final entries = _progressForDeck(deckId);
    final today = _stripTime(DateTime.now());
    final start = today.subtract(Duration(days: days - 1));
    final summary = _summarizeRange(entries, start, today);
    return summary.total > 0;
  }

  Future<void> _resetProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ruleProgressKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _progressByDeck = <String, Map<String, _ProgressEntry>>{};
    });
  }

  void _recordProgress(_QuestionSnapshot snapshot, bool isCorrect) {
    final deckId = snapshot.deck.id;
    final dateKey = _dateKey(_stripTime(DateTime.now()));
    final existing = Map<String, _ProgressEntry>.from(_progressForDeck(deckId));
    final entry =
        existing[dateKey] ?? const _ProgressEntry(correct: 0, total: 0);
    existing[dateKey] = entry.copyWith(
      correct: entry.correct + (isCorrect ? 1 : 0),
      total: entry.total + 1,
    );
    setState(() {
      _progressByDeck[deckId] = existing;
    });
    unawaited(_saveProgress());
  }

  Set<String> _availableCustomDeckIds() {
    return _decks
        .where((deck) => deck.kind != DeckKind.custom)
        .map((deck) => deck.id)
        .toSet();
  }

  Set<String> _activeCustomDeckIds() {
    final available = _availableCustomDeckIds();
    return _customDeckIds.where(available.contains).toSet();
  }

  PracticeDeck? _pickCustomDeck() {
    final activeIds = _activeCustomDeckIds();
    final candidates = _decks
        .where(
          (deck) => deck.kind != DeckKind.custom && activeIds.contains(deck.id),
        )
        .toList();
    if (candidates.isEmpty) {
      return null;
    }
    return candidates[_customDeckRandom.nextInt(candidates.length)];
  }

  Future<void> _maybeSyncProEntitlement() async {
    if (forceProTier) {
      return;
    }
    if (!_isProUser || !_storeAvailable) {
      return;
    }
    if (_proEntitlementCheckInProgress) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final int lastCheck = prefs.getInt(_proEntitlementCheckKey) ?? 0;
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastCheck < _proEntitlementCheckCooldown.inMilliseconds) {
      return;
    }
    await prefs.setInt(_proEntitlementCheckKey, now);
    _proEntitlementCheckInProgress = true;
    _proEntitlementCheckTimer?.cancel();
    _proEntitlementCheckTimer = Timer(_proEntitlementCheckTimeout, () {
      if (!mounted) {
        return;
      }
      _cancelProEntitlementCheck();
    });
    try {
      await _iap.restorePurchases();
    } on PlatformException {
      if (!mounted) {
        return;
      }
      _cancelProEntitlementCheck();
    }
  }

  Future<void> _handleProEntitlementCheck(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    if (!_proEntitlementCheckInProgress) {
      return;
    }
    final bool hasError = purchaseDetailsList.any(
      (purchase) => purchase.status == PurchaseStatus.error,
    );
    final bool hasPro = purchaseDetailsList.any(
      (purchase) =>
          purchase.productID == _proProductId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored ||
              purchase.status == PurchaseStatus.pending),
    );
    _cancelProEntitlementCheck();
    if (!hasError && !hasPro && _isProUser) {
      await _setTier(AppTier.free);
    }
  }

  void _cancelProEntitlementCheck() {
    _proEntitlementCheckInProgress = false;
    _proEntitlementCheckTimer?.cancel();
    _proEntitlementCheckTimer = null;
  }

  Future<void> _loadTier() async {
    if (forceProTier) {
      if (_tier != AppTier.pro) {
        _applyTier(AppTier.pro);
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final bool isPro = prefs.getBool(_proTierKey) ?? false;
    if (!mounted) {
      return;
    }
    if (isPro && _tier != AppTier.pro) {
      _applyTier(AppTier.pro);
    }
    if (isPro) {
      await _maybeSyncProEntitlement();
    }
  }

  void _applyTier(AppTier tier, {PracticeDeck? selectDeck}) {
    setState(() {
      _tier = tier;
      _engine = _buildEngineForTier(tier);
      _decks = _buildDecks();
      final String? preferredId = selectDeck?.id ?? _selectedDeck?.id;
      final PracticeDeck? preferredDeck = _findDeckById(preferredId);
      if (preferredDeck != null && _isDeckAvailable(preferredDeck)) {
        _selectedDeck = preferredDeck;
      } else {
        _selectedDeck = _decks.isNotEmpty ? _decks.first : null;
      }
    });
  }

  PracticeDeck? _findDeckById(String? id) {
    if (id == null) {
      return null;
    }
    for (final deck in _decks) {
      if (deck.id == id) {
        return deck;
      }
    }
    return null;
  }

  List<PracticeDeck> _buildDecks() {
    final decks = <PracticeDeck>[];
    final labels = <String>{};

    for (final mode in TrainerMode.values) {
      final deck = PracticeDeck.verbs(mode);
      if (!showLockedDecks && !_isDeckAvailable(deck)) {
        continue;
      }
      if (labels.add(deck.id)) {
        decks.add(deck);
      }
    }

    for (final lesson in lessonCatalog) {
      for (final topic in lesson.topics) {
        if (!_isTopicSupported(topic)) {
          continue;
        }
        final deck = PracticeDeck.topic(lesson, topic);
        if (!showLockedDecks && !_isDeckAvailable(deck)) {
          continue;
        }
        if (labels.add(deck.id)) {
          decks.add(deck);
        }
      }
    }

    const customDeck = PracticeDeck.custom();
    if (showLockedDecks || _isDeckAvailable(customDeck)) {
      if (labels.add(customDeck.id)) {
        decks.add(customDeck);
      }
    }

    return decks;
  }

  String _deckLabel(PracticeDeck deck, AppLocalizations l10n) {
    if (deck.kind == DeckKind.custom) {
      return l10n.customDeckTitle;
    }
    if (deck.kind == DeckKind.verbs && deck.mode != null) {
      return _modeLabel(deck.mode!, l10n);
    }
    final topic = deck.topic;
    if (topic == null) {
      return '';
    }
    return _ruleLabel(topic.title, l10n);
  }

  Color _deckAccentColor(PracticeDeck deck) {
    switch (deck.kind) {
      case DeckKind.verbs:
        return _accentWarm;
      case DeckKind.topic:
        return _accentCool;
      case DeckKind.custom:
        return _proGold;
    }
  }

  String _modeLabel(TrainerMode mode, AppLocalizations l10n) {
    switch (mode) {
      case TrainerMode.te:
        return l10n.modeTe;
      case TrainerMode.ta:
        return l10n.modeTa;
      case TrainerMode.nai:
        return l10n.modeNai;
      case TrainerMode.masu:
        return l10n.modeMasu;
      case TrainerMode.potential:
        return l10n.modePotential;
      case TrainerMode.mix:
        return l10n.modeMix;
      case TrainerMode.kamo:
        return l10n.modeKamo;
    }
  }

  String _ruleLabel(String ruleKey, AppLocalizations l10n) {
    switch (ruleKey) {
      case '~shi':
        return l10n.ruleShi;
      case '~sou desu':
        return l10n.ruleSouDesu;
      case '~te miru':
        return l10n.ruleTeMiru;
      case 'Nara':
        return l10n.ruleNara;
      case 'hoshi':
        return l10n.ruleHoshi;
      case 'ageru/kureru/morau':
        return l10n.ruleAgeruKureruMorau;
      case 'Causativo':
        return l10n.ruleCausative;
      case 'Causativo + te ageru/kureru/morau':
        return l10n.ruleCausativeGiveReceive;
      case '-nasai':
        return l10n.ruleNasai;
      case '~tara':
        return l10n.ruleTara;
      case 'number + mo / shika':
        return l10n.ruleNumberMoShika;
      case 'Volitiva':
        return l10n.ruleVolitional;
      case 'Volitivo + to omotte':
        return l10n.ruleVolitionalToOmotte;
      case '~te oku':
        return l10n.ruleTeOku;
      case 'Relative':
        return l10n.ruleRelative;
      case '~nagara':
        return l10n.ruleNagara;
      case 'Forma ba':
        return l10n.ruleBaForm;
      default:
        return ruleKey;
    }
  }

  List<String> _proRuleLabels(AppLocalizations l10n) {
    return _customRules.keys
        .where((ruleKey) => !_freeRuleTitles.contains(ruleKey))
        .map((ruleKey) => _ruleLabel(ruleKey, l10n))
        .toList();
  }

  List<String> _premiumVerbLabels() {
    return premiumVerbList
        .map((verb) => '${verb.dictionary} (${verb.reading})')
        .toList();
  }

  List<_CustomDeckOption> _customModeOptions(AppLocalizations l10n) {
    return _decks
        .where((deck) => deck.kind == DeckKind.verbs)
        .map((deck) => _CustomDeckOption(
              deck.id,
              _deckLabel(deck, l10n),
              _CustomOptionKind.mode,
            ))
        .toList();
  }

  List<_CustomDeckOption> _customRuleOptions(AppLocalizations l10n) {
    return _decks
        .where((deck) => deck.kind == DeckKind.topic)
        .map((deck) => _CustomDeckOption(
              deck.id,
              _deckLabel(deck, l10n),
              _CustomOptionKind.rule,
            ))
        .toList();
  }

  bool get _isProUser => _tier == AppTier.pro;
  bool get _hasQuestion => _currentVerb != null && _currentAnswer.isNotEmpty;

  bool _isFreeRule(_ResolvedRule resolvedRule) {
    if (resolvedRule.mode != null) {
      return _freeVerbModes.contains(resolvedRule.mode);
    }
    return _freeRuleTitles.contains(resolvedRule.rule?.title ?? '');
  }

  bool _isDeckAvailable(PracticeDeck deck) {
    if (deck.kind == DeckKind.custom) {
      return _isProUser;
    }
    final resolvedRule = _resolveRule(deck);
    if (resolvedRule == null) {
      return false;
    }
    final bool isFree = _isFreeRule(resolvedRule);
    if (_isProUser) {
      return true;
    }
    return isFree;
  }

  bool _isTopicSupported(LessonTopic topic) {
    if (topic.trainerMode != null) {
      return false;
    }
    return _customRules.containsKey(topic.title);
  }

  _ResolvedRule? _resolveRule(PracticeDeck deck) {
    if (deck.kind == DeckKind.custom) {
      return null;
    }
    if (deck.kind == DeckKind.verbs && deck.mode != null) {
      return _ResolvedRule.mode(deck.mode!);
    }
    if (deck.kind == DeckKind.topic) {
      final topic = deck.topic;
      if (topic == null) {
        return null;
      }
      if (topic.trainerMode != null) {
        return _ResolvedRule.mode(topic.trainerMode!);
      }
      final rule = _customRules[topic.title];
      if (rule != null) {
        return _ResolvedRule.rule(rule);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextStyle titleStyle =
        Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ) ??
            const TextStyle(
              fontSize: 22,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            );
    return PopScope(
      canPop: !_sessionActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sessionActive) {
          _stopSession();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppTitle(l10n, titleStyle),
          leadingWidth:
              (!_sessionActive && showProBanners && !_isProUser) ? 156 : null,
          leading: (!_sessionActive && showProBanners && !_isProUser)
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildProPill(),
                  ),
                )
              : null,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgDeep, Color(0xFF1A1C20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: _isProUser
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: Container(
                    height: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_proGold, _accentCool],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                )
              : null,
          actions: [
            PopupMenuButton<_AppMenuAction>(
              tooltip: l10n.settingsTitle,
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                if (action == _AppMenuAction.settings) {
                  _openSettings();
                } else if (action == _AppMenuAction.stats) {
                  final deck = _selectedDeck;
                  if (deck != null && deck.kind != DeckKind.custom) {
                    _openStatsPage(deck);
                  }
                }
              },
              itemBuilder: (context) {
                final deck = _selectedDeck;
                final bool canShowStats = !_sessionActive &&
                    deck != null &&
                    deck.kind != DeckKind.custom &&
                    _hasProgressForDeck(deck.id);
                final items = <PopupMenuEntry<_AppMenuAction>>[
                  PopupMenuItem(
                    value: _AppMenuAction.settings,
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 18),
                        const SizedBox(width: 10),
                        Text(l10n.settingsTitle),
                      ],
                    ),
                  ),
                ];
                if (canShowStats) {
                  items.add(
                    PopupMenuItem(
                      value: _AppMenuAction.stats,
                      child: Row(
                        children: [
                          const Icon(Icons.show_chart, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.statsButton),
                        ],
                      ),
                    ),
                  );
                }
                return items;
              },
            ),
            if (_sessionActive)
              TextButton.icon(
                onPressed: _stopSession,
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.exitSession),
                style: TextButton.styleFrom(
                  foregroundColor: _accentCoral,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_bgDeep, Color(0xFF1B1D22)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -100,
                right: -60,
                child: _buildGlow(const Color(0x33FFC857), 220),
              ),
              Positioned(
                bottom: -120,
                left: -80,
                child: _buildGlow(const Color(0x334DD0E1), 260),
              ),
              if (_sessionActive)
                _buildSessionBody()
              else
                _buildSelectionBody(),
            ],
          ),
        ),
        bottomNavigationBar: _sessionActive ? null : _buildStartBar(),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = min(constraints.maxWidth, 680);
        final double minHeight = max(420, constraints.maxHeight * 0.62);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                minHeight: minHeight,
              ),
              child: _buildControls(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double contentWidth = min(constraints.maxWidth, 720);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            height: constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildQuestionCard()),
                  const SizedBox(height: 12),
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle(AppLocalizations l10n, TextStyle titleStyle) {
    final title = Text(l10n.appTitle, style: titleStyle);
    if (!_isProUser) {
      return title;
    }
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_proGold, _accentCool],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: title,
    );
  }

  void _openStatsPage(PracticeDeck deck) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StatsPage(
          deckLabel: _deckLabel(deck, l10n),
          accentColor: _deckAccentColor(deck),
          entries: Map<String, _ProgressEntry>.from(
            _progressForDeck(deck.id),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          localeOverride: widget.localeOverride,
          onLocaleChanged: widget.onLocaleChanged,
          leftHandedMode: _leftHandedMode,
          onLeftHandedModeChanged: _updateLeftHandedMode,
          onResetStats: _resetProgressData,
        ),
      ),
    );
  }

  Future<void> _openCustomDeckConfig() async {
    final deck = _selectedDeck;
    if (deck == null || deck.kind != DeckKind.custom) {
      return;
    }
    if (!_isDeckAvailable(deck)) {
      _showProUpsell(pendingDeck: deck);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<_CustomDeckResult>(
      MaterialPageRoute(
        builder: (context) => _CustomDeckPage(
          key: const ValueKey('customDeckConfig'),
          title: l10n.customDeckTitle,
          subtitle: l10n.customDeckSubtitle,
          saveLabel: l10n.customDeckSave,
          emptyHint: l10n.customDeckEmptyHint,
          selectedCountBuilder: l10n.customDeckSelectedCount,
          options: [
            ..._customModeOptions(l10n),
            ..._customRuleOptions(l10n),
          ],
          initialSelection: _activeCustomDeckIds(),
        ),
      ),
    );
    if (result != null) {
      await _saveCustomDeckSelection(result.ids);
      if (result.startNow && result.ids.isNotEmpty) {
        _startSession();
      }
    }
  }

  Widget _buildControls() {
    final deck = _selectedDeck;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> deckLabels = <String, String>{
      for (final PracticeDeck value in _decks)
        value.id: _deckLabel(value, l10n),
    };
    final bool deckAvailable = deck != null && _isDeckAvailable(deck);
    final bool customSelectionEmpty = deck?.kind == DeckKind.custom &&
        deckAvailable &&
        _activeCustomDeckIds().isEmpty;
    final bool showUnavailableHint = deck != null && !deckAvailable;
    final bool showProgressSnapshot = deck != null &&
        deck.kind != DeckKind.custom &&
        (deckAvailable || _hasRecentProgressForDeck(deck.id));
    final Color highlightAccent =
        deck != null ? _deckAccentColor(deck) : _accentWarm;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [_bgCard, Color(0xFF1D2128)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chooseRuleTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.chooseRuleSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: highlightAccent.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: highlightAccent.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<PracticeDeck>(
                    initialValue: deck,
                    isExpanded: true,
                    hint: Text(l10n.chooseRuleHint),
                    dropdownColor: _bgCard,
                    icon: Icon(Icons.expand_more, color: highlightAccent),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _bgCardAlt.withValues(alpha: 0.95),
                      prefixIcon: Icon(
                        Icons.auto_awesome,
                        color: highlightAccent,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    selectedItemBuilder: (context) {
                      return _decks
                          .map(
                            (deck) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(deckLabels[deck.id] ?? deck.id),
                            ),
                          )
                          .toList();
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      _handleDeckSelection(value);
                    },
                    items: _deckDropdownItems(context, deckLabels),
                  ),
                ),
                if (showUnavailableHint) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.chooseRuleUnavailableHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (customSelectionEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.customDeckEmptyHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (showProgressSnapshot) ...[
                  const SizedBox(height: 14),
                  _buildProgressSnapshot(deck, l10n),
                ],
                if (showProBanners && !_isProUser) ...[
                  const SizedBox(height: 16),
                  _buildProBanner(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartBar() {
    final deck = _selectedDeck;
    final bool canStartSession = _canPracticeDeck(deck);
    final l10n = AppLocalizations.of(context)!;
    final Color accent = deck != null ? _deckAccentColor(deck) : _accentWarm;
    final Color endAccent =
        Color.lerp(accent, _accentCoral, 0.55) ?? _accentCoral;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: IgnorePointer(
        ignoring: !canStartSession,
        child: AnimatedOpacity(
          opacity: canStartSession ? 1 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: canStartSession ? _startSession : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, endAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 22, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    l10n.startSession,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSnapshot(PracticeDeck deck, AppLocalizations l10n) {
    final entries = _progressForDeck(deck.id);
    final today = _stripTime(DateTime.now());
    final start = today.subtract(const Duration(days: 29));
    final summary = _summarizeRange(entries, start, today);
    final _TierPreview? preview = _tierPreviewOverrideInfo(l10n);
    final _ProgressSummary effectiveSummary = preview == null
        ? summary
        : _ProgressSummary(correct: preview.correct, total: preview.total);
    final bool hasData =
        preview != null || summary.total >= _tierSnapshotMinimumTotal;
    final bool hasTierData =
        preview != null || summary.total >= _tierSnapshotMinimumTotal;
    final String percentText = hasData
        ? '${(effectiveSummary.percent * 100).toStringAsFixed(0)}%'
        : '\u3046\u301c\u3093';
    final String noDataLabel =
        _wrapOnWordBoundary(l10n.statsNoData, maxCharsPerLine: 9);
    final _TierInfo? tier = hasTierData
        ? (preview?.tier ?? _tierInfoForPercent(effectiveSummary.percent, l10n))
        : null;
    final _TierInfo? visualTier =
        hasTierData ? tier : _tierInfoForPercent(_tierThresholdD, l10n);
    final bool isTierS = hasTierData && tier?.assetPath == _assetTierS;
    final bool isTierA = visualTier?.assetPath == _assetTierA;
    final bool isTierB = visualTier?.assetPath == _assetTierB;
    final String mascotAsset =
        hasTierData && tier != null ? tier.assetPath : _assetMascotte;
    final theme = Theme.of(context);
    final accent = _deckAccentColor(deck);
    final _PatternStyle patternStyle = _patternStyleForTier(visualTier);
    final int mascotCacheHeight =
        (170 * 1.55 * MediaQuery.of(context).devicePixelRatio).round();
    final double baseTintAmount =
        isTierS ? 0.14 : ((isTierA || isTierB) ? 0.07 : 0.1);
    final double gradStartTintAmount =
        isTierS ? 0.28 : ((isTierA || isTierB) ? 0.14 : 0.2);
    final double gradEndTintAmount =
        isTierS ? 0.32 : ((isTierA || isTierB) ? 0.18 : 0.24);
    final Color tierTint = patternStyle.glowColor ?? patternStyle.color;
    final Color cardBase =
        Color.lerp(_bgCardAlt, tierTint, baseTintAmount) ?? _bgCardAlt;
    final List<Color> cardGradient = <Color>[
      Color.lerp(_bgCardAlt, tierTint, gradStartTintAmount) ?? _bgCardAlt,
      Color.lerp(_bgDeep, tierTint, gradEndTintAmount) ?? _bgDeep,
    ];
    final double patternOpacity = isTierS ? 0.65 : 0.45;
    final Color patternInk = isTierS
        // Keep Tier S base pattern color stable and unmistakably non-highlight.
        ? patternStyle.color
        : patternStyle.color.withValues(alpha: patternOpacity);
    final List<Color>? patternGradient = patternStyle.gradientColors
        ?.map((color) => color.withValues(alpha: patternOpacity))
        .toList();
    final Color? patternGlow = isTierS
        ? patternStyle.glowColor
        : patternStyle.glowColor?.withValues(alpha: patternOpacity);
    final Color frameColor = isTierS
        ? const Color(0xFFFF7AD1).withValues(alpha: 0.8)
        : accent.withValues(alpha: 0.22);
    final TextStyle percentStyle = theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: hasData ? Colors.white : theme.hintColor,
          shadows: isTierS
              ? [
                  const Shadow(
                    color: Color(0xFFFF5CD6),
                    blurRadius: 12,
                  ),
                  const Shadow(
                    color: Color(0xFF8A4CFF),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: hasData ? Colors.white : theme.hintColor,
        );
    return RepaintBoundary(
      child: InkWell(
        onTap: () => _openStatsPage(deck),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: cardBase,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: frameColor),
            gradient: LinearGradient(
              colors: cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isTierS
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF5CD6).withValues(alpha: 0.4),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF8A4CFF).withValues(alpha: 0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 170,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _proPulse,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            isComplex: true,
                            willChange: false,
                            painter: _PepPatternPainter(
                              color: patternInk,
                              gradientColors: patternGradient,
                              glowColor: patternGlow,
                              darkerEvery: patternStyle.darkerEvery,
                              highlightEvery: patternStyle.highlightEvery,
                              highlightColor: patternStyle.highlightColor,
                              highlightGlowColor:
                                  patternStyle.highlightGlowColor,
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final double bob =
                              (_proPulse.value * 2 - 1) * _mascotBobAmplitude;
                          return Transform.translate(
                            offset: Offset(0, -bob),
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                  if (isTierS)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, 0.32),
                      child: AnimatedBuilder(
                        animation: _proPulse,
                        builder: (context, child) {
                          final double bob =
                              (_proPulse.value * 2 - 1) * _mascotBobAmplitude;
                          final double baseY = hasData ? 0 : 100;
                          return Transform.translate(
                            offset: Offset(0, baseY + bob),
                            child: child,
                          );
                        },
                        child: RepaintBoundary(
                          child: Transform.scale(
                            scale: 1.55,
                            child: Image.asset(
                              mascotAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.low,
                              cacheHeight: mascotCacheHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          percentText,
                          style: percentStyle,
                        ),
                      ],
                    ),
                  ),
                  if (hasData)
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: _OutlinedText(
                        text: l10n.statsCorrectOfTotal(
                          effectiveSummary.correct,
                          effectiveSummary.total,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              shadows: isTierS
                                  ? [
                                      const Shadow(
                                        color: Color(0xFFFF5CD6),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ) ??
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                        strokeWidth: 2,
                        strokeColor: Colors.black.withValues(alpha: 0.72),
                      ),
                    ),
                  if (!hasData)
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 96),
                        child: Text(
                          noDataLabel,
                          maxLines: 3,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                height: 1.15,
                              ) ??
                              const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  if (hasTierData && tier != null)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _TierBadge(tier: tier, compact: true),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _wrapOnWordBoundary(String text, {int maxCharsPerLine = 9}) {
    if (text.isEmpty || maxCharsPerLine < 1) {
      return text;
    }
    final List<String> words = text.split(RegExp(r'\s+'));
    if (words.length <= 1) {
      return text;
    }
    final List<String> lines = <String>[];
    String current = '';
    for (final String word in words) {
      final bool fitsCurrent = current.isNotEmpty &&
          current.length + 1 + word.length <= maxCharsPerLine;
      if (current.isEmpty) {
        current = word;
      } else if (fitsCurrent) {
        current = '$current $word';
      } else {
        lines.add(current);
        current = word;
      }
    }
    if (current.isNotEmpty) {
      lines.add(current);
    }
    return lines.join('\n');
  }

  List<DropdownMenuItem<PracticeDeck>> _deckDropdownItems(
    BuildContext context,
    Map<String, String> deckLabels,
  ) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;
    final l10n = AppLocalizations.of(context)!;
    return _decks.map(
      (deck) {
        final bool isAvailable = _isDeckAvailable(deck);
        final bool showBadges = showProBadges && !_isProUser;
        final bool showPro = showBadges && !isAvailable;
        final bool showFree = showBadges && isAvailable;
        final deckLabel = deckLabels[deck.id] ?? _deckLabel(deck, l10n);
        final Color proBadgeColor = isAvailable ? _proGold : disabledColor;
        final Color accentBase = _deckAccentColor(deck);
        final bool isDimmed = !isAvailable;
        final Color accent =
            isDimmed ? theme.hintColor.withValues(alpha: 0.4) : accentBase;
        final Color labelColor = isAvailable ? Colors.white : disabledColor;
        final Color tileColor =
            isDimmed ? _bgCardAlt.withValues(alpha: 0.55) : _bgCardAlt;
        final Color borderColor = isDimmed
            ? Colors.white.withValues(alpha: 0.08)
            : accentBase.withValues(alpha: 0.22);
        return DropdownMenuItem<PracticeDeck>(
          value: deck,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: isDimmed
                        ? null
                        : [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    deckLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showFree)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: _accentCool,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.badgeFree,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _accentCool,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                if (showPro)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: proBadgeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.badgePro,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: proBadgeColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    ).toList();
  }

  void _selectDeck(PracticeDeck deck) {
    setState(() {
      _selectedDeck = deck;
    });
    _resetSessionProgress();
  }

  void _handleDeckSelection(PracticeDeck deck) {
    if (!_isDeckAvailable(deck)) {
      _showProUpsell(pendingDeck: deck);
      return;
    }
    _selectDeck(deck);
    if (deck.kind == DeckKind.custom) {
      _openCustomDeckConfig();
    }
  }

  Widget _buildQuestionCard() {
    final deck = _selectedDeck;
    final bool hasQuestion = _hasQuestion;
    final l10n = AppLocalizations.of(context)!;

    final PracticeDeck? headerDeck = _currentDeck ?? deck;
    final String header = headerDeck == null
        ? l10n.chooseRuleTitle
        : _deckLabel(headerDeck, l10n);
    final bool showMixTargetMode = hasQuestion &&
        headerDeck?.kind == DeckKind.verbs &&
        headerDeck?.mode == TrainerMode.mix &&
        _currentQuestionMode != null;
    final String prompt = _currentVerb?.dictionary ?? '';
    final String? promptReading = _currentVerb?.reading;
    final bool showPromptReading = _shouldShowReading(prompt, promptReading);
    final bool canGoBack = _sessionActive && _historyIndex > 0;

    if (!hasQuestion) {
      final subtitle =
          deck == null ? l10n.selectRuleToBegin : l10n.preparingFirstQuestion;
      return _buildPlaceholderCard(header, subtitle);
    }

    final TextStyle? headerStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            );
    final TextStyle promptStyle = (Theme.of(context).textTheme.displaySmall ??
            Theme.of(context).textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 50,
      height: 1.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showRankingBadge =
            _answerVisible && _remainingForRankingCount() > 0;
        return SizedBox(
          width: double.infinity,
          child: Card(
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            header,
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                        ),
                        Align(
                          alignment: _leftHandedMode
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: IconButton(
                            onPressed: canGoBack ? _previousQuestion : null,
                            tooltip: l10n.backButton,
                            icon: const Icon(Icons.undo, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMixTargetMode) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _accentWarm.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _accentWarm.withValues(alpha: 0.36),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _modeLabel(_currentQuestionMode!, l10n),
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _accentWarm,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ],
                  SizedBox(height: showMixTargetMode ? 16 : 26),
                  _buildScaledWordText(
                    prompt,
                    style: promptStyle,
                    widthFactor: 0.82,
                  ),
                  if (showPromptReading) ...[
                    const SizedBox(height: 8),
                    Text(
                      promptReading!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _answerVisible
                        ? _buildVerbAnswer()
                        : _buildAnswerHint(),
                  ),
                  SizedBox(height: showRankingBadge ? 2 : 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerHint() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      key: const ValueKey('answerHint'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        l10n.answerHint,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }

  Widget _buildBottomControls() {
    final bool canNavigate = _sessionActive && _hasQuestion;
    final bool showSolutionStep = _hasQuestion && !_answerVisible;
    final _AnswerResult currentResult = _currentAnswerResult();
    final bool needsScore =
        _answerVisible && currentResult == _AnswerResult.ungraded;
    final l10n = AppLocalizations.of(context)!;
    final Widget mainControl = needsScore
        ? _buildScoreButtons(canNavigate, l10n)
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canNavigate ? _handleForwardAction : null,
              icon: Icon(
                showSolutionStep ? Icons.visibility : Icons.arrow_forward,
                size: 20,
              ),
              label: Text(
                showSolutionStep ? l10n.showSolutionButton : l10n.nextButton,
              ),
            ),
          );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            mainControl,
            const SizedBox(height: 10),
            _buildProgressRow(),
          ],
        ),
      ),
    );
  }

  void _handleForwardAction() {
    if (!_sessionActive || !_hasQuestion) {
      return;
    }
    if (!_answerVisible) {
      _revealAnswer();
      return;
    }
    _nextQuestion();
  }

  Widget _buildScoreButtons(bool canNavigate, AppLocalizations l10n) {
    final Widget wrongButton = Expanded(
      child: OutlinedButton.icon(
        onPressed: canNavigate ? () => _markAnswerAndAdvance(false) : null,
        icon: const Icon(Icons.close, size: 20),
        label: Text(l10n.answerWrongButton),
      ),
    );
    final Widget correctButton = Expanded(
      child: ElevatedButton.icon(
        onPressed: canNavigate ? () => _markAnswerAndAdvance(true) : null,
        icon: const Icon(Icons.check, size: 20),
        label: Text(l10n.answerCorrectButton),
      ),
    );
    final List<Widget> scoreButtons = _leftHandedMode
        ? <Widget>[correctButton, const SizedBox(width: 12), wrongButton]
        : <Widget>[wrongButton, const SizedBox(width: 12), correctButton];
    return Row(
      key: const ValueKey('scoreButtons'),
      children: scoreButtons,
    );
  }

  void _revealAnswer() {
    if (_answerVisible || !_hasQuestion) {
      return;
    }
    setState(() {
      _answerVisible = true;
      _markAnswerVisible();
    });
  }

  _AnswerResult _currentAnswerResult() {
    if (_historyIndex < 0 || _historyIndex >= _questionHistory.length) {
      return _AnswerResult.ungraded;
    }
    return _questionHistory[_historyIndex].result;
  }

  void _markAnswerAndAdvance(bool isCorrect) {
    if (!_sessionActive || !_hasQuestion) {
      return;
    }
    if (_historyIndex < 0 || _historyIndex >= _questionHistory.length) {
      return;
    }
    final current = _questionHistory[_historyIndex];
    if (current.result == _AnswerResult.ungraded) {
      final updated = current.copyWith(
        result: isCorrect ? _AnswerResult.correct : _AnswerResult.wrong,
      );
      setState(() {
        _questionHistory[_historyIndex] = updated;
      });
      _recordProgress(updated, isCorrect);
    }
    _nextQuestion();
  }

  void _markAnswerVisible() {
    if (_historyIndex < 0 || _historyIndex >= _questionHistory.length) {
      return;
    }
    final current = _questionHistory[_historyIndex];
    if (current.answerVisible) {
      return;
    }
    _questionHistory[_historyIndex] = current.copyWith(answerVisible: true);
  }

  Widget _buildProgressRow() {
    final int current = _currentQuestionNumber();
    if (!_sessionActive || current == 0) {
      return const SizedBox.shrink();
    }
    final int capped = min(current, _sessionGoal);
    final double progress = capped / _sessionGoal;
    return Row(
      children: [
        Text(
          '$current',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(_accentWarm),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProPill() {
    final l10n = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: Tween(begin: 0.85, end: 1.0).animate(_proPulse),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.04).animate(_proPulse),
        child: InkWell(
          onTap: _showProUpsell,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_proGold, _proPink],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: _proGold.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  l10n.proPill,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProBanner() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _showProUpsell,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_proGold, _proPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.black, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.proBannerText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.proBannerCta,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _maybeShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeen = prefs.getBool(_tutorialSeenKey) ?? false;
    if (hasSeen) {
      return;
    }
    await prefs.setBool(_tutorialSeenKey, true);
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showTutorialDialog();
    });
  }

  void _showTutorialDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_proGold, _accentCool],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.tutorialTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildTutorialLine(
                  Icons.check_circle,
                  l10n.tutorialLine1,
                ),
                const SizedBox(height: 10),
                _buildTutorialLine(
                  Icons.arrow_forward,
                  l10n.tutorialLine2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.tutorialButton),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorialLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _showStoreUnavailable() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.proStoreUnavailable)),
    );
  }

  void _showPurchaseError() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.proPurchaseError)),
    );
  }

  void _showProUpsell({PracticeDeck? pendingDeck}) {
    if (_isProUser) {
      return;
    }
    _pendingDeckId = pendingDeck?.id;
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProUpsellPage(
          title: l10n.proPill,
          subtitle: l10n.proBannerText,
          priceLabel: _proProduct?.price ?? _proFallbackPrice,
          oneTimeLabel: l10n.proOneTimeLabel,
          ctaLabel: l10n.proBannerCta,
          storeUnavailableLabel: l10n.proStoreUnavailable,
          purchasePendingLabel: l10n.proPurchaseInProgress,
          alreadyUnlockedLabel: l10n.proAlreadyUnlocked,
          benefitsTitle: l10n.proBenefitsTitle,
          benefits: [
            l10n.proBenefitRules,
            l10n.proBenefitVerbs,
            l10n.proBenefitSupport,
          ],
          rulesTitle: l10n.proRulesTitle,
          rules: _proRuleLabels(l10n),
          verbsTitle: l10n.proVerbsTitle,
          verbs: _premiumVerbLabels(),
          restoreLabel: l10n.proRestoreButton,
          isProUser: _isProUser,
          purchasePending: _purchasePending,
          storeReady: _storeAvailable && _proProduct != null,
          storeError: _storeError,
          onBuy: _buyPro,
          onRestore: _restorePurchases,
        ),
      ),
    );
  }

  Future<void> _setTier(AppTier tier, {PracticeDeck? selectDeck}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proTierKey, tier == AppTier.pro);
    if (!mounted) {
      return;
    }
    _applyTier(tier, selectDeck: selectDeck);
  }

  Widget _buildPlaceholderCard(String title, String subtitle) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerbAnswer() {
    if (_currentAnswer.isEmpty) {
      return const SizedBox.shrink();
    }
    final textStyle = _answerTextStyle(context);
    final reading = _formattedAnswerReading();
    final showReading = _shouldShowReading(_formattedAnswer(), reading);
    return Column(
      key: const ValueKey('answer'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildScaledWordText(
          _formattedAnswer(),
          style: textStyle,
          widthFactor: 0.88,
        ),
        if (showReading) ...[
          const SizedBox(height: 6),
          Text(
            reading,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
        const SizedBox(height: 24),
        _buildAnswerTranslationLine(),
        _buildRankingProgressBadge(),
      ],
    );
  }

  Widget _buildScaledWordText(
    String text, {
    required TextStyle style,
    double widthFactor = 0.9,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }

  Widget _buildAnswerTranslationLine() {
    final String translation = _currentAnswerTranslation();
    if (translation.isEmpty) {
      return const SizedBox(height: 28);
    }
    return Text(
      translation,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).hintColor.withValues(alpha: 0.9),
          ),
    );
  }

  Widget _buildRankingProgressBadge() {
    final int remaining = _remainingForRankingCount();
    if (remaining <= 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_proGold, _proPink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.black, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _rankingHintText(remaining),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _rankingRemainingCountText(remaining),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _remainingForRankingCount() {
    if (_isTierPreviewEnabled()) {
      return 0;
    }
    final PracticeDeck? deck = _currentDeck;
    if (deck == null) {
      return 0;
    }
    final entries = _progressForDeck(deck.id);
    final int total = entries.values.fold<int>(
      0,
      (sum, entry) => sum + entry.total,
    );
    return max(0, _tierSnapshotMinimumTotal - total);
  }

  String _rankingHintText(int remaining) {
    return _localizedByLanguageCode(
      en: 'Keep going to unlock ranking',
      it: 'Continua per sbloccare la classifica',
      fr: 'Continuez pour débloquer le classement',
      es: 'Sigue para desbloquear la clasificación',
    );
  }

  String _rankingRemainingCountText(int remaining) {
    return _localizedByLanguageCode(
      en: '$remaining left',
      it: '$remaining mancanti',
      fr: 'il en reste $remaining',
      es: 'faltan $remaining',
    );
  }

  String _currentAnswerTranslation() {
    final VerbEntry? verb = _currentVerb;
    if (verb == null) {
      return '';
    }
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String meaning = localizedVerbMeaning(verb, languageCode);
    if (meaning.isEmpty) {
      return '';
    }
    final TrainerMode? mode = _currentQuestionMode;
    if (mode != null) {
      return _translationForMode(mode, meaning);
    }
    return _translationForRule(_currentDeck?.topic?.title, meaning);
  }

  String _translationForMode(TrainerMode mode, String meaning) {
    String resolvedMeaning = meaning;
    final String languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'it' && mode == TrainerMode.ta) {
      resolvedMeaning = _italianPastParticiple(meaning);
    } else if (languageCode == 'fr' && mode == TrainerMode.ta) {
      resolvedMeaning = _frenchPastParticiple(meaning);
    } else if (languageCode == 'es' && mode == TrainerMode.ta) {
      resolvedMeaning = _spanishPastParticiple(meaning);
    }

    String template;
    switch (mode) {
      case TrainerMode.te:
        template = _localizedByLanguageCode(
          en: '{v} and...',
          it: '{v} e...',
          fr: '{v} et...',
          es: '{v} y...',
        );
        break;
      case TrainerMode.ta:
        template = _localizedByLanguageCode(
          en: 'past: {v}',
          it: 'passato: {v}',
          fr: 'passé : {v}',
          es: 'pasado: {v}',
        );
        break;
      case TrainerMode.nai:
        template = _localizedByLanguageCode(
          en: 'not {v}',
          it: 'non: {v}',
          fr: 'ne pas {v}',
          es: 'no {v}',
        );
        break;
      case TrainerMode.masu:
        template = _localizedByLanguageCode(
          en: 'polite: {v}',
          it: 'forma cortese: {v}',
          fr: 'forme polie: {v}',
          es: 'forma cortés: {v}',
        );
        break;
      case TrainerMode.potential:
        template = _localizedByLanguageCode(
          en: 'can {v}',
          it: 'può {v}',
          fr: 'peut {v}',
          es: 'puede {v}',
        );
        break;
      case TrainerMode.kamo:
        template = _localizedByLanguageCode(
          en: 'maybe {v}',
          it: 'forse {v}',
          fr: 'peut-être {v}',
          es: 'quizás {v}',
        );
        break;
      case TrainerMode.mix:
        template = _localizedByLanguageCode(
          en: 'to {v}',
          it: '{v}',
          fr: '{v}',
          es: '{v}',
        );
        break;
    }
    return template.replaceAll('{v}', resolvedMeaning);
  }

  String _italianPastParticiple(String infinitiveMeaning) {
    final String trimmed = infinitiveMeaning.trim();
    if (trimmed.isEmpty) {
      return infinitiveMeaning;
    }
    final List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return infinitiveMeaning;
    }
    final String converted = _italianVerbPastParticiple(words.first);
    if (converted == words.first) {
      return infinitiveMeaning;
    }
    words[0] = converted;
    return words.join(' ');
  }

  String _spanishPastParticiple(String infinitiveMeaning) {
    final String trimmed = infinitiveMeaning.trim();
    if (trimmed.isEmpty) {
      return infinitiveMeaning;
    }
    final List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return infinitiveMeaning;
    }
    final String converted = _spanishVerbPastParticiple(words.first);
    if (converted == words.first) {
      return infinitiveMeaning;
    }
    words[0] = converted;
    return words.join(' ');
  }

  String _frenchPastParticiple(String infinitiveMeaning) {
    final String trimmed = infinitiveMeaning.trim();
    if (trimmed.isEmpty) {
      return infinitiveMeaning;
    }
    final List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return infinitiveMeaning;
    }

    int index = 0;
    final String first = words.first.toLowerCase();
    if ((first == 'se' || first == "s'") && words.length > 1) {
      index = 1;
    }

    final String converted = _frenchVerbPastParticiple(words[index]);
    if (converted == words[index]) {
      return infinitiveMeaning;
    }
    words[index] = converted;
    return words.join(' ');
  }

  String _frenchVerbPastParticiple(String infinitive) {
    final String lower = infinitive.toLowerCase();

    const Map<String, String> irregular = <String, String>{
      'aller': 'allé',
      'apprendre': 'appris',
      'avoir': 'eu',
      'boire': 'bu',
      'comprendre': 'compris',
      'courir': 'couru',
      'devoir': 'dû',
      'dire': 'dit',
      'ecrire': 'écrit',
      'écrire': 'écrit',
      'etre': 'été',
      'être': 'été',
      'faire': 'fait',
      'lire': 'lu',
      'mettre': 'mis',
      'mourir': 'mort',
      'ouvrir': 'ouvert',
      'prendre': 'pris',
      'recevoir': 'reçu',
      'savoir': 'su',
      'tenir': 'tenu',
      'venir': 'venu',
      'voir': 'vu',
      'vivre': 'vécu',
      'eteindre': 'éteint',
      'éteindre': 'éteint',
    };

    final String? irregularForm = irregular[lower];
    if (irregularForm != null) {
      return _matchInitialCase(infinitive, irregularForm);
    }

    String? generated;
    if (lower.endsWith('er') && lower.length > 2) {
      generated = '${lower.substring(0, lower.length - 2)}é';
    } else if (lower.endsWith('ir') && lower.length > 2) {
      generated = '${lower.substring(0, lower.length - 2)}i';
    } else if (lower.endsWith('re') && lower.length > 2) {
      generated = '${lower.substring(0, lower.length - 2)}u';
    }
    if (generated == null) {
      return infinitive;
    }
    return _matchInitialCase(infinitive, generated);
  }

  String _spanishVerbPastParticiple(String infinitive) {
    final String lower = infinitive.toLowerCase();

    const Map<String, String> irregular = <String, String>{
      'abrir': 'abierto',
      'devolver': 'devuelto',
      'escribir': 'escrito',
      'hacer': 'hecho',
      'ir': 'ido',
      'morir': 'muerto',
      'poner': 'puesto',
      'resolver': 'resuelto',
      'romper': 'roto',
      'ver': 'visto',
      'volver': 'vuelto',
    };

    String base = lower;
    if (base.endsWith('se') && base.length > 2) {
      base = base.substring(0, base.length - 2);
    }

    final String? irregularForm = irregular[base];
    if (irregularForm != null) {
      return _matchInitialCase(infinitive, irregularForm);
    }

    String? generated;
    if (base.endsWith('ar') && base.length > 2) {
      generated = '${base.substring(0, base.length - 2)}ado';
    } else if ((base.endsWith('er') || base.endsWith('ir')) &&
        base.length > 2) {
      generated = '${base.substring(0, base.length - 2)}ido';
    }
    if (generated == null) {
      return infinitive;
    }
    return _matchInitialCase(infinitive, generated);
  }

  String _italianVerbPastParticiple(String infinitive) {
    final String lower = infinitive.toLowerCase();

    const Map<String, String> irregular = <String, String>{
      'accendere': 'acceso',
      'aprire': 'aperto',
      'bere': 'bevuto',
      'chiudere': 'chiuso',
      'correre': 'corso',
      'decidere': 'deciso',
      'fare': 'fatto',
      'leggere': 'letto',
      'morire': 'morto',
      'prendere': 'preso',
      'raccogliere': 'raccolto',
      'scegliere': 'scelto',
      'scrivere': 'scritto',
      'spegnere': 'spento',
      'togliere': 'tolto',
      'vedere': 'visto',
      'venire': 'venuto',
      'vivere': 'vissuto',
    };

    String base = lower;
    if (base.endsWith('rsi') && base.length > 3) {
      base = '${base.substring(0, base.length - 3)}re';
    }

    final String? irregularForm = irregular[base];
    if (irregularForm != null) {
      return _matchInitialCase(infinitive, irregularForm);
    }

    String? generated;
    if (base.endsWith('are') && base.length > 3) {
      generated = '${base.substring(0, base.length - 3)}ato';
    } else if (base.endsWith('ere') && base.length > 3) {
      generated = '${base.substring(0, base.length - 3)}uto';
    } else if (base.endsWith('ire') && base.length > 3) {
      generated = '${base.substring(0, base.length - 3)}ito';
    }
    if (generated == null) {
      return infinitive;
    }
    return _matchInitialCase(infinitive, generated);
  }

  String _matchInitialCase(String source, String value) {
    if (source.isEmpty || value.isEmpty) {
      return value;
    }
    final String first = source[0];
    final bool startsUpper =
        first == first.toUpperCase() && first != first.toLowerCase();
    if (!startsUpper) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _translationForRule(String? ruleTitle, String meaning) {
    String template;
    switch (ruleTitle) {
      case '~shi':
        template = _localizedByLanguageCode(
          en: '{v} and...',
          it: '{v} e...',
          fr: '{v} et...',
          es: '{v} y...',
        );
        break;
      case '~sou desu':
        template = _localizedByLanguageCode(
          en: 'it seems to {v}',
          it: 'sembra: {v}',
          fr: 'il semble : {v}',
          es: 'parece {v}',
        );
        break;
      case '~te miru':
        template = _localizedByLanguageCode(
          en: 'try to {v}',
          it: 'provare a: {v}',
          fr: 'essayer de : {v}',
          es: 'intentar {v}',
        );
        break;
      case 'Nara':
        template = _localizedByLanguageCode(
          en: 'if about: {v}',
          it: 'se si parla di: {v}',
          fr: 'si cela concerne : {v}',
          es: 'si se trata de: {v}',
        );
        break;
      case 'hoshi':
        template = _localizedByLanguageCode(
          en: 'want someone to {v}',
          it: 'volere che qualcuno: {v}',
          fr: 'vouloir que quelqu’un : {v}',
          es: 'querer que alguien {v}',
        );
        break;
      case 'ageru/kureru/morau':
        template = _localizedByLanguageCode(
          en: '{v} for someone / receive {v}',
          it: '{v} per qualcuno / ricevere: {v}',
          fr: '{v} pour quelqu’un / recevoir : {v}',
          es: '{v} para alguien / recibir {v}',
        );
        break;
      case 'Causativo':
        template = _localizedByLanguageCode(
          en: 'make/let someone {v}',
          it: 'far fare a qualcuno: {v}',
          fr: 'faire/laisser quelqu’un : {v}',
          es: 'hacer/dejar que alguien {v}',
        );
        break;
      case 'Causativo + te ageru/kureru/morau':
        template = _localizedByLanguageCode(
          en: 'have someone {v} for someone',
          it: 'far fare a qualcuno: {v}, per qualcuno',
          fr: 'faire {v} par quelqu’un, pour quelqu’un',
          es: 'hacer que alguien {v} para alguien',
        );
        break;
      case '-nasai':
        template = _localizedByLanguageCode(
          en: '{v}! (command)',
          it: '{v}! (imperativo)',
          fr: '{v}! (ordre)',
          es: '{v}! (orden)',
        );
        break;
      case '~tara':
        template = _localizedByLanguageCode(
          en: 'if/when: {v}',
          it: 'se/quando: {v}',
          fr: 'si/quand : {v}',
          es: 'si/cuando: {v}',
        );
        break;
      case 'number + mo / shika':
        template = _localizedByLanguageCode(
          en: 'as many as... / only...',
          it: 'addirittura... / solo...',
          fr: 'autant que... / seulement...',
          es: 'hasta... / solo...',
        );
        break;
      case 'Volitiva':
        template = _localizedByLanguageCode(
          en: "let's {v}",
          it: 'facciamo: {v}',
          fr: 'allons : {v}',
          es: 'vamos a {v}',
        );
        break;
      case 'Volitivo + to omotte':
        template = _localizedByLanguageCode(
          en: 'thinking of {v}',
          it: 'sto pensando di: {v}',
          fr: 'en pensant à : {v}',
          es: 'pensando en {v}',
        );
        break;
      case '~te oku':
        template = _localizedByLanguageCode(
          en: '{v} in advance',
          it: '{v} in anticipo',
          fr: '{v} à l’avance',
          es: '{v} por adelantado',
        );
        break;
      case 'Relative':
        template = _localizedByLanguageCode(
          en: '{v} (relative clause)',
          it: '{v} (frase relativa)',
          fr: '{v} (proposition relative)',
          es: '{v} (frase relativa)',
        );
        break;
      case '~nagara':
        template = _localizedByLanguageCode(
          en: 'while {v}',
          it: 'mentre: {v}',
          fr: 'en {v} en même temps',
          es: 'mientras {v}',
        );
        break;
      case 'Forma ba':
        template = _localizedByLanguageCode(
          en: 'if {v}',
          it: 'se: {v}',
          fr: 'si {v}',
          es: 'si {v}',
        );
        break;
      default:
        template = _localizedByLanguageCode(
          en: 'to {v}',
          it: '{v}',
          fr: '{v}',
          es: '{v}',
        );
        break;
    }
    return template.replaceAll('{v}', meaning);
  }

  String _localizedByLanguageCode({
    required String en,
    required String it,
    required String fr,
    required String es,
  }) {
    final String code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'it':
        return it;
      case 'fr':
        return fr;
      case 'es':
        return es;
      default:
        return en;
    }
  }

  TextStyle _answerTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle baseStyle = theme.textTheme.headlineMedium ??
        theme.textTheme.titleLarge ??
        theme.textTheme.titleMedium ??
        const TextStyle();
    final double requestedSize =
        baseStyle.fontSize != null ? max(baseStyle.fontSize!, 40) : 40;
    return baseStyle.copyWith(
      fontSize: requestedSize,
      color: theme.colorScheme.secondary,
    );
  }

  String _formattedAnswer() {
    final answer = _currentAnswer;
    const ruChar = '\u308b';
    const masu = '\u307e\u3059';
    if (_currentQuestionMode == TrainerMode.potential &&
        answer.isNotEmpty &&
        answer.endsWith(ruChar)) {
      final polite =
          '${answer.substring(0, answer.length - ruChar.length)}$masu';
      if (polite != answer) {
        return '$answer / $polite';
      }
    }
    return answer;
  }

  String _formattedAnswerReading() {
    final answer = _currentAnswerReading;
    if (answer.isEmpty) {
      return '';
    }
    const ruChar = '\u308b';
    const masu = '\u307e\u3059';
    if (_currentQuestionMode == TrainerMode.potential &&
        answer.isNotEmpty &&
        answer.endsWith(ruChar)) {
      final polite =
          '${answer.substring(0, answer.length - ruChar.length)}$masu';
      if (polite != answer) {
        return '$answer / $polite';
      }
    }
    return answer;
  }

  bool _shouldShowReading(String? surface, String? reading) {
    if (surface == null || reading == null) {
      return false;
    }
    if (reading.isEmpty) {
      return false;
    }
    return surface != reading;
  }

  void _startSession() {
    final deck = _selectedDeck;
    if (!_canPracticeDeck(deck)) {
      if (deck != null && !_isDeckAvailable(deck)) {
        _showProUpsell(pendingDeck: deck);
      }
      return;
    }
    setState(() {
      _sessionActive = true;
      _questionCounter = 0;
      _questionHistory.clear();
      _historyIndex = -1;
      _currentDeck = null;
      _currentVerb = null;
      _currentQuestionMode = null;
      _currentAnswer = '';
      _currentAnswerReading = '';
    });
    _nextQuestion();
  }

  void _stopSession() {
    setState(() {
      _resetSessionProgress();
    });
  }

  void _nextQuestion() {
    if (!_sessionActive) {
      return;
    }
    final deck = _selectedDeck;
    if (!_canPracticeDeck(deck)) {
      return;
    }
    if (_historyIndex < _questionHistory.length - 1) {
      setState(() {
        _historyIndex++;
        _applySnapshot(_questionHistory[_historyIndex]);
      });
      return;
    }
    _loadQuestion(deck!);
  }

  void _previousQuestion() {
    if (!_sessionActive || _historyIndex <= 0) {
      return;
    }
    setState(() {
      _historyIndex--;
      _applySnapshot(_questionHistory[_historyIndex]);
    });
  }

  void _loadQuestion(PracticeDeck deck) {
    final PracticeDeck? effectiveDeck =
        deck.kind == DeckKind.custom ? _pickCustomDeck() : deck;
    if (effectiveDeck == null) {
      return;
    }
    final resolvedRule = _resolveRule(effectiveDeck);
    if (resolvedRule == null) {
      return;
    }
    final verb = _engine.nextVerb();
    TrainerMode? resolvedMode;
    String answer;
    String answerReading;
    if (resolvedRule.mode != null) {
      resolvedMode = resolvedRule.mode == TrainerMode.mix
          ? _engine.randomModeForMix()
          : resolvedRule.mode;
      answer = verb.conjugationFor(resolvedMode!).answer;
      answerReading = verb.readingFor(resolvedMode);
    } else {
      resolvedMode = null;
      final rule = resolvedRule.rule!;
      answer = rule.buildAnswer(verb);
      answerReading = rule.buildReading(verb);
    }
    final snapshot = _QuestionSnapshot(
      number: ++_questionCounter,
      deck: effectiveDeck,
      mode: resolvedMode,
      verb: verb,
      answer: answer,
      answerReading: answerReading,
      answerVisible: false,
      result: _AnswerResult.ungraded,
    );

    setState(() {
      _questionHistory.add(snapshot);
      _historyIndex = _questionHistory.length - 1;
      _applySnapshot(snapshot);
    });
  }

  void _applySnapshot(_QuestionSnapshot snapshot) {
    _currentDeck = snapshot.deck;
    _currentQuestionMode = snapshot.mode;
    _currentVerb = snapshot.verb;
    _currentAnswer = snapshot.answer;
    _currentAnswerReading = snapshot.answerReading;
    _answerVisible = snapshot.answerVisible;
  }

  int _currentQuestionNumber() {
    if (_historyIndex < 0 || _historyIndex >= _questionHistory.length) {
      return 0;
    }
    return _questionHistory[_historyIndex].number;
  }

  void _resetSessionProgress() {
    _sessionActive = false;
    _questionCounter = 0;
    _currentDeck = null;
    _currentVerb = null;
    _currentQuestionMode = null;
    _currentAnswer = '';
    _currentAnswerReading = '';
    _questionHistory.clear();
    _historyIndex = -1;
    _answerVisible = false;
  }
}

enum _StatsRange { week, month }

class _StatsPage extends StatefulWidget {
  const _StatsPage({
    required this.deckLabel,
    required this.accentColor,
    required this.entries,
  });

  final String deckLabel;
  final Color accentColor;
  final Map<String, _ProgressEntry> entries;

  @override
  State<_StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<_StatsPage> {
  _StatsRange _range = _StatsRange.week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final _TierPreview? preview = _tierPreviewOverrideInfo(l10n);
    final today = _stripTime(DateTime.now());
    final int rangeDays = _range == _StatsRange.week ? 7 : 30;
    final currentStart = today.subtract(Duration(days: rangeDays - 1));
    final previousEnd = currentStart.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(Duration(days: rangeDays - 1));

    final currentSummary = _summarizeRange(widget.entries, currentStart, today);
    final _ProgressSummary effectiveSummary = preview == null
        ? currentSummary
        : _ProgressSummary(correct: preview.correct, total: preview.total);
    final previousSummary =
        _summarizeRange(widget.entries, previousStart, previousEnd);

    final points = _buildSeries(widget.entries, currentStart, rangeDays);
    final bool hasSeriesData = points.any((point) => point.percent != null);
    final bool hasCurrent = preview != null || currentSummary.total > 0;
    final bool hasTierData =
        preview != null || currentSummary.total >= _tierStatsMinimumTotal;
    final String percentText = hasCurrent
        ? '${(effectiveSummary.percent * 100).toStringAsFixed(0)}%'
        : l10n.statsNoData;
    final _TierInfo? tier = hasTierData
        ? (preview?.tier ?? _tierInfoForPercent(effectiveSummary.percent, l10n))
        : null;
    final String mascotAsset =
        hasTierData && tier != null ? tier.assetPath : _assetMascotte;
    final _TierInfo? visualTier =
        hasTierData ? tier : _tierInfoForPercent(_tierThresholdD, l10n);
    final bool isTierS = hasTierData && tier?.assetPath == _assetTierS;
    final bool isTierA = visualTier?.assetPath == _assetTierA;
    final bool isTierB = visualTier?.assetPath == _assetTierB;
    final _PatternStyle statsHeaderPattern = _patternStyleForTier(visualTier);
    final Color statsHeaderTint =
        statsHeaderPattern.glowColor ?? statsHeaderPattern.color;
    final double statsHeaderStartTintAmount =
        isTierS ? 0.24 : ((isTierA || isTierB) ? 0.12 : 0.18);
    final double statsHeaderEndTintAmount =
        isTierS ? 0.3 : ((isTierA || isTierB) ? 0.16 : 0.22);
    final Color statsHeaderFrameColor = isTierS
        ? const Color(0xFFFF7AD1).withValues(alpha: 0.8)
        : widget.accentColor.withValues(alpha: 0.28);
    final List<Color> statsHeaderGradient = <Color>[
      Color.lerp(_bgCard, statsHeaderTint, statsHeaderStartTintAmount) ??
          _bgCard,
      Color.lerp(_bgCardAlt, statsHeaderTint, statsHeaderEndTintAmount) ??
          _bgCardAlt,
    ];
    final TextStyle statsPercentStyle = theme.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Colors.white,
          shadows: isTierS
              ? [
                  const Shadow(
                    color: Color(0xFFFF5CD6),
                    blurRadius: 12,
                  ),
                  const Shadow(
                    color: Color(0xFF8A4CFF),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ) ??
        const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Colors.white,
        );
    final TextStyle statsMetaStyle = theme.textTheme.bodySmall?.copyWith(
          color:
              hasCurrent ? Colors.white.withValues(alpha: 0.9) : Colors.white70,
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(
          color:
              hasCurrent ? Colors.white.withValues(alpha: 0.9) : Colors.white70,
          fontWeight: FontWeight.w700,
        );

    final DateFormat dateFormat =
        DateFormat.MMMd(Localizations.localeOf(context).toString());
    final String rangeLabel =
        '${dateFormat.format(currentStart)} - ${dateFormat.format(today)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            widget.deckLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statsHeaderFrameColor,
              ),
              gradient: LinearGradient(
                colors: statsHeaderGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: isTierS
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF5CD6).withValues(alpha: 0.36),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          percentText,
                          style: statsPercentStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasCurrent
                              ? l10n.statsCorrectOfTotal(
                                  effectiveSummary.correct,
                                  effectiveSummary.total,
                                )
                              : l10n.statsNoData,
                          style: statsMetaStyle,
                        ),
                      ],
                    ),
                  ),
                  if (hasTierData && tier != null) _TierBadge(tier: tier),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRangeChip(
                label: l10n.statsRangeWeek,
                selected: _range == _StatsRange.week,
                onSelected: () => _setRange(_StatsRange.week),
              ),
              const SizedBox(width: 8),
              _buildRangeChip(
                label: l10n.statsRangeMonth,
                selected: _range == _StatsRange.month,
                onSelected: () => _setRange(_StatsRange.month),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: _range == _StatsRange.week
                      ? l10n.statsThisWeek
                      : l10n.statsThisMonth,
                  summary: currentSummary,
                  accent: widget.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  label: _range == _StatsRange.week
                      ? l10n.statsLastWeek
                      : l10n.statsLastMonth,
                  summary: previousSummary,
                  accent: _bgCardAlt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.statsTrendTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _buildMascotThumb(mascotAsset, widget.accentColor),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 190,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '100%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            '50%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            '0%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: _ProgressChartPainter(
                                points: points,
                                accentColor: widget.accentColor,
                              ),
                            ),
                            if (!hasSeriesData)
                              Center(
                                child: Text(
                                  l10n.statsNoData,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rangeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setRange(_StatsRange range) {
    setState(() {
      _range = range;
    });
  }

  Widget _buildRangeChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: widget.accentColor,
      backgroundColor: _bgCardAlt,
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required _ProgressSummary summary,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final bool hasData = summary.total > 0;
    final String percentText = hasData
        ? '${(summary.percent * 100).toStringAsFixed(0)}%'
        : AppLocalizations.of(context)!.statsNoData;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percentText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasData
                ? AppLocalizations.of(context)!
                    .statsCorrectOfTotal(summary.correct, summary.total)
                : AppLocalizations.of(context)!.statsNoData,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotThumb(String asset, Color accent) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
        ),
        color: _bgCardAlt,
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  const _ProgressChartPainter({
    required this.points,
    required this.accentColor,
  });

  final List<_ProgressPoint> points;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (final double level in [0.0, 0.5, 1.0]) {
      final double y = size.height - (size.height * level);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) {
      return;
    }

    final double step =
        points.length > 1 ? size.width / (points.length - 1) : 0;
    final Paint linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint pointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.35),
          accentColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path? segmentPath;
    double? segmentStartX;
    double? segmentEndX;
    final List<Offset> pointsOffsets = <Offset>[];

    void drawSegment(Path path, double startX, double endX) {
      final Path area = Path.from(path)
        ..lineTo(endX, size.height)
        ..lineTo(startX, size.height)
        ..close();
      canvas.drawPath(area, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      final double? percent = points[i].percent;
      final double x = step * i;
      if (percent == null) {
        if (segmentPath != null &&
            segmentStartX != null &&
            segmentEndX != null) {
          drawSegment(segmentPath, segmentStartX, segmentEndX);
        }
        segmentPath = null;
        segmentStartX = null;
        segmentEndX = null;
        continue;
      }
      final double y = size.height - (percent * size.height);
      if (segmentPath == null) {
        segmentPath = Path()..moveTo(x, y);
        segmentStartX = x;
      } else {
        segmentPath.lineTo(x, y);
      }
      segmentEndX = x;
      pointsOffsets.add(Offset(x, y));
    }

    if (segmentPath != null && segmentStartX != null && segmentEndX != null) {
      drawSegment(segmentPath, segmentStartX, segmentEndX);
    }

    for (final point in pointsOffsets) {
      canvas.drawCircle(point, 2.4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.accentColor != accentColor;
  }
}

class _PepPatternPainter extends CustomPainter {
  const _PepPatternPainter({
    required this.color,
    this.gradientColors,
    this.glowColor,
    this.darkerEvery = 0,
    this.highlightEvery = 0,
    this.highlightColor,
    this.highlightGlowColor,
  });

  final Color color;
  final List<Color>? gradientColors;
  final Color? glowColor;
  final int darkerEvery;
  final int highlightEvery;
  final Color? highlightColor;
  final Color? highlightGlowColor;

  @override
  void paint(Canvas canvas, Size size) {
    const String label = '\u30da\u30e9\u30da\u30e9';
    final bool useFlatColors = gradientColors == null;
    final Color? baseGlow = useFlatColors ? color : null;

    final TextStyle baseStyle = TextStyle(
      color: color,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      shadows: baseGlow == null
          ? null
          : <Shadow>[
              Shadow(color: baseGlow.withValues(alpha: 0.46), blurRadius: 12),
              Shadow(color: baseGlow.withValues(alpha: 0.26), blurRadius: 22),
              Shadow(color: baseGlow.withValues(alpha: 0.14), blurRadius: 32),
            ],
    );

    final TextPainter measurePainter = TextPainter(
      text: TextSpan(text: label, style: baseStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final int repeatCount = (size.width / measurePainter.width).ceil() + 4;
    final String rowText = List<String>.filled(repeatCount, label).join();
    final double rowHeight = measurePainter.height + 6;
    final TextPainter? flatPainter = useFlatColors
        ? (TextPainter(
            text: TextSpan(text: rowText, style: baseStyle),
            textDirection: ui.TextDirection.ltr,
          )..layout())
        : null;

    int rowIndex = 0;
    for (double y = -rowHeight; y < size.height + rowHeight; y += rowHeight) {
      final double xJitter = (rowIndex % 4) * 8 - 10;
      final double yJitter = (rowIndex % 3) * 2 - 2;
      final Offset rowOffset = Offset(-8 + xJitter, y + yJitter);
      if (flatPainter != null) {
        flatPainter.paint(canvas, rowOffset);
      } else {
        final Paint paint = Paint()
          ..shader = LinearGradient(
            colors: gradientColors!,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Rect.fromLTWH(0, y, size.width, rowHeight));
        final TextStyle rowStyle = TextStyle(
          foreground: paint,
          fontSize: baseStyle.fontSize,
          fontWeight: baseStyle.fontWeight,
          letterSpacing: baseStyle.letterSpacing,
          shadows: baseStyle.shadows,
        );
        final TextPainter rowPainter = TextPainter(
          text: TextSpan(text: rowText, style: rowStyle),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        rowPainter.paint(canvas, rowOffset);
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant _PepPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.darkerEvery != darkerEvery ||
        oldDelegate.highlightEvery != highlightEvery ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.highlightGlowColor != highlightGlowColor;
  }
}

class _LanguageOption {
  const _LanguageOption(this.code, this.title, [this.subtitle]);

  final String? code;
  final String title;
  final String? subtitle;
}

class _CustomDeckOption {
  const _CustomDeckOption(this.id, this.label, this.kind);

  final String id;
  final String label;
  final _CustomOptionKind kind;
}

enum _CustomOptionKind { mode, rule }

class _CustomDeckResult {
  const _CustomDeckResult({
    required this.ids,
    required this.startNow,
  });

  final Set<String> ids;
  final bool startNow;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.localeOverride,
    required this.onLocaleChanged,
    required this.leftHandedMode,
    required this.onLeftHandedModeChanged,
    required this.onResetStats,
  });

  final Locale? localeOverride;
  final ValueChanged<Locale?> onLocaleChanged;
  final bool leftHandedMode;
  final ValueChanged<bool> onLeftHandedModeChanged;
  final Future<void> Function() onResetStats;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedCode;
  bool _leftHandedMode = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.localeOverride?.languageCode;
    _leftHandedMode = widget.leftHandedMode;
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCode = oldWidget.localeOverride?.languageCode;
    final newCode = widget.localeOverride?.languageCode;
    if (oldCode != newCode) {
      _selectedCode = newCode;
    }
    if (oldWidget.leftHandedMode != widget.leftHandedMode) {
      _leftHandedMode = widget.leftHandedMode;
    }
  }

  Future<void> _openFeedbackForm() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(_feedbackUrl);
    bool launched = false;
    try {
      if (kIsWeb) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      } else {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
      }
    } catch (_) {
      launched = false;
    }
    if (!mounted) {
      return;
    }
    if (!launched) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportProblemError)),
      );
    }
  }

  void _updateLocale(String? code) {
    setState(() {
      _selectedCode = code;
    });
    widget.onLocaleChanged(_localeFromCode(code));
  }

  void _updateLeftHandedMode(bool enabled) {
    setState(() {
      _leftHandedMode = enabled;
    });
    widget.onLeftHandedModeChanged(enabled);
  }

  Future<void> _confirmResetStats() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.resetStatsConfirmTitle),
          content: Text(l10n.resetStatsConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.resetStatsCancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.resetStatsConfirmButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await widget.onResetStats();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.resetStatsDone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final String? selectedCode = _selectedCode;
    final options = <_LanguageOption>[
      _LanguageOption(
        null,
        l10n.languageSystem,
        l10n.languageSystemSubtitle,
      ),
      _LanguageOption('en', l10n.languageEnglish),
      _LanguageOption('it', l10n.languageItalian),
      _LanguageOption('fr', l10n.languageFrench),
      _LanguageOption('es', l10n.languageSpanish),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgDeep, Color(0xFF1A1C20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bgDeep, Color(0xFF1B1D22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsLanguageTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.settingsLanguageSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RadioGroup<String?>(
                          groupValue: selectedCode,
                          onChanged: _updateLocale,
                          child: Column(
                            children: [
                              for (int i = 0; i < options.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                RadioListTile<String?>(
                                  value: options[i].code,
                                  title: Text(options[i].title),
                                  subtitle: options[i].subtitle == null
                                      ? null
                                      : Text(options[i].subtitle!),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(
                      Icons.back_hand_outlined,
                      color: _accentCool,
                    ),
                    title: Text(l10n.settingsLeftHandedModeTitle),
                    subtitle: Text(l10n.settingsLeftHandedModeSubtitle),
                    value: _leftHandedMode,
                    onChanged: _updateLeftHandedMode,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.refresh,
                      color: _accentWarm,
                    ),
                    title: Text(l10n.resetStatsTitle),
                    subtitle: Text(l10n.resetStatsSubtitle),
                    onTap: _confirmResetStats,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.report_problem_outlined,
                      color: _accentCoral,
                    ),
                    title: Text(l10n.reportProblemTitle),
                    subtitle: Text(l10n.reportProblemSubtitle),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: _openFeedbackForm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDeckPage extends StatefulWidget {
  const _CustomDeckPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.saveLabel,
    required this.emptyHint,
    required this.selectedCountBuilder,
    required this.options,
    required this.initialSelection,
  });

  final String title;
  final String subtitle;
  final String saveLabel;
  final String emptyHint;
  final String Function(Object) selectedCountBuilder;
  final List<_CustomDeckOption> options;
  final Set<String> initialSelection;

  @override
  State<_CustomDeckPage> createState() => _CustomDeckPageState();
}

class _CustomDeckPageState extends State<_CustomDeckPage> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.of(widget.initialSelection);
  }

  bool get _hasSelection => _selectedIds.isNotEmpty;

  void _toggleOption(String id, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _saveSelection() {
    Navigator.of(context).pop(
      _CustomDeckResult(ids: _selectedIds, startNow: false),
    );
  }

  void _startSession() {
    Navigator.of(context).pop(
      _CustomDeckResult(ids: _selectedIds, startNow: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgDeep, Color(0xFF1A1C20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bgDeep, Color(0xFF1B1D22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.selectedCountBuilder(_selectedIds.length),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_hasSelection) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.emptyHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptions(context, widget.options),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasSelection ? _startSession : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.startSession,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _saveSelection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(widget.saveLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(
    BuildContext context,
    List<_CustomDeckOption> options,
  ) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in options) _buildOptionTile(theme, option),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(ThemeData theme, _CustomDeckOption option) {
    final bool selected = _selectedIds.contains(option.id);
    final Color accent =
        option.kind == _CustomOptionKind.mode ? _accentWarm : _accentCool;
    final Color barColor = selected ? accent : accent.withValues(alpha: 0.3);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _toggleOption(option.id, !selected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _bgCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: selected ? 0.4 : 0.18),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) => _toggleOption(option.id, value ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(99),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProUpsellPage extends StatelessWidget {
  const ProUpsellPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.oneTimeLabel,
    required this.ctaLabel,
    required this.storeUnavailableLabel,
    required this.purchasePendingLabel,
    required this.alreadyUnlockedLabel,
    required this.benefitsTitle,
    required this.benefits,
    required this.rulesTitle,
    required this.rules,
    required this.verbsTitle,
    required this.verbs,
    required this.restoreLabel,
    required this.isProUser,
    required this.purchasePending,
    required this.storeReady,
    required this.storeError,
    required this.onBuy,
    required this.onRestore,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final String oneTimeLabel;
  final String ctaLabel;
  final String storeUnavailableLabel;
  final String purchasePendingLabel;
  final String alreadyUnlockedLabel;
  final String benefitsTitle;
  final List<String> benefits;
  final String rulesTitle;
  final List<String> rules;
  final String verbsTitle;
  final List<String> verbs;
  final String restoreLabel;
  final bool isProUser;
  final bool purchasePending;
  final bool storeReady;
  final String? storeError;
  final VoidCallback onBuy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String priceText = '$priceLabel - $oneTimeLabel';
    final bool canBuy = storeReady && !purchasePending && !isProUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgDeep, Color(0xFF1A1C20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bgDeep, Color(0xFF1B1D22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_proGold, _proPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.black, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        priceText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle(context, benefitsTitle),
                const SizedBox(height: 8),
                for (final benefit in benefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: _accentCool,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                _sectionTitle(context, rulesTitle),
                const SizedBox(height: 8),
                _chipWrap(context, rules),
                const SizedBox(height: 12),
                _sectionTitle(context, verbsTitle),
                const SizedBox(height: 8),
                _chipWrap(context, verbs),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: storeReady ? onRestore : null,
                  child: Text(restoreLabel),
                ),
                if (!storeReady) ...[
                  const SizedBox(height: 6),
                  Text(
                    storeUnavailableLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
                if (kDebugMode && storeError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    storeError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProUser)
                Text(
                  alreadyUnlockedLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _accentCool,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (purchasePending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    purchasePendingLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canBuy ? onBuy : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: purchasePending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(ctaLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _chipWrap(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _bgCardAlt,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
