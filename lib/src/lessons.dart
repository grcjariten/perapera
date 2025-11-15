import 'data.dart';

class Lesson {
  const Lesson({
    required this.number,
    required this.title,
    required this.page,
    required this.topics,
  });

  final int number;
  final String title;
  final int page;
  final List<LessonTopic> topics;

  String get label => 'Capitolo $number';
}

enum LessonTopicType { grammar, culture, expressions }

class PracticeCard {
  const PracticeCard({
    required this.prompt,
    required this.answer,
    this.note,
  });

  final String prompt;
  final String answer;
  final String? note;
}

class LessonTopic {
  const LessonTopic({
    required this.title,
    required this.description,
    this.patterns = const <String>[],
    this.examples = const <String>[],
    this.type = LessonTopicType.grammar,
    this.trainerMode,
    this.cards = const <PracticeCard>[],
  });

  final String title;
  final String description;
  final List<String> patterns;
  final List<String> examples;
  final LessonTopicType type;
  final TrainerMode? trainerMode;
  final List<PracticeCard> cards;
}

const List<Lesson> lessonCatalog = <Lesson>[
  Lesson(
    number: 13,
    title: 'Arubaito sagashi - Looking for a Part-time Job',
    page: 26,
    topics: <LessonTopic>[
      LessonTopic(
        title: 'Verbi potenziali',
        description:
            'Esprimono capacità o possibilità. Diversi pattern in base al gruppo.',
        trainerMode: TrainerMode.potential,
        patterns: <String>[
          '食べる → 食べられる',
          '行く → 行ける / 読む → 読める',
          'する → できる / 来る → こられる',
        ],
        examples: <String>[
          '日本語が話せます。',
          '日曜日なら行けます。',
        ],
      ),
      LessonTopic(
        title: '~shi per elencare motivi',
        description:
            'Con ~し si elencano più motivi o caratteristiche prima della conclusione.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '暑い + 高い',
            answer: '暑いし、高いし。'
          ),
          PracticeCard(
            prompt: '大阪（楽しい） + 食べ物がおいしい',
            answer: '大阪は楽しいし、食べ物もおいしい。'
          ),
          PracticeCard(
            prompt: '静か + きれい',
            answer: '静かだし、きれいです。'
          ),
        ],
      ),
      LessonTopic(
        title: '~sou desu (sembra che...)',
        description:
            'Usato per descrivere apparenze basate su osservazione immediata.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '雨（降る）',
            answer: '雨が降りそうです。'
          ),
          PracticeCard(
            prompt: 'ケーキ（おいしい）',
            answer: 'そのケーキはおいしそうです。'
          ),
          PracticeCard(
            prompt: '田中さん（疲れている）',
            answer: '田中さんは疲れていそうです。'
          ),
        ],
      ),
      LessonTopic(
        title: '~te miru',
        description: 'La forma ～てみる indica un tentativo o esperimento.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '食べる',
            answer: '食べてみます。'
          ),
          PracticeCard(
            prompt: '読む',
            answer: '読んでみます。'
          ),
          PracticeCard(
            prompt: '行く',
            answer: '行ってみます。'
          ),
        ],
      ),
      LessonTopic(
        title: 'Nara',
        description:
            'Nara introduce un tema limitato e un commento/consiglio su quel tema.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '東京：駅の近くが便利',
            answer: '東京なら駅の近くが便利です。'
          ),
          PracticeCard(
            prompt: '土曜日：会える',
            answer: '土曜日なら会えます。'
          ),
          PracticeCard(
            prompt: '寒い日：鍋がいい',
            answer: '寒い日なら鍋がいいです。'
          ),
        ],
      ),
    ],
  ),
  Lesson(
    number: 14,
    title: 'Barentain de - Valentine\'s Day',
    page: 50,
    topics: <LessonTopic>[
      LessonTopic(
        title: 'Hoshii',
        description:
            'Aggettivo per esprimere desiderio personale; con altri soggetti si usa ～たがっている.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: 'カメラが欲しい',
            answer: 'カメラが欲しいです。'
          ),
          PracticeCard(
            prompt: '妹（犬を欲しがっている）',
            answer: '妹は犬を欲しがっています。'
          ),
          PracticeCard(
            prompt: '特別に欲しいものはない',
            answer: '特別に欲しいものはありません。'
          ),
        ],
      ),
      LessonTopic(
        title: '~kamoshiremasen',
        description: 'Indica possibilità o incertezza; si usa la forma piana.',
        trainerMode: TrainerMode.kamo,
        examples: <String>[
          '明日は雨が降るかもしれません。',
        ],
      ),
      LessonTopic(
        title: 'ageru / kureru / morau',
        description:
            'Verbi per esprimere dare/ricevere con sfumature di cortesia.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '先生に花をあげる',
            answer: '先生に花をあげます。'
          ),
          PracticeCard(
            prompt: '友だちが本をくれる',
            answer: '友だちが本をくれます。'
          ),
          PracticeCard(
            prompt: '母に手伝ってもらう',
            answer: '母に手伝ってもらいます。'
          ),
        ],
      ),
      LessonTopic(
        title: '~tara dou desu ka',
        description: 'Consiglio gentile basato sulla condizionale passata.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '少し休む',
            answer: '少し休んだらどうですか。'
          ),
          PracticeCard(
            prompt: '先生に聞く',
            answer: '先生に聞いたらどうですか。'
          ),
          PracticeCard(
            prompt: '病院に行く',
            answer: '病院に行ったらどうですか。'
          ),
        ],
      ),
      LessonTopic(
        title: 'number + mo / number + shika + negativa',
        description:
            '～も enfatizza quantità maggiore del previsto; ～しか＋neg ne evidenzia pochezza.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '弁当３個＋も',
            answer: '弁当を三個も作りました。'
          ),
          PracticeCard(
            prompt: 'りんご１個＋しか',
            answer: 'りんごは一つしかありません。'
          ),
          PracticeCard(
            prompt: '時間２時間＋しか',
            answer: '時間が二時間しかありません。'
          ),
        ],
      ),
    ],
  ),
  Lesson(
    number: 15,
    title: 'Nagano ryokou - A Trip to Nagano',
    page: 80,
    topics: <LessonTopic>[
      LessonTopic(
        title: 'Forma volitiva',
        description:
            'Equivale a un “facciamo...”. I verbi ru prendono ～よう, quelli u → ～おう.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '食べる',
            answer: '食べよう。'
          ),
          PracticeCard(
            prompt: '飲む',
            answer: '飲もう。'
          ),
          PracticeCard(
            prompt: '行く',
            answer: '行こう。'
          ),
        ],
      ),
      LessonTopic(
        title: 'Volitivo + to omotte imasu',
        description: 'Indica un piano deciso/già in preparazione.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '仕事をやめようと思う',
            answer: '仕事をやめようと思っています。'
          ),
          PracticeCard(
            prompt: '来年日本へ行こうと思う',
            answer: '来年日本へ行こうと思っています。'
          ),
          PracticeCard(
            prompt: '新しい車を買おうと思う',
            answer: '新しい車を買おうと思っています。'
          ),
        ],
      ),
      LessonTopic(
        title: '~te oku',
        description: 'Fare qualcosa in anticipo/preparazione.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '切符を買う',
            answer: '切符を買っておきます。'
          ),
          PracticeCard(
            prompt: '部屋を掃除する',
            answer: '部屋を掃除しておきます。'
          ),
          PracticeCard(
            prompt: '資料を印刷する',
            answer: '資料を印刷しておきます。'
          ),
        ],
      ),
      LessonTopic(
        title: 'Frasi relative',
        description:
            'Una frase piana può qualificare un sostantivo senza pronomi relativi.',
        cards: <PracticeCard>[
          PracticeCard(
            prompt: '昨日買った本',
            answer: '昨日買った本は面白いです。'
          ),
          PracticeCard(
            prompt: '話している人',
            answer: '話している人は私の兄です。'
          ),
          PracticeCard(
            prompt: '日本語を勉強している学生',
            answer: '日本語を勉強している学生です。'
          ),
        ],
      ),
    ],
  ),
];
