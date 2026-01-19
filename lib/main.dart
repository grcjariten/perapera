import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perapera_trainer/trainer_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TrainerApp());
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'NotoSansJP';
    final ThemeData baseTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'perapera',
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
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: _bgCard,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.35),
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
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accentCool, width: 1.2),
          ),
        ),
      ),
      home: const TrainerHomePage(),
    );
  }
}

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

enum DeckKind { verbs, topic }

enum AppTier { free, pro }

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

class PracticeDeck {
  const PracticeDeck.verbs(this.mode)
      : kind = DeckKind.verbs,
        lesson = null,
        topic = null;

  const PracticeDeck.topic(this.lesson, this.topic)
      : kind = DeckKind.topic,
        mode = null;

  final DeckKind kind;
  final TrainerMode? mode;
  final Lesson? lesson;
  final LessonTopic? topic;

  String get label {
    if (kind == DeckKind.verbs && mode != null) {
      return mode!.label;
    }
    return topic?.title ?? '';
  }

}

class _QuestionSnapshot {
  const _QuestionSnapshot({
    required this.number,
    required this.mode,
    required this.verb,
    required this.answer,
    required this.answerReading,
  });

  final int number;
  final TrainerMode? mode;
  final VerbEntry verb;
  final String answer;
  final String answerReading;
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

const Map<String, String> _godanIMap = <String, String>{
  'う': 'い',
  'つ': 'ち',
  'る': 'り',
  'く': 'き',
  'ぐ': 'ぎ',
  'す': 'し',
  'ぶ': 'び',
  'む': 'み',
  'ぬ': 'に',
};

const Map<String, String> _godanOMap = <String, String>{
  'う': 'おう',
  'つ': 'とう',
  'る': 'ろう',
  'く': 'こう',
  'ぐ': 'ごう',
  'す': 'そう',
  'ぶ': 'ぼう',
  'む': 'もう',
  'ぬ': 'のう',
};

const Map<String, String> _godanEMap = <String, String>{
  'う': 'えば',
  'つ': 'てば',
  'る': 'れば',
  'く': 'けば',
  'ぐ': 'げば',
  'す': 'せば',
  'ぶ': 'べば',
  'む': 'めば',
  'ぬ': 'ねば',
};

String _teSurface(VerbEntry verb) =>
    verb.conjugationFor(TrainerMode.te).answer;
String _taSurface(VerbEntry verb) =>
    verb.conjugationFor(TrainerMode.ta).answer;
String _naiSurface(VerbEntry verb) =>
    verb.conjugationFor(TrainerMode.nai).answer;

String _teReading(VerbEntry verb) => verb.readingFor(TrainerMode.te);
String _taReading(VerbEntry verb) => verb.readingFor(TrainerMode.ta);
String _naiReading(VerbEntry verb) => verb.readingFor(TrainerMode.nai);

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
      return 'し';
    case VerbClass.kuru:
      return verb.dictionary.substring(0, verb.dictionary.length - 1);
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '${prefix}し';
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
      return 'し';
    case VerbClass.kuru:
      return 'き';
    case VerbClass.suruCompound:
      final String prefix =
          verb.reading.substring(0, verb.reading.length - 2);
      return '${prefix}し';
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
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}よう';
    case VerbClass.suru:
      return 'しよう';
    case VerbClass.kuru:
      return '来よう';
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '${prefix}しよう';
  }
}

String _volitionalReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanOMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.reading.substring(0, verb.reading.length - 1)}よう';
    case VerbClass.suru:
      return 'しよう';
    case VerbClass.kuru:
      return 'こよう';
    case VerbClass.suruCompound:
      final String prefix =
          verb.reading.substring(0, verb.reading.length - 2);
      return '${prefix}しよう';
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
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}れば';
    case VerbClass.suru:
      return 'すれば';
    case VerbClass.kuru:
      return 'くれば';
    case VerbClass.suruCompound:
      final String prefix =
          verb.dictionary.substring(0, verb.dictionary.length - 2);
      return '${prefix}すれば';
  }
}

