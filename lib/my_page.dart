part of 'frontend_screens.dart';

const _warm = Color(0xfffff3e5);
const _rust = Color(0xff9b4417);
const _muted = Color(0xff516477);
const _line = Color(0xffdcebe5);

class _StudyLibrary extends ChangeNotifier {
  _StudyLibrary({required this.preview, this.onSignOut}) {
    if (preview) {
      streak = 7;
      summary = const LearningSummary(
        totalAnswers: 130,
        correctAnswers: 107,
        learnedWords: 120,
        todayAnswers: 7,
      );
    }
  }

  final bool preview;
  final Future<void> Function()? onSignOut;
  bool previewSignedIn = false;

  /// 로그인한 이메일 (미리보기·로그아웃 상태면 null)
  String? get email => preview ? null : learningRepository.email;

  Future<void> signOut() async {
    if (preview) {
      setPreviewSignedIn(false);
      return;
    }
    await onSignOut?.call();
  }

  int dailyGoal = HomeScreen.goal;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
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
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    reminderTime = time;
    notifyListeners();
  }

  final saved = <(String, String), Word>{};
  final mistakes = <(String, String), Word>{};
  String nickname = '어휘새싹';

  // 수파베이스에서 불러온 학습 기록 (로그인했을 때만 채워짐)
  int streak = 0;
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
      final (name, newStreak, newSummary, wrongRows, attempts) = await (
        learningRepository.fetchNickname(),
        learningRepository.fetchStreak(),
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
      streak = newStreak;
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
            xp: library.summary.xp,
            onEdit: () => _editNickname(context, library),
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
            detail: library.reminderTime.format(context),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: library.reminderTime,
              );
              if (context.mounted && time != null) {
                library.setReminderTime(time);
              }
            },
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
                showLicensePage(context: context, applicationName: '하루어휘'),
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
    required this.xp,
    required this.onEdit,
  });

  final String nickname;
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
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xfffbf5e7),
              child: Image.asset(
                _homeMascotAsset,
                width: 72,
                height: 78,
                fit: BoxFit.contain,
              ),
            ),
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
                          '프로필 편집 ›',
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
