import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/level_data.dart';
import '../../../models/game_state.dart';
import '../../../providers/game_provider.dart';
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

    final availableUids = gameState.availableTileUids;
    final sortedTiles = [...gameState.tiles]
      ..sort((a, b) => a.layer.compareTo(b.layer));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = max(0.0, constraints.maxWidth - 16);
        final availableHeight = max(0.0, constraints.maxHeight - 16);
        final metrics = _BoardLayoutMetrics.forLevel(gameState.levelId);
        final layoutBounds = _BoardLayoutBounds.fromTiles(
          gameState.tiles,
          metrics: metrics,
        );

        final tileW = layoutBounds.tileWidthFor(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        );
        final tileH = tileW * _tileAspectRatio;
        final boardW = layoutBounds.widthInTileUnits * tileW;
        final boardH = layoutBounds.heightInTileUnits * tileW;
        final canvasW = max(availableWidth, boardW);
        final canvasH = max(availableHeight, boardH);
        final boardLeft = (canvasW - boardW) / 2;
        final boardTop = (canvasH - boardH) / 2;

        Offset tileOffset(int row, int col, int layer) {
          final projected = layoutBounds.project(row, col, layer, tileW);
          return Offset(
            boardLeft + projected.dx - layoutBounds.minX * tileW,
            boardTop + projected.dy - layoutBounds.minY * tileW,
          );
        }

        Widget boardCanvas = SizedBox(
          width: canvasW,
          height: canvasH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...sortedTiles.asMap().entries.map((entry) {
                final index = entry.key;
                final tile = entry.value;
                final offset = tileOffset(tile.row, tile.col, tile.layer);
                final isAvail = availableUids.contains(tile.uid);

                Widget child = TileWidget(
                  key: ValueKey(tile.uid),
                  tile: tile,
                  width: tileW,
                  height: tileH,
                  isAvailable: isAvail,
                );

                if (!tile.isMatched && !isAvail) {
                  child = IgnorePointer(child: child);
                }

                child = child
                    .animate(delay: (index * 25).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: 0.4,
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    );

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  width: tileW,
                  height: tileH,
                  child: child,
                );
              }),
              ...gameState.pendingScorePops.map((pop) {
                final offset = tileOffset(pop.row, pop.col, pop.layer);
                return _MatchBurstOverlay(
                  key: ValueKey('burst_${pop.row}_${pop.col}_${pop.layer}'),
                  x: offset.dx,
                  y: offset.dy,
                  tileW: tileW,
                  tileH: tileH,
                );
              }),
              ...gameState.pendingScorePops.map((pop) {
                final offset = tileOffset(pop.row, pop.col, pop.layer);
                return _ScorePopOverlay(
                  key: ValueKey('pop_${pop.row}_${pop.col}_${pop.layer}'),
                  x: offset.dx,
                  y: offset.dy,
                  tileW: tileW,
                  tileH: tileH,
                );
              }),
              if (gameState.status == GameStatus.won)
                Positioned(
                  left: boardLeft,
                  top: boardTop,
                  width: boardW,
                  height: boardH,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.kenteGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).animate().fadeIn(duration: 500.ms).shimmer(
                          delay: 300.ms,
                          duration: 1400.ms,
                          color: AppColors.kenteGold.withValues(alpha: 0.40),
                        ),
                  ),
                ),
              if (gameState.status == GameStatus.lost)
                Positioned(
                  left: boardLeft,
                  top: boardTop,
                  width: boardW,
                  height: boardH,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).animate().fadeIn(delay: 380.ms, duration: 350.ms),
                  ),
                ),
            ],
          ),
        );

        Widget board = SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: InteractiveViewer(
            constrained: false,
            alignment: Alignment.center,
            panEnabled: canvasW > availableWidth || canvasH > availableHeight,
            scaleEnabled: false,
            boundaryMargin: const EdgeInsets.all(20),
            child: boardCanvas,
          ),
        );

        if (gameState.status == GameStatus.lost) {
          board = board
              .animate()
              .shake(duration: 420.ms, hz: 5, offset: const Offset(6, 0));
        }

        return board;
      },
    );
  }
}

