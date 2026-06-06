import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/sankofa_game_theme.dart';

class ParchmentBackground extends StatelessWidget {
  final Widget child;

  const ParchmentBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: SankofaGameTheme.screenGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Image.asset(
              SankofaGameTheme.gameBackgroundTexture,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const IgnorePointer(
            child: CustomPaint(
              painter: _ParchmentPainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ParchmentPainter extends CustomPainter {
  const _ParchmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final radius = max(size.width, size.height) * 0.85;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.12),
          radius: 1.05,
          colors: [
            SankofaGameTheme.boardSurfaceAlt.withValues(alpha: 0.16),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.12),
          radius: 1.08,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.16),
          ],
          stops: const [0.62, 1.0],
        ).createShader(rect),
    );

    final edgePaint = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(18),
        const Radius.circular(28),
      ),
      edgePaint,
    );

    final innerEdgePaint = Paint()
      ..color = SankofaGameTheme.parchmentLight.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(26),
        const Radius.circular(24),
      ),
      innerEdgePaint,
    );

    _paintCornerMotif(canvas, const Offset(28, 28), 1);
    _paintCornerMotif(canvas, Offset(size.width - 28, 28), -1);
    _paintCornerMotif(canvas, Offset(28, size.height - 28), 1);
    _paintCornerMotif(canvas, Offset(size.width - 28, size.height - 28), -1);
  }

  void _paintCornerMotif(Canvas canvas, Offset origin, double direction) {
    final paint = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx + 18 * direction,
        origin.dy + 6,
        origin.dx + 16 * direction,
        origin.dy + 24,
      )
      ..quadraticBezierTo(
        origin.dx + 10 * direction,
        origin.dy + 38,
        origin.dx + 28 * direction,
        origin.dy + 42,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(origin.translate(10 * direction, 18), 5, paint);

    final linePaint = Paint()
      ..color = SankofaGameTheme.parchmentDark.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      origin.translate(0, 54),
      origin.translate(20 * direction, 54),
      linePaint,
    );
    canvas.drawLine(
      origin.translate(34 * direction, 0),
      origin.translate(34 * direction, 20),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
