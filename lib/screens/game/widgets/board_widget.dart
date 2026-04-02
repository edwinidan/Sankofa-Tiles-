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
    const layerOffsetX = 11.0; // higher layers shift left
    const layerOffsetY = 11.0; // higher layers shift up

    final maxLayer = gameState.tiles.isEmpty
        ? 0
        : gameState.tiles.map((t) => t.layer).reduce((a, b) => a > b ? a : b);

    // Headroom at top so y values for high-layer row-0 tiles stay >= 0
    final yOffset = maxLayer * layerOffsetY;
    // Padding on left so high-layer tiles don't get negative x values
    final xOffset = maxLayer * layerOffsetX;

    // Compute available uids once for the whole build pass
    final availableUids = gameState.availableTileUids;

    // Sort tiles: lower layers first so higher layers paint on top
    final sortedTiles = [...gameState.tiles]
      ..sort((a, b) => a.layer.compareTo(b.layer));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth  = constraints.maxWidth  - 16;
        final availableHeight = constraints.maxHeight - 16;

        // Size tiles to fill the board width exactly (no max cap).
        // xOffset is headroom reserved for stacked-layer shift, so subtract it.
        double tileW = ((availableWidth - xOffset) / cols).clamp(30.0, 65.0);
        double tileH = tileW * (85 / 64);

        // Scale down uniformly if the board is too tall.
        final boardH0 = rows * tileH + yOffset;
        if (boardH0 > availableHeight) {
          final s = availableHeight / boardH0;
          tileW *= s;
          tileH *= s;
        }

        final boardW = cols * tileW + xOffset;
        final boardH = rows * tileH + yOffset;
        const scaleFactor = 1.0;

        return Center(
          child: Transform.scale(
            scale: scaleFactor,
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
                  // Score pop overlays — float "+100" at matched tile positions
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
          ),
        );
      },
    );
  }
}

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
