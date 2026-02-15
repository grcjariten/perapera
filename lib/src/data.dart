import 'dart:math';

enum TrainerMode {
  masu('forma ~ます'),
  te('forma ~て'),
  ta('forma ~た'),
  nai('forma ~ない'),
  potential('forma ~potenziale'),
  mix('mix casuale'),
  kamo('forma ~かもしれません');

  const TrainerMode(this.label);

  final String label;
}

enum VerbClass {
  godan,
  ichidan,
  suru,
  kuru,
  suruCompound,
}

const List<TrainerMode> mixModes = <TrainerMode>[
  TrainerMode.masu,
  TrainerMode.te,
  TrainerMode.ta,
  TrainerMode.nai,
  TrainerMode.potential,
  TrainerMode.kamo,
];

class Conjugation {
  const Conjugation(this.answer, this.note);

  final String answer;
  final String note;
}

class VerbEntry {
  const VerbEntry({
    required this.dictionary,
    required this.reading,
    required this.verbClass,
    required this.te,
    required this.ta,
    required this.nai,
    required this.potential,
  });

  final String dictionary;
  final String reading;
  final VerbClass verbClass;
  final Conjugation te;
  final Conjugation ta;
  final Conjugation nai;
  final Conjugation potential;

  Conjugation conjugationFor(TrainerMode mode) {
    switch (mode) {
      case TrainerMode.te:
        return te;
      case TrainerMode.ta:
        return ta;
      case TrainerMode.nai:
        return nai;
      case TrainerMode.masu:
        return Conjugation(_masuSurface(), '');
      case TrainerMode.potential:
        return potential;
      case TrainerMode.kamo:
        return Conjugation(
          '$dictionaryかもしれません',
          '（普通形＋かもしれません）',
        );
      case TrainerMode.mix:
        throw ArgumentError(
            'TrainerMode.mix va risolto prima di chiedere la coniugazione.');
    }
  }

  static const Map<String, String> _godanTe = <String, String>{
    'う': 'って',
    'つ': 'って',
    'る': 'って',
    'く': 'いて',
    'ぐ': 'いで',
    'す': 'して',
    'ぶ': 'んで',
    'む': 'んで',
    'ぬ': 'んで',
  };

  static const Map<String, String> _godanTa = <String, String>{
    'う': 'った',
    'つ': 'った',
    'る': 'った',
    'く': 'いた',
    'ぐ': 'いだ',
    'す': 'した',
    'ぶ': 'んだ',
    'む': 'んだ',
    'ぬ': 'んだ',
  };

  static const Map<String, String> _godanNai = <String, String>{
    'う': 'わ',
    'つ': 'た',
    'る': 'ら',
    'く': 'か',
    'ぐ': 'が',
    'す': 'さ',
    'ぶ': 'ば',
    'む': 'ま',
    'ぬ': 'な',
  };

  static const Map<String, String> _godanPotential = <String, String>{
    'う': 'え',
    'つ': 'て',
    'る': 'れ',
    'く': 'け',
    'ぐ': 'げ',
    'す': 'せ',
    'ぶ': 'べ',
    'む': 'め',
    'ぬ': 'ね',
  };

