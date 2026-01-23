import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:perapera_trainer/l10n/app_localizations.dart';
import 'package:perapera_trainer/trainer_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/premium_flags.dart';

void main() {
  runApp(const TrainerApp());
}

const String _localeOverrideKey = 'perapera_locale_override';
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
const String _proEntitlementCheckKey = 'perapera_pro_entitlement_check';
const Duration _proEntitlementCheckCooldown = Duration(days: 7);
const Duration _proEntitlementCheckTimeout = Duration(seconds: 8);

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

class _QuestionSnapshot {
  const _QuestionSnapshot({
    required this.number,
    required this.deck,
    required this.mode,
    required this.verb,
    required this.answer,
    required this.answerReading,
    required this.answerVisible,
  });

  final int number;
  final PracticeDeck deck;
  final TrainerMode? mode;
  final VerbEntry verb;
  final String answer;
  final String answerReading;
  final bool answerVisible;

  _QuestionSnapshot copyWith({bool? answerVisible}) {
    return _QuestionSnapshot(
      number: number,
      deck: deck,
      mode: mode,
      verb: verb,
      answer: answer,
      answerReading: answerReading,
      answerVisible: answerVisible ?? this.answerVisible,
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

const Map<String, String> _godanIMap = <String, String>{
  'う': 'い',
  'く': 'き',
  'ぐ': 'ぎ',
  'す': 'し',
  'つ': 'ち',
  'ぬ': 'に',
  'ぶ': 'び',
  'む': 'み',
  'る': 'り',
};

const Map<String, String> _godanOMap = <String, String>{
  'う': 'おう',
  'く': 'こう',
  'ぐ': 'ごう',
  'す': 'そう',
  'つ': 'とう',
  'ぬ': 'のう',
  'ぶ': 'ぼう',
  'む': 'もう',
  'る': 'ろう',
};

const Map<String, String> _godanEMap = <String, String>{
  'う': 'えば',
  'く': 'けば',
  'ぐ': 'げば',
  'す': 'せば',
  'つ': 'てば',
  'ぬ': 'ねば',
  'ぶ': 'べば',
  'む': 'めば',
  'る': 'れば',
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
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}よう';
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
      return '${verb.dictionary.substring(0, verb.dictionary.length - 1)}れば';
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
      return '${verb.reading.substring(0, verb.reading.length - 1)}れば';
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
    buildAnswer: (verb) => '${_taSurface(verb)}ら',
    buildReading: (verb) => '${_taReading(verb)}ら',
  ),
  'number + mo / shika': _VerbRule(
    title: 'number + mo / shika',
    buildAnswer: (verb) =>
        '一つも${_naiSurface(verb)} / 一つしか${_naiSurface(verb)}',
    buildReading: (verb) =>
        'ひとつも${_naiReading(verb)} / ひとつしか${_naiReading(verb)}',
  ),
  'Volitiva': _VerbRule(
    title: 'Volitiva',
    buildAnswer: _volitionalSurface,
    buildReading: _volitionalReading,
  ),
  'Volitivo + to omotte': _VerbRule(
    title: 'Volitivo + to omotte',
    buildAnswer: (verb) => '${_volitionalSurface(verb)}と思って',
    buildReading: (verb) => '${_volitionalReading(verb)}とおもって',
  ),
  '~te oku': _VerbRule(
    title: '~te oku',
    buildAnswer: (verb) => '${_teSurface(verb)}おく',
    buildReading: (verb) => '${_teReading(verb)}おく',
  ),
  'Relative': _VerbRule(
    title: 'Relative',
    buildAnswer: (verb) => '${verb.dictionary}時',
    buildReading: (verb) => '${verb.reading}とき',
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

  final List<_QuestionSnapshot> _questionHistory = <_QuestionSnapshot>[];
  int _historyIndex = -1;

  bool _sessionActive = false;
  bool _answerVisible = false;
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
    _maybeShowTutorial();
    _loadTier();
    _initInAppPurchase();
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

    final customDeck = const PracticeDeck.custom();
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
    return WillPopScope(
      onWillPop: () async {
        if (!_sessionActive) {
          return true;
        }
        _stopSession();
        return false;
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
            IconButton(
              onPressed: _openSettings,
              tooltip: l10n.settingsTitle,
              icon: const Icon(Icons.settings),
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
              if (_sessionActive) _buildSessionBody() else _buildSelectionBody(),
            ],
          ),
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

  Widget _buildSelectionBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = min(constraints.maxWidth, 680);
        final double minHeight = max(420, constraints.maxHeight * 0.62);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          localeOverride: widget.localeOverride,
          onLocaleChanged: widget.onLocaleChanged,
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
    final canStartSession = _canPracticeDeck(deck);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bool deckAvailable = deck != null && _isDeckAvailable(deck);
    final bool customSelectionEmpty =
        deck?.kind == DeckKind.custom &&
        deckAvailable &&
        _activeCustomDeckIds().isEmpty;
    final bool showUnavailableHint = deck != null && !deckAvailable;

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
                DropdownButtonFormField<PracticeDeck>(
                  value: deck,
                  isExpanded: true,
                  hint: Text(l10n.chooseRuleHint),
                  dropdownColor: _bgCard,
                  icon: const Icon(Icons.expand_more),
                  selectedItemBuilder: (context) {
                    return _decks
                        .map(
                          (deck) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_deckLabel(deck, l10n)),
                          ),
                        )
                        .toList();
                  },
                  onChanged: (value) {
                    if (value == null) return;
                    _handleDeckSelection(value);
                  },
                  items: _deckDropdownItems(context),
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
                if (showProBanners && !_isProUser) ...[
                  const SizedBox(height: 16),
                  _buildProBanner(),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canStartSession ? _startSession : null,
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: Text(l10n.startSession),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<PracticeDeck>> _deckDropdownItems(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;
    final l10n = AppLocalizations.of(context)!;
    return _decks
        .map(
          (deck) {
            final bool isAvailable = _isDeckAvailable(deck);
            final bool showBadges = showProBadges && !_isProUser;
            final bool showPro = showBadges && !isAvailable;
            final bool showFree = showBadges && isAvailable;
            final deckLabel = _deckLabel(deck, l10n);
            final Color proBadgeColor =
                isAvailable ? _proGold : disabledColor;
            final Color accentBase = _deckAccentColor(deck);
            final bool isDimmed = !isAvailable;
            final Color accent = isDimmed
                ? theme.hintColor.withOpacity(0.4)
                : accentBase;
            final Color labelColor =
                isAvailable ? Colors.white : disabledColor;
            final Color tileColor = isDimmed
                ? _bgCardAlt.withOpacity(0.55)
                : _bgCardAlt;
            final Color borderColor = isDimmed
                ? Colors.white.withOpacity(0.08)
                : accentBase.withOpacity(0.22);
            return DropdownMenuItem<PracticeDeck>(
              value: deck,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  color: accent.withOpacity(0.35),
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
        )
        .toList();
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
    final String prompt = _currentVerb?.dictionary ?? '';
    final String? promptReading = _currentVerb?.reading;
    final bool showPromptReading = _shouldShowReading(prompt, promptReading);

    if (!hasQuestion) {
      final subtitle = deck == null
          ? l10n.selectRuleToBegin
          : l10n.preparingFirstQuestion;
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _sessionActive && _historyIndex > 0
                            ? _previousQuestion
                            : null,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: Text(l10n.backButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canNavigate ? _handleForwardAction : null,
                    icon: Icon(
                      showSolutionStep
                          ? Icons.visibility
                          : Icons.arrow_forward,
                      size: 20,
                    ),
                    label: Text(
                      showSolutionStep
                          ? l10n.showSolutionButton
                          : l10n.nextButton,
                    ),
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

  void _revealAnswer() {
    if (_answerVisible || !_hasQuestion) {
      return;
    }
    setState(() {
      _answerVisible = true;
      _markAnswerVisible();
    });
  }

  void _markAnswerVisible() {
    if (_historyIndex < 0 || _historyIndex >= _questionHistory.length) {
      return;
    }
    final current = _questionHistory[_historyIndex];
    if (current.answerVisible) {
      return;
    }
    _questionHistory[_historyIndex] =
        current.copyWith(answerVisible: true);
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
              backgroundColor: Colors.white.withOpacity(0.08),
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
                  color: _proGold.withOpacity(0.35),
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
                color: Colors.black.withOpacity(0.18),
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
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
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
  });

  final Locale? localeOverride;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.localeOverride?.languageCode;
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCode = oldWidget.localeOverride?.languageCode;
    final newCode = widget.localeOverride?.languageCode;
    if (oldCode != newCode) {
      _selectedCode = newCode;
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
                        for (int i = 0; i < options.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          RadioListTile<String?>(
                            value: options[i].code,
                            groupValue: selectedCode,
                            onChanged: _updateLocale,
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
            for (final option in options)
              _buildOptionTile(theme, option),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(ThemeData theme, _CustomDeckOption option) {
    final bool selected = _selectedIds.contains(option.id);
    final Color accent = option.kind == _CustomOptionKind.mode
        ? _accentWarm
        : _accentCool;
    final Color barColor =
        selected ? accent : accent.withOpacity(0.3);
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
            color: accent.withOpacity(selected ? 0.4 : 0.18),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) =>
                  _toggleOption(option.id, value ?? false),
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
                          color: accent.withOpacity(0.35),
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
    final String priceText = '$priceLabel • $oneTimeLabel';
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
                border: Border.all(color: Colors.white.withOpacity(0.06)),
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