String _baReading(VerbEntry verb) {
  switch (verb.verbClass) {
    case VerbClass.godan:
      final String stem = verb.reading.substring(0, verb.reading.length - 1);
      final String ending = verb.reading.substring(verb.reading.length - 1);
      return '$stem${_godanEMap[ending] ?? ''}';
    case VerbClass.ichidan:
      return '${verb.reading.substring(0, verb.reading.length - 1)}れば';
    case VerbClass.suru:
      return 'すれば';
    case VerbClass.kuru:
      return 'くれば';
    case VerbClass.suruCompound:
      final String prefix =
          verb.reading.substring(0, verb.reading.length - 2);
      return '${prefix}すれば';
  }
}

final Map<String, _VerbRule> _customRules = <String, _VerbRule>{
  '~shi': _VerbRule(
    title: '~shi',
    buildAnswer: (verb) => '${verb.dictionary}し',
    buildReading: (verb) => '${verb.reading}し',
  ),
  '~sou desu': _VerbRule(
    title: '~sou desu',
    buildAnswer: (verb) => '${_masuStemSurface(verb)}そうです',
    buildReading: (verb) => '${_masuStemReading(verb)}そうです',
  ),
  '~te miru': _VerbRule(
    title: '~te miru',
    buildAnswer: (verb) => '${_teSurface(verb)}みる',
    buildReading: (verb) => '${_teReading(verb)}みる',
  ),
  'Nara': _VerbRule(
    title: 'Nara',
    buildAnswer: (verb) => '${verb.dictionary}なら',
    buildReading: (verb) => '${verb.reading}なら',
  ),
  'hoshi': _VerbRule(
    title: 'hoshi',
    buildAnswer: (verb) => '${_teSurface(verb)}ほしい',
    buildReading: (verb) => '${_teReading(verb)}ほしい',
  ),
  'ageru/kureru/morau': _VerbRule(
    title: 'ageru/kureru/morau',
    buildAnswer: (verb) =>
        '${_teSurface(verb)}あげる / ${_teSurface(verb)}くれる / ${_teSurface(verb)}もらう',
    buildReading: (verb) =>
        '${_teReading(verb)}あげる / ${_teReading(verb)}くれる / ${_teReading(verb)}もらう',
  ),
  '~tara': _VerbRule(
    title: '~tara',
    buildAnswer: (verb) => '${_taSurface(verb)}らどうですか',
    buildReading: (verb) => '${_taReading(verb)}らどうですか',
  ),
  'number + mo / shika': _VerbRule(
    title: 'number + mo / shika',
    buildAnswer: (verb) =>
        '一回も${_naiSurface(verb)} / 一回しか${_naiSurface(verb)}',
    buildReading: (verb) =>
        'いっかいも${_naiReading(verb)} / いっかいしか${_naiReading(verb)}',
  ),
  'Volitiva': _VerbRule(
    title: 'Volitiva',
    buildAnswer: _volitionalSurface,
    buildReading: _volitionalReading,
  ),
  'Volitivo + to omotte': _VerbRule(
    title: 'Volitivo + to omotte',
    buildAnswer: (verb) => '${_volitionalSurface(verb)}と思っています',
    buildReading: (verb) => '${_volitionalReading(verb)}とおもっています',
  ),
  '~te oku': _VerbRule(
    title: '~te oku',
    buildAnswer: (verb) => '${_teSurface(verb)}おく',
    buildReading: (verb) => '${_teReading(verb)}おく',
  ),
  'Relative': _VerbRule(
    title: 'Relative',
    buildAnswer: (verb) => '${verb.dictionary}人',
    buildReading: (verb) => '${verb.reading}ひと',
  ),
  '~nagara': _VerbRule(
    title: '~nagara',
    buildAnswer: (verb) => '${_masuStemSurface(verb)}ながら',
    buildReading: (verb) => '${_masuStemReading(verb)}ながら',
  ),
  'Forma ba': _VerbRule(
    title: 'Forma ba',
    buildAnswer: _baSurface,
    buildReading: _baReading,
  ),
};

