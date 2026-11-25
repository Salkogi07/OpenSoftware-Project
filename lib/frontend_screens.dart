import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'learning/learning_repository.dart';
import 'learning/learning_stats.dart';
import 'record_screen.dart' as record;

part 'home_page.dart';
part 'my_page.dart';
part 'study_preview.dart';
part 'frame_icons.dart';

void main() => runApp(const VocabularyApp());

const navy = Color(0xff082440);
const green = Color(0xff087d17);
const mint = Color(0xffe7f7eb);
const orange = Color(0xffffe4bf);

const _tabSelectedColor = Color(0xffef6b00);
const _tabUnselectedColor = Color(0xff697370);
const _tabDividerColor = Color(0xffeeeeee);

double _phoneSpacing(BuildContext context, double value) {
  const referenceWidth = 360.0;
  final width = MediaQuery.sizeOf(context).width.clamp(300.0, 420.0);
  return value * width / referenceWidth;
}

AppBar _tabAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  bool showBack = true,
  String visibleTitle = '하루어휘',
  double? toolbarHeight,
  bool showDivider = true,
}) => AppBar(
  title: Semantics(
    label: title == '하루어휘' ? null : title,
    child: Text(visibleTitle),
  ),
  automaticallyImplyLeading: false,
  leading: showBack && Navigator.of(context).canPop()
      ? IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const _FrameIcon(_FrameSymbol.back, color: navy),
        )
      : null,
  centerTitle: true,
  toolbarHeight: toolbarHeight ?? _phoneSpacing(context, 60),
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 0,
  titleTextStyle: const TextStyle(
    color: navy,
    fontFamily: 'Pretendard',
    fontSize: 23,
    fontVariations: [FontVariation('wght', 850)],
  ),
  bottom: showDivider
      ? const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _tabDividerColor),
        )
      : null,
  actions: [
    ...?actions,
    Builder(
      builder: (context) => IconButton(
        tooltip: '알림',
        icon: const Stack(
          children: [
            _FrameIcon(_FrameSymbol.bell, color: navy),
            Positioned(
              top: 0,
              right: 0,
              child: CircleAvatar(
                radius: 3,
                backgroundColor: _tabSelectedColor,
              ),
            ),
          ],
        ),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('알림'),
            content: Text('표시할 알림이 없어요.'),
          ),
        ),
      ),
    ),
  ],
);

const cardRadius = BorderRadius.all(Radius.circular(14));
const cardPadding = EdgeInsets.all(20);
const buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(15)),
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
  chipTheme: const ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: mint,
    checkmarkColor: green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(9)),
    ),
    padding: EdgeInsets.zero,
    side: BorderSide(color: Color(0xffe4eceb)),
    labelStyle: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 11,
      height: 1.2,
      color: navy,
      fontVariations: [FontVariation('wght', 850)],
    ),
  ),
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
          ? _pretendardText(14, weight: 750, color: _tabSelectedColor)
          : _pretendardText(14, weight: 650, color: _tabUnselectedColor),
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
      fontWeight: FontWeight.w800,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      height: 1.25,
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
      minimumSize: const Size.fromHeight(50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      backgroundColor: navy,
      foregroundColor: Colors.white,
      shape: buttonShape,
      animationDuration: feedbackDuration,
      textStyle: _pretendardText(19, weight: 820),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      foregroundColor: navy,
      shape: buttonShape,
      animationDuration: feedbackDuration,
      textStyle: _pretendardText(19, weight: 820),
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
      home: const MainScreen(preview: true),
    );
  }
}

// 화면을 넓은 브라우저에서도 휴대폰처럼 읽기 편한 폭으로 표시합니다.
class ScreenBody extends StatelessWidget {
  const ScreenBody({
    super.key,
    required this.children,
    this.footer,
    this.footerPadding,
    this.controller,
    this.contentPadding,
    this.scrollFooter = false,
  });

  final List<Widget> children;
  final Widget? footer;
  final EdgeInsetsGeometry? footerPadding;
  final ScrollController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final bool scrollFooter;

