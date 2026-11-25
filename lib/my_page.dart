part of 'frontend_screens.dart';

const _warm = Color(0xfffff3e5);
const _rust = Color(0xff9b4417);
const _muted = Color(0xff516477);
const _line = Color(0xffdcebe5);

class _StudyLibrary extends ChangeNotifier {
  _StudyLibrary({required this.preview, this.onSignOut}) {
    if (preview) {
      streak = 7;
      longestStreak = 7;
      summary = const LearningSummary(
        totalAnswers: 130,
        correctAnswers: 107,
        learnedWords: 120,
        todayAnswers: 7,
      );
    } else {
      _loadSettings();
      _loadQuizSession();
    }
  }

  /// 풀다가 나간 문제 (이어서 풀기). 없으면 null
  _ActiveQuiz? activeQuiz;

  // 주제·난이도별로 아직 안 낸 문제 (같은 문제가 바로 다시 나오지 않게)
  final _remaining = <(String, String), List<Word>>{};

  /// [topic]·[difficulty] 문제 [count]개 뽑기. 다 내면 다시 섞어서 처음부터
  List<Word> nextBatch(
    List<Word> bank,
    String topic,
    String difficulty,
    int count,
  ) => takeBatch(
    _remaining.putIfAbsent((topic, difficulty), () => []),
    count,
    () => bank.where(
      (word) => word.topic == topic && word.difficulty == difficulty,
    ),
  );

  /// 문제를 넘길 때마다 진행 상황 저장 (로그인 상태면 앱을 다시 켜도 이어짐)
  void saveQuizProgress(_ActiveQuiz quiz) {
    activeQuiz = quiz;
    notifyListeners();
    final ids = [for (final word in quiz.words) ?word.id];
    if (preview || ids.length != quiz.words.length) return;
    saveQuizSession(
      QuizSession(
        questionIds: ids,
        index: quiz.index,
        answers: quiz.answers,
        isReview: quiz.isReview,
        topic: quiz.topic,
        difficulty: quiz.difficulty,
      ),
    ).catchError((Object e) => debugPrint('풀던 문제 저장 실패: $e'));
  }

  void clearQuizProgress() {
    if (activeQuiz == null) return;
    activeQuiz = null;
    notifyListeners();
    if (!preview) {
      saveQuizSession(null)
          .catchError((Object e) => debugPrint('풀던 문제 지우기 실패: $e'));
    }
  }