  static const Map<String, String> _godanIMap = <String, String>{
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

  static const String _masuSuffix = 'ます';
  static const String _suruMasu = 'します';
  static const String _kuruMasuReading = 'きます';

  String _masuSurface() {
    switch (verbClass) {
      case VerbClass.godan:
        final String stem = dictionary.substring(0, dictionary.length - 1);
        final String ending = dictionary.substring(dictionary.length - 1);
        return '$stem${_godanIMap[ending] ?? ''}$_masuSuffix';
      case VerbClass.ichidan:
        return '${dictionary.substring(0, dictionary.length - 1)}$_masuSuffix';
      case VerbClass.suru:
        return _suruMasu;
      case VerbClass.kuru:
        return '${dictionary.substring(0, dictionary.length - 1)}$_masuSuffix';
      case VerbClass.suruCompound:
        final String prefix = dictionary.substring(0, dictionary.length - 2);
        return '$prefix$_suruMasu';
    }
  }

  String readingFor(TrainerMode mode) {
    switch (verbClass) {
      case VerbClass.godan:
        return _readingForGodan(mode);
      case VerbClass.ichidan:
        return _readingForIchidan(mode);
      case VerbClass.suru:
        return _readingForSuru(mode, '');
      case VerbClass.kuru:
        return _readingForKuru(mode);
      case VerbClass.suruCompound:
        return _readingForSuru(mode, reading.substring(0, reading.length - 2));
    }
  }

  String _readingForGodan(TrainerMode mode) {
    if (mode == TrainerMode.mix) {
      throw ArgumentError(
          'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
    if (mode == TrainerMode.kamo) {
      return '$readingかもしれません';
    }
    final String stem = reading.substring(0, reading.length - 1);
    final String ending = reading.substring(reading.length - 1);
    switch (mode) {
      case TrainerMode.te:
        if (reading == 'いく') {
          return 'いって';
        }
        return '$stem${_godanTe[ending] ?? ''}';
      case TrainerMode.ta:
        if (reading == 'いく') {
          return 'いった';
        }
        return '$stem${_godanTa[ending] ?? ''}';
      case TrainerMode.nai:
        return '$stem${_godanNai[ending] ?? ''}ない';
      case TrainerMode.masu:
        return '$stem${_godanIMap[ending] ?? ''}$_masuSuffix';
      case TrainerMode.potential:
        return '$stem${_godanPotential[ending] ?? ''}る';
      case TrainerMode.mix:
      case TrainerMode.kamo:
        throw ArgumentError(
            'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
  }

  String _readingForIchidan(TrainerMode mode) {
    if (mode == TrainerMode.mix) {
      throw ArgumentError(
          'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
    if (mode == TrainerMode.kamo) {
      return '$readingかもしれません';
    }
    final String stem = reading.substring(0, reading.length - 1);
    switch (mode) {
      case TrainerMode.te:
        return '$stemて';
      case TrainerMode.ta:
        return '$stemた';
      case TrainerMode.nai:
        return '$stemない';
      case TrainerMode.masu:
        return '$stem$_masuSuffix';
      case TrainerMode.potential:
        return '$stemられる';
      case TrainerMode.mix:
      case TrainerMode.kamo:
        throw ArgumentError(
            'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
  }

  String _readingForSuru(TrainerMode mode, String prefix) {
    if (mode == TrainerMode.mix) {
      throw ArgumentError(
          'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
    switch (mode) {
      case TrainerMode.te:
        return '$prefixして';
      case TrainerMode.ta:
        return '$prefixした';
      case TrainerMode.nai:
        return '$prefixしない';
      case TrainerMode.masu:
        return '$prefix$_suruMasu';
      case TrainerMode.potential:
        return '$prefixできる';
      case TrainerMode.kamo:
        return '$prefixするかもしれません';
      case TrainerMode.mix:
        throw ArgumentError(
            'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
  }

  String _readingForKuru(TrainerMode mode) {
    if (mode == TrainerMode.mix) {
      throw ArgumentError(
          'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
    switch (mode) {
      case TrainerMode.te:
        return 'きて';
      case TrainerMode.ta:
        return 'きた';
      case TrainerMode.nai:
        return 'こない';
      case TrainerMode.masu:
        return _kuruMasuReading;
      case TrainerMode.potential:
        return 'こられる';
      case TrainerMode.kamo:
        return 'くるかもしれません';
      case TrainerMode.mix:
        throw ArgumentError(
            'TrainerMode.mix va risolto prima di chiedere la lettura.');
    }
  }
}

class TrainerEngine {
  TrainerEngine({Random? random, List<VerbEntry>? verbs})
      : _random = random ?? Random(),
        _pool = List<VerbEntry>.of(verbs ?? verbList) {
    _rotate();
  }

  final Random _random;
  final List<VerbEntry> _pool;
  int _cursor = 0;

  VerbEntry nextVerb() {
    if (_cursor >= _pool.length) {
      _rotate();
    }
    return _pool[_cursor++];
  }

  TrainerMode randomModeForMix() {
    return mixModes[_random.nextInt(mixModes.length)];
  }

  void _rotate() {
    _pool.shuffle(_random);
    _cursor = 0;
  }
}

const List<VerbEntry> freeVerbList = <VerbEntry>[
  VerbEntry(
    dictionary: '行く',
    reading: 'いく',
    verbClass: VerbClass.godan,
    te: Conjugation('行って', '（く→って）'),
    ta: Conjugation('行った', '（く→った）'),
    nai: Conjugation('行かない', '（く→かない）'),
    potential: Conjugation('行ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '来る',
    reading: 'くる',
    verbClass: VerbClass.kuru,
    te: Conjugation('来て', '（不規則）'),
    ta: Conjugation('来た', '（不規則）'),
    nai: Conjugation('来ない', '（不規則）'),
    potential: Conjugation('来られる', '（不規則）'),
  ),
  VerbEntry(
    dictionary: 'する',
    reading: 'する',
    verbClass: VerbClass.suru,
    te: Conjugation('して', '（不規則）'),
    ta: Conjugation('した', '（不規則）'),
    nai: Conjugation('しない', '（不規則）'),
    potential: Conjugation('できる', '（する→できる）'),
  ),
  VerbEntry(
    dictionary: '食べる',
    reading: 'たべる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('食べて', '（る→て）'),
    ta: Conjugation('食べた', '（る→た）'),
    nai: Conjugation('食べない', '（る→ない）'),
    potential: Conjugation('食べられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '飲む',
    reading: 'のむ',
    verbClass: VerbClass.godan,
    te: Conjugation('飲んで', '（む→んで）'),
    ta: Conjugation('飲んだ', '（む→んだ）'),
    nai: Conjugation('飲まない', '（む→まない）'),
    potential: Conjugation('飲める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '見る',
    reading: 'みる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('見て', '（る→て）'),
    ta: Conjugation('見た', '（る→た）'),
    nai: Conjugation('見ない', '（る→ない）'),
    potential: Conjugation('見られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '読む',
    reading: 'よむ',
    verbClass: VerbClass.godan,
    te: Conjugation('読んで', '（む→んで）'),
    ta: Conjugation('読んだ', '（む→んだ）'),
    nai: Conjugation('読まない', '（む→まない）'),
    potential: Conjugation('読める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '書く',
    reading: 'かく',
    verbClass: VerbClass.godan,
    te: Conjugation('書いて', '（く→いて）'),
    ta: Conjugation('書いた', '（く→いた）'),
    nai: Conjugation('書かない', '（く→かない）'),
    potential: Conjugation('書ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '買う',
    reading: 'かう',
    verbClass: VerbClass.godan,
    te: Conjugation('買って', '（う→って）'),
    ta: Conjugation('買った', '（う→った）'),
    nai: Conjugation('買わない', '（う→わない）'),
    potential: Conjugation('買える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '話す',
    reading: 'はなす',
    verbClass: VerbClass.godan,
    te: Conjugation('話して', '（す→して）'),
    ta: Conjugation('話した', '（す→した）'),
    nai: Conjugation('話さない', '（す→さない）'),
    potential: Conjugation('話せる', '（す→せる）'),
  ),
  VerbEntry(
    dictionary: '聞く',
    reading: 'きく',
    verbClass: VerbClass.godan,
    te: Conjugation('聞いて', '（く→いて）'),
    ta: Conjugation('聞いた', '（く→いた）'),
    nai: Conjugation('聞かない', '（く→かない）'),
    potential: Conjugation('聞ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '会う',
    reading: 'あう',
    verbClass: VerbClass.godan,
    te: Conjugation('会って', '（う→って）'),
    ta: Conjugation('会った', '（う→った）'),
    nai: Conjugation('会わない', '（う→わない）'),
    potential: Conjugation('会える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '待つ',
    reading: 'まつ',
    verbClass: VerbClass.godan,
    te: Conjugation('待って', '（つ→って）'),
    ta: Conjugation('待った', '（つ→った）'),
    nai: Conjugation('待たない', '（つ→たない）'),
    potential: Conjugation('待てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '歩く',
    reading: 'あるく',
    verbClass: VerbClass.godan,
    te: Conjugation('歩いて', '（く→いて）'),
    ta: Conjugation('歩いた', '（く→いた）'),
    nai: Conjugation('歩かない', '（く→かない）'),
    potential: Conjugation('歩ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '泳ぐ',
    reading: 'およぐ',
    verbClass: VerbClass.godan,
    te: Conjugation('泳いで', '（ぐ→いで）'),
    ta: Conjugation('泳いだ', '（ぐ→いだ）'),
    nai: Conjugation('泳がない', '（ぐ→がない）'),
    potential: Conjugation('泳げる', '（ぐ→げる）'),
  ),
  VerbEntry(
    dictionary: '死ぬ',
    reading: 'しぬ',
    verbClass: VerbClass.godan,
    te: Conjugation('死んで', '（ぬ→んで）'),
    ta: Conjugation('死んだ', '（ぬ→んだ）'),
    nai: Conjugation('死なない', '（ぬ→なない）'),
    potential: Conjugation('死ねる', '（ぬ→ねる）'),
  ),
  VerbEntry(
    dictionary: '遊ぶ',
    reading: 'あそぶ',
    verbClass: VerbClass.godan,
    te: Conjugation('遊んで', '（ぶ→んで）'),
    ta: Conjugation('遊んだ', '（ぶ→んだ）'),
    nai: Conjugation('遊ばない', '（ぶ→ばない）'),
    potential: Conjugation('遊べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '立つ',
    reading: 'たつ',
    verbClass: VerbClass.godan,
    te: Conjugation('立って', '（つ→って）'),
    ta: Conjugation('立った', '（つ→った）'),
    nai: Conjugation('立たない', '（つ→たない）'),
    potential: Conjugation('立てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '入る',
    reading: 'はいる',
    verbClass: VerbClass.godan,
    te: Conjugation('入って', '（る→って）'),
    ta: Conjugation('入った', '（る→った）'),
    nai: Conjugation('入らない', '（る→らない）'),
    potential: Conjugation('入れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '出る',
    reading: 'でる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('出て', '（る→て）'),
    ta: Conjugation('出た', '（る→た）'),
    nai: Conjugation('出ない', '（る→ない）'),
    potential: Conjugation('出られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '乗る',
    reading: 'のる',
    verbClass: VerbClass.godan,
    te: Conjugation('乗って', '（る→って）'),
    ta: Conjugation('乗った', '（る→った）'),
    nai: Conjugation('乗らない', '（る→らない）'),
    potential: Conjugation('乗れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '休む',
    reading: 'やすむ',
    verbClass: VerbClass.godan,
    te: Conjugation('休んで', '（む→んで）'),
    ta: Conjugation('休んだ', '（む→んだ）'),
    nai: Conjugation('休まない', '（む→まない）'),
    potential: Conjugation('休める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '起きる',
    reading: 'おきる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('起きて', '（る→て）'),
    ta: Conjugation('起きた', '（る→た）'),
    nai: Conjugation('起きない', '（る→ない）'),
    potential: Conjugation('起きられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '寝る',
    reading: 'ねる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('寝て', '（る→て）'),
    ta: Conjugation('寝た', '（る→た）'),
    nai: Conjugation('寝ない', '（る→ない）'),
    potential: Conjugation('寝られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '勉強する',
    reading: 'べんきょうする',
    verbClass: VerbClass.suruCompound,
    te: Conjugation('勉強して', '（する→して）'),
    ta: Conjugation('勉強した', '（する→した）'),
    nai: Conjugation('勉強しない', '（する→しない）'),
    potential: Conjugation('勉強できる', '（する→できる）'),
  ),
  VerbEntry(
    dictionary: '働く',
    reading: 'はたらく',
    verbClass: VerbClass.godan,
    te: Conjugation('働いて', '（く→いて）'),
    ta: Conjugation('働いた', '（く→いた）'),
    nai: Conjugation('働かない', '（く→かない）'),
    potential: Conjugation('働ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '使う',
    reading: 'つかう',
    verbClass: VerbClass.godan,
    te: Conjugation('使って', '（う→って）'),
    ta: Conjugation('使った', '（う→った）'),
    nai: Conjugation('使わない', '（う→わない）'),
    potential: Conjugation('使える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: 'あげる',
    reading: 'あげる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('あげて', '（る→て）'),
    ta: Conjugation('あげた', '（る→た）'),
    nai: Conjugation('あげない', '（る→ない）'),
    potential: Conjugation('あげられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: 'もらう',
    reading: 'もらう',
    verbClass: VerbClass.godan,
    te: Conjugation('もらって', '（う→って）'),
    ta: Conjugation('もらった', '（う→った）'),
    nai: Conjugation('もらわない', '（う→わない）'),
    potential: Conjugation('もらえる', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '持つ',
    reading: 'もつ',
    verbClass: VerbClass.godan,
    te: Conjugation('持って', '（つ→って）'),
    ta: Conjugation('持った', '（つ→った）'),
    nai: Conjugation('持たない', '（つ→たない）'),
    potential: Conjugation('持てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '帰る',
    reading: 'かえる',
    verbClass: VerbClass.godan,
    te: Conjugation('帰って', '（る→って）'),
    ta: Conjugation('帰った', '（る→った）'),
    nai: Conjugation('帰らない', '（る→らない）'),
    potential: Conjugation('帰れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '走る',
    reading: 'はしる',
    verbClass: VerbClass.godan,
    te: Conjugation('走って', '（る→って）'),
    ta: Conjugation('走った', '（る→った）'),
    nai: Conjugation('走らない', '（る→らない）'),
    potential: Conjugation('走れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '知る',
    reading: 'しる',
    verbClass: VerbClass.godan,
    te: Conjugation('知って', '（る→って）'),
    ta: Conjugation('知った', '（る→った）'),
    nai: Conjugation('知らない', '（る→らない）'),
    potential: Conjugation('知れる', '（る→れる）'),
  ),
];

const List<VerbEntry> premiumVerbList = <VerbEntry>[
  VerbEntry(
    dictionary: '作る',
    reading: 'つくる',
    verbClass: VerbClass.godan,
    te: Conjugation('作って', '（る→って）'),
    ta: Conjugation('作った', '（る→った）'),
    nai: Conjugation('作らない', '（る→らない）'),
    potential: Conjugation('作れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '送る',
    reading: 'おくる',
    verbClass: VerbClass.godan,
    te: Conjugation('送って', '（る→って）'),
    ta: Conjugation('送った', '（る→った）'),
    nai: Conjugation('送らない', '（る→らない）'),
    potential: Conjugation('送れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '売る',
    reading: 'うる',
    verbClass: VerbClass.godan,
    te: Conjugation('売って', '（る→って）'),
    ta: Conjugation('売った', '（る→った）'),
    nai: Conjugation('売らない', '（る→らない）'),
    potential: Conjugation('売れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '切る',
    reading: 'きる',
    verbClass: VerbClass.godan,
    te: Conjugation('切って', '（る→って）'),
    ta: Conjugation('切った', '（る→った）'),
    nai: Conjugation('切らない', '（る→らない）'),
    potential: Conjugation('切れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '取る',
    reading: 'とる',
    verbClass: VerbClass.godan,
    te: Conjugation('取って', '（る→って）'),
    ta: Conjugation('取った', '（る→った）'),
    nai: Conjugation('取らない', '（る→らない）'),
    potential: Conjugation('取れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '習う',
    reading: 'ならう',
    verbClass: VerbClass.godan,
    te: Conjugation('習って', '（う→って）'),
    ta: Conjugation('習った', '（う→った）'),
    nai: Conjugation('習わない', '（う→わない）'),
    potential: Conjugation('習える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '歌う',
    reading: 'うたう',
    verbClass: VerbClass.godan,
    te: Conjugation('歌って', '（う→って）'),
    ta: Conjugation('歌った', '（う→った）'),
    nai: Conjugation('歌わない', '（う→わない）'),
    potential: Conjugation('歌える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '払う',
    reading: 'はらう',
    verbClass: VerbClass.godan,
    te: Conjugation('払って', '（う→って）'),
    ta: Conjugation('払った', '（う→った）'),
    nai: Conjugation('払わない', '（う→わない）'),
    potential: Conjugation('払える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '拾う',
    reading: 'ひろう',
    verbClass: VerbClass.godan,
    te: Conjugation('拾って', '（う→って）'),
    ta: Conjugation('拾った', '（う→った）'),
    nai: Conjugation('拾わない', '（う→わない）'),
    potential: Conjugation('拾える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '急ぐ',
    reading: 'いそぐ',
    verbClass: VerbClass.godan,
    te: Conjugation('急いで', '（ぐ→いで）'),
    ta: Conjugation('急いだ', '（ぐ→いだ）'),
    nai: Conjugation('急がない', '（ぐ→がない）'),
    potential: Conjugation('急げる', '（ぐ→げる）'),
  ),
  VerbEntry(
    dictionary: '脱ぐ',
    reading: 'ぬぐ',
    verbClass: VerbClass.godan,
    te: Conjugation('脱いで', '（ぐ→いで）'),
    ta: Conjugation('脱いだ', '（ぐ→いだ）'),
    nai: Conjugation('脱がない', '（ぐ→がない）'),
    potential: Conjugation('脱げる', '（ぐ→げる）'),
  ),
  VerbEntry(
    dictionary: '消す',
    reading: 'けす',
    verbClass: VerbClass.godan,
    te: Conjugation('消して', '（す→して）'),
    ta: Conjugation('消した', '（す→した）'),
    nai: Conjugation('消さない', '（す→さない）'),
    potential: Conjugation('消せる', '（す→せる）'),
  ),
  VerbEntry(
    dictionary: '返す',
    reading: 'かえす',
    verbClass: VerbClass.godan,
    te: Conjugation('返して', '（す→して）'),
    ta: Conjugation('返した', '（す→した）'),
    nai: Conjugation('返さない', '（す→さない）'),
    potential: Conjugation('返せる', '（す→せる）'),
  ),
  VerbEntry(
    dictionary: '探す',
    reading: 'さがす',
    verbClass: VerbClass.godan,
    te: Conjugation('探して', '（す→して）'),
    ta: Conjugation('探した', '（す→した）'),
    nai: Conjugation('探さない', '（す→さない）'),
    potential: Conjugation('探せる', '（す→せる）'),
  ),
  VerbEntry(
    dictionary: '打つ',
    reading: 'うつ',
    verbClass: VerbClass.godan,
    te: Conjugation('打って', '（つ→って）'),
    ta: Conjugation('打った', '（つ→った）'),
    nai: Conjugation('打たない', '（つ→たない）'),
    potential: Conjugation('打てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '住む',
    reading: 'すむ',
    verbClass: VerbClass.godan,
    te: Conjugation('住んで', '（む→んで）'),
    ta: Conjugation('住んだ', '（む→んだ）'),
    nai: Conjugation('住まない', '（む→まない）'),
    potential: Conjugation('住める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '呼ぶ',
    reading: 'よぶ',
    verbClass: VerbClass.godan,
    te: Conjugation('呼んで', '（ぶ→んで）'),
    ta: Conjugation('呼んだ', '（ぶ→んだ）'),
    nai: Conjugation('呼ばない', '（ぶ→ばない）'),
    potential: Conjugation('呼べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '飛ぶ',
    reading: 'とぶ',
    verbClass: VerbClass.godan,
    te: Conjugation('飛んで', '（ぶ→んで）'),
    ta: Conjugation('飛んだ', '（ぶ→んだ）'),
    nai: Conjugation('飛ばない', '（ぶ→ばない）'),
    potential: Conjugation('飛べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '運ぶ',
    reading: 'はこぶ',
    verbClass: VerbClass.godan,
    te: Conjugation('運んで', '（ぶ→んで）'),
    ta: Conjugation('運んだ', '（ぶ→んだ）'),
    nai: Conjugation('運ばない', '（ぶ→ばない）'),
    potential: Conjugation('運べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '選ぶ',
    reading: 'えらぶ',
    verbClass: VerbClass.godan,
    te: Conjugation('選んで', '（ぶ→んで）'),
    ta: Conjugation('選んだ', '（ぶ→んだ）'),
    nai: Conjugation('選ばない', '（ぶ→ばない）'),
    potential: Conjugation('選べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '教える',
    reading: 'おしえる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('教えて', '（る→て）'),
    ta: Conjugation('教えた', '（る→た）'),
    nai: Conjugation('教えない', '（る→ない）'),
    potential: Conjugation('教えられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '覚える',
    reading: 'おぼえる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('覚えて', '（る→て）'),
    ta: Conjugation('覚えた', '（る→た）'),
    nai: Conjugation('覚えない', '（る→ない）'),
    potential: Conjugation('覚えられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '忘れる',
    reading: 'わすれる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('忘れて', '（る→て）'),
    ta: Conjugation('忘れた', '（る→た）'),
    nai: Conjugation('忘れない', '（る→ない）'),
    potential: Conjugation('忘れられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '借りる',
    reading: 'かりる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('借りて', '（る→て）'),
    ta: Conjugation('借りた', '（る→た）'),
    nai: Conjugation('借りない', '（る→ない）'),
    potential: Conjugation('借りられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '受ける',
    reading: 'うける',
    verbClass: VerbClass.ichidan,
    te: Conjugation('受けて', '（る→て）'),
    ta: Conjugation('受けた', '（る→た）'),
    nai: Conjugation('受けない', '（る→ない）'),
    potential: Conjugation('受けられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '出かける',
    reading: 'でかける',
    verbClass: VerbClass.ichidan,
    te: Conjugation('出かけて', '（る→て）'),
    ta: Conjugation('出かけた', '（る→た）'),
    nai: Conjugation('出かけない', '（る→ない）'),
    potential: Conjugation('出かけられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '始める',
    reading: 'はじめる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('始めて', '（る→て）'),
    ta: Conjugation('始めた', '（る→た）'),
    nai: Conjugation('始めない', '（る→ない）'),
    potential: Conjugation('始められる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '続ける',
    reading: 'つづける',
    verbClass: VerbClass.ichidan,
    te: Conjugation('続けて', '（る→て）'),
    ta: Conjugation('続けた', '（る→た）'),
    nai: Conjugation('続けない', '（る→ない）'),
    potential: Conjugation('続けられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: 'つける',
    reading: 'つける',
    verbClass: VerbClass.ichidan,
    te: Conjugation('つけて', '（る→て）'),
    ta: Conjugation('つけた', '（る→た）'),
    nai: Conjugation('つけない', '（る→ない）'),
    potential: Conjugation('つけられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '開ける',
    reading: 'あける',
    verbClass: VerbClass.ichidan,
    te: Conjugation('開けて', '（る→て）'),
    ta: Conjugation('開けた', '（る→た）'),
    nai: Conjugation('開けない', '（る→ない）'),
    potential: Conjugation('開けられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '閉める',
    reading: 'しめる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('閉めて', '（る→て）'),
    ta: Conjugation('閉めた', '（る→た）'),
    nai: Conjugation('閉めない', '（る→ない）'),
    potential: Conjugation('閉められる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '捨てる',
    reading: 'すてる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('捨てて', '（る→て）'),
    ta: Conjugation('捨てた', '（る→た）'),
    nai: Conjugation('捨てない', '（る→ない）'),
    potential: Conjugation('捨てられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '浴びる',
    reading: 'あびる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('浴びて', '（る→て）'),
    ta: Conjugation('浴びた', '（る→た）'),
    nai: Conjugation('浴びない', '（る→ない）'),
    potential: Conjugation('浴びられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '迎える',
    reading: 'むかえる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('迎えて', '（る→て）'),
    ta: Conjugation('迎えた', '（る→た）'),
    nai: Conjugation('迎えない', '（る→ない）'),
    potential: Conjugation('迎えられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '決める',
    reading: 'きめる',
    verbClass: VerbClass.ichidan,
    te: Conjugation('決めて', '（る→て）'),
    ta: Conjugation('決めた', '（る→た）'),
    nai: Conjugation('決めない', '（る→ない）'),
    potential: Conjugation('決められる', '（る→られる）'),
  ),
];

const List<VerbEntry> verbList = <VerbEntry>[
  ...freeVerbList,
  ...premiumVerbList,
];

const Map<String, Map<String, String>> _verbMeaningByDictionary =
    <String, Map<String, String>>{
  'あげる': {'en': 'give', 'it': 'dare', 'fr': 'donner', 'es': 'dar'},
  'する': {'en': 'do', 'it': 'fare', 'fr': 'faire', 'es': 'hacer'},
  'つける': {
    'en': 'turn on',
    'it': 'accendere',
    'fr': 'allumer',
    'es': 'encender'
  },
  'もらう': {'en': 'receive', 'it': 'ricevere', 'fr': 'recevoir', 'es': 'recibir'},
  '乗る': {'en': 'ride', 'it': 'salire', 'fr': 'monter', 'es': 'subir'},
  '休む': {'en': 'rest', 'it': 'riposare', 'fr': 'se reposer', 'es': 'descansar'},
  '会う': {
    'en': 'meet',
    'it': 'incontrare',
    'fr': 'rencontrer',
    'es': 'encontrarse'
  },
  '住む': {'en': 'live', 'it': 'vivere', 'fr': 'habiter', 'es': 'vivir'},
  '作る': {'en': 'make', 'it': 'fare', 'fr': 'fabriquer', 'es': 'hacer'},
  '使う': {'en': 'use', 'it': 'usare', 'fr': 'utiliser', 'es': 'usar'},
  '借りる': {
    'en': 'borrow',
    'it': 'prendere in prestito',
    'fr': 'emprunter',
    'es': 'pedir prestado'
  },
  '働く': {'en': 'work', 'it': 'lavorare', 'fr': 'travailler', 'es': 'trabajar'},
  '入る': {'en': 'enter', 'it': 'entrare', 'fr': 'entrer', 'es': 'entrar'},
  '出かける': {'en': 'go out', 'it': 'uscire', 'fr': 'sortir', 'es': 'salir'},
  '出る': {'en': 'leave', 'it': 'uscire', 'fr': 'sortir', 'es': 'salir'},
  '切る': {'en': 'cut', 'it': 'tagliare', 'fr': 'couper', 'es': 'cortar'},
  '勉強する': {'en': 'study', 'it': 'studiare', 'fr': 'etudier', 'es': 'estudiar'},
  '取る': {'en': 'take', 'it': 'prendere', 'fr': 'prendre', 'es': 'tomar'},
  '受ける': {'en': 'take', 'it': 'prendere', 'fr': 'prendre', 'es': 'tomar'},
  '呼ぶ': {'en': 'call', 'it': 'chiamare', 'fr': 'appeler', 'es': 'llamar'},
  '売る': {'en': 'sell', 'it': 'vendere', 'fr': 'vendre', 'es': 'vender'},
  '始める': {'en': 'start', 'it': 'iniziare', 'fr': 'commencer', 'es': 'empezar'},
  '寝る': {'en': 'sleep', 'it': 'dormire', 'fr': 'dormir', 'es': 'dormir'},
  '帰る': {
    'en': 'go home',
    'it': 'tornare',
    'fr': 'rentrer',
    'es': 'volver a casa'
  },
  '待つ': {'en': 'wait', 'it': 'aspettare', 'fr': 'attendre', 'es': 'esperar'},
  '忘れる': {
    'en': 'forget',
    'it': 'dimenticare',
    'fr': 'oublier',
    'es': 'olvidar'
  },
  '急ぐ': {
    'en': 'hurry',
    'it': 'sbrigarsi',
    'fr': 'se depecher',
    'es': 'darse prisa'
  },
  '打つ': {'en': 'hit', 'it': 'colpire', 'fr': 'frapper', 'es': 'golpear'},
  '払う': {'en': 'pay', 'it': 'pagare', 'fr': 'payer', 'es': 'pagar'},
  '拾う': {
    'en': 'pick up',
    'it': 'raccogliere',
    'fr': 'ramasser',
    'es': 'recoger'
  },
  '持つ': {'en': 'hold', 'it': 'tenere', 'fr': 'tenir', 'es': 'sostener'},
  '捨てる': {'en': 'throw away', 'it': 'buttare', 'fr': 'jeter', 'es': 'tirar'},
  '探す': {'en': 'look for', 'it': 'cercare', 'fr': 'chercher', 'es': 'buscar'},
  '教える': {'en': 'teach', 'it': 'insegnare', 'fr': 'enseigner', 'es': 'ensenar'},
  '書く': {'en': 'write', 'it': 'scrivere', 'fr': 'ecrire', 'es': 'escribir'},
  '来る': {'en': 'come', 'it': 'venire', 'fr': 'venir', 'es': 'venir'},
  '歌う': {'en': 'sing', 'it': 'cantare', 'fr': 'chanter', 'es': 'cantar'},
  '歩く': {'en': 'walk', 'it': 'camminare', 'fr': 'marcher', 'es': 'caminar'},
  '死ぬ': {'en': 'die', 'it': 'morire', 'fr': 'mourir', 'es': 'morir'},
  '決める': {'en': 'decide', 'it': 'decidere', 'fr': 'decider', 'es': 'decidir'},
  '泳ぐ': {'en': 'swim', 'it': 'nuotare', 'fr': 'nager', 'es': 'nadar'},
  '浴びる': {
    'en': 'shower',
    'it': 'fare la doccia',
    'fr': 'se doucher',
    'es': 'ducharse'
  },
  '消す': {'en': 'turn off', 'it': 'spegnere', 'fr': 'eteindre', 'es': 'apagar'},
  '知る': {'en': 'know', 'it': 'sapere', 'fr': 'savoir', 'es': 'saber'},
  '立つ': {
    'en': 'stand',
    'it': 'alzarsi',
    'fr': 'se tenir debout',
    'es': 'ponerse de pie'
  },
  '続ける': {
    'en': 'continue',
    'it': 'continuare',
    'fr': 'continuer',
    'es': 'continuar'
  },
  '習う': {'en': 'learn', 'it': 'imparare', 'fr': 'apprendre', 'es': 'aprender'},
  '聞く': {'en': 'listen', 'it': 'ascoltare', 'fr': 'ecouter', 'es': 'escuchar'},
  '脱ぐ': {
    'en': 'take off',
    'it': 'togliersi',
    'fr': 'enlever',
    'es': 'quitarse'
  },
  '行く': {'en': 'go', 'it': 'andare', 'fr': 'aller', 'es': 'ir'},
  '見る': {'en': 'see', 'it': 'vedere', 'fr': 'voir', 'es': 'ver'},
  '覚える': {
    'en': 'remember',
    'it': 'ricordare',
    'fr': 'memoriser',
    'es': 'recordar'
  },
  '話す': {'en': 'speak', 'it': 'parlare', 'fr': 'parler', 'es': 'hablar'},
  '読む': {'en': 'read', 'it': 'leggere', 'fr': 'lire', 'es': 'leer'},
  '買う': {'en': 'buy', 'it': 'comprare', 'fr': 'acheter', 'es': 'comprar'},
  '走る': {'en': 'run', 'it': 'correre', 'fr': 'courir', 'es': 'correr'},
  '起きる': {
    'en': 'wake up',
    'it': 'svegliarsi',
    'fr': 'se reveiller',
    'es': 'despertarse'
  },
  '迎える': {
    'en': 'pick up',
    'it': 'andare a prendere',
    'fr': 'aller chercher',
    'es': 'ir a recoger'
  },
  '返す': {'en': 'return', 'it': 'restituire', 'fr': 'rendre', 'es': 'devolver'},
  '送る': {'en': 'send', 'it': 'inviare', 'fr': 'envoyer', 'es': 'enviar'},
  '遊ぶ': {'en': 'play', 'it': 'giocare', 'fr': 'jouer', 'es': 'jugar'},
  '運ぶ': {
    'en': 'carry',
    'it': 'trasportare',
    'fr': 'transporter',
    'es': 'llevar'
  },
  '選ぶ': {'en': 'choose', 'it': 'scegliere', 'fr': 'choisir', 'es': 'elegir'},
  '閉める': {'en': 'close', 'it': 'chiudere', 'fr': 'fermer', 'es': 'cerrar'},
  '開ける': {'en': 'open', 'it': 'aprire', 'fr': 'ouvrir', 'es': 'abrir'},
  '飛ぶ': {'en': 'fly', 'it': 'volare', 'fr': 'voler', 'es': 'volar'},
  '食べる': {'en': 'eat', 'it': 'mangiare', 'fr': 'manger', 'es': 'comer'},
  '飲む': {'en': 'drink', 'it': 'bere', 'fr': 'boire', 'es': 'beber'},
};

String localizedVerbMeaning(VerbEntry verb, String languageCode) {
  final Map<String, String>? meanings =
      _verbMeaningByDictionary[verb.dictionary];
  if (meanings == null || meanings.isEmpty) {
    return '';
  }
  return meanings[languageCode] ?? meanings['en'] ?? '';
}

String englishVerbMeaning(VerbEntry verb) {
  return localizedVerbMeaning(verb, 'en');
}
