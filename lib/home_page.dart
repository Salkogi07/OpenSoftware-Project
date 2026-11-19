part of 'frontend_screens.dart';

const _homeBackground = Color(0xfffcfbfa);
const _homeInk = Color(0xff233042);
const _homeGreen = Color(0xff3c6954);
const _homeMint = Color(0xffdeefe5);
const _homeMuted = Color(0xff606b68);
const _homeBorder = Color(0xffe9ebee);
const _homeMascotAsset = 'assets/images/chick_mascot_transparent.png';

TextStyle _pretendardText(
  double size, {
  double weight = 400,
  Color color = navy,
}) => TextStyle(
  fontFamily: 'Pretendard',
  fontSize: size,
  height: 1.35,
  color: color,
  fontVariations: [FontVariation('wght', weight)],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onContinue, this.onRecords});

  final VoidCallback onContinue;
  final VoidCallback? onRecords;

  @override
  Widget build(BuildContext context) {
    const completed = 7;
    const goal = 10;

    return Scaffold(
      backgroundColor: _homeBackground,
      appBar: _tabAppBar(
        '하루어휘 - 홈',
        actions: [
          IconButton(
            tooltip: '알림',
            onPressed: () => _showNotifications(context),
            icon: const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded, size: 31),
                Positioned(
                  top: 0,
                  right: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xffee8b47),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: 7),
                  ),
                ),
              ],
            ),
            color: _homeInk,
          ),
        ],
      ),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(18, 27, 18, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: _HomeGreeting(),
          ),
          const SizedBox(height: 19),
          const Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _HomeBadge(
                icon: Text('🔥', style: TextStyle(fontSize: 19, height: 1)),
                label: '7일 연속',
                background: Color(0xfffae6c8),
                foreground: Color(0xff514b3f),
              ),
              _HomeBadge(
                icon: _StudyBars(
                  color: Color(0xff365e70),
                  lastColor: Color(0xff76a99a),
                ),
                label: 'Lv.4',
                background: _homeMint,
                foreground: _homeGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _DailyProgress(completed: completed, goal: goal),
          const SizedBox(height: 20),
          const _HomeMascotCard(remaining: goal - completed),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              backgroundColor: _homeInk,
              shape: buttonShape,
              textStyle: _homeText(17, weight: 750),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 26),
            label: const Text('이어 학습하기'),
            onPressed: onContinue,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 43),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              foregroundColor: _homeInk,
              side: const BorderSide(color: Color(0xff818987)),
              shape: buttonShape,
              textStyle: _homeText(17, weight: 750),
            ),
            icon: const _StudyBars(color: _homeInk),
            label: const Text('나의 기록'),
            onPressed: onRecords ?? () => _showRecords(context),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => AlertDialog(
      title: const Text('알림'),
      content: const Text('표시할 알림이 없어요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    ),
  );

  void _showRecords(BuildContext context) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => AlertDialog(
      title: const Text('나의 기록'),
      content: const Text('연속 학습 7일 · Lv.4\n오늘은 10개 중 7개를 공부했어요.\n\n예시 기록입니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

TextStyle _homeText(
  double size, {
  double weight = 400,
  Color color = _homeInk,
}) => _pretendardText(size, weight: weight, color: color);

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '오늘도 '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _homeMint,
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(40, 8),
                          ),
                        ),
                        child: SizedBox(height: 9),
                      ),
                    ),
                    Text('한 단어씩,', style: _homeText(25, weight: 800)),
                  ],
                ),
              ),
              const TextSpan(text: ' 차근차근.'),
            ],
          ),
          style: _homeText(25, weight: 800),
        ),
        const Positioned(top: -9, right: -12, child: _HomeRays()),
      ],
    ),
  );
}

class _HomeRays extends StatelessWidget {
  const _HomeRays();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(size: Size(18, 18), painter: _HomeRaysPainter());
}

class _HomeRaysPainter extends CustomPainter {
  const _HomeRaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xfff3b550)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(2, 8), const Offset(4, 2), paint);
    canvas.drawLine(const Offset(7, 10), const Offset(12, 5), paint);
    canvas.drawLine(const Offset(9, 15), const Offset(16, 13), paint);
  }

  @override
  bool shouldRepaint(_HomeRaysPainter oldDelegate) => false;
}

class _StudyBars extends StatelessWidget {
  const _StudyBars({required this.color, this.lastColor});

  final Color color;
  final Color? lastColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(9, color),
        const SizedBox(width: 2),
        _bar(15, color),
        const SizedBox(width: 2),
        _bar(lastColor == null ? 7 : 15, lastColor ?? color),
      ],
    ),
  );

  Widget _bar(double height, Color fill) => Container(
    width: 3.5,
    height: height,
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _HomeBadge extends StatelessWidget {
  const _HomeBadge({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final Widget icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: icon),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: _homeText(15, weight: 750, color: foreground),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DailyProgress extends StatelessWidget {
  const _DailyProgress({required this.completed, required this.goal});

  final int completed;
  final int goal;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: _homeBorder),
      borderRadius: const BorderRadius.all(Radius.circular(15)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('오늘의 학습', style: _homeText(18, weight: 750))),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$completed',
                    style: const TextStyle(color: _homeGreen),
                  ),
                  TextSpan(text: ' / $goal'),
                ],
              ),
              style: _homeText(17, weight: 650),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: completed / goal,
          minHeight: 12,
          stopIndicatorRadius: 0,
          trackGap: 0,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: _homeGreen,
          backgroundColor: Color(0xffe5f2ea),
          semanticsLabel: '오늘의 학습 진행률',
        ),
      ],
    ),
  );
}

class _HomeMascotCard extends StatelessWidget {
  const _HomeMascotCard({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xfff1f7f2), Color(0xffe9f5ee)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(right: -32, bottom: -39, child: _MascotHill(74)),
          const Positioned(right: 5, bottom: -63, child: _MascotHill(100)),
          const Positioned(right: 63, bottom: -56, child: _MascotHill(72)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: double.infinity,
                    height: 136,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        const Positioned(
                          bottom: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xffd5e7de),
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(42, 6),
                              ),
                            ),
                            child: SizedBox(width: 84, height: 12),
                          ),
                        ),
                        Positioned.fill(
                          child: Image.asset(
                            _homeMascotAsset,
                            fit: BoxFit.contain,
                            semanticLabel: '하루어휘 병아리',
                          ),
                        ),
                        const Positioned(top: 4, right: 4, child: _HomeRays()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 1,
                  height: 64,
                  child: ColoredBox(color: Color(0xffd9e8df)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘도 한 단어씩!',
                        style: _homeText(23, weight: 800, color: _homeGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '목표까지 $remaining문제 남았어요.',
                        style: _homeText(15, color: _homeMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MascotHill extends StatelessWidget {
  const _MascotHill(this.diameter);

  final double diameter;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xffd8ebdf),
      shape: BoxShape.circle,
    ),
    child: SizedBox.square(dimension: diameter),
  );
}