  Future<void> _loadQuizSession() async {
    try {
      final session = await loadQuizSession();
      if (session == null || _disposed) return;
      final bank = await loadQuestionBank();
      final byId = {for (final word in bank) word.id: word};
      final words = [for (final id in session.questionIds) ?byId[id]];
      if (_disposed || activeQuiz != null) return;
      if (words.length != session.count) {
        await saveQuizSession(null); // 문제 은행이 바뀌어 찾을 수 없는 문제가 있음
        return;
      }
      final (topic, difficulty) = (session.topic, session.difficulty);
      activeQuiz = _ActiveQuiz(
        words: words,
        index: session.index,
        answers: session.answers,
        isReview: session.isReview,
        topic: topic,
        difficulty: difficulty,
        nextBatch: topic == null || difficulty == null
            ? null
            : () => nextBatch(bank, topic, difficulty, session.count),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('풀던 문제 불러오기 실패: $e');
    }
  }

  // 기기에 저장한 하루 목표·알림 설정 불러오기 (미리보기는 저장하지 않음)
  Future<void> _loadSettings() async {
    try {
      final settings = await loadStudySettings();
      if (_disposed) return;
      dailyGoal = settings.dailyGoal;
      reminderTime = settings.reminderTime;
      reminderOn = settings.reminderOn;
      notifyListeners();
    } catch (e) {
      debugPrint('학습 설정 불러오기 실패: $e');
    }
  }

  final bool preview;
  final Future<void> Function()? onSignOut;
  bool previewSignedIn = false;

  /// 로그인한 이메일 (미리보기·로그아웃 상태면 null)
  String? get email => preview ? null : learningRepository.email;

  /// 가입한 날 (미리보기·로그아웃 상태면 null)
  DateTime? get signedUpAt => preview ? null : learningRepository.signedUpAt;

  /// 이 기기를 포함해 로그인된 모든 기기에서 로그아웃
  Future<void> signOutEverywhere() async {
    if (!preview) await AuthService().signOutEverywhere();
    await signOut();
  }

  Future<void> signOut() async {
    if (preview) {
      setPreviewSignedIn(false);
      return;
    }
    await onSignOut?.call();
  }

  Future<void> changePassword(String newPassword) async {
    if (!preview) await AuthService().changePassword(newPassword);
  }

  /// 회원 탈퇴 뒤 로그인 화면으로 (미리보기는 로그아웃 상태로만 바꿈)
  Future<void> deleteAccount() async {
    if (!preview) {
      // 공개 저장소에 올린 프로필 사진부터 지움 (DB 함수로는 파일을 지울 수 없음)
      await learningRepository.removeAvatarPhotos();
      await AuthService().deleteAccount();
    }
    await signOut();
  }

  int dailyGoal = StudySettings.defaults.dailyGoal;
  TimeOfDay reminderTime = StudySettings.defaults.reminderTime;
  bool reminderOn = false;
  final _previewLearned = <(String, String)>{};

  int get studyCompleted =>
      math.min(5, preview ? summary.todayAnswers - 5 : summary.todayAnswers);

  void setPreviewSignedIn(bool signedIn) {
    previewSignedIn = signedIn;
    notifyListeners();
  }

  void recordPreviewAnswer(Word word, bool correct) {
    if (!preview) return;
    summary = LearningSummary(
      totalAnswers: summary.totalAnswers + 1,
      correctAnswers: summary.correctAnswers + (correct ? 1 : 0),
      learnedWords:
          summary.learnedWords + (_previewLearned.add(key(word)) ? 1 : 0),
      todayAnswers: summary.todayAnswers + 1,
    );
    notifyListeners();
  }

  void setGoal(int goal) {
    dailyGoal = goal;
    if (!preview) saveDailyGoal(goal);
    notifyListeners();
  }

  /// 매일 [time]에 학습 알림. 알림 권한을 거절하면 false
  Future<bool> turnOnReminderAt(TimeOfDay time) async {
    if (!preview && !await turnOnReminder(time)) return false;
    reminderTime = time;
    reminderOn = true;
    notifyListeners();
    return true;
  }

  Future<void> turnOffReminderNow() async {
    if (!preview) await turnOffReminder(reminderTime);
    reminderOn = false;
    notifyListeners();
  }

  final saved = <(String, String), Word>{};
  final mistakes = <(String, String), Word>{};
  String nickname = '어휘새싹';

  /// 프로필 사진: 'mascot:<에셋>', 'photo:<주소>', 미리보기는 'file:<경로>'. null이면 기본 캐릭터
  String? avatar;

  // 수파베이스에서 불러온 학습 기록 (로그인했을 때만 채워짐)
  int streak = 0;
  int longestStreak = 0;
  LearningSummary summary = LearningSummary.empty;
  WeeklyStats weekly = weeklyStats(const [], DateTime.now());
  List<Word> topWrongWords = const [];
  bool loading = false;
  String? loadError;
  bool _disposed = false;

  /// DB에서 연속 출석·요약·어휘장·주간 통계를 다시 불러옴. 탭을 옮기거나 홈으로 돌아올 때 부름
  Future<void> refresh() async {
    if (preview || _disposed || !learningRepository.isLoggedIn) return;
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      await learningRepository.flush(); // 방금 푼 결과 저장이 끝난 뒤에 불러옴
      final (name, streaks, newSummary, wrongRows, attempts) = await (
        learningRepository.fetchNickname(),
        learningRepository.fetchStreaks(),
        learningRepository.fetchSummary(),
        learningRepository.fetchWrongQuestionRows(),
        learningRepository.fetchRecentAttempts(),
      ).wait;
      final newWeekly = weeklyStats(attempts, DateTime.now());
      final topRows = await learningRepository.fetchQuestionRows(
        newWeekly.topWrongQuestionIds,
      );
      final byId = {for (final row in topRows) row['id'] as String: row};
      if (_disposed) return;
      if (name != null && name.isNotEmpty) nickname = name;
      streak = streaks.$1;
      longestStreak = streaks.$2;
      summary = newSummary;
      weekly = newWeekly;
      topWrongWords = [
        for (final id in newWeekly.topWrongQuestionIds)
          if (byId[id] case final row?) Word.fromJson(row),
      ];
      mistakes
        ..clear()
        ..addEntries(
          wrongRows.map(Word.fromJson).map((word) => MapEntry(key(word), word)),
        );
    } catch (e) {
      debugPrint('학습 기록 불러오기 실패: $e');
      loadError = '기록을 불러오지 못했어요.';
    } finally {
      loading = false;
      if (!_disposed) notifyListeners();
    }
    // 프로필 사진은 따로 불러옴: 실패해도 학습 기록 표시에는 영향 없음
    try {
      final value = await learningRepository.fetchAvatar();
      if (_disposed) return;
      avatar = value;
      notifyListeners();
    } catch (e) {
      debugPrint('프로필 사진 불러오기 실패: $e');
    }
  }

