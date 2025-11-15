import 'dart:math';

enum TrainerMode {
  te('forma て'),
  ta('forma た'),
  nai('forma ない'),
  potential('forma potenziale'),
  mix('mix casuale'),
  kamo('forma かもしれません');

  const TrainerMode(this.label);

  final String label;
}

const List<TrainerMode> mixModes = <TrainerMode>[
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
    required this.te,
    required this.ta,
    required this.nai,
    required this.potential,
  });

  final String dictionary;
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
      case TrainerMode.potential:
        return potential;
      case TrainerMode.kamo:
        return Conjugation(
          '$dictionaryかもしれません',
          '（普通形＋かもしれません）',
        );
      case TrainerMode.mix:
        throw ArgumentError('TrainerMode.mix va risolto prima di chiedere la coniugazione.');
    }
  }
}

class TrainerEngine {
  TrainerEngine({Random? random})
      : _random = random ?? Random(),
        _pool = List<VerbEntry>.of(verbList) {
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

const List<VerbEntry> verbList = <VerbEntry>[
  VerbEntry(
    dictionary: '行く',
    te: Conjugation('行って', '（く→って）'),
    ta: Conjugation('行った', '（く→った）'),
    nai: Conjugation('行かない', '（く→かない）'),
    potential: Conjugation('行ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '来る',
    te: Conjugation('来て', '（不規則）'),
    ta: Conjugation('来た', '（不規則）'),
    nai: Conjugation('来ない', '（不規則）'),
    potential: Conjugation('来られる', '（不規則）'),
  ),
  VerbEntry(
    dictionary: 'する',
    te: Conjugation('して', '（不規則）'),
    ta: Conjugation('した', '（不規則）'),
    nai: Conjugation('しない', '（不規則）'),
    potential: Conjugation('できる', '（する→できる）'),
  ),
  VerbEntry(
    dictionary: '食べる',
    te: Conjugation('食べて', '（る→て）'),
    ta: Conjugation('食べた', '（る→た）'),
    nai: Conjugation('食べない', '（る→ない）'),
    potential: Conjugation('食べられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '飲む',
    te: Conjugation('飲んで', '（む→んで）'),
    ta: Conjugation('飲んだ', '（む→んだ）'),
    nai: Conjugation('飲まない', '（む→まない）'),
    potential: Conjugation('飲める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '見る',
    te: Conjugation('見て', '（る→て）'),
    ta: Conjugation('見た', '（る→た）'),
    nai: Conjugation('見ない', '（る→ない）'),
    potential: Conjugation('見られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '読む',
    te: Conjugation('読んで', '（む→んで）'),
    ta: Conjugation('読んだ', '（む→んだ）'),
    nai: Conjugation('読まない', '（む→まない）'),
    potential: Conjugation('読める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '書く',
    te: Conjugation('書いて', '（く→いて）'),
    ta: Conjugation('書いた', '（く→いた）'),
    nai: Conjugation('書かない', '（く→かない）'),
    potential: Conjugation('書ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '買う',
    te: Conjugation('買って', '（う→って）'),
    ta: Conjugation('買った', '（う→った）'),
    nai: Conjugation('買わない', '（う→わない）'),
    potential: Conjugation('買える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '話す',
    te: Conjugation('話して', '（す→して）'),
    ta: Conjugation('話した', '（す→した）'),
    nai: Conjugation('話さない', '（す→さない）'),
    potential: Conjugation('話せる', '（す→せる）'),
  ),
  VerbEntry(
    dictionary: '聞く',
    te: Conjugation('聞いて', '（く→いて）'),
    ta: Conjugation('聞いた', '（く→いた）'),
    nai: Conjugation('聞かない', '（く→かない）'),
    potential: Conjugation('聞ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '会う',
    te: Conjugation('会って', '（う→って）'),
    ta: Conjugation('会った', '（う→った）'),
    nai: Conjugation('会わない', '（う→わない）'),
    potential: Conjugation('会える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '待つ',
    te: Conjugation('待って', '（つ→って）'),
    ta: Conjugation('待った', '（つ→った）'),
    nai: Conjugation('待たない', '（つ→たない）'),
    potential: Conjugation('待てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '歩く',
    te: Conjugation('歩いて', '（く→いて）'),
    ta: Conjugation('歩いた', '（く→いた）'),
    nai: Conjugation('歩かない', '（く→かない）'),
    potential: Conjugation('歩ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '泳ぐ',
    te: Conjugation('泳いで', '（ぐ→いで）'),
    ta: Conjugation('泳いだ', '（ぐ→いだ）'),
    nai: Conjugation('泳がない', '（ぐ→がない）'),
    potential: Conjugation('泳げる', '（ぐ→げる）'),
  ),
  VerbEntry(
    dictionary: '死ぬ',
    te: Conjugation('死んで', '（ぬ→んで）'),
    ta: Conjugation('死んだ', '（ぬ→んだ）'),
    nai: Conjugation('死なない', '（ぬ→なない）'),
    potential: Conjugation('死ねる', '（ぬ→ねる）'),
  ),
  VerbEntry(
    dictionary: '遊ぶ',
    te: Conjugation('遊んで', '（ぶ→んで）'),
    ta: Conjugation('遊んだ', '（ぶ→んだ）'),
    nai: Conjugation('遊ばない', '（ぶ→ばない）'),
    potential: Conjugation('遊べる', '（ぶ→べる）'),
  ),
  VerbEntry(
    dictionary: '立つ',
    te: Conjugation('立って', '（つ→って）'),
    ta: Conjugation('立った', '（つ→った）'),
    nai: Conjugation('立たない', '（つ→たない）'),
    potential: Conjugation('立てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '入る',
    te: Conjugation('入って', '（る→って）'),
    ta: Conjugation('入った', '（る→った）'),
    nai: Conjugation('入らない', '（る→らない）'),
    potential: Conjugation('入れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '出る',
    te: Conjugation('出て', '（る→て）'),
    ta: Conjugation('出た', '（る→た）'),
    nai: Conjugation('出ない', '（る→ない）'),
    potential: Conjugation('出られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '乗る',
    te: Conjugation('乗って', '（る→って）'),
    ta: Conjugation('乗った', '（る→った）'),
    nai: Conjugation('乗らない', '（る→らない）'),
    potential: Conjugation('乗れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '休む',
    te: Conjugation('休んで', '（む→んで）'),
    ta: Conjugation('休んだ', '（む→んだ）'),
    nai: Conjugation('休まない', '（む→まない）'),
    potential: Conjugation('休める', '（む→める）'),
  ),
  VerbEntry(
    dictionary: '起きる',
    te: Conjugation('起きて', '（る→て）'),
    ta: Conjugation('起きた', '（る→た）'),
    nai: Conjugation('起きない', '（る→ない）'),
    potential: Conjugation('起きられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '寝る',
    te: Conjugation('寝て', '（る→て）'),
    ta: Conjugation('寝た', '（る→た）'),
    nai: Conjugation('寝ない', '（る→ない）'),
    potential: Conjugation('寝られる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: '勉強する',
    te: Conjugation('勉強して', '（する→して）'),
    ta: Conjugation('勉強した', '（する→した）'),
    nai: Conjugation('勉強しない', '（する→しない）'),
    potential: Conjugation('勉強できる', '（する→できる）'),
  ),
  VerbEntry(
    dictionary: '働く',
    te: Conjugation('働いて', '（く→いて）'),
    ta: Conjugation('働いた', '（く→いた）'),
    nai: Conjugation('働かない', '（く→かない）'),
    potential: Conjugation('働ける', '（く→ける）'),
  ),
  VerbEntry(
    dictionary: '使う',
    te: Conjugation('使って', '（う→って）'),
    ta: Conjugation('使った', '（う→った）'),
    nai: Conjugation('使わない', '（う→わない）'),
    potential: Conjugation('使える', '（う→える）'),
  ),
  VerbEntry(
    dictionary: 'あげる',
    te: Conjugation('あげて', '（る→て）'),
    ta: Conjugation('あげた', '（る→た）'),
    nai: Conjugation('あげない', '（る→ない）'),
    potential: Conjugation('あげられる', '（る→られる）'),
  ),
  VerbEntry(
    dictionary: 'もらう',
    te: Conjugation('もらって', '（う→って）'),
    ta: Conjugation('もらった', '（う→った）'),
    nai: Conjugation('もらわない', '（う→わない）'),
    potential: Conjugation('もらえる', '（う→える）'),
  ),
  VerbEntry(
    dictionary: '持つ',
    te: Conjugation('持って', '（つ→って）'),
    ta: Conjugation('持った', '（つ→った）'),
    nai: Conjugation('持たない', '（つ→たない）'),
    potential: Conjugation('持てる', '（つ→てる）'),
  ),
  VerbEntry(
    dictionary: '帰る',
    te: Conjugation('帰って', '（る→って）'),
    ta: Conjugation('帰った', '（る→った）'),
    nai: Conjugation('帰らない', '（る→らない）'),
    potential: Conjugation('帰れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '走る',
    te: Conjugation('走って', '（る→って）'),
    ta: Conjugation('走った', '（る→った）'),
    nai: Conjugation('走らない', '（る→らない）'),
    potential: Conjugation('走れる', '（る→れる）'),
  ),
  VerbEntry(
    dictionary: '知る',
    te: Conjugation('知って', '（る→って）'),
    ta: Conjugation('知った', '（る→った）'),
    nai: Conjugation('知らない', '（る→らない）'),
    potential: Conjugation('知れる', '（る→れる）'),
  ),
];
