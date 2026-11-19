part of 'frontend_screens.dart';

const _softMint = Color(0xfff0faf6);
const _warm = Color(0xfffff3e5);
const _rust = Color(0xff9b4417);
const _muted = Color(0xff516477);
const _line = Color(0xffdcebe5);

class _StudyLibrary extends ChangeNotifier {
  final saved = <(String, String), Word>{};
  final mistakes = <(String, String), Word>{};
  String nickname = '어휘새싹';

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

class _MyPage extends StatelessWidget {
  const _MyPage();

  Future<void> _editProfile(BuildContext context, _StudyLibrary library) async {
    var name = library.nickname;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 관리'),
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
      appBar: _tabAppBar('마이페이지 탭'),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _LevelCard(nickname: library.nickname),
          const SizedBox(height: 22),
          const _MyHeading('나의 학습 현황', trailing: '예시 기록'),
          const _TileRow(
            tiles: [
              _MyTile(
                icon: Icons.local_fire_department_rounded,
                label: '연속 학습',
                value: '7일',
                background: _warm,
                ink: _rust,
              ),
              _MyTile(
                icon: Icons.track_changes_rounded,
                label: '전체 정답률',
                value: '82%',
              ),
              _MyTile(
                icon: Icons.auto_stories_rounded,
                label: '총 학습 단어',
                value: '120개',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _MyHeading('나의 복습'),
          _ReviewCard(
            title: '오답노트',
            description: '틀린 단어를 다시 확인해요.',
            count: library.mistakes.length,
            saved: false,
            onOpen: () => openWords(false),
            onReview: library.mistakes.isEmpty
                ? null
                : () => _review(context, library.mistakes.values),
          ),
          const SizedBox(height: 10),
          _ReviewCard(
            title: '내 단어장',
            description: '하트로 저장한 단어를 복습해요.',
            count: library.saved.length,
            saved: true,
            onOpen: () => openWords(true),
            onReview: library.saved.isEmpty
                ? null
                : () => _review(context, library.saved.values),
          ),
          const SizedBox(height: 22),
          const _MyHeading('나의 배지'),
          const _TileRow(
            tiles: [
              _MyTile(
                icon: Icons.local_fire_department_rounded,
                label: '7일 연속 학습',
                background: _warm,
                ink: _rust,
              ),
              _MyTile(
                icon: Icons.workspace_premium_rounded,
                label: '정답률 80% 달성',
                background: Color(0xffeeedfa),
                ink: Color(0xff594493),
              ),
              _MyTile(icon: Icons.auto_stories_rounded, label: '학습 단어 100개 달성'),
            ],
          ),
          const SizedBox(height: 22),
          const _MyHeading('설정'),
          _MyPanel(
            child: Column(
              children: [
                _SettingLink(
                  icon: Icons.notifications_none_rounded,
                  label: '알림 설정',
                  onTap: () =>
                      _openSettings(context, '알림 설정', '학습 알림은 디자인 시안 항목입니다.'),
                ),
                const Divider(height: 1, color: _line),
                _SettingLink(
                  icon: Icons.person_outline_rounded,
                  label: '프로필 관리',
                  onTap: () => _editProfile(context, library),
                ),
                const Divider(height: 1, color: _line),
                _SettingLink(
                  icon: Icons.settings_outlined,
                  label: '앱 설정',
                  onTap: () =>
                      _openSettings(context, '앱 설정', '하루어휘 · 버전 0.1.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context, String title, String detail) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: ScreenBody(children: [Text(detail)]),
          ),
        ),
      );
}

void _review(BuildContext context, Iterable<Word> words) {
  final batch = words.toList(growable: false);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizScreen(words: batch, isReview: true),
    ),
  );
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
  const _MyPanel({required this.child, this.color = _softMint});

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
  const _LevelCard({required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) => _MyPanel(
    color: mint,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xfffaf4e9),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/chick_mascot.webp',
                fit: BoxFit.contain,
                semanticLabel: '하루어휘 병아리',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '나의 레벨',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(nickname, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 10,
                  runSpacing: 3,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xffffe3ba),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          'Lv.4',
                          style: TextStyle(
                            color: _rust,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '320 / 400 XP',
                      style: TextStyle(
                        color: green,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  value: .8,
                  minHeight: 8,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: green,
                  backgroundColor: Color(0xffbce6d6),
                  semanticsLabel: '경험치, 400 중 320',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TileRow extends StatelessWidget {
  const _TileRow({required this.tiles});

  final List<_MyTile> tiles;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < tiles.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: tiles[i]),
      ],
    ],
  );
}

class _MyTile extends StatelessWidget {
  const _MyTile({
    required this.icon,
    required this.label,
    this.value,
    this.background = _softMint,
    this.ink = green,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final badge = value == null;
    return _MyPanel(
      color: badge ? Colors.white : _softMint,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            children: [
              Container(
                width: badge ? 42 : 30,
                height: badge ? 42 : 30,
                decoration: BoxDecoration(
                  color: badge ? background : (ink == green ? mint : _warm),
                  shape: BoxShape.circle,
                  border: badge
                      ? Border.all(color: ink.withValues(alpha: .24), width: 2)
                      : null,
                ),
                child: Icon(icon, color: ink, size: badge ? 23 : 17),
              ),
              const SizedBox(height: 4),
              if (value case final number?)
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.description,
    required this.count,
    required this.saved,
    required this.onOpen,
    required this.onReview,
  });

  final String title;
  final String description;
  final int count;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final ink = saved ? green : _rust;
    return _MyPanel(
      child: Column(
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: saved ? mint : orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      saved ? Icons.favorite_rounded : Icons.fact_check_rounded,
                      color: ink,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count개',
                    style: TextStyle(color: ink, fontWeight: FontWeight.w800),
                  ),
                  Icon(Icons.chevron_right_rounded, color: ink),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onOpen,
                    child: const Text('단어 보기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: saved ? green : _rust,
                      disabledBackgroundColor: saved ? mint : _warm,
                      disabledForegroundColor: ink,
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                    onPressed: onReview,
                    child: Text(
                      saved ? '복습하기' : '다시 풀기',
                      textAlign: TextAlign.center,
                    ),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: green, size: 20),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: onTap,
  );
}