  /// 캐릭터 아바타로 바꾸기 ('mascot:<이름>')
  Future<void> chooseMascot(String asset) => _setAvatar('mascot:$asset');

  /// 갤러리에서 고른 사진으로 바꾸기. 미리보기는 올리지 않고 이 기기 파일을 그대로 보여 줌
  Future<void> choosePhoto(XFile file) async {
    if (preview) return _setAvatar('file:${file.path}');
    final value = await learningRepository.uploadAvatarPhoto(
      await file.readAsBytes(),
      file.name.split('.').last,
    );
    if (value != null) await _setAvatar(value);
  }

  Future<void> _setAvatar(String value) async {
    if (!preview) await learningRepository.updateAvatar(value);
    avatar = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  (String, String) key(Word word) => (word.name, word.meaning);

  void recordMistake(Word word) {
    mistakes[key(word)] = word;
    notifyListeners();
  }

  void toggle(Word word) {
    if (saved.remove(key(word)) == null) saved[key(word)] = word;
    notifyListeners();
  }

  void rename(String name) {
    nickname = name;
    if (!preview) learningRepository.updateNickname(name);
    notifyListeners();
  }
}

class _LibraryScope extends InheritedNotifier<_StudyLibrary> {
  const _LibraryScope({required super.notifier, required super.child});

  static _StudyLibrary? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LibraryScope>()?.notifier;

  static _StudyLibrary? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_LibraryScope>()?.notifier;
}

class _SaveWordButton extends StatelessWidget {
  const _SaveWordButton({required this.library, required this.word});

  final _StudyLibrary library;
  final Word word;

  @override
  Widget build(BuildContext context) {
    final saved = library.saved.containsKey(library.key(word));
    return IconButton(
      tooltip: saved ? '저장 해제' : '내 단어장에 저장',
      icon: Icon(
        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: saved ? _rust : green,
      ),
      onPressed: () => library.toggle(word),
    );
  }
}

Future<void> _editNickname(BuildContext context, _StudyLibrary library) async {
  var name = library.nickname;
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('닉네임 변경'),
      content: TextFormField(
        initialValue: name,
        maxLength: 16,
        decoration: const InputDecoration(labelText: '닉네임'),
        onChanged: (value) => name = value,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            if (name.trim().isNotEmpty) Navigator.pop(context, name.trim());
          },
          child: const Text('저장'),
        ),
      ],
    ),
  );
  if (context.mounted && result != null) library.rename(result);
}