const Set<TrainerMode> _freeVerbModes = <TrainerMode>{
  TrainerMode.te,
  TrainerMode.ta,
  TrainerMode.nai,
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
  late final TrainerEngine _engine;

  final AppTier _tier = AppTier.free;

  late final AnimationController _proPulseController;
  late final Animation<double> _proPulse;

  late final List<PracticeDeck> _decks;
  PracticeDeck? _selectedDeck;
  TrainerMode? _currentQuestionMode;
  VerbEntry? _currentVerb;
  String _currentAnswer = '';
  String _currentAnswerReading = '';

  final List<_QuestionSnapshot> _questionHistory = <_QuestionSnapshot>[];
  int _historyIndex = -1;

  bool _sessionActive = false;
  bool _answerVisible = false;
  int _questionCounter = 0;

  @override
  void initState() {
    super.initState();
    _engine = TrainerEngine(verbs: _isProUser ? verbList : freeVerbList);
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
    _maybeShowTutorial();
  }

  @override
  void dispose() {
    _proPulseController.dispose();
    super.dispose();
  }

  bool _canPracticeDeck(PracticeDeck? deck) {
    if (deck == null) {
      return false;
    }
    return _isDeckAvailable(deck);
  }

  List<PracticeDeck> _buildDecks() {
    final decks = <PracticeDeck>[];
    final labels = <String>{};

    for (final mode in TrainerMode.values) {
      final deck = PracticeDeck.verbs(mode);
      if (labels.add(deck.label)) {
        decks.add(deck);
      }
    }

    for (final lesson in lessonCatalog) {
      for (final topic in lesson.topics) {
        if (!_isTopicSupported(topic)) {
          continue;
        }
        final deck = PracticeDeck.topic(lesson, topic);
        if (labels.add(deck.label)) {
          decks.add(deck);
        }
      }
    }

    return decks;
  }

  bool get _isProUser => _tier == AppTier.pro;
  bool get _hasQuestion => _currentVerb != null && _currentAnswer.isNotEmpty;

  bool _isDeckAvailable(PracticeDeck deck) {
    final resolvedRule = _resolveRule(deck);
    if (resolvedRule == null) {
      return false;
    }
    if (_isProUser) {
      return true;
    }
    if (resolvedRule.mode != null) {
      return _freeVerbModes.contains(resolvedRule.mode);
    }
    return _freeRuleTitles.contains(resolvedRule.rule?.title ?? '');
  }

  bool _isTopicSupported(LessonTopic topic) {
    if (topic.trainerMode != null) {
      return false;
    }
    return _customRules.containsKey(topic.title);
  }

  _ResolvedRule? _resolveRule(PracticeDeck deck) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('perapera'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgDeep, Color(0xFF1A1C20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!_isProUser)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildProPill(),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final double controlHeight =
                    (constraints.maxHeight * 0.48).clamp(220.0, 420.0);
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: controlHeight),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildControls(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildQuestionCard()),
                      const SizedBox(height: 12),
                      _buildBottomControls(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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

  Widget _buildControls() {
    final deck = _selectedDeck;
    final canStartSession = _canPracticeDeck(deck);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Scegli la regola',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<PracticeDeck>(
              value: deck,
              isExpanded: true,
              hint: const Text('Scegli una regola'),
              dropdownColor: _bgCard,
              icon: const Icon(Icons.expand_more),
              onChanged: (value) {
                if (value == null) return;
                _selectDeck(value);
              },
              items: _deckDropdownItems(context),
            ),
            if (!canStartSession) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Seleziona una regola disponibile per iniziare.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (!_isProUser) _buildProBanner(),
            if (!_isProUser) const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      !_sessionActive && canStartSession ? _startSession : null,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Inizia sessione'),
                ),
                if (_sessionActive)
                  OutlinedButton.icon(
                    onPressed: _stopSession,
                    icon: const Icon(Icons.stop, size: 20),
                    label: const Text('Ferma'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentCoral,
                      side: const BorderSide(color: _accentCoral),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<PracticeDeck>> _deckDropdownItems(
    BuildContext context,
  ) {
    final disabledColor = Theme.of(context).disabledColor;
    return _decks
        .map(
          (deck) {
            final bool isAvailable = _isDeckAvailable(deck);
            final bool showPro = !_isProUser && !isAvailable;
            final bool showFree = !_isProUser && isAvailable;
            return DropdownMenuItem<PracticeDeck>(
              value: deck,
              enabled: isAvailable,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      deck.label,
                      style:
                          isAvailable ? null : TextStyle(color: disabledColor),
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
                          'FREE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        const Icon(
                          Icons.star,
                          color: _proGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PRO',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _proGold,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        )
        .toList();
  }

  void _selectDeck(PracticeDeck deck) {
    setState(() {
      _selectedDeck = deck;
    });
    _resetSessionProgress();
  }

  Widget _buildQuestionCard() {
    final deck = _selectedDeck;
    final bool hasQuestion = _hasQuestion;

    final String header = deck?.label ?? 'Scegli una regola';
    final String prompt = _currentVerb?.dictionary ?? '';
    final String? promptReading = _currentVerb?.reading;
    final bool showPromptReading = _shouldShowReading(prompt, promptReading);

    if (!hasQuestion) {
      final subtitle = deck == null
          ? 'Seleziona una regola.'
          : 'Premi "Inizia sessione" per partire.';
      return _buildPlaceholderCard(header, subtitle);
    }

    final TextStyle? headerStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            );
    final TextStyle? promptStyle = Theme.of(context)
        .textTheme
        .displaySmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          child: Card(
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    header,
                    textAlign: TextAlign.center,
                    style: headerStyle,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: promptStyle,
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
                  const SizedBox(height: 12),
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _answerVisible
                            ? _buildVerbAnswer()
                            : _buildAnswerHint(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerHint() {
    return Padding(
      key: const ValueKey('answerHint'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Tocca "Mostra soluzione" quando vuoi.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hasQuestion ? _toggleAnswer : null,
                icon: Icon(
                  _answerVisible ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                label: Text(
                  _answerVisible ? 'Nascondi soluzione' : 'Mostra soluzione',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _sessionActive && _historyIndex > 0
                            ? _previousQuestion
                            : null,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Indietro'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sessionActive ? _nextQuestion : null,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('Avanti'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildProgressRow(),
          ],
        ),
      ),
    );
  }

  void _toggleAnswer() {
    setState(() {
      _answerVisible = !_answerVisible;
    });
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
          'Domanda $current/$_sessionGoal',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(_accentWarm),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProPill() {
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
                  color: _proGold.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bolt, size: 16, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  'Passa a Pro',
                  style: TextStyle(
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
                'Pro: sblocca le regole bloccate e nuovi verbi.',
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
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Passa a Pro',
                style: TextStyle(
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
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
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
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mini guida',
                      style: TextStyle(
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
                  'Scegli una regola grammaticale e esercitati.',
                ),
                const SizedBox(height: 10),
                _buildTutorialLine(
                  Icons.arrow_forward,
                  'Pensa alla risposta e poi mostra la soluzione.',
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
                    child: const Text('Ok, si parte'),
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

  void _showProUpsell() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Passa a Pro per sbloccare le regole bloccate e nuovi verbi.'),
        duration: Duration(seconds: 2),
      ),
    );
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
      children: [
        Text(
          _formattedAnswer(),
          textAlign: TextAlign.center,
          style: textStyle,
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
      ],
    );
  }

  TextStyle _answerTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle baseStyle = theme.textTheme.headlineMedium ??
        theme.textTheme.titleLarge ??
        theme.textTheme.titleMedium ??
        const TextStyle();
    final double requestedSize =
        baseStyle.fontSize != null ? max(baseStyle.fontSize!, 28) : 28;
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
      return;
    }
    setState(() {
      _sessionActive = true;
      _questionCounter = 0;
      _questionHistory.clear();
      _historyIndex = -1;
      _currentVerb = null;
      _currentQuestionMode = null;
      _currentAnswer = '';
      _currentAnswerReading = '';
    });
    _nextQuestion();
  }

  void _stopSession() {
    setState(() {
      _sessionActive = false;
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
        _answerVisible = false;
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
      _answerVisible = false;
    });
  }

  void _loadQuestion(PracticeDeck deck) {
    final resolvedRule = _resolveRule(deck);
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
      mode: resolvedMode,
      verb: verb,
      answer: answer,
      answerReading: answerReading,
    );

    setState(() {
      _questionHistory.add(snapshot);
      _historyIndex = _questionHistory.length - 1;
      _applySnapshot(snapshot);
      _answerVisible = false;
    });
  }

  void _applySnapshot(_QuestionSnapshot snapshot) {
    _currentQuestionMode = snapshot.mode;
    _currentVerb = snapshot.verb;
    _currentAnswer = snapshot.answer;
    _currentAnswerReading = snapshot.answerReading;
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
    _currentVerb = null;
    _currentQuestionMode = null;
    _currentAnswer = '';
    _currentAnswerReading = '';
    _questionHistory.clear();
    _historyIndex = -1;
    _answerVisible = false;
  }
}

