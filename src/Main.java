import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Trainer trainer = new Trainer();
        trainer.start();
    }

    private static final class Trainer {
        private static final Random RANDOM = new Random();
        private static final Mode[] MIX_OPTIONS = {
                Mode.TE, Mode.TA, Mode.NAI, Mode.POTENTIAL, Mode.KAMO
        };
        private static final List<VerbEntry> VERB_LIST = List.of(
                verb("行く", c("行って", "（く→って）"), c("行った", "（く→った）"),
                        c("行かない", "（く→かない）"), c("行ける", "（く→ける）")),
                verb("来る", c("来て", "（不規則）"), c("来た", "（不規則）"),
                        c("来ない", "（不規則）"), c("来られる", "（不規則）")),
                verb("する", c("して", "（不規則）"), c("した", "（不規則）"),
                        c("しない", "（不規則）"), c("できる", "（する→できる）")),
                verb("食べる", c("食べて", "（る→て）"), c("食べた", "（る→た）"),
                        c("食べない", "（る→ない）"), c("食べられる", "（る→られる）")),
                verb("飲む", c("飲んで", "（む→んで）"), c("飲んだ", "（む→んだ）"),
                        c("飲まない", "（む→まない）"), c("飲める", "（む→める）")),
                verb("見る", c("見て", "（る→て）"), c("見た", "（る→た）"),
                        c("見ない", "（る→ない）"), c("見られる", "（る→られる）")),
                verb("読む", c("読んで", "（む→んで）"), c("読んだ", "（む→んだ）"),
                        c("読まない", "（む→まない）"), c("読める", "（む→める）")),
                verb("書く", c("書いて", "（く→いて）"), c("書いた", "（く→いた）"),
                        c("書かない", "（く→かない）"), c("書ける", "（く→ける）")),
                verb("買う", c("買って", "（う→って）"), c("買った", "（う→った）"),
                        c("買わない", "（う→わない）"), c("買える", "（う→える）")),
                verb("話す", c("話して", "（す→して）"), c("話した", "（す→した）"),
                        c("話さない", "（す→さない）"), c("話せる", "（す→せる）")),
                verb("聞く", c("聞いて", "（く→いて）"), c("聞いた", "（く→いた）"),
                        c("聞かない", "（く→かない）"), c("聞ける", "（く→ける）")),
                verb("会う", c("会って", "（う→って）"), c("会った", "（う→った）"),
                        c("会わない", "（う→わない）"), c("会える", "（う→える）")),
                verb("待つ", c("待って", "（つ→って）"), c("待った", "（つ→った）"),
                        c("待たない", "（つ→たない）"), c("待てる", "（つ→てる）")),
                verb("歩く", c("歩いて", "（く→いて）"), c("歩いた", "（く→いた）"),
                        c("歩かない", "（く→かない）"), c("歩ける", "（く→ける）")),
                verb("泳ぐ", c("泳いで", "（ぐ→いで）"), c("泳いだ", "（ぐ→いだ）"),
                        c("泳がない", "（ぐ→がない）"), c("泳げる", "（ぐ→げる）")),
                verb("死ぬ", c("死んで", "（ぬ→んで）"), c("死んだ", "（ぬ→んだ）"),
                        c("死なない", "（ぬ→なない）"), c("死ねる", "（ぬ→ねる）")),
                verb("遊ぶ", c("遊んで", "（ぶ→んで）"), c("遊んだ", "（ぶ→んだ）"),
                        c("遊ばない", "（ぶ→ばない）"), c("遊べる", "（ぶ→べる）")),
                verb("立つ", c("立って", "（つ→って）"), c("立った", "（つ→った）"),
                        c("立たない", "（つ→たない）"), c("立てる", "（つ→てる）")),
                verb("入る", c("入って", "（る→って）"), c("入った", "（る→った）"),
                        c("入らない", "（る→らない）"), c("入れる", "（る→れる）")),
                verb("出る", c("出て", "（る→て）"), c("出た", "（る→た）"),
                        c("出ない", "（る→ない）"), c("出られる", "（る→られる）")),
                verb("乗る", c("乗って", "（る→って）"), c("乗った", "（る→った）"),
                        c("乗らない", "（る→らない）"), c("乗れる", "（る→れる）")),
                verb("休む", c("休んで", "（む→んで）"), c("休んだ", "（む→んだ）"),
                        c("休まない", "（む→まない）"), c("休める", "（む→める）")),
                verb("起きる", c("起きて", "（る→て）"), c("起きた", "（る→た）"),
                        c("起きない", "（る→ない）"), c("起きられる", "（る→られる）")),
                verb("寝る", c("寝て", "（る→て）"), c("寝た", "（る→た）"),
                        c("寝ない", "（る→ない）"), c("寝られる", "（る→られる）")),
                verb("勉強する", c("勉強して", "（する→して）"), c("勉強した", "（する→した）"),
                        c("勉強しない", "（する→しない）"), c("勉強できる", "（する→できる）")),
                verb("働く", c("働いて", "（く→いて）"), c("働いた", "（く→いた）"),
                        c("働かない", "（く→かない）"), c("働ける", "（く→ける）")),
                verb("使う", c("使って", "（う→って）"), c("使った", "（う→った）"),
                        c("使わない", "（う→わない）"), c("使える", "（う→える）")),
                verb("あげる", c("あげて", "（る→て）"), c("あげた", "（る→た）"),
                        c("あげない", "（る→ない）"), c("あげられる", "（る→られる）")),
                verb("もらう", c("もらって", "（う→って）"), c("もらった", "（う→った）"),
                        c("もらわない", "（う→わない）"), c("もらえる", "（う→える）")),
                verb("持つ", c("持って", "（つ→って）"), c("持った", "（つ→った）"),
                        c("持たない", "（つ→たない）"), c("持てる", "（つ→てる）")),
                verb("帰る", c("帰って", "（る→って）"), c("帰った", "（る→った）"),
                        c("帰らない", "（る→らない）"), c("帰れる", "（る→れる）")),
                verb("走る", c("走って", "（る→って）"), c("走った", "（る→った）"),
                        c("走らない", "（る→らない）"), c("走れる", "（る→れる）")),
                verb("知る", c("知って", "（る→って）"), c("知った", "（る→った）"),
                        c("知らない", "（る→らない）"), c("知れる", "（る→れる）"))
        );

        private final Scanner scanner = new Scanner(System.in, StandardCharsets.UTF_8);
        private final List<VerbEntry> quizOrder = new ArrayList<>(VERB_LIST);
        private final List<Question> questionHistory = new ArrayList<>();
        private int navigationIndex = 0;
        private int verbCursor = 0;
        private int questionCounter = 0;

        void start() {
            Collections.shuffle(quizOrder, RANDOM);
            Mode currentMode = promptMode(null);
            int questionCount = promptQuestionCount(null);

            boolean running = true;
            while (running) {
                runSession(currentMode, questionCount);
                while (true) {
                    System.out.println("「Vuoi continuare stessa modalità, cambiare forma o fermarti?」");
                    System.out.print("s = stessa, c = cambiare, f = fermare > ");
                    String choice = scanner.nextLine().trim();
                    if (choice.isEmpty()) {
                        System.out.println("Per favore scegli s, c oppure f.");
                        continue;
                    }
                    char option = Character.toLowerCase(choice.charAt(0));
                    if (option == 's') {
                        questionCount = promptQuestionCount(questionCount);
                        break;
                    } else if (option == 'c') {
                        currentMode = promptMode(currentMode);
                        questionCount = promptQuestionCount(questionCount);
                        break;
                    } else if (option == 'f') {
                        running = false;
                        break;
                    } else {
                        System.out.println("Scelta non valida. Usa s, c oppure f.");
                    }
                }
            }
            System.out.println("お疲れさまでした！");
        }

        private void runSession(Mode mode, int questionCount) {
            int newQuestionsPresented = 0;
            while (newQuestionsPresented < questionCount) {
                boolean isNewQuestion = false;
                Question question;
                if (navigationIndex >= questionHistory.size()) {
                    question = createQuestion(mode);
                    questionHistory.add(question);
                    navigationIndex = questionHistory.size() - 1;
                    isNewQuestion = true;
                } else {
                    question = questionHistory.get(navigationIndex);
                }

                NavigationAction action = presentQuestion(question);
                if (action == NavigationAction.BACK) {
                    if (navigationIndex > 0) {
                        navigationIndex--;
                    } else {
                        System.out.println("Nessuna domanda precedente disponibile.");
                    }
                    continue;
                }

                if (isNewQuestion) {
                    newQuestionsPresented++;
                }

                if (navigationIndex < questionHistory.size() - 1) {
                    navigationIndex++;
                } else {
                    navigationIndex = questionHistory.size();
                }
            }
        }

        private NavigationAction presentQuestion(Question question) {
            Conjugation conjugation = question.verb.getConjugation(question.mode);

            System.out.printf("Q%d - %s%n", question.number, question.mode.displayLabel());
            System.out.println("Verbo: " + question.verb.dictionary());
            System.out.println("Coniuga il verbo nella forma richiesta.");
            System.out.print("Scrivi la forma (Invio per mostrare la soluzione, b per tornare indietro): ");
            String attempt = scanner.nextLine().trim();
            if (attempt.equalsIgnoreCase("b")) {
                return NavigationAction.BACK;
            }
            System.out.printf("**Soluzione:** ||%s||%n", conjugation.answer());
            if (!conjugation.note().isEmpty()) {
                System.out.println(conjugation.note());
            }
            System.out.print("Premi Invio per continuare oppure digita b per tornare alla domanda precedente: ");
            String command = scanner.nextLine().trim();
            System.out.println();
            if (command.equalsIgnoreCase("b")) {
                return NavigationAction.BACK;
            }
            return NavigationAction.CONTINUE;
        }

        private Question createQuestion(Mode selectedMode) {
            Mode actualMode = selectedMode == Mode.MIX
                    ? MIX_OPTIONS[RANDOM.nextInt(MIX_OPTIONS.length)]
                    : selectedMode;
            VerbEntry verb = nextVerb();
            questionCounter++;
            return new Question(questionCounter, actualMode, verb);
        }

        private VerbEntry nextVerb() {
            if (verbCursor >= quizOrder.size()) {
                Collections.shuffle(quizOrder, RANDOM);
                verbCursor = 0;
            }
            return quizOrder.get(verbCursor++);
        }

        private enum NavigationAction {
            CONTINUE,
            BACK
        }

        private static final class Question {
            private final int number;
            private final Mode mode;
            private final VerbEntry verb;

            private Question(int number, Mode mode, VerbEntry verb) {
                this.number = number;
                this.mode = mode;
                this.verb = verb;
            }
        }

        private Mode promptMode(Mode currentMode) {
            Mode defaultMode = currentMode;
            while (true) {
                System.out.println("Quale forma vuoi esercitare? (1=te, 2=ta, 3=nai, 4=potenziale, 5=mix, 6=kamo)");
                if (defaultMode != null) {
                    System.out.printf("Premi Invio per mantenere %s.%n", defaultMode.displayLabel());
                }
                System.out.print("> ");
                String input = scanner.nextLine().trim();
                if (input.isEmpty() && defaultMode != null) {
                    return defaultMode;
                }
                switch (input) {
                    case "1":
                        return Mode.TE;
                    case "2":
                        return Mode.TA;
                    case "3":
                        return Mode.NAI;
                    case "4":
                        return Mode.POTENTIAL;
                    case "5":
                        return Mode.MIX;
                    case "6":
                        return Mode.KAMO;
                    default:
                        System.out.println("Seleziona un numero da 1 a 6.");
                }
            }
        }

        private int promptQuestionCount(Integer previousValue) {
            while (true) {
                if (previousValue == null) {
                    System.out.print("Quante domande di fila vuoi? > ");
                } else {
                    System.out.printf("Quante domande di fila vuoi? (Invio per %d) > ", previousValue);
                }
                String input = scanner.nextLine().trim();
                if (input.isEmpty()) {
                    if (previousValue != null) {
                        return previousValue;
                    }
                } else {
                    try {
                        int value = Integer.parseInt(input);
                        if (value > 0) {
                            return value;
                        }
                        System.out.println("Inserisci un numero positivo.");
                    } catch (NumberFormatException ex) {
                        System.out.println("Per favore inserisci un numero valido.");
                    }
                }
            }
        }
    }

    private enum Mode {
        TE("forma �?�"),
        TA("forma �?Y"),
        NAI("forma �?��?\""),
        POTENTIAL("forma potenziale"),
        MIX("mix casuale"),
        KAMO("forma �?<�''�?-�'O�?��?>�'\"");

        private final String displayLabel;

        Mode(String displayLabel) {
            this.displayLabel = displayLabel;
        }

        String displayLabel() {
            return displayLabel;
        }
    }

    private static final class VerbEntry {
        private final String dictionary;
        private final Conjugation te;
        private final Conjugation ta;
        private final Conjugation nai;
        private final Conjugation potential;
        private final Conjugation kamo;

        VerbEntry(String dictionary, Conjugation te, Conjugation ta,
                  Conjugation nai, Conjugation potential) {
            this.dictionary = dictionary;
            this.te = te;
            this.ta = ta;
            this.nai = nai;
            this.potential = potential;
            this.kamo = new Conjugation(dictionary + "�?<�''�?-�'O�?��?>�'\"", "��^�T��?s�����<�?<�''�?-�'O�?��?>�'\"��%");
        }

        String dictionary() {
            return dictionary;
        }

        Conjugation getConjugation(Mode mode) {
            switch (mode) {
                case TE:
                    return te;
                case TA:
                    return ta;
                case NAI:
                    return nai;
                case POTENTIAL:
                    return potential;
                case KAMO:
                    return kamo;
                default:
                    throw new IllegalArgumentException("Modalit�� non supportata: " + mode);
            }
        }
    }

    private static final class Conjugation {
        private final String answer;
        private final String note;

        Conjugation(String answer, String note) {
            this.answer = answer;
            this.note = note;
        }

        String answer() {
            return answer;
        }

        String note() {
            return note == null ? "" : note;
        }
    }

    private static VerbEntry verb(String dictionary,
                                  Conjugation te,
                                  Conjugation ta,
                                  Conjugation nai,
                                  Conjugation potential) {
        return new VerbEntry(dictionary, te, ta, nai, potential);
    }

    private static Conjugation c(String answer, String note) {
        return new Conjugation(answer, note == null ? "" : note);
    }
}