Future<void> _confirmSignOut(
  BuildContext context,
  _StudyLibrary library,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('로그아웃할까요?'),
      content: const Text('학습 기록은 계정에 저장되어 있어요. 다시 로그인하면 이어서 볼 수 있어요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('로그아웃'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await library.signOut();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃하지 못했어요. 인터넷 연결을 확인해 주세요.')),
      );
    }
  }
}

/// 알림이 켜져 있으면 시간 변경/끄기를 고르고, 꺼져 있으면 바로 시간을 골라 켬
Future<void> _editReminder(BuildContext context, _StudyLibrary library) async {
  const change = 1, off = 2;
  final action = library.reminderOn
      ? await showDialog<int>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text('매일 ${library.reminderTime.format(context)}에 알림'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, change),
                child: const Text('알림 시간 바꾸기'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, off),
                child: const Text('알림 끄기'),
              ),
            ],
          ),
        )
      : change;
  if (!context.mounted || action == null) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    if (action == off) {
      await library.turnOffReminderNow();
      messenger.showSnackBar(const SnackBar(content: Text('학습 알림을 껐어요.')));
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: library.reminderTime,
      helpText: '매일 학습 알림 받을 시간',
    );
    if (time == null) return;
    final on = await library.turnOnReminderAt(time);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          on
              ? '매일 ${time.format(context)}에 학습 알림을 보내 드릴게요.'
              : '알림 권한을 허용해야 학습 알림을 받을 수 있어요. 설정 앱에서 알림을 켜 주세요.',
        ),
      ),
    );
  } catch (e) {
    debugPrint('학습 알림 설정 실패: $e');
    messenger.showSnackBar(
      const SnackBar(content: Text('알림을 설정하지 못했어요. 잠시 후 다시 시도해 주세요.')),
    );
  }
}

class _MyPage extends StatelessWidget {
  const _MyPage();

