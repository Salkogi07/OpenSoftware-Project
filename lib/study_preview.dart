part of 'frontend_screens.dart';

const _greetingMascot = 'assets/images/chick_greeting.png';
const _readingMascot = 'assets/images/chick_reading.png';
const _celebratingMascot = 'assets/images/chick_celebrate.png';

const _officialTopic = '공식 석상에서 자주 쓰는 단어';
const _formalTopic = '현재는 상대적으로 드문 격식어';
const _confusingTopic = '뜻을 혼동하기 쉬운 표현';

const _studyTopics = [
  (_officialTopic, '공식적인\n자리에서 쓰는 말', Icons.work_rounded),
  (_confusingTopic, '원래 알던 단어에서\n뻗어 나온 말', Icons.eco_rounded),
  (_formalTopic, '요즘 잘\n안 쓰는 말', Icons.chat_bubble_rounded),
];

const _studyCardRadius = BorderRadius.all(Radius.circular(12));
const _studyMuted = Color(0xff6d7a88);

class _StudyTopicTile extends StatelessWidget {
  const _StudyTopicTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSprout = icon == Icons.eco_rounded;
    final isChat = icon == Icons.chat_bubble_rounded;
    final ink = isSprout ? const Color(0xff58ad65) : const Color(0xffdc851f);
    final radius = _studyCardRadius;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: Color(0xffcde2d2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 44,
                decoration: BoxDecoration(
                  color: isSprout
                      ? const Color(0xffe8f4e9)
                      : const Color(0xfffbeedf),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: isSprout
                    ? CustomPaint(
                        size: const Size.square(25),
                        painter: _SproutIcon(ink),
                      )
                    : isChat
                    ? _FrameIcon(_FrameSymbol.chat, color: ink)
                    : _FrameIcon(_FrameSymbol.briefcase, color: ink),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: _pretendardText(
                  11.5,
                  weight: 800,
                ).copyWith(height: 1.26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SproutIcon extends CustomPainter {
  const _SproutIcon(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()..color = color;
    final leaves = Path()
      ..moveTo(12, 12)
      ..cubicTo(5, 13, 1, 9, 1, 4)
      ..cubicTo(7, 2, 12, 6, 12, 12)
      ..cubicTo(12, 6, 17, 2, 23, 4)
      ..cubicTo(23, 9, 19, 13, 12, 12)
      ..close();
    canvas.drawPath(leaves, paint);
    paint
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(12, 11), const Offset(12, 21), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SproutIcon oldDelegate) => oldDelegate.color != color;
}

Widget _studyProgress(
  double value, {
  Color color = green,
  Color trackColor = mint,
}) => LinearProgressIndicator(
  value: value.clamp(0.0, 1.0).toDouble(),
  minHeight: 9,
  stopIndicatorRadius: 0,
  trackGap: 0,
  borderRadius: BorderRadius.circular(9),
  color: color,
  backgroundColor: trackColor,
);

class _StudyBanner extends StatelessWidget {
  const _StudyBanner({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: _studyCardRadius,
    child: Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xffeaf4eb))),
        const Positioned(
          left: -25,
          bottom: -23,
          child: _BannerHill(width: 100, height: 51),
        ),
        const Positioned(
          right: -22,
          bottom: -19,
          child: _BannerHill(width: 94, height: 49),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 147),
          padding: const EdgeInsets.fromLTRB(9, 9, 11, 9),
          child: Row(
            children: [
              Image.asset(
                _readingMascot,
                width: 108,
                height: 117,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _pretendardText(
                        25,
                        weight: 850,
                      ).copyWith(height: 1.28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: _pretendardText(
                        13,
                        weight: 650,
                        color: _studyMuted,
                      ),
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

class _BannerHill extends StatelessWidget {
  const _BannerHill({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(painter: _BannerHillPainter()),
  );
}

class _BannerHillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xffdff0e2);
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width * .64, size.height), paint);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .44,
        size.height * .21,
        size.width * .56,
        size.height * .79,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BannerHillPainter oldDelegate) => false;
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.mascot,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.minHeight,
    required this.cornerRadius,
    this.warm = false,
  });

  final String mascot;
  final String tag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool warm;
  final double minHeight;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final ink = warm ? _tabSelectedColor : green;
    final badge = warm ? const Color(0xfff8e4ce) : const Color(0xffdeefdf);
    return Material(
      color: warm ? const Color(0xfffcf3e8) : const Color(0xffeff7f0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: warm
            ? const BorderSide(color: Color(0xfffaead7))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.fromLTRB(15, 4, 13, 4),
          child: Row(
            children: [
              Image.asset(
                mascot,
                width: 86,
                height: minHeight - 10,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: badge,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          tag,
                          style: _pretendardText(
                            11,
                            weight: 750,
                            color: warm ? _rust : green,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: _pretendardText(
                        17.5,
                        weight: 850,
                      ).copyWith(height: 1.16),
                    ),
                    Text(
                      subtitle,
                      style: _pretendardText(
                        12,
                        weight: 650,
                        color: _studyMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 11,
                backgroundColor: warm ? const Color(0xffffad40) : badge,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: warm ? Colors.white : ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyTab extends StatelessWidget {
  const _MyTab({required this.library});

  final _StudyLibrary library;

  @override
  Widget build(BuildContext context) {
    _LibraryScope.watch(context);
    if (!library.preview || library.previewSignedIn) return const _MyPage();
    return Scaffold(
      appBar: _tabAppBar(context, '에르'),
      body: ScreenBody(
        children: [
          SizedBox(height: _phoneSpacing(context, 74)),
          Center(
            child: CircleAvatar(
              radius: 68,
              backgroundColor: mint,
              child: Image.asset(_homeMascotAsset, width: 122, height: 122),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '로그인이 필요해요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text(
            '로그인하거나 회원가입하면\n학습 기록을 저장하고 다시 볼 수 있어요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => library.setPreviewSignedIn(true),
            child: const Text('로그인'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => library.setPreviewSignedIn(true),
            child: const Text('회원가입'),
          ),
        ],
      ),
    );
  }
}

typedef _SampleWord = ({
  String name,
  String meaning,
  String sentence,
  String usage,
  List<String> distractors,
});

const _sampleWords = <String, List<_SampleWord>>{
  _officialTopic: [
    (
      name: '개회',
      meaning: '모임이나 회의를 시작함.',
      sentence: '참석자들이 자리에 앉자 의장이 회의의 시작을 알리며 {빈칸}를 선언했다.',
      usage: '회의, 총회, 대회가 시작될 때 써요.',
      distractors: ['폐회', '의결', '연기'],
    ),
    (
      name: '상정',
      meaning: '안건을 회의에 올림.',
      sentence: '위원회는 새 예산안을 회의에 {빈칸}했다.',
      usage: '아직 결정하지 않은 안건을 논의 대상으로 올릴 때 써요.',
      distractors: ['가결', '반려', '공표'],
    ),
    (
      name: '표결',
      meaning: '투표로 안건에 대한 의견을 결정함.',
      sentence: '의장이 안건의 찬반을 투표로 정하자며 {빈칸}을 요청했다.',
      usage: '찬성과 반대를 표로 확인해 결정할 때 써요.',
      distractors: ['질의', '보고', '축사'],
    ),
    (
      name: '가결',
      meaning: '회의에서 안건이 통과됨.',
      sentence: '찬성표가 과반을 넘어 안건이 {빈칸}되었다.',
      usage: '필요한 찬성표를 얻어 안건이 통과될 때 써요.',
      distractors: ['부결', '보류', '철회'],
    ),
    (
      name: '폐회',
      meaning: '모임이나 회의를 마침.',
      sentence: '모든 안건을 처리한 뒤 의장이 {빈칸}를 선언했다.',
      usage: '회의나 모임의 공식 종료를 알릴 때 써요.',
      distractors: ['개회', '속개', '휴회'],
    ),
  ],
  _formalTopic: [
    (
      name: '진언',
      meaning: '윗사람에게 의견을 아룀.',
      sentence: '신하는 왕에게 백성의 어려움을 {빈칸}했다.',
      usage: '윗사람에게 조언이나 의견을 정중하게 전할 때 써요.',
      distractors: ['묵인', '하명', '회피'],
    ),
    (
      name: '귀추',
      meaning: '일이 되어 가는 끝이나 결말.',
      sentence: '협상 결과가 어떻게 될지 시민들이 그 {빈칸}에 주목했다.',
      usage: '아직 결말이 나지 않은 일의 결과에 관심을 나타낼 때 써요.',
      distractors: ['경위', '계기', '전제'],
    ),
    (
      name: '불식',
      meaning: '의심이나 걱정 따위를 떨쳐 없앰.',
      sentence: '연구진은 실험 자료를 공개해 안전성에 대한 의혹을 {빈칸}했다.',
      usage: '의심이나 불안을 해소했다고 표현할 때 써요.',
      distractors: ['조장', '방치', '은폐'],
    ),
    (
      name: '도외시',
      meaning: '상관없는 일로 여겨 무시함.',
      sentence: '위원회는 주민 의견을 하나도 검토하지 않고 {빈칸}한 채 계획을 확정했다.',
      usage: '고려해야 할 대상을 아예 무시했음을 지적할 때 써요.',
      distractors: ['반영', '수렴', '존중'],
    ),
    (
      name: '고사',
      meaning: '권유나 제안을 공손하게 사양함.',
      sentence: '그는 추천에 감사한다며 위원장 제안을 정중히 {빈칸}했다.',
      usage: '권유받은 자리나 제안을 예의를 갖춰 거절할 때 써요.',
      distractors: ['수락', '촉구', '권유'],
    ),
  ],
  _confusingTopic: [
    (
      name: '결재',
      meaning: '문서나 안건을 검토해 승인함.',
      sentence: '기획안은 팀장의 {빈칸}를 받은 뒤 발송한다.',
      usage: '상급자의 승인에는 결재, 물건값 지불에는 결제를 써요.',
      distractors: ['결제', '결렬', '결석'],
    ),
    (
      name: '결제',
      meaning: '대금을 지불함.',
      sentence: '손님은 점심값을 카드로 {빈칸}했다.',
      usage: '카드나 현금으로 값을 낼 때 써요.',
      distractors: ['결재', '결성', '결의'],
    ),
    (
      name: '지양',
      meaning: '바람직하지 않은 일을 피함.',
      sentence: '회의에서는 근거 없는 비난을 {빈칸}하고 사실만 이야기하자.',
      usage: '피할 행동에는 지양, 추구할 목표에는 지향을 써요.',
      distractors: ['지향', '조장', '장려'],
    ),
    (
      name: '지향',
      meaning: '어떤 목표를 향해 나아감.',
      sentence: '우리 팀은 누구나 이용할 수 있는 서비스를 {빈칸}한다.',
      usage: '향하고자 하는 방향이나 목표를 말할 때 써요.',
      distractors: ['지양', '배제', '포기'],
    ),
    (
      name: '금일',
      meaning: '오늘.',
      sentence: '안내문을 쓴 바로 오늘, 즉 {빈칸} 오후 5시에 접수를 마감합니다.',
      usage: '공식적인 안내에서 오늘을 가리킬 때 써요.',
      distractors: ['작일', '익일', '명일'],
    ),
  ],
};

final _previewBank = Future.value([
  for (final topic in _sampleWords.keys) ..._previewQuestions(topic, '중'),
]);

List<Word> _previewQuestions(String topic, String difficulty) {
  final samples = _sampleWords[topic]!;
  return [
    for (var index = 0; index < samples.length; index++)
      _previewQuestion(samples[index], topic, difficulty, index % 4),
  ];
}

Word _previewQuestion(
  _SampleWord sample,
  String topic,
  String difficulty,
  int answerIndex,
) {
  final choices = [...sample.distractors]..insert(answerIndex, sample.name);
  return Word(
    topic: topic,
    difficulty: difficulty,
    name: sample.name,
    meaning: sample.meaning,
    prompt: switch (difficulty) {
      '하' => '${sample.sentence}\n힌트 · ${sample.meaning}',
      '중' => sample.sentence,
      _ => '다음 뜻에 맞는 표현은?\n${sample.meaning}',
    },
    choices: choices,
    answerIndex: answerIndex,
    example: sample.sentence.replaceFirst('{빈칸}', sample.name),
    explanation: sample.usage,
    usesBlank: difficulty != '상',
    hint: difficulty == '하' ? sample.meaning : null,
    distractor: '',
    alternative: '',
  );
}
