import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perapera_trainer/trainer_core.dart';

void main() {
  runApp(const TrainerApp());
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perapera Trainer',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF81C784),
          secondary: Color(0xFF64B5F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2C2C2C),
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
      return '[Verbi] ${mode!.label}';
    }
    final lessonNumber = lesson?.number ?? 0;
    final topicLabel = topic?.title ?? '';
    return '[Cap $lessonNumber] $topicLabel';
  }
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  final TrainerEngine _engine = TrainerEngine();
  final Random _random = Random();

  late final List<PracticeDeck> _decks;
  PracticeDeck? _selectedDeck;
  TrainerMode? _currentQuestionMode;
  VerbEntry? _currentVerb;
  Conjugation? _currentConjugation;
  LessonTopic? _currentLessonTopic;
  PracticeCard? _currentCard;

  bool _sessionActive = false;
  bool _answerVisible = false;
  int _questionCounter = 0;

  @override
  void initState() {
    super.initState();
    _decks = <PracticeDeck>[
      for (final mode in TrainerMode.values) PracticeDeck.verbs(mode),
      for (final lesson in lessonCatalog)
        for (final topic in lesson.topics) PracticeDeck.topic(lesson, topic),
    ];
    _selectedDeck = _decks.isNotEmpty ? _decks.first : null;
  }

  bool _canPracticeDeck(PracticeDeck? deck) {
    if (deck == null) {
      return false;
    }
    if (deck.kind == DeckKind.verbs && deck.mode != null) {
      return true;
    }
    if (deck.kind == DeckKind.topic) {
      if (deck.topic?.trainerMode != null) {
        return true;
      }
      if (deck.topic?.cards.isNotEmpty ?? false) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('perapera - allenamento'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double controlHeight =
                (constraints.maxHeight * 0.5).clamp(220.0, 420.0);
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildQuestionCard()),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: controlHeight),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildControls(),
                    ),
                  ),
                ],
              ),
            );
          },
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
            Text(
              'Seleziona il deck',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<PracticeDeck>(
              value: deck,
              isExpanded: true,
              hint: const Text('Scegli una modalita o una regola'),
              onChanged: (value) {
                if (value == null) return;
                _selectDeck(value);
              },
              items: _deckDropdownItems(context),
            ),
            if (deck != null) ...[
              const SizedBox(height: 4),
              Text(
                _canPracticeDeck(deck)
                    ? 'Esercizio automatico disponibile.'
                    : 'Esercizio automatico in arrivo per questa regola.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      !_sessionActive && canStartSession ? _startSession : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Inizia sessione'),
                ),
                if (_sessionActive)
                  OutlinedButton.icon(
                    onPressed: _stopSession,
                    icon: const Icon(Icons.stop),
                    label: const Text('Ferma'),
                  ),
              ],
            ),
            if (!canStartSession)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Seleziona una modalita o un argomento con esercizi automatici.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
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
          (deck) => DropdownMenuItem<PracticeDeck>(
            value: deck,
            child: Text(
              deck.label,
              style: _canPracticeDeck(deck)
                  ? null
                  : TextStyle(color: disabledColor),
            ),
          ),
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
    final bool usesTopicCards = deck != null &&
        deck.kind == DeckKind.topic &&
        (deck.topic?.trainerMode == null) &&
        (deck.topic?.cards.isNotEmpty ?? false);
    final bool usesVerbPractice = deck != null &&
        !usesTopicCards &&
        (deck.kind == DeckKind.verbs ||
            (deck.kind == DeckKind.topic &&
                deck.topic?.trainerMode != null));

    final bool hasVerbQuestion = usesVerbPractice &&
        _currentVerb != null &&
        _currentQuestionMode != null;
    final bool hasTopicQuestion =
        usesTopicCards && _currentCard != null && _currentLessonTopic != null;
    final bool hasQuestion = hasVerbQuestion || hasTopicQuestion;

    final String header = deck?.label ?? 'Scegli un deck';
    final String prompt = usesVerbPractice
        ? (_currentVerb?.dictionary ?? '')
        : usesTopicCards
            ? (_currentCard?.prompt ?? '')
            : (_currentLessonTopic?.title ?? '');

    if (!hasQuestion) {
      final subtitle = deck == null
          ? 'Seleziona una modalita o un argomento.'
          : 'Premi "Inizia sessione" per partire.';
      return _buildPlaceholderCard(header, subtitle);
    }

    final TextStyle? headerStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    final TextStyle? promptStyle = Theme.of(context)
        .textTheme
        .headlineLarge
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
                  if (usesTopicCards && _currentLessonTopic != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _topicTypeLabel(_currentLessonTopic!.type),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _answerVisible
                          ? (usesVerbPractice
                              ? _buildVerbAnswer()
                              : _buildTopicCardAnswer())
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _answerVisible = !_answerVisible;
                        });
                      },
                      icon: Icon(
                        _answerVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label: Text(
                        _answerVisible
                            ? 'Nascondi soluzione'
                            : 'Mostra soluzione',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _sessionActive ? _nextQuestion : null,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Domanda successiva'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Q$_questionCounter',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final conjugation = _currentConjugation;
    if (conjugation == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Text(
          _formattedAnswer(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        if (conjugation.note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            conjugation.note,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTopicCardAnswer() {
    final card = _currentCard;
    if (card == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          card.answer,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        if (card.note != null && card.note!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            card.note!,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _topicTypeLabel(LessonTopicType type) {
    switch (type) {
      case LessonTopicType.culture:
        return 'Nota culturale';
      case LessonTopicType.expressions:
        return 'Espressioni utili';
      case LessonTopicType.grammar:
      default:
        return 'Grammatica';
    }
  }

  String _formattedAnswer() {
    final answer = _currentConjugation?.answer ?? '';
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

  void _startSession() {
    final deck = _selectedDeck;
    if (!_canPracticeDeck(deck)) {
      return;
    }
    setState(() {
      _sessionActive = true;
      _questionCounter = 0;
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
    if (deck == null) {
      return;
    }
    if (deck.kind == DeckKind.verbs && deck.mode != null) {
      _loadVerbQuestion(deck.mode!);
    } else if (deck.kind == DeckKind.topic) {
      final topic = deck.topic;
      if (topic == null) {
        return;
      }
      if (topic.trainerMode != null) {
        _loadVerbQuestion(topic.trainerMode!, topic: topic);
      } else if (topic.cards.isNotEmpty) {
        _loadTopicCard(topic);
      }
    }
  }

  void _loadVerbQuestion(TrainerMode mode, {LessonTopic? topic}) {
    final resolvedMode =
        mode == TrainerMode.mix ? _engine.randomModeForMix() : mode;
    final verb = _engine.nextVerb();
    final conjugation = verb.conjugationFor(resolvedMode);

    setState(() {
      _questionCounter++;
      _currentQuestionMode = resolvedMode;
      _currentVerb = verb;
      _currentConjugation = conjugation;
      _currentLessonTopic = topic;
      _currentCard = null;
      _answerVisible = false;
    });
  }

  void _loadTopicCard(LessonTopic topic) {
    if (topic.cards.isEmpty) {
      return;
    }
    final card = topic.cards[_random.nextInt(topic.cards.length)];
    setState(() {
      _questionCounter++;
      _currentQuestionMode = null;
      _currentVerb = null;
      _currentConjugation = null;
      _currentLessonTopic = topic;
      _currentCard = card;
      _answerVisible = false;
    });
  }

  void _resetSessionProgress() {
    _sessionActive = false;
    _questionCounter = 0;
    _currentVerb = null;
    _currentConjugation = null;
    _currentQuestionMode = null;
    _currentLessonTopic = null;
    _currentCard = null;
    _answerVisible = false;
  }
}
