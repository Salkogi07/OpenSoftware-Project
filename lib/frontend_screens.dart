import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'learning/learning_repository.dart';
import 'learning/learning_stats.dart';
import 'record_screen.dart' as record;

part 'home_page.dart';
part 'my_page.dart';

void main() => runApp(const VocabularyApp());

const navy = Color(0xff1d2d44);
const green = Color(0xff2f6b55);
const mint = Color(0xffe3f5ed);
const orange = Color(0xffffe4bf);

const _tabSelectedColor = Color(0xffc76a13);
const _tabUnselectedColor = Color(0xff697370);
const _tabDividerColor = Color(0xffeeeeee);

AppBar _tabAppBar(String title, {List<Widget>? actions}) => AppBar(
  title: Text(title),
  centerTitle: true,
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 0,
  titleTextStyle: const TextStyle(
    color: Color(0xff171717),
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w800,
  ),
  bottom: const PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, thickness: 1, color: _tabDividerColor),
  ),
  actions: actions,
);

const cardRadius = BorderRadius.all(Radius.circular(24));
const cardPadding = EdgeInsets.all(20);
const buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
);
const feedbackDuration = Duration(milliseconds: 250);

// 디자인 화면 공통 테마 (로그인 뒤 하단 탭 화면에도 사용)
final frontendTheme = ThemeData(
  fontFamily: 'Pretendard',
  colorScheme: ColorScheme.fromSeed(
    seedColor: green,
    primary: navy,
    primaryContainer: mint,
    onPrimaryContainer: green,
    tertiary: navy,
    tertiaryContainer: orange,
    onTertiaryContainer: navy,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    indicatorColor: Colors.transparent,
    elevation: 0,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? _tabSelectedColor
            : _tabUnselectedColor,
        size: 24,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? _pretendardText(13, weight: 700, color: _tabSelectedColor)
          : _pretendardText(13, weight: 500, color: _tabUnselectedColor),
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 15, height: 1.5),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ).apply(bodyColor: navy, displayColor: navy),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: navy,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: navy,
      fontFamily: 'Pretendard',
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      backgroundColor: navy,
      foregroundColor: Colors.white,
      shape: buttonShape,
      animationDuration: feedbackDuration,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      foregroundColor: navy,
      shape: buttonShape,
      animationDuration: feedbackDuration,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루어휘',
      debugShowCheckedModeBanner: false,
      theme: frontendTheme,
      home: const MainScreen(),
    );
  }
}

// 화면을 넓은 브라우저에서도 휴대폰처럼 읽기 편한 폭으로 표시합니다.
class ScreenBody extends StatelessWidget {
  const ScreenBody({
    super.key,
    required this.children,
    this.footer,
    this.controller,
    this.contentPadding,
  });

  final List<Widget> children;
  final Widget? footer;
  final ScrollController? controller;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      contentPadding ??
                      EdgeInsets.fromLTRB(
                        MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
                        16,
                        MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
                        24,
                      ),
                  children: children,
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void goHome(BuildContext context) {
    context.findAncestorStateOfType<_MainScreenState>()!.goHome();
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;
  final library = _StudyLibrary();
  final navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    library.refresh(); // 로그인한 사용자의 학습 기록을 DB에서 불러옴
  }

  @override
  void dispose() {
    library.dispose();
    super.dispose();
  }

  void goHome() {
    for (final key in navigatorKeys) {
      key.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => selectedTab = 0);
    library.refresh(); // 퀴즈를 마치고 돌아오면 방금 푼 결과를 반영
  }