  @override
  Widget build(BuildContext context) {
    final bodyPadding =
        contentPadding ??
        EdgeInsets.fromLTRB(
          _phoneSpacing(context, 15),
          _phoneSpacing(context, 12),
          _phoneSpacing(context, 15),
          24,
        );
    final footerWidget = footer;
    final paddedFooter = footerWidget == null
        ? null
        : Padding(
            padding:
                footerPadding ??
                EdgeInsets.fromLTRB(
                  _phoneSpacing(context, 15),
                  12,
                  _phoneSpacing(context, 15),
                  _phoneSpacing(context, 46),
                ),
            child: footerWidget,
          );
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: scrollFooter && paddedFooter != null
              ? CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverPadding(
                      padding: bodyPadding,
                      sliver: SliverList.list(children: children),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: paddedFooter,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: bodyPadding,
                        children: children,
                      ),
                    ),
                    if (paddedFooter != null) paddedFooter,
                  ],
                ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.preview = false});

  final bool preview;

  static void goHome(BuildContext context) {
    context.findAncestorStateOfType<_MainScreenState>()!.goHome();
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;
  late final library = _StudyLibrary(preview: widget.preview);
  final navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  late final tabObservers = {
    for (final tab in [0, 1, 3])
      tab: _QuizRouteObserver(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && selectedTab == tab) setState(() {});
        });
      }),
  };

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
      child: ColoredBox(
        color: widget.preview ? const Color(0xfff2f5f8) : Colors.white,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.preview && kIsWeb ? 390 : double.infinity,
            ),
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
              bottomNavigationBar:
                  tabObservers[selectedTab]?.showingQuiz == true
                  ? null
                  : DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: _tabDividerColor),
                        ),
                      ),
                      child: ColoredBox(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                widget.preview &&
                                    kIsWeb &&
                                    selectedTab == 0 &&
                                    MediaQuery.sizeOf(context).width <= 430
                                ? 18
                                : 0,
                          ),
                          child: NavigationBar(
                            height: _phoneSpacing(context, 62),
                            labelBehavior:
                                NavigationDestinationLabelBehavior.alwaysShow,
                            selectedIndex: selectedTab,
                            onDestinationSelected: (index) {
                              if (index == 1) {
                                navigatorKeys[1].currentState?.popUntil(
                                  (route) => route.isFirst,
                                );
                              }
                              setState(() => selectedTab = index);
                              library.refresh(); // 탭을 옮길 때마다 최신 기록으로
                            },
                            destinations: const [
                              NavigationDestination(
                                icon: _FrameIcon(_FrameSymbol.home),
                                selectedIcon: _FrameIcon(
                                  _FrameSymbol.home,
                                  active: true,
                                ),
                                label: '홈',
                              ),
                              NavigationDestination(
                                icon: _FrameIcon(_FrameSymbol.book),
                                selectedIcon: _FrameIcon(
                                  _FrameSymbol.book,
                                  active: true,
                                ),
                                label: '학습',
                              ),
                              NavigationDestination(
                                icon: _FrameIcon(_FrameSymbol.history),
                                selectedIcon: _FrameIcon(
                                  _FrameSymbol.history,
                                  active: true,
                                ),
                                label: '기록',
                              ),
                              NavigationDestination(
                                icon: _FrameIcon(_FrameSymbol.person),
                                selectedIcon: _FrameIcon(
                                  _FrameSymbol.person,
                                  active: true,
                                ),
                                label: '마이',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStudySetup() {
    final study = navigatorKeys[1].currentState;
    study?.popUntil((route) => route.isFirst);
    study?.push(MaterialPageRoute<void>(builder: (_) => const TopicScreen()));
    setState(() => selectedTab = 1);
  }

  Widget _tabNavigator(int tabIndex, GlobalKey<NavigatorState> key) =>
      NavigatorPopHandler<Object?>(
        enabled: selectedTab == tabIndex,
        onPopWithResult: (result) => key.currentState!.pop(result),
        child: Navigator(
          key: key,
          observers: [tabObservers[tabIndex]!],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => switch (tabIndex) {
              0 => HomeScreen(
                onContinue: _openStudySetup,
                onRecords: () => setState(() => selectedTab = 2),
              ),
              1 => const StudyScreen(),
              _ => _MyTab(library: library),
            },
          ),
        ),
      );
}

class _QuizRouteObserver extends NavigatorObserver {
  _QuizRouteObserver(this.onQuizVisibilityChanged);

  final VoidCallback onQuizVisibilityChanged;
  bool showingQuiz = false;

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    final wasShowingQuiz = showingQuiz;
    showingQuiz = topRoute is _QuizRoute;
    if (showingQuiz != wasShowingQuiz) onQuizVisibilityChanged();
  }
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
      appBar: _tabAppBar(context, '기록 탭'),
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
    final library = _LibraryScope.watch(context);
    final completed = library?.studyCompleted ?? 0;

    void setup({String? topic, String? difficulty}) =>
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                TopicScreen(initialTopic: topic, initialDifficulty: difficulty),
          ),
        );

    void review() {
      final mistakes = library?.mistakes.values;
      if (mistakes != null && mistakes.isNotEmpty) {
        _review(context, mistakes);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아직 틀린 단어가 없어요. 학습 중 틀린 단어가 여기에 모여요.')),
        );
      }
    }

    return Scaffold(
      appBar: _tabAppBar(
        context,
        '학습 탭',
        visibleTitle: '학습',
        toolbarHeight: 45,
        showDivider: false,
      ),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
        children: [
          const _StudyBanner(
            title: '오늘의 어휘를\n학습해볼까요?',
            subtitle: '짧은 퀴즈로 쉽고 재미있게 배워요!',
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text('학습 진행', style: _pretendardText(17, weight: 850)),
              ),
              Text.rich(
                TextSpan(
                  text: '오늘의 학습 ',
                  style: _pretendardText(13, weight: 550, color: _muted),
                  children: [
                    TextSpan(
                      text: '$completed',
                      style: _pretendardText(16, weight: 850, color: green),
                    ),
                    TextSpan(
                      text: ' / 5',
                      style: _pretendardText(16, weight: 850),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _studyProgress(
            completed / 5,
            color: const Color(0xff277c2c),
            trackColor: const Color(0xffedf5ee),
          ),
          const SizedBox(height: 24),
          _StudyCard(
            mascot: 'assets/images/chick_calendar.png',
            tag: '매일 새로운 어휘',
            title: '오늘의 추천 어휘',
            subtitle: '지금 꼭 알아야 할 단어 5개!',
            warm: true,
            minHeight: 78,
            cornerRadius: 12,
            onTap: () => setup(topic: _officialTopic, difficulty: '중'),
          ),
          const SizedBox(height: 8),
          _StudyCard(
            mascot: 'assets/images/chick_review.png',
            tag: '틀린 단어 복습',
            minHeight: 74,
            cornerRadius: 12,
            title: '단어장 복습',
            subtitle: '내가 틀린 단어를 다시 풀어요.',
            onTap: review,
          ),
          const SizedBox(height: 8),
          _StudyCard(
            mascot: 'assets/images/chick_topic.png',
            tag: '주제별로 차근차근',
            minHeight: 71,
            cornerRadius: 12,
            title: '주제별 학습',
            subtitle: '상황에 맞는 어휘를 골라 배워요.',
            onTap: () => setup(),
          ),
          const SizedBox(height: 23),
          Row(
            children: [
              const _FrameIcon(_FrameSymbol.book, size: 19, color: _studyMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '학습 주제 미리보기',
                  style: _pretendardText(15, weight: 850),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => setup(),
                child: Text(
                  '전체 보기 ›',
                  style: _pretendardText(11, weight: 700, color: _studyMuted),
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, (topic, label, icon))
                    in _studyTopics.indexed) ...[
                  if (index > 0) const SizedBox(width: 5),
                  Expanded(
                    child: _StudyTopicTile(
                      label: label,
                      icon: icon,
                      onTap: () => setup(topic: topic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key, this.initialTopic, this.initialDifficulty});

  final String? initialTopic;
  final String? initialDifficulty;

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
  late String? topic = widget.initialTopic;
  late String? difficulty = widget.initialDifficulty;

  Future<List<Word>> loadQuestions() => loadQuestionBank();

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
      appBar: _tabAppBar(context, '하루어휘', showBack: false),
      body: FutureBuilder<List<Word>>(
        future: _LibraryScope.watch(context)?.preview == true
            ? _previewBank
            : bank,
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
          final preview = _LibraryScope.watch(context)?.preview ?? false;
          final words = snapshot.data;
          if (words == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final selectedTopic = topic;
          final selectedDifficulty = difficulty;
          return ScreenBody(
            footer: FilledButton(
              onPressed: selectedTopic == null || selectedDifficulty == null
                  ? null
                  : () {
                      if (ModalRoute.of(context)?.isCurrent != true) return;
                      List<Word> next() => preview
                          ? _previewQuestions(selectedTopic, selectedDifficulty)
                          : nextBatch(words, selectedTopic, selectedDifficulty);
                      openQuiz(context, next(), nextBatch: next);
                    },
              child: const Text('5문제 시작하기'),
            ),
            children: [
              Text('학습 주제', style: text.headlineMedium),
              const SizedBox(height: 8),
              const Text('주제와 난이도를 골라 5문제를 풀어보세요.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  for (final category
                      in words.map((word) => word.topic).toSet())
                    ChoiceChip(
                      label: Text(
                        category,
                        style: _pretendardText(11, weight: 850),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
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
                spacing: 4,
                runSpacing: 2,
                children: [
                  for (final entry in difficulties.entries)
                    ChoiceChip(
                      label: Text('${entry.key} · ${entry.value}'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      selected: selectedDifficulty == entry.key,
                      onSelected: (_) => setState(() => difficulty = entry.key),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 900문제 은행(assets/questions.json) 읽기
Future<List<Word>> loadQuestionBank() async {
  final source = await rootBundle.loadString('assets/questions.json');
  final rows = jsonDecode(source) as List<dynamic>;
  return rows.map((row) => Word.fromJson(row as Map<String, dynamic>)).toList();
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
    this.usesBlank = false,
    this.hint,
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
  final bool usesBlank;
  final String? hint;

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
  bool isReview = false,
  List<Word> Function()? nextBatch,
}) {
  if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
  Navigator.of(context).push(
    _QuizRoute(
      QuizScreen(words: words, isReview: isReview, nextBatch: nextBatch),
    ),
  );
}

class _QuizRoute extends MaterialPageRoute<void> {
  _QuizRoute(QuizScreen screen) : super(builder: (_) => screen);
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
    final library = _LibraryScope.read(context);
    final correct = choice == word.correctChoice;
    if (savedQuestionIndex != questionIndex) {
      library?.recordPreviewAnswer(word, correct);
    }
    if (!correct) {
      library?.recordMistake(word);
    }
    final firstSubmission = savedQuestionIndex != questionIndex;
    savedQuestionIndex = questionIndex;
    if (word.id case final id?
        when firstSubmission && library?.preview != true) {
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
      if (library?.preview != true) learningRepository.markAttendance();
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
    final choices =
        word.choices ??
        (questionIndex.isEven
            ? [word.alternative, word.name]
            : [word.name, word.alternative]);
    final prompt =
        word.prompt ??
        (word.name.isEmpty
            ? word.example
            : word.example.replaceFirst(word.name, '{빈칸}'));
    final selected = selectedChoice;
    final compact = MediaQuery.sizeOf(context).height < 800;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _tabAppBar(
        context,
        '학습 퀴즈',
        visibleTitle: '학습',
        toolbarHeight: 52,
      ),
      body: ScreenBody(
        controller: scrollController,
        contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
        footerPadding: EdgeInsets.fromLTRB(16, 20, 16, compact ? 32 : 56),
        footer: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
            backgroundColor: const Color(0xff193f60),
            disabledBackgroundColor: const Color(0xff193f60),
            disabledForegroundColor: Colors.white,
            textStyle: _pretendardText(22, weight: 850),
          ),
          onPressed: selected == null || showingExplanation
              ? null
              : () => submitAnswer(selected),
          child: const Text('정답 확인하기'),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${questionIndex + 1}',
                        style: const TextStyle(color: _quizGreen),
                      ),
                      TextSpan(text: ' / ${widget.words.length}'),
                    ],
                  ),
                  style: _pretendardText(18, weight: 850),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (questionIndex + 1) / widget.words.length,
                    minHeight: 13,
                    stopIndicatorRadius: 0,
                    trackGap: 0,
                    borderRadius: BorderRadius.circular(8),
                    color: _quizGreen,
                    backgroundColor: _quizTrack,
                    semanticsLabel: '퀴즈 진행률',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _QuizPromptCard(prompt: prompt, hint: word.hint, compact: compact),
          const SizedBox(height: 12),
          for (final (index, choice) in choices.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index < choices.length - 1 ? 8 : 0,
              ),
              child: _QuizChoice(
                index: index,
                choice: choice,
                selected: selected == choice,
                onPressed: showingExplanation
                    ? null
                    : () => setState(() => selectedChoice = choice),
              ),
            ),
        ],
      ),
    );
  }
}

const _quizMascotAsset = 'assets/images/chick_thinking.png';
const _quizGreen = Color(0xff099604);
const _quizTrack = Color(0xffdff3e4);
const _quizCardBoxGap = 16.0;
const _quizGuidance = '빈칸에 알맞은 표현을 골라보세요.';

class _QuizPromptCard extends StatelessWidget {
  const _QuizPromptCard({
    required this.prompt,
    required this.compact,
    this.hint,
  });

  final String prompt;
  final bool compact;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final hintSuffix = hint == null ? null : '\n힌트 · $hint';
    final sentence = hintSuffix != null && prompt.endsWith(hintSuffix)
        ? prompt.substring(0, prompt.length - hintSuffix.length)
        : prompt;
    final parts = sentence.split('{빈칸}');
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 12 : 24,
        16,
        compact ? 12 : 26,
      ),
      decoration: BoxDecoration(
        color: _quizTrack,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                _quizMascotAsset,
                width: 78,
                height: compact ? 78 : 94,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      margin: const EdgeInsets.only(left: 18, top: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffcfeeda),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _FrameIcon(
                            _FrameSymbol.book,
                            size: 22,
                            color: navy,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '어휘 퀴즈',
                              style: _pretendardText(17, weight: 850),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: _quizCardBoxGap),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff3f8b68),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _quizGuidance,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: _pretendardText(
                            16,
                            weight: 750,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _quizCardBoxGap),
          Container(
            constraints: const BoxConstraints(minHeight: 108),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: Colors.white,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  for (final (index, segment) in parts.indexed) ...[
                    if (index > 0)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 88,
                          constraints: const BoxConstraints(minHeight: 35),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xfffff4ec),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xffff560c),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '?',
                            semanticsLabel: '빈칸',
                            style: _pretendardText(
                              27,
                              weight: 900,
                              color: const Color(0xffff560c),
                            ),
                          ),
                        ),
                      ),
                    TextSpan(text: segment),
                  ],
                ],
              ),
              textAlign: TextAlign.center,
              style: _pretendardText(26, weight: 850).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizChoice extends StatelessWidget {
  const _QuizChoice({
    required this.index,
    required this.choice,
    required this.selected,
    required this.onPressed,
  });

  final int index;
  final String choice;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.fromLTRB(19, 4, 14, 4),
        backgroundColor: selected ? const Color(0xffe6f7e9) : Colors.white,
        side: BorderSide(
          color: selected ? _quizGreen : const Color(0xffaeb7c5),
          width: 1,
        ),
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: selected ? _quizGreen : _quizTrack,
            child: Text(
              '${index + 1}',
              style: _pretendardText(
                17,
                weight: 850,
                color: selected ? Colors.white : _quizGreen,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              choice,
              style: _pretendardText(20, weight: 850, color: navy),
            ),
          ),
        ],
      ),
    ),
  );
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
      _QuizRoute(
        QuizScreen(
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
    const horizontalPadding = 20.0;
    const buttonGap = SizedBox(height: 5);
    return Scaffold(
      appBar: AppBar(title: Text(isReview ? '복습 완료' : '학습 완료')),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(
          horizontalPadding,
          8,
          horizontalPadding,
          8,
        ),
        footerPadding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          _phoneSpacing(context, 46),
        ),
        scrollFooter: true,
        footer: Column(
          mainAxisSize: MainAxisSize.min,
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
            if (widget.nextBatch case final nextBatch?) ...[
              buttonGap,
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
              buttonGap,
            ],
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
    final library = _LibraryScope.watch(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _tabAppBar(context, '해설'),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(15, 7, 15, 12),
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
                        ? _celebratingMascot
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
                      Row(
                        children: [
                          Icon(
                            correct
                                ? Icons.check_circle
                                : Icons.cancel_outlined,
                            color: correct ? green : _tabSelectedColor,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              correct ? '정답이에요!' : '아쉬워요!',
                              style: _pretendardText(
                                23,
                                weight: 850,
                                color: correct ? green : navy,
                              ),
                            ),
                          ),
                        ],
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
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('정답 단어', style: text.labelLarge)),
                    if (library != null)
                      SizedBox.square(
                        dimension: 33,
                        child: _SaveWordButton(library: library, word: word),
                      ),
                  ],
                ),
                Text(
                  word.name,
                  style: text.headlineMedium?.copyWith(fontSize: 32),
                ),
                Text(word.meaning, style: text.bodyMedium),
                if (word.correctChoice != word.name)
                  Text('정답 보기 · ${word.correctChoice}'),
                if (!correct) Text('내가 고른 보기 · $answer', style: text.bodySmall),
                if (word.example.isNotEmpty) ...[
                  const Divider(color: _line),
                  Text('예문', style: text.titleMedium),
                  Text(word.example, style: text.bodyLarge),
                ],
              ],
            ),
          ),
          if (word.explanation case final detail?) ...[
            const SizedBox(height: 12),
            _MyPanel(
              color: _warm,
              child: ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: _tabSelectedColor,
                ),
                title: Text(
                  word.id == null ? '언제 쓰나요?' : '해설',
                  style: const TextStyle(
                    color: _rust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(detail),
              ),
            ),
          ],
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
              ? _celebratingMascot
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
