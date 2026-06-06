import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/sankofa_game_theme.dart';

class GameBoardBackdrop extends StatelessWidget {
  final Widget child;

  const GameBoardBackdrop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DarkAdinkraBoardPainter(),
                ),
              ),
            ),
            Positioned.fill(child: child),
          ],
        );
      },
    );
  }
}

class DarkAdinkraBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final horizontalInset = min(14.0, size.width * 0.035);
    final verticalInset = min(10.0, size.height * 0.025);
    final boardRect = Rect.fromLTRB(
      horizontalInset,
      verticalInset,
      size.width - horizontalInset,
      size.height - verticalInset,
    );
    final boardRRect = RRect.fromRectAndRadius(
      boardRect,
      const Radius.circular(SankofaGameTheme.boardRadius),
    );
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawRRect(
      boardRRect.shift(const Offset(0, 10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawRRect(
      boardRRect.shift(const Offset(0, 7)),
      Paint()..color = const Color(0xFF08120F).withValues(alpha: 0.88),
    );

    canvas.drawRRect(
      boardRRect,
      Paint()..shader = SankofaGameTheme.boardGradient.createShader(boardRect),
    );

    canvas.drawRRect(
      boardRRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.08),
          radius: 0.9,
          colors: [
            const Color(0xFF426454).withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ).createShader(boardRect),
    );

    final texturePaint = Paint()
      ..color = SankofaGameTheme.parchmentLight.withValues(alpha: 0.018);
    for (var i = 0; i < 90; i++) {
      final angle = (i * 2.399963229728653) % (2 * pi);
      final distance =
          min(boardRect.width, boardRect.height) * ((i * 37) % 45) / 100;
      final point = center + Offset(cos(angle), sin(angle)) * distance;
      if (boardRect.deflate(16).contains(point)) {
        canvas.drawCircle(point, i % 5 == 0 ? 0.85 : 0.5, texturePaint);
      }
    }

    canvas.drawRRect(
      boardRRect,
      Paint()
        ..color = SankofaGameTheme.antiqueGold.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.deflate(3.5),
        const Radius.circular(SankofaGameTheme.boardRadius - 3.5),
      ),
      Paint()
        ..color = const Color(0xFF08120F).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.deflate(6),
        const Radius.circular(SankofaGameTheme.boardRadius - 6),
      ),
      Paint()
        ..color = SankofaGameTheme.parchmentLight.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    _paintAdinkraMotif(
      canvas,
      center,
      min(boardRect.width, boardRect.height) * 0.25,
    );
  }

  void _paintAdinkraMotif(Canvas canvas, Offset center, double radius) {
    final motifPaint = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, motifPaint);
    canvas.drawCircle(center, radius * 0.42, motifPaint);

    final diamond = Path()
      ..moveTo(center.dx, center.dy - radius * 0.72)
      ..lineTo(center.dx + radius * 0.72, center.dy)
      ..lineTo(center.dx, center.dy + radius * 0.72)
      ..lineTo(center.dx - radius * 0.72, center.dy)
      ..close();
    canvas.drawPath(diamond, motifPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      -pi * 0.25,
      pi * 1.5,
      false,
      motifPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.24),
      pi * 0.75,
      pi * 1.5,
      false,
      motifPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