  Future<void> _editDailyGoal(
    BuildContext context,
    _StudyLibrary library,
  ) async {
    const customGoal = 0;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('하루 학습 목표'),
        children: [
          for (final goal in [5, 10, 15, 20])
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(goal),
              child: Text('$goal문제'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(customGoal),
            child: const Text('직접 입력'),
          ),
        ],
      ),
    );
    if (!context.mounted || selected == null) return;

    final goal = selected == customGoal
        ? await _inputDailyGoal(context, library.dailyGoal)
        : selected;
    if (context.mounted && goal != null) library.setGoal(goal);
  }

  Future<int?> _inputDailyGoal(BuildContext context, int currentGoal) {
    final form = GlobalKey<FormState>();
    var goal = currentGoal;
    return showDialog<int>(
      context: context,
      builder: (context) {
        void save() {
          final state = form.currentState!;
          if (!state.validate()) return;
          state.save();
          Navigator.of(context).pop(goal);
        }

        return AlertDialog(
          title: const Text('하루 학습 목표 직접 입력'),
          scrollable: true,
          content: Form(
            key: form,
            child: TextFormField(
              initialValue: '$currentGoal',
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '하루에 풀 문제 수',
                suffixText: '문제',
              ),
              validator: (value) {
                final count = int.tryParse(value?.trim() ?? '', radix: 10);
                return count == null || count < 1 ? '1 이상의 정수를 입력해 주세요.' : null;
              },
              onSaved: (value) => goal = int.parse(value!.trim(), radix: 10),
              onFieldSubmitted: (_) => save(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(onPressed: save, child: const Text('저장')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context)!;

    void openWords(bool saved) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LibraryScope(
          notifier: library,
          child: _WordCollection(saved: saved),
        ),
      ),
    );

    return Scaffold(
      appBar: _tabAppBar(context, '마이페이지 탭'),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        children: [
          _LevelCard(
            nickname: library.nickname,
            avatar: library.avatar,
            xp: library.summary.xp,
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _LibraryScope(
                  notifier: library,
                  child: const _ProfileScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _MyHeading('나의 학습 현황', trailing: _loadStatus(library)),
          _TileRow(
            tiles: [
              _MyTile(
                icon: Icons.local_fire_department_rounded,
                label: '연속 학습',
                value: '${library.streak}일',
                ink: _tabSelectedColor,
              ),
              _MyTile(
                icon: Icons.track_changes_rounded,
                label: '전체 정답률',
                value: _percent(library.summary.accuracy),
              ),
              _MyTile(
                icon: Icons.auto_stories_rounded,
                label: '총 학습 단어',
                value: '${library.summary.learnedWords}개',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _MyHeading('나의 복습'),
          _SettingLink(
            icon: Icons.assignment_outlined,
            label: '오답노트',
            detail: '${library.mistakes.length}개',
            onTap: () => openWords(false),
          ),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.favorite_rounded,
            label: '내 단어장',
            detail: '${library.saved.length}개',
            onTap: () => openWords(true),
          ),
          const SizedBox(height: 18),
          const _MyHeading('학습 설정'),
          _SettingLink(
            icon: Icons.notifications_none_rounded,
            label: '알림 설정',
            detail: library.reminderOn
                ? library.reminderTime.format(context)
                : '꺼짐',
            onTap: () => _editReminder(context, library),
          ),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.track_changes_rounded,
            label: '하루 학습 목표',
            detail: '${library.dailyGoal}문제',
            onTap: () => _editDailyGoal(context, library),
          ),
          const SizedBox(height: 18),
          const _MyHeading('계정'),
          _SettingLink(
            icon: Icons.person_outline_rounded,
            label: '계정 관리',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _LibraryScope(
                  notifier: library,
                  child: const _AccountScreen(),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.logout_rounded,
            label: '로그아웃',
            onTap: () => _confirmSignOut(context, library),
          ),
          const SizedBox(height: 18),
          const _MyHeading('정보'),
          _SettingLink(
            icon: Icons.privacy_tip_outlined,
            label: '개인정보 처리방침',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _PrivacyPolicyScreen(),
              ),
            ),
          ),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.description_outlined,
            label: '오픈소스 라이선스',
            onTap: () =>
                showLicensePage(context: context, applicationName: '에르'),
          ),
        ],
      ),
    );
  }
}

/// 정답률 표시: 푼 문제가 없으면 '-'
String _percent(double? accuracy) =>
    accuracy == null ? '-' : '${(accuracy * 100).round()}%';

/// 불러오는 중·실패·로그인 안 함 상태 안내 (제목 오른쪽 작은 글씨)
String? _loadStatus(_StudyLibrary library) {
  if (library.preview) return null;
  if (!learningRepository.isLoggedIn) return '로그인하면 기록이 저장돼요';
  if (library.loading) return '불러오는 중';
  return library.loadError;
}

void _review(BuildContext context, Iterable<Word> words) {
  final batch = words.toList(growable: false);
  openQuiz(context, batch, isReview: true);
}

class _MyHeading extends StatelessWidget {
  const _MyHeading(this.title, {this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (trailing case final label?)
          Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      ],
    ),
  );
}

class _MyPanel extends StatelessWidget {
  const _MyPanel({required this.child, this.color = mint});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: const RoundedRectangleBorder(
      borderRadius: cardRadius,
      side: BorderSide(color: _line),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.nickname,
    required this.avatar,
    required this.xp,
    required this.onEdit,
  });

  final String nickname;
  final String? avatar;
  final int xp;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final level = levelFor(xp);
    return _MyPanel(
      color: mint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(
          children: [
            _ProfileAvatar(avatar: avatar, radius: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              nickname,
                              style: _pretendardText(17, weight: 850),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffffe4bc),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Lv.${level.level}',
                                style: _pretendardText(
                                  13,
                                  weight: 850,
                                  color: _tabSelectedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.only(left: 4),
                        ),
                        onPressed: onEdit,
                        child: Text(
                          '프로필 설정 ›',
                          style: _pretendardText(
                            12,
                            weight: 700,
                            color: _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$xp / ${level.xpForNext} XP',
                    style: _pretendardText(13, weight: 850, color: green),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: level.xpInLevel / xpPerLevel,
                    minHeight: 11,
                    stopIndicatorRadius: 0,
                    trackGap: 0,
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xff00a32a),
                    backgroundColor: const Color(0xffcaefd3),
                    semanticsLabel: '경험치, ${level.xpForNext} 중 $xp',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileRow extends StatelessWidget {
  const _TileRow({required this.tiles});

  final List<_MyTile> tiles;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < tiles.length; i++) ...[
        if (i > 0)
          const SizedBox(
            height: 70,
            child: VerticalDivider(width: 12, color: _line),
          ),
        Expanded(child: tiles[i]),
      ],
    ],
  );
}

class _MyTile extends StatelessWidget {
  const _MyTile({
    required this.icon,
    required this.label,
    required this.value,
    this.ink = green,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color ink;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      children: [
        Icon(icon, color: ink, size: 26),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      ],
    ),
  );
}

class _WordCollection extends StatelessWidget {
  const _WordCollection({required this.saved});

  final bool saved;

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context)!;
    final words = (saved ? library.saved : library.mistakes).values;
    final emptyText = saved
        ? '아직 저장한 단어가 없어요. 문제를 풀며 하트를 눌러 보세요.'
        : '아직 오답이 없어요. 학습 중 틀린 단어가 여기에 자동으로 모여요.';
    return Scaffold(
      appBar: AppBar(title: Text(saved ? '내 단어장' : '오답노트')),
      body: ScreenBody(
        footer: words.isEmpty
            ? null
            : FilledButton(
                onPressed: () => _review(context, words),
                child: Text(saved ? '저장한 단어 복습하기' : '틀린 단어 다시 풀기'),
              ),
        children: [
          _MyHeading('단어 ${words.length}개'),
          if (words.isEmpty) Text(emptyText),
          for (final word in words)
            Padding(
              key: ValueKey(library.key(word)),
              padding: const EdgeInsets.only(bottom: 10),
              child: _MyPanel(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    word.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(word.meaning),
                      if (word.example.isNotEmpty)
                        Text(
                          '예문 · ${word.example}',
                          style: const TextStyle(color: _muted),
                        ),
                    ],
                  ),
                  trailing: saved
                      ? _SaveWordButton(library: library, word: word)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingLink extends StatelessWidget {
  const _SettingLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? detail;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    visualDensity: VisualDensity.compact,
    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
    leading: switch (icon) {
      Icons.assignment_outlined => const _ReviewGlyph(
        Icons.assignment_rounded,
        _tabSelectedColor,
        _warm,
      ),
      Icons.favorite_rounded => const _ReviewGlyph(
        Icons.favorite_rounded,
        green,
        mint,
      ),
      Icons.notifications_none_rounded => const _FrameIcon(
        _FrameSymbol.bell,
        color: _tabUnselectedColor,
      ),
      Icons.person_outline_rounded => const _FrameIcon(
        _FrameSymbol.person,
        color: _tabUnselectedColor,
      ),
      _ => Icon(icon, size: 24, color: _tabUnselectedColor),
    },
    title: Text(label, style: _pretendardText(17, weight: 820)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (detail != null)
          Text(
            detail!,
            style: TextStyle(
              color:
                  icon == Icons.assignment_outlined ||
                      icon == Icons.favorite_rounded
                  ? _tabSelectedColor
                  : _muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        const Icon(Icons.chevron_right_rounded, size: 20),
      ],
    ),
    onTap: onTap,
  );
}

class _ReviewGlyph extends StatelessWidget {
  const _ReviewGlyph(this.icon, this.color, this.background);

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    width: 35,
    height: 35,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, size: 23, color: color),
  );
}
