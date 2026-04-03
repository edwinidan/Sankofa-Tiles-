import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/game_state.dart';
import '../../../providers/game_provider.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/theme/app_colors.dart';
import 'tile_widget.dart';

class BoardWidget extends ConsumerWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final levelDef = getLevelById(gameState.levelId);
    if (levelDef == null || gameState.status == GameStatus.idle) {
      return const SizedBox.shrink();
    }

    final cols = levelDef.boardCols;
    final rows = levelDef.boardRows;

    const gapH = 0.0;
    const gapV = 0.0;
    const layerOffsetX = 11.0;
    const layerOffsetY = 11.0;

    final maxLayer = gameState.tiles.isEmpty
        ? 0
        : gameState.tiles.map((t) => t.layer).reduce((a, b) => a > b ? a : b);

    final yOffset = maxLayer * layerOffsetY;
    final xOffset = maxLayer * layerOffsetX;

    final availableUids = gameState.availableTileUids;

    final sortedTiles = [...gameState.tiles]
      ..sort((a, b) => a.layer.compareTo(b.layer));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth  = constraints.maxWidth  - 16;
        final availableHeight = constraints.maxHeight - 16;

        double tileW = ((availableWidth - xOffset) / cols).clamp(30.0, 65.0);
        double tileH = tileW * (85 / 64);

        final boardH0 = rows * tileH + yOffset;
        if (boardH0 > availableHeight) {
          final s = availableHeight / boardH0;
          tileW *= s;
          tileH *= s;
        }

        final boardW = cols * tileW + xOffset;
        final boardH = rows * tileH + yOffset;

        Widget board = Container(
          width: boardW,
          height: boardH,
          decoration: BoxDecoration(
            color: AppColors.boardGreen.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.kenteGoldDim.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
          child: Stack(
              clipBehavior: Clip.none,
              children: [
                ...sortedTiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tile  = entry.value;
                  final x = tile.col * (tileW + gapH)
                             + xOffset - tile.layer * layerOffsetX;
                  final y = tile.row * (tileH + gapV)
                             - tile.layer * layerOffsetY
                             + yOffset;

                  final isAvail = availableUids.contains(tile.uid);

                  Widget child = TileWidget(
                    key: ValueKey(tile.uid),
                    tile: tile,
                    width: tileW,
                    height: tileH,
                    isAvailable: isAvail,
                  );

                  if (!tile.isMatched && !isAvail) {
                    child = Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(child: child),
                    );
                  }

                  // Staggered entry — ripples across the board by sorted index
                  child = child
                    .animate(delay: (index * 25).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: 0.4,
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    );

                  return Positioned(
                    left: x,
                    top: y,
                    width: tileW,
                    height: tileH,
                    child: child,
                  );
                }),

                // Particle burst + score pop overlays — one per matched tile pos
                ...gameState.pendingScorePops.map((pop) {
                  final x = pop.col * (tileW + gapH)
                             + xOffset - pop.layer * layerOffsetX;
                  final y = pop.row * (tileH + gapV)
                             - pop.layer * layerOffsetY
                             + yOffset;
                  return _MatchBurstOverlay(
                    key: ValueKey('burst_${pop.row}_${pop.col}_${pop.layer}'),
                    x: x,
                    y: y,
                    tileW: tileW,
                    tileH: tileH,
                  );
                }),
                ...gameState.pendingScorePops.map((pop) {
                  final x = pop.col * (tileW + gapH)
                             + xOffset - pop.layer * layerOffsetX;
                  final y = pop.row * (tileH + gapV)
                             - pop.layer * layerOffsetY
                             + yOffset;
                  return _ScorePopOverlay(
                    key: ValueKey('pop_${pop.row}_${pop.col}_${pop.layer}'),
                    x: x,
                    y: y,
                    tileW: tileW,
                    tileH: tileH,
                  );
                }),

                // Win: gold shimmer wash over the board
                if (gameState.status == GameStatus.won)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kenteGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .shimmer(
                          delay: 300.ms,
                          duration: 1400.ms,
                          color: AppColors.kenteGold.withValues(alpha: 0.40),
                        ),
                    ),
                  ),

                // Lose: red tint fades in after the shake settles
                if (gameState.status == GameStatus.lost)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                        .animate()
                        .fadeIn(delay: 380.ms, duration: 350.ms),
                    ),
                  ),
              ],
            ),
          );

        // Lose: shake the board, then red tint overlay takes over
        if (gameState.status == GameStatus.lost) {
          board = board
            .animate()
            .shake(duration: 420.ms, hz: 5, offset: const Offset(6, 0));
        }

        return Center(child: board);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Particle burst — 3 random variants
