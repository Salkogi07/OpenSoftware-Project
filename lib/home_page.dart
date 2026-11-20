part of 'frontend_screens.dart';

const _homeInk = navy;
const _homeGreen = Color(0xff307c34);
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

TextStyle _homeText(
  double size, {
  double weight = 400,
  Color color = _homeInk,
}) => _pretendardText(size, weight: weight, color: color);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onContinue, this.onRecords});

  final VoidCallback onContinue;
  final VoidCallback? onRecords;
  static const goal = 10;

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context);
    final completed = library?.summary.todayAnswers ?? 0;
    final streak = library?.streak ?? 0;
    final level = levelFor(library?.summary.xp ?? 0).level;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _tabAppBar(context, '하루어휘 - 홈', showDivider: false),
      body: ScreenBody(
        contentPadding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
        footerPadding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
        footer: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(59),
            backgroundColor: const Color(0xff1d3446),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            textStyle: _homeText(20, weight: 800),
          ),
          onPressed: onContinue,
          icon: const Icon(Icons.play_arrow_rounded, size: 30),
          label: const Text('이어 학습하기'),
        ),
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘도',
                            style: text.headlineMedium?.copyWith(
                              fontSize: 34,
                              height: 1.12,
                            ),
                          ),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  mint,
                                  mint,
                                ],
                                stops: [0, .75, .76, 1],
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '한 단어씩!',
                              style: text.headlineMedium?.copyWith(
                                fontSize: 34,
                                height: 1.12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          _HomeBadge(
                            icon: const Icon(
                              Icons.local_fire_department_rounded,
                              color: _tabSelectedColor,
                              size: 17,
                            ),
                            label: '$streak일 연속',
                            background: const Color(0xffffe3cd),
                            foreground: navy,
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: const Color(0xff75af77),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _StudyBars(color: Color(0xff78ba7c)),
                              const SizedBox(width: 5),
                              Text(
                                'Lv.$level',
                                style: _homeText(
                                  16,
                                  weight: 850,
                                  color: _homeGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 174),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const FractionallySizedBox(
                            widthFactor: .87,
                            heightFactor: .84,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xffe3f6e9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 4,
                            left: 35,
                            right: 30,
                            height: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xffcaedd6),
                                borderRadius: BorderRadius.all(
                                  Radius.elliptical(70, 10),
                                ),
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: .91,
                            heightFactor: 1,
                            child: Image.asset(
                              _greetingMascot,
                              fit: BoxFit.contain,
                              semanticLabel: '하루어휘 병아리',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('오늘의 단어', style: _homeText(18, weight: 850)),
          const SizedBox(height: 9),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(69),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xffddd8d0)),
            ),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('사뿐사뿐'),
                content: Text('가볍게 발을 내디디는 모양.\n\n고양이가 복도를 사뿐사뿐 걸었다.'),
              ),
            ),
            child: Row(
              children: [
                if (MediaQuery.sizeOf(context).width >= 220) ...[
                  const SizedBox(
                    width: 46,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xffe6f5e9),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: Size(26, 26),
                          painter: _HomeWordIcon(speaker: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('사뿐사뿐', style: _homeText(20, weight: 850)),
                      Text(
                        '가볍게 발을 내디디는 모양',
                        style: _pretendardText(13, weight: 500, color: _muted),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.sizeOf(context).width >= 220)
                  const CustomPaint(
                    size: Size(25, 25),
                    painter: _HomeWordIcon(speaker: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DailyProgress(
            completed: completed,
            goal: library?.dailyGoal ?? goal,
          ),
          if (onRecords != null && library?.preview != true)
            TextButton(onPressed: onRecords, child: const Text('나의 기록')),
        ],
      ),
    );
  }
}

class _StudyBars extends StatelessWidget {
  const _StudyBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(8, color),
        const SizedBox(width: 2),
        _bar(12, color),
        const SizedBox(width: 2),
        _bar(16, color),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: icon),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: _homeText(14, weight: 850, color: foreground),
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
    constraints: const BoxConstraints(minHeight: 140),
    padding: const EdgeInsets.fromLTRB(18, 19, 18, 19),
    decoration: BoxDecoration(
      color: const Color(0xffeaf8ef),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('오늘의 목표', style: _homeText(22, weight: 850))),
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
              style: _homeText(21, weight: 850),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: math.min(1, completed / goal),
          minHeight: 15,
          stopIndicatorRadius: 0,
          trackGap: 0,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: _homeGreen,
          backgroundColor: const Color(0xffccefd5),
          semanticsLabel: '오늘의 학습 진행률',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(
              Icons.track_changes_rounded,
              size: 25,
              color: _tabSelectedColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                completed >= goal
                    ? '오늘의 목표를 달성했어요!'
                    : '${goal - completed}문제만 더 풀면 목표 달성!',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HomeWordIcon extends CustomPainter {
  const _HomeWordIcon({required this.speaker});

  final bool speaker;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = speaker ? const Color(0xff717477) : _homeGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (speaker) {
      canvas.drawPath(
        Path()
          ..moveTo(10, 4)
          ..lineTo(6, 8)
          ..lineTo(3, 8)
          ..quadraticBezierTo(2, 8, 2, 9)
          ..lineTo(2, 15)
          ..quadraticBezierTo(2, 16, 3, 16)
          ..lineTo(6, 16)
          ..lineTo(10, 20)
          ..quadraticBezierTo(11.5, 21, 11.5, 19)
          ..lineTo(11.5, 5)
          ..quadraticBezierTo(11.5, 3, 10, 4),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(15, 8)
          ..quadraticBezierTo(19, 12, 15, 16),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(18, 5.5)
          ..quadraticBezierTo(24, 12, 18, 18.5),
        paint,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(12, 5.5)
          ..quadraticBezierTo(7, 1.8, 1.5, 5)
          ..lineTo(1.5, 20)
          ..quadraticBezierTo(7, 17, 12, 20)
          ..quadraticBezierTo(17, 17, 22.5, 20)
          ..lineTo(22.5, 5)
          ..quadraticBezierTo(17, 1.8, 12, 5.5)
          ..close(),
        paint,
      );
      canvas.drawLine(const Offset(12, 5.5), const Offset(12, 20), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HomeWordIcon oldDelegate) =>
      oldDelegate.speaker != speaker;
}