const _tileAspectRatio = 85 / 64;
const _layoutStepX = 0.5;
const _layoutStepY = _tileAspectRatio * 0.5;
const _layerOffsetXInTileUnits = 0.14;
const _layerOffsetYInTileUnits = _tileAspectRatio * 0.10;
const _tileV2TestStepScale = 0.85;
const _minimumPlayableTileWidth = 34.0;
const _maximumPlayableTileWidth = 64.0;

class _BoardLayoutMetrics {
  final double stepX;
  final double stepY;
  final double layerOffsetX;
  final double layerOffsetY;

  const _BoardLayoutMetrics({
    required this.stepX,
    required this.stepY,
    required this.layerOffsetX,
    required this.layerOffsetY,
  });

  static const tileV2Test = _BoardLayoutMetrics(
    stepX: _layoutStepX * _tileV2TestStepScale,
    stepY: _layoutStepY * _tileV2TestStepScale,
    layerOffsetX: _layerOffsetXInTileUnits,
    layerOffsetY: _layerOffsetYInTileUnits,
  );

  static _BoardLayoutMetrics forLevel(int levelId) {
    return tileV2Test;
  }
}

class _BoardLayoutBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final _BoardLayoutMetrics metrics;

  const _BoardLayoutBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.metrics,
  });

  double get widthInTileUnits => maxX - minX;
  double get heightInTileUnits => maxY - minY;

  static _BoardLayoutBounds fromTiles(
    List tiles, {
    required _BoardLayoutMetrics metrics,
  }) {
    if (tiles.isEmpty) {
      return _BoardLayoutBounds(
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        metrics: metrics,
      );
    }

    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;

    for (final tile in tiles) {
      final left = metrics.projectX(tile.col, tile.layer);
      final top = metrics.projectY(tile.row, tile.layer);
      minX = min(minX, left);
      maxX = max(maxX, left + 1);
      minY = min(minY, top);
      maxY = max(maxY, top + _tileAspectRatio);
    }

    return _BoardLayoutBounds(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      metrics: metrics,
    );
  }

  double tileWidthFor({
    required double availableWidth,
    required double availableHeight,
  }) {
    if (availableWidth <= 0 || availableHeight <= 0) {
      return _minimumPlayableTileWidth;
    }

    final fitW = availableWidth / widthInTileUnits;
    final fitH = availableHeight / heightInTileUnits;
    final fitted = min(fitW, fitH);

    return fitted.clamp(
      _minimumPlayableTileWidth,
      _maximumPlayableTileWidth,
    );
  }

  Offset project(int row, int col, int layer, double tileW) {
    return Offset(
      metrics.projectX(col, layer) * tileW,
      metrics.projectY(row, layer) * tileW,
    );
  }
}

extension on _BoardLayoutMetrics {
  double projectX(int col, int layer) {
    return col * stepX - layer * layerOffsetX;
  }

  double projectY(int row, int layer) {
    return row * stepY - layer * layerOffsetY;
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
  final double angle; // initial rotation (radians) — confetti only
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
      _BurstVariant.inferno => 700,
      _BurstVariant.confetti => 850,
      _BurstVariant.nova => 600,
    };
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();

    _particles = switch (_variant) {
      _BurstVariant.inferno => _buildInferno(rng),
      _BurstVariant.confetti => _buildConfetti(rng),
      _BurstVariant.nova => _buildNova(rng),
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
      Color(0xFFFFFFFF), // white
      Color(0xFFFFF5A0), // near-white yellow
      Color(0xFFFFE066), // warm yellow
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
    final top = widget.y + widget.tileH / 2 - paintSize / 2;

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
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 45),
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