// ---------------------------------------------------------------------------

enum _BurstVariant { inferno, confetti, nova }

class _BurstParticle {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double angle;    // initial rotation (radians) — confetti only
  final double angularV; // angular velocity (rad/s)   — confetti only

  const _BurstParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    this.angle = 0,
    this.angularV = 0,
  });
}

class _BurstPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final List<_BurstParticle> particles;
  final _BurstVariant variant;

  const _BurstPainter({
    required this.progress,
    required this.particles,
    required this.variant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (variant) {
      case _BurstVariant.inferno:
        _paintInferno(canvas, size);
      case _BurstVariant.confetti:
        _paintConfetti(canvas, size);
      case _BurstVariant.nova:
        _paintNova(canvas, size);
    }
  }

  // -- Inferno: 22 glowing gold/amber/orange circles + flash ring -----------
  void _paintInferno(Canvas canvas, Size size) {
    const totalS = 0.70;
    const gravity = 130.0;
    final t = progress * totalS;
    final cx = size.width / 2;
    final cy = size.height / 2;

    if (progress < 0.35) {
      final rp = progress / 0.35;
      canvas.drawCircle(
        Offset(cx, cy),
        rp * 48.0,
        Paint()
          ..color = const Color(0xFFFFE066).withValues(alpha: (1 - rp) * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }

    final alpha = (1.0 - pow(progress, 1.8).toDouble()).clamp(0.0, 1.0);
    for (final p in particles) {
      final px = cx + p.vx * t;
      final py = cy + p.vy * t + 0.5 * gravity * t * t;
      final r = (p.size * (1.0 - progress * 0.25)).clamp(0.8, 10.0);

      canvas.drawCircle(
        Offset(px, py),
        r * 2.8,
        Paint()
          ..color = p.color.withValues(alpha: alpha * 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );
      canvas.drawCircle(
        Offset(px, py),
        r,
        Paint()
          ..color = p.color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  // -- Confetti: 28 spinning kente-coloured rectangles ----------------------
  void _paintConfetti(Canvas canvas, Size size) {
    const totalS = 0.85;
    const gravity = 90.0;
    final t = progress * totalS;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final alpha = (1.0 - pow(progress, 1.5).toDouble()).clamp(0.0, 1.0);

    for (final p in particles) {
      final px = cx + p.vx * t;
      final py = cy + p.vy * t + 0.5 * gravity * t * t;
      final currentAngle = p.angle + p.angularV * t;
      final w = p.size;
      final h = p.size * 2.4;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(currentAngle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Paint()
          ..color = p.color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  // -- Nova: 16 white/gold particles in 2 rings + central flash disc --------
  void _paintNova(Canvas canvas, Size size) {
    const totalS = 0.60;
    const gravity = 150.0;
    final t = progress * totalS;
    final cx = size.width / 2;
    final cy = size.height / 2;

    if (progress < 0.25) {
      final fp = progress / 0.25;
      canvas.drawCircle(
        Offset(cx, cy),
        fp * 32.0,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: (1 - fp) * 0.85),
      );
    }

    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    for (final p in particles) {
      final px = cx + p.vx * t;
      final py = cy + p.vy * t + 0.5 * gravity * t * t;
      final r = (p.size * (1.0 - progress * 0.6)).clamp(0.5, 12.0);

      canvas.drawCircle(
        Offset(px, py),
        r,
        Paint()
          ..color = p.color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}

class _MatchBurstOverlay extends StatefulWidget {
  final double x;
  final double y;
  final double tileW;
  final double tileH;

  const _MatchBurstOverlay({
    super.key,
    required this.x,
    required this.y,
    required this.tileW,
    required this.tileH,
  });

  @override
  State<_MatchBurstOverlay> createState() => _MatchBurstOverlayState();
}

class _MatchBurstOverlayState extends State<_MatchBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_BurstParticle> _particles;
  late _BurstVariant _variant;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _variant = _BurstVariant.values[rng.nextInt(_BurstVariant.values.length)];

    final ms = switch (_variant) {
      _BurstVariant.inferno  => 700,
      _BurstVariant.confetti => 850,
      _BurstVariant.nova     => 600,
    };
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();

    _particles = switch (_variant) {
      _BurstVariant.inferno  => _buildInferno(rng),
      _BurstVariant.confetti => _buildConfetti(rng),
      _BurstVariant.nova     => _buildNova(rng),
    };
  }

  List<_BurstParticle> _buildInferno(Random rng) {
    const colors = [
      AppColors.kenteGold,
      Color(0xFFEFBF2A), // bright gold
      Color(0xFFF5D060), // light gold
      AppColors.kenteGoldDim,
      Color(0xFFF5E6C8), // tile cream
      Color(0xFFCC8B14), // dark amber
      Color(0xFFFF9A1A), // vivid orange
      Color(0xFFFFF5A0), // near-white yellow
    ];
    return List.generate(22, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 90.0 + rng.nextDouble() * 170.0;
      return _BurstParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 55,
        color: colors[rng.nextInt(colors.length)],
        size: 3.0 + rng.nextDouble() * 4.5,
      );
    });
  }

  List<_BurstParticle> _buildConfetti(Random rng) {
    return List.generate(28, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 70.0 + rng.nextDouble() * 110.0;
      return _BurstParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        color: AppColors.kenteGold,
        size: 3.5 + rng.nextDouble() * 3.0,
        angle: rng.nextDouble() * 2 * pi,
        angularV: (rng.nextDouble() - 0.5) * 12.0, // ±6 rad/s spin
      );
    });
  }

  List<_BurstParticle> _buildNova(Random rng) {
    const colors = [
      Color(0xFFFFFFFF),   // white
      Color(0xFFFFF5A0),   // near-white yellow
      Color(0xFFFFE066),   // warm yellow
      AppColors.kenteGold,
    ];
    final particles = <_BurstParticle>[];
    // Inner ring: 8 fast, large particles — evenly spread
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + (rng.nextDouble() - 0.5) * 0.3;
      final speed = 200.0 + rng.nextDouble() * 70.0;
      particles.add(_BurstParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 40,
        color: colors[rng.nextInt(colors.length)],
        size: 6.0 + rng.nextDouble() * 4.0,
      ));
    }
    // Outer ring: 8 slower, smaller particles — offset by 22.5°
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + pi / 8 + (rng.nextDouble() - 0.5) * 0.2;
      final speed = 55.0 + rng.nextDouble() * 45.0;
      particles.add(_BurstParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        color: colors[rng.nextInt(colors.length)],
        size: 4.0 + rng.nextDouble() * 3.0,
      ));
    }
    return particles;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paint area: 280×280, centered on the tile center
    const paintSize = 280.0;
    final left = widget.x + widget.tileW / 2 - paintSize / 2;
    final top  = widget.y + widget.tileH / 2 - paintSize / 2;

    return Positioned(
      left: left,
      top: top,
      width: paintSize,
      height: paintSize,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _BurstPainter(
              progress: _ctrl.value,
              particles: _particles,
              variant: _variant,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score pop
// ---------------------------------------------------------------------------

class _ScorePopOverlay extends StatefulWidget {
  final double x;
  final double y;
  final double tileW;
  final double tileH;

  const _ScorePopOverlay({
    super.key,
    required this.x,
    required this.y,
    required this.tileW,
    required this.tileH,
  });

  @override
  State<_ScorePopOverlay> createState() => _ScorePopOverlayState();
}

class _ScorePopOverlayState extends State<_ScorePopOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _dy;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _dy = Tween<double>(begin: 0, end: -44).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0), weight: 45),
    ]).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.x + widget.tileW / 2 - 22,
        top: widget.y + widget.tileH * 0.25 + _dy.value,
        child: IgnorePointer(
          child: Opacity(
            opacity: _opacity.value,
            child: const Text(
              '+100',
              style: TextStyle(
                color: AppColors.kenteGold,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Color(0xCC000000),
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