  @override
  Widget build(BuildContext context) {
    return _LibraryScope(
      notifier: library,
      child: Scaffold(
        body: IndexedStack(
          index: selectedTab,
          children: [
            for (var tabIndex = 0; tabIndex < 4; tabIndex++)
              if (tabIndex == 2)
                const _RecordTab()
              else
                _tabNavigator(
                  tabIndex,
                  navigatorKeys[tabIndex == 3 ? 2 : tabIndex],
                ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _tabDividerColor)),
          ),
          child: NavigationBar(
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selectedTab,
            onDestinationSelected: (index) {
              setState(() => selectedTab = index);
              library.refresh(); // 탭을 옮길 때마다 최신 기록으로
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: '학습',
              ),
              NavigationDestination(
                icon: _StudyBars(color: _tabUnselectedColor),
                selectedIcon: _StudyBars(color: _tabSelectedColor),
                label: '기록',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: '마이',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabNavigator(int tabIndex, GlobalKey<NavigatorState> key) =>
      NavigatorPopHandler<Object?>(
        enabled: selectedTab == tabIndex,
        onPopWithResult: (result) => key.currentState!.pop(result),
        child: Navigator(
          key: key,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => switch (tabIndex) {
              0 => HomeScreen(
                onContinue: () => setState(() => selectedTab = 1),
                onRecords: () => setState(() => selectedTab = 2),
              ),
              1 => const StudyScreen(),
              _ => const _MyPage(),
            },
          ),
        ),
      );
}

// 기록 탭: 시안 화면(record_screen.dart)에 최근 7일 실제 통계(learning_stats.dart)를 채워서 보여 줌
class _RecordTab extends StatelessWidget {
  const _RecordTab();

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context);
    final weekly = library?.weekly ?? weeklyStats(const [], DateTime.now());
    final today = koreanDate(DateTime.now());
    final accuracy = weekly.accuracy;

    return record.RecordScreen(
      appBar: _tabAppBar('기록 탭'),
      status: library == null ? null : _loadStatus(library),
      accuracyPercent: accuracy == null ? null : (accuracy * 100).round(),
      weeklyRecords: [
        for (var i = 0; i < 7; i++)
          record.DailyRecord(
            day: _weekdays[today.subtract(Duration(days: 6 - i)).weekday - 1],
            solvedCount: weekly.dailyCounts[i],
            accuracy: weekly.dailyAccuracyPercent(i),
          ),
      ],
      topWrongWords: [
        for (final word in library?.topWrongWords ?? const <Word>[])
          record.WrongWordRank(
            word: word.name,
            topic: word.topic,
            meaning: word.meaning,
            // 문제 번호로 짝을 찾아서, 문제 하나를 못 불러와도 횟수가 어긋나지 않게
            wrongCount: weekly
                .topWrongCounts[weekly.topWrongQuestionIds.indexOf(word.id!)],
          ),
      ],
    );
  }
}

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopicScreen();
  }
}

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  static const difficulties = {
    '하': '표현을 보고 뜻 고르기',
    '중': '상황에 맞는 표현 고르기',
    '상': '정의에 맞는 표현 고르기',
  };

  late Future<List<Word>> bank = loadQuestions();
  final remaining = <(String, String), List<Word>>{};
  String? topic;
  String? difficulty;

  Future<List<Word>> loadQuestions() async {
    final source = await rootBundle.loadString('assets/questions.json');
    final rows = jsonDecode(source) as List<dynamic>;
    return rows
        .map((row) => Word.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  List<Word> nextBatch(List<Word> bank, String topic, String difficulty) {
    final key = (topic, difficulty);
    final queue = remaining.putIfAbsent(key, () => []);
    if (queue.isEmpty) {
      queue.addAll(
        bank.where(
          (word) => word.topic == topic && word.difficulty == difficulty,
        ),
      );
      queue.shuffle();
    }
    final batch = queue.take(5).toList();
    queue.removeRange(0, batch.length);
    return batch;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _tabAppBar('학습 탭'),
      body: FutureBuilder<List<Word>>(
        future: bank,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ScreenBody(
              children: [
                const Text('문제를 불러오지 못했어요.'),
                OutlinedButton(
                  onPressed: () => setState(() => bank = loadQuestions()),
                  child: const Text('다시 불러오기'),
                ),
              ],
            );
          }
          final words = snapshot.data;
          if (words == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final selectedTopic = topic;
          final selectedDifficulty = difficulty;
          return ScreenBody(
            children: [
              Text('학습 주제', style: text.headlineMedium),
              const SizedBox(height: 8),
              const Text('주제와 난이도를 골라 5문제를 풀어보세요.'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category
                      in words.map((word) => word.topic).toSet())
                    ChoiceChip(
                      label: Text(category),
                      selected: selectedTopic == category,
                      onSelected: (_) => setState(() => topic = category),
                    ),
                ],
              ),
              if (selectedTopic == '현재는 상대적으로 드문 격식어') ...[
                const SizedBox(height: 8),
                const Text('사용 빈도 조사와 별개로 정한 학습 주제예요.'),
              ],
              const SizedBox(height: 24),
              Text('난이도', style: text.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in difficulties.entries)
                    ChoiceChip(
                      label: Text('${entry.key} · ${entry.value}'),
                      selected: selectedDifficulty == entry.key,
                      onSelected: (_) => setState(() => difficulty = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: selectedTopic == null || selectedDifficulty == null
                    ? null
                    : () {
                        if (ModalRoute.of(context)?.isCurrent != true) return;
                        List<Word> next() =>
                            nextBatch(words, selectedTopic, selectedDifficulty);
                        openQuiz(context, next(), nextBatch: next);
                      },
                child: const Text('5문제 시작하기'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Word {
  const Word({
    required this.topic,
    required this.name,
    required this.meaning,
    required this.distractor,
    required this.example,
    required this.alternative,
    this.id,
    this.difficulty,
    this.prompt,
    this.choices,
    this.answerIndex,
    this.explanation,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    id: json['id'] as String,
    topic: json['topic'] as String,
    difficulty: json['difficulty'] as String,
    prompt: json['prompt'] as String,
    choices: List<String>.unmodifiable(json['choices'] as List<dynamic>),
    answerIndex: (json['answer'] as int) - 1,
    name: json['word'] as String,
    meaning: json['meaning'] as String,
    explanation: json['explanation'] as String,
    distractor: '',
    example: json['example'] as String? ?? '',
    alternative: '',
  );

  /// 문제 번호(예: ER-001). 수파베이스에 푼 결과를 저장할 때 씀
  final String? id;
  final String? difficulty;
  final String? prompt;
  final List<String>? choices;
  final int? answerIndex;
  final String? explanation;

  String get correctChoice => choices?[answerIndex!] ?? name;

  final String topic;
  final String name;
  final String meaning;
  final String distractor;
  final String example;
  final String alternative;
}

const everyday = Word(
  topic: '일상생활',
  name: '결재',
  alternative: '결제',
  meaning: '문서나 안건을 검토하여 승인함.',
  distractor: '물건을 산 뒤 값을 지불함.',
  example: '팀장님께 기획안 결재를 받았어요.',
);
const messages = Word(
  topic: '학교와 공지',
  name: '금일',
  alternative: '금요일',
  meaning: '오늘을 뜻하는 말.',
  distractor: '이번 주 금요일을 뜻하는 말.',
  example: '신청서는 금일 오후 5시까지 제출해 주세요.',
);
const news = Word(
  topic: '뉴스와 사회',
  name: '귀추',
  alternative: '계기',
  meaning: '일이 되어 가는 끝이나 결말.',
  distractor: '어떤 일이 시작된 이유나 배경.',
  example: '많은 시민이 이번 논의의 귀추에 주목하고 있다.',
);

void openQuiz(
  BuildContext context,
  List<Word> words, {
  List<Word> Function()? nextBatch,
}) {
  if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizScreen(words: words, nextBatch: nextBatch),
    ),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.words,
    this.isReview = false,
    this.nextBatch,
  }) : assert(words.length > 0);

  final List<Word> words;
  final bool isReview;
  final List<Word> Function()? nextBatch;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final scrollController = ScrollController();
  int questionIndex = 0;
  bool showingExplanation = false;
  String? selectedChoice;
  final List<bool> answers = [];
  // 푼 결과 저장용: 문제가 보인 뒤 걸린 시간, 이미 저장한 문제 위치(같은 문제를 두 번 저장하지 않게)
  final answerTimer = Stopwatch()..start();
  int? savedQuestionIndex;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> submitAnswer(String choice) async {
    if (showingExplanation) return;
    setState(() {
      showingExplanation = true;
      selectedChoice = choice;
    });
    final word = widget.words[questionIndex];
    if (choice != word.correctChoice) {
      _LibraryScope.read(context)?.recordMistake(word);
    }
    if (word.id case final id? when savedQuestionIndex != questionIndex) {
      savedQuestionIndex = questionIndex;
      learningRepository.recordAnswer(
        questionId: id,
        isCorrect: choice == word.correctChoice,
        timeSpentMs: answerTimer.elapsedMilliseconds,
      );
    }
    final lastQuestion = questionIndex == widget.words.length - 1;
    final advance = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ExplanationScreen(
          word: word,
          answer: choice,
          continueLabel: lastQuestion ? '학습 마치기' : '다음 문제',
          onContinue: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (!mounted) return;
    if (advance == true) answers.add(choice == word.correctChoice);
    if (advance == true && lastQuestion) {
      learningRepository.markAttendance();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CompletionScreen(
            words: widget.words,
            answers: List.unmodifiable(answers),
            isReview: widget.isReview,
            nextBatch: widget.nextBatch,
          ),
        ),
      );
      return;
    }
    setState(() {
      showingExplanation = false;
      selectedChoice = null;
      if (advance == true) {
        questionIndex++;
        answerTimer.reset();
      }
    });
    if (advance == true && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words[questionIndex];
    final text = Theme.of(context).textTheme;
    final choices =
        word.choices ??
        (questionIndex.isEven
            ? [word.alternative, word.name]
            : [word.name, word.alternative]);
    final prompt =
        word.prompt ??
        (word.name.isEmpty
            ? word.example
            : word.example.replaceFirst(word.name, '( ______ )'));
    return Scaffold(
      appBar: AppBar(
        title: Text(word.topic),
        actions: [
          if (_LibraryScope.watch(context) case final library?)
            _SaveWordButton(library: library, word: word),
        ],
      ),
      body: ScreenBody(
        controller: scrollController,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: questionIndex / widget.words.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: green,
                  backgroundColor: mint,
                  semanticsLabel:
                      '퀴즈 진행도, ${widget.words.length}문제 중 $questionIndex문제 완료',
                ),
              ),
              const SizedBox(width: 16),
              Text('${questionIndex + 1} / ${widget.words.length}'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.isReview
                ? '복습 · 난이도 ${word.difficulty ?? ""}'
                : '난이도 ${word.difficulty ?? ""}',
            style: text.titleLarge,
          ),
          const SizedBox(height: 20),
          Card(
            color: mint,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: cardRadius),
            child: Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '문제 ${questionIndex + 1}',
                    style: text.labelLarge?.copyWith(color: green),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    prompt,
                    style: text.titleLarge?.copyWith(fontSize: 23, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final choice in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  minimumSize: const Size.fromHeight(60),
                  side: BorderSide(
                    color: green,
                    width: selectedChoice == choice ? 2.5 : 1,
                  ),
                ),
                onPressed: showingExplanation
                    ? null
                    : () => submitAnswer(choice),
                child: Row(
                  children: [
                    Icon(
                      selectedChoice == choice
                          ? Icons.check_circle_outline_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        choice,
                        style: text.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({
    super.key,
    required this.words,
    required this.answers,
    required this.isReview,
    this.nextBatch,
  });

  final List<Word> words;
  final List<bool> answers;
  final bool isReview;
  final List<Word> Function()? nextBatch;

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  bool leaving = false;

  void startQuiz(List<Word> words, {bool isReview = false}) {
    if (leaving) return;
    setState(() => leaving = true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          words: words,
          isReview: isReview,
          nextBatch: widget.nextBatch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.words;
    final answers = widget.answers;
    final isReview = widget.isReview;
    final correctCount = answers.where((correct) => correct).length;
    final accuracy = words.isEmpty ? 0.0 : correctCount / words.length;
    final percentage = (accuracy * 100).round();
    final earnedXp = correctCount * 3;
    final missedWords = [
      for (var index = 0; index < words.length; index++)
        if (!answers[index]) words[index],
    ];
    final reviewWords = missedWords.isEmpty ? words : missedWords;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(isReview ? '복습 완료' : '학습 완료')),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.replay_rounded),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              label: Text(missedWords.isEmpty ? '한 번 더 복습하기' : '틀린 문제 다시 풀기'),
              onPressed: reviewWords.isEmpty || leaving
                  ? null
                  : () => startQuiz(reviewWords, isReview: true),
            ),
            if (widget.nextBatch case final nextBatch?)
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: leaving ? null : () => startQuiz(nextBatch()),
                child: const Text(
                  '같은 주제로 다음 5문제 풀기',
                  textAlign: TextAlign.center,
                ),
              ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: leaving
                  ? null
                  : () {
                      if (leaving) return;
                      setState(() => leaving = true);
                      MainScreen.goHome(context);
                    },
              child: const Text('홈으로'),
            ),
          ],
        ),
        children: [
          const MascotPanel(
            message: '끝까지 해냈어요! 🎉',
            compact: true,
            dance: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: orange,
              borderRadius: cardRadius,
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    const Text('이번 학습에서 받은 보상'),
                    Text('+$earnedXp XP', style: text.titleMedium),
                  ],
                ),
                Text(
                  '정답 1문제당 3 XP · $correctCount문제 정답',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      '정답률 $percentage%',
                      style: text.titleMedium?.copyWith(color: green),
                    ),
                    Text('${words.length}문제 중 $correctCount문제를 맞혔어요.'),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: accuracy,
                  minHeight: 6,
                  color: green,
                  backgroundColor: mint,
                  borderRadius: BorderRadius.circular(8),
                  semanticsLabel: '정답률',
                  semanticsValue: '$percentage%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            missedWords.isEmpty ? '모두 정답이에요! 🎉' : '다시 확인할 단어',
            style: text.titleMedium,
          ),
          const SizedBox(height: 8),
          if (missedWords.isEmpty)
            const Text('배운 단어를 한 번 더 복습하면 오래 기억할 수 있어요.')
          else
            for (final word in missedWords)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: word.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' · ${word.meaning}'),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class ExplanationScreen extends StatefulWidget {
  const ExplanationScreen({
    super.key,
    required this.word,
    required this.answer,
    this.continueLabel = '학습 목록으로',
    this.onContinue,
  });

  final Word word;
  final String answer;
  final String continueLabel;
  final VoidCallback? onContinue;

  @override
  State<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends State<ExplanationScreen> {
  bool continuing = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final answer = widget.answer;
    final correct = answer == word.correctChoice;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('해설')),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        footer: FilledButton(
          onPressed: continuing
              ? null
              : () {
                  if (continuing) return;
                  setState(() => continuing = true);
                  (widget.onContinue ?? () => Navigator.of(context).pop())();
                },
          child: Text(widget.continueLabel, textAlign: TextAlign.center),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: correct ? mint : orange,
              borderRadius: cardRadius,
            ),
            child: Row(
              children: [
                MascotReaction(
                  sad: !correct,
                  child: Image.asset(
                    correct
                        ? 'assets/images/chick_mascot_happy.png'
                        : 'assets/images/chick_mascot_sad.png',
                    width: 80,
                    height: 86,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        correct ? Icons.check_circle : Icons.cancel_outlined,
                        color: correct ? green : Colors.deepOrange,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        correct ? '정답이에요!' : '아쉬워요!',
                        style: text.titleLarge?.copyWith(
                          color: correct ? green : navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        correct ? '정말 잘했어요!' : '정답을 함께 확인해 봐요.',
                        style: text.bodyMedium?.copyWith(
                          color: correct ? green : navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: cardPadding,
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              border: Border.all(color: navy),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (word.choices != null) ...[
                  Text(
                    '정답 보기 · ${word.correctChoice}',
                    style: text.titleMedium,
                  ),
                  if (!correct) Text('내가 고른 보기 · $answer'),
                  const SizedBox(height: 14),
                ],
                Text('오늘의 단어', style: text.labelLarge),
                const SizedBox(height: 12),
                Text(
                  word.name,
                  style: text.headlineMedium?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 14),
                Text('뜻', style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  word.meaning,
                  style: text.bodyLarge?.copyWith(color: green),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: navy),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        word.explanation == null ? '예문' : '해설',
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.explanation ?? word.example,
                        style: text.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MascotPanel extends StatelessWidget {
  const MascotPanel({
    super.key,
    required this.message,
    this.background = mint,
    this.animate = false,
    this.dance = false,
    this.sad = false,
    this.compact = false,
  });

  final String message;
  final Color background;
  final bool animate;
  final bool dance;
  final bool sad;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final imageSize = compact
        ? 56.0
        : (MediaQuery.sizeOf(context).height * 0.21).clamp(108.0, 150.0);
    final mascot = ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          dance
              ? 'assets/images/chick_mascot_happy.png'
              : sad
              ? 'assets/images/chick_mascot_sad.png'
              : 'assets/images/chick_mascot.webp',
          width: imageSize,
          height: imageSize * 1.08,
          fit: BoxFit.contain,
        ),
      ),
    );
    final shouldAnimate = animate && !MediaQuery.disableAnimationsOf(context);
    final animatedMascot = dance || sad
        ? MascotReaction(sad: sad, child: mascot)
        : TweenAnimationBuilder<double>(
            tween: Tween(begin: shouldAnimate ? 0.92 : 1.0, end: 1.0),
            duration: shouldAnimate ? feedbackDuration : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: mascot,
          );
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: background, borderRadius: cardRadius),
        child: Row(
          children: [
            animatedMascot,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: background == mint ? green : navy),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(color: background, borderRadius: cardRadius),
      child: Column(
        children: [
          animatedMascot,
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: background == mint ? green : navy),
          ),
        ],
      ),
    );
  }
}

class MascotReaction extends StatefulWidget {
  const MascotReaction({super.key, required this.child, this.sad = false});
  final Widget child;
  final bool sad;

  @override
  State<MascotReaction> createState() => _MascotReactionState();
}

class _MascotReactionState extends State<MascotReaction>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.sad ? 1400 : 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      controller.stop();
      controller.value = 0;
    } else if (!controller.isAnimating) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.sad ? '슬퍼하며 고개를 떨구는 병아리' : '웃으며 춤추는 병아리',
      child: AnimatedBuilder(
        animation: controller,
        child: widget.child,
        builder: (context, child) {
          final beat = controller.value * 2 * math.pi;
          final sway = math.sin(beat);
          final hop = math.sin(beat * 2).abs();
          // 오답 반응은 천천히 몸을 낮추며 고개를 숙이는 동작입니다.
          final droop = (1 - math.cos(beat)) / 2;
          return Transform.translate(
            offset: widget.sad
                ? Offset(sway * 2, droop * 7)
                : Offset(sway * 4, -hop * 6),
            child: Transform.rotate(
              angle: widget.sad ? -droop * 0.055 : sway * 0.06,
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scaleX: widget.sad ? 1.0 : 1 + hop * 0.035,
                scaleY: widget.sad ? 1 - droop * 0.025 : 1 - hop * 0.025,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
