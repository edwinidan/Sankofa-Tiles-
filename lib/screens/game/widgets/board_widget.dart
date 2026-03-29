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

    const gapH = 4.0;
    const gapV = 4.0;
    const layerOffsetX = 4.0; // higher layers shift right
    const layerOffsetY = 4.0; // higher layers shift up

    final maxLayer = gameState.tiles.isEmpty
        ? 0
        : gameState.tiles.map((t) => t.layer).reduce((a, b) => a > b ? a : b);

    // Headroom at top so y values for high-layer row-0 tiles stay >= 0
    final yOffset = maxLayer * layerOffsetY;

    // Compute available uids once for the whole build pass
    final availableUids = gameState.availableTileUids;

    // Sort tiles: lower layers first so higher layers paint on top
    final sortedTiles = [...gameState.tiles]
      ..sort((a, b) => a.layer.compareTo(b.layer));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth  = constraints.maxWidth  - 16;
        final availableHeight = constraints.maxHeight - 16;

        final tileW = (availableWidth / cols).clamp(36.0, 80.0);
        final tileH = tileW * (85 / 64);

        final boardW = cols * (tileW + gapH) - gapH + maxLayer * layerOffsetX;
        final boardH = rows * (tileH + gapV) - gapV + yOffset;

        final scaleFactor = boardH > availableHeight
            ? availableHeight / boardH
            : 1.0;

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
              padding: const EdgeInsets.all(4),
              child: Stack(
                clipBehavior: Clip.none,
                children: sortedTiles.map((tile) {
                  final x = tile.col * (tileW + gapH)
                             + tile.layer * layerOffsetX;
                  final y = tile.row * (tileH + gapV)
                             - tile.layer * layerOffsetY
                             + yOffset;

                  final isAvail = availableUids.contains(tile.uid);

                  Widget child = TileWidget(
                    key: ValueKey(tile.uid),
                    tile: tile,
                    width: tileW,
                    height: tileH,
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
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
