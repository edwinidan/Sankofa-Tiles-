import 'dart:math';
import 'package:flutter/material.dart';
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

        return Center(
          child: Container(
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
                ...sortedTiles.map((tile) {
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
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Particle burst
// ---------------------------------------------------------------------------

class _BurstParticle {
  final double vx;
  final double vy;
  final Color color;
  final double size;

  const _BurstParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class _BurstPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final List<_BurstParticle> particles;

  const _BurstPainter({required this.progress, required this.particles});

  static const _totalSeconds = 0.55;
  static const _gravity = 180.0; // px/s² downward

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * _totalSeconds;
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final p in particles) {
      final px = cx + p.vx * t;
      final py = cy + p.vy * t + 0.5 * _gravity * t * t;
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final radius = p.size * (1.0 - progress * 0.35);

      canvas.drawCircle(
        Offset(px, py),
        radius.clamp(0.5, 8.0),
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

  static const _kColors = [
    AppColors.kenteGold,
    Color(0xFFEFBF2A), // bright gold
    Color(0xFFF5D060), // light gold
    AppColors.kenteGoldDim,
    Color(0xFFF5E6C8), // tile face cream
    Color(0xFFCC8B14), // dark amber
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    final rng = Random();
    _particles = List.generate(10, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 55.0 + rng.nextDouble() * 85.0;
      return _BurstParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 25, // slight upward bias
        color: _kColors[rng.nextInt(_kColors.length)],
        size: 2.5 + rng.nextDouble() * 2.5,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paint area: 180×180, centered on the tile center
    const paintSize = 180.0;
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
