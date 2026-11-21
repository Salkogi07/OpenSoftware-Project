part of 'frontend_screens.dart';

enum _FrameSymbol { bell, back, home, book, history, person, briefcase, chat }

class _FrameIcon extends StatelessWidget {
  const _FrameIcon(
    this.symbol, {
    this.active = false,
    this.size = 25,
    this.color,
  });

  final _FrameSymbol symbol;
  final bool active;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _FrameIconPainter(
      symbol,
      active,
      color ?? IconTheme.of(context).color ?? navy,
    ),
  );
}

class _FrameIconPainter extends CustomPainter {
  const _FrameIconPainter(this.symbol, this.active, this.color);

  final _FrameSymbol symbol;
  final bool active;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final ink = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = color;
    final detail = Paint()
      ..color = active ? Colors.white : color
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final edge = active ? fill : ink;

    switch (symbol) {
      case _FrameSymbol.bell:
        canvas.drawPath(
          Path()
            ..moveTo(4.8, 17)
            ..lineTo(7, 14.5)
            ..lineTo(7, 9)
            ..cubicTo(7, 2.5, 17, 2.5, 17, 9)
            ..lineTo(17, 14.5)
            ..lineTo(19.2, 17)
            ..close(),
          ink,
        );
        canvas.drawLine(const Offset(12, 2), const Offset(12, 4), ink);
        canvas.drawArc(
          const Rect.fromLTWH(9.6, 17.5, 4.8, 4.3),
          0,
          math.pi,
          false,
          ink,
        );
      case _FrameSymbol.back:
        canvas.drawPath(
          Path()
            ..moveTo(11, 6)
            ..lineTo(5, 12)
            ..lineTo(11, 18),
          ink,
        );
        canvas.drawLine(const Offset(5, 12), const Offset(21, 12), ink);
      case _FrameSymbol.home:
        canvas.drawPath(
          Path()
            ..moveTo(2.5, 11.4)
            ..lineTo(12, 3)
            ..lineTo(21.5, 11.4)
            ..lineTo(19.3, 11.4)
            ..lineTo(19.3, 21)
            ..lineTo(14, 21)
            ..lineTo(14, 15)
            ..lineTo(10, 15)
            ..lineTo(10, 21)
            ..lineTo(4.7, 21)
            ..lineTo(4.7, 11.4)
            ..close(),
          edge,
        );
      case _FrameSymbol.book:
        canvas.drawPath(
          Path()
            ..moveTo(12, 5.5)
            ..quadraticBezierTo(7.2, 2.1, 2.6, 5.1)
            ..lineTo(2.6, 20)
            ..quadraticBezierTo(7.6, 17.4, 12, 20.5)
            ..quadraticBezierTo(16.4, 17.4, 21.4, 20)
            ..lineTo(21.4, 5.1)
            ..quadraticBezierTo(16.6, 2.1, 12, 5.5)
            ..close(),
          edge,
        );
        canvas.drawLine(const Offset(12, 6), const Offset(12, 19), detail);
        for (final y in [8.0, 11.0, 14.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(14.5, y)
              ..quadraticBezierTo(16.7, y - 1, 19, y),
            detail,
          );
        }
      case _FrameSymbol.history:
        for (final (x, top) in [(4.0, 12.0), (10.0, 3.0), (16.0, 8.0)]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(x, top, x + 4, 21),
              const Radius.circular(2),
            ),
            fill,
          );
        }
      case _FrameSymbol.person:
        canvas.drawCircle(const Offset(12, 7), 4, edge);
        canvas.drawPath(
          Path()
            ..moveTo(3.8, 21)
            ..lineTo(3.8, 18.8)
            ..cubicTo(4, 12.4, 20, 12.4, 20.2, 18.8)
            ..lineTo(20.2, 21)
            ..close(),
          edge,
        );
      case _FrameSymbol.briefcase:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2, 7, 20, 14),
            const Radius.circular(3),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(8, 3, 8, 6),
            const Radius.circular(2),
          ),
          ink,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(10, 11, 4, 2),
            const Radius.circular(1),
          ),
          Paint()..color = Colors.white,
        );
      case _FrameSymbol.chat:
        canvas.drawOval(const Rect.fromLTWH(1.5, 2.7, 21, 16.5), fill);
        canvas.drawPath(
          Path()
            ..moveTo(6, 15)
            ..lineTo(4, 22)
            ..lineTo(12, 18)
            ..close(),
          fill,
        );
        final white = Paint()..color = Colors.white;
        for (final x in [7.5, 12.0, 16.5]) {
          canvas.drawCircle(Offset(x, 11), 1.25, white);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FrameIconPainter oldDelegate) =>
      oldDelegate.symbol != symbol ||
      oldDelegate.active != active ||
      oldDelegate.color != color;
}
