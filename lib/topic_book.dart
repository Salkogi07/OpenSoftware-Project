part of 'frontend_screens.dart';

// 학습 주제 미리보기: 주제에 나오는 단어를 교과서처럼 가나다순으로 미리 읽어 보기

/// 교과서 한 항목: 단어와 함께 보면 좋은 말
typedef _BookEntry = ({Word word, List<Word> related});

const _initials = [
  'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', //
  'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
];
const _doubleInitials = {'ㄲ': 'ㄱ', 'ㄸ': 'ㄷ', 'ㅃ': 'ㅂ', 'ㅆ': 'ㅅ', 'ㅉ': 'ㅈ'};

/// 단어 첫 글자의 초성 (된소리는 예사소리 장에 넣음). 한글이 아니면 '기타'
String _chapterOf(String word) {
  final code = word.isEmpty ? 0 : word.codeUnitAt(0) - 0xac00;
  if (code < 0 || code > 11171) return '기타';
  final initial = _initials[code ~/ 588];
  return _doubleInitials[initial] ?? initial;
}

/// [bank]에서 [topic] 단어를 가나다순으로 모으고, 같은 단어 문제의 보기에 나온
/// 다른 단어를 "함께 보면 좋은 말"로 붙임
List<_BookEntry> _buildTopicBook(List<Word> bank, String topic) {
  final inTopic = bank.where((word) => word.topic == topic).toList();
  final byName = <String, Word>{};
  for (final word in inTopic) {
    byName.putIfAbsent(word.name, () => word);
  }
  final related = <String, Set<String>>{};
  for (final question in inTopic) {
    final choices = question.choices ?? const [];
    // 보기가 단어인 문제(중·상)만: 뜻을 고르는 문제(하)의 보기는 뜻풀이라 제외
    if (!choices.any(byName.containsKey)) continue;
    related
        .putIfAbsent(question.name, () => {})
        .addAll(
          choices.where((c) => c != question.name && byName.containsKey(c)),
        );
  }
  final names = byName.keys.toList()..sort();
  // 표제어와 글자가 많이 겹치는 말부터 3개까지. 끝 글자가 같으면(가결 ↔ 부결) 더 앞에
  int shared(String a, String b) =>
      a.split('').toSet().intersection(b.split('').toSet()).length * 2 +
      (a.isNotEmpty && b.isNotEmpty && a[a.length - 1] == b[b.length - 1]
          ? 1
          : 0);
  return [
    for (final name in names)
      (
        word: byName[name]!,
        related:
            ((related[name] ?? {}).toList()
                  ..sort((a, b) => shared(name, b).compareTo(shared(name, a))))
                .take(3)
                .map((other) => byName[other]!)
                .toList(),
      ),
  ];
}

class _TopicBookScreen extends StatefulWidget {
  const _TopicBookScreen({required this.topic});

  final String topic;

  @override
  State<_TopicBookScreen> createState() => _TopicBookScreenState();
}

class _TopicBookScreenState extends State<_TopicBookScreen> {
  late Future<List<Word>> bank = loadQuestionBank();

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context);
    final preview = library?.preview ?? false;
    final icon = [
      for (final (name, _, icon) in _studyTopics)
        if (name == widget.topic) icon,
    ].firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('학습 주제 미리보기')),
      body: FutureBuilder<List<Word>>(
        future: preview ? _previewBank : bank,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ScreenBody(
              children: [
                const Text('단어를 불러오지 못했어요.'),
                OutlinedButton(
                  onPressed: () => setState(() => bank = loadQuestionBank()),
                  child: const Text('다시 불러오기'),
                ),
              ],
            );
          }
          final words = snapshot.data;
          if (words == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = _buildTopicBook(words, widget.topic);
          return ScreenBody(
            footerPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            footer: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TopicScreen(initialTopic: widget.topic),
                ),
              ),
              child: const Text('이 주제로 문제 풀기'),
            ),
            children: [
              _BookCover(
                icon: icon ?? Icons.menu_book_rounded,
                topic: widget.topic,
                description: _topicDescriptions[widget.topic] ?? '',
                count: entries.length,
              ),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text('이 주제에 아직 단어가 없어요.'),
                ),
              for (final (index, entry) in entries.indexed) ...[
                if (index == 0 ||
                    _chapterOf(entry.word.name) !=
                        _chapterOf(entries[index - 1].word.name))
                  _ChapterHeading(_chapterOf(entry.word.name)),
                _BookEntryCard(number: index + 1, entry: entry),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.icon,
    required this.topic,
    required this.description,
    required this.count,
  });

  final IconData icon;
  final String topic;
  final String description;
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(color: mint, borderRadius: cardRadius),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: green, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic, style: _pretendardText(19, weight: 900)),
              const SizedBox(height: 2),
              Text(
                description,
                style: _pretendardText(13.5, weight: 600, color: _muted),
              ),
              const SizedBox(height: 6),
              Text(
                '단어 $count개 · 가나다순',
                style: _pretendardText(13, weight: 750, color: green),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ㄱ, ㄴ, ㄷ… 장 제목
class _ChapterHeading extends StatelessWidget {
  const _ChapterHeading(this.initial);

  final String initial;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: navy, shape: BoxShape.circle),
          child: Text(
            initial,
            style: _pretendardText(17, weight: 900, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _line, thickness: 1)),
      ],
    ),
  );
}

class _BookEntryCard extends StatelessWidget {
  const _BookEntryCard({required this.number, required this.entry});

  final int number;
  final _BookEntry entry;

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context);
    final word = entry.word;
    // 미리보기 예시 단어에만 있는 예문·쓰임 (문제 은행의 해설은 뜻을 되풀이하므로 뺌)
    final usage = word.explanation;
    final showUsage =
        usage != null && usage.isNotEmpty && !usage.contains('뜻합니다');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          borderRadius: cardRadius,
          border: Border.all(color: _line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$number  ',
                          style: _pretendardText(13, weight: 800, color: green),
                        ),
                        TextSpan(
                          text: word.name,
                          style: _pretendardText(20, weight: 900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(word.meaning, style: _pretendardText(15, weight: 600)),
                  if (word.example.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _BookNote(label: '예문', body: word.example),
                  ],
                  if (showUsage) ...[
                    const SizedBox(height: 6),
                    _BookNote(label: '쓰임', body: usage),
                  ],
                  if (entry.related.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '함께 보면 좋은 말',
                      style: _pretendardText(12.5, weight: 800, color: _rust),
                    ),
                    const SizedBox(height: 4),
                    for (final other in entry.related)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: other.name,
                                style: _pretendardText(13.5, weight: 800),
                              ),
                              TextSpan(
                                text: '  ${other.meaning}',
                                style: _pretendardText(
                                  13,
                                  weight: 550,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (library != null) _SaveWordButton(library: library, word: word),
          ],
        ),
      ),
    );
  }
}

class _BookNote extends StatelessWidget {
  const _BookNote({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label  ',
          style: _pretendardText(12.5, weight: 800, color: green),
        ),
        TextSpan(
          text: body,
          style: _pretendardText(13.5, weight: 550, color: navy),
        ),
      ],
    ),
  );
}
