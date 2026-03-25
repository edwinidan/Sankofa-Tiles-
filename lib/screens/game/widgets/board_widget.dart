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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 16;
        final availableHeight = constraints.maxHeight - 16;

        // Calculate tile size to fit the grid
        final tileW = (availableWidth / cols).clamp(36.0, 80.0);
        final tileH = tileW * (72 / 56); // maintain aspect ratio
        const gapH = 4.0;
        const gapV = 4.0;

        final gridWidth = cols * tileW + (cols - 1) * gapH;
        final gridHeight = rows * tileH + (rows - 1) * gapV;

        // If doesn't fit vertically, shrink
        final scaleFactor = gridHeight > availableHeight
            ? availableHeight / gridHeight
            : 1.0;

        return Center(
          child: Transform.scale(
            scale: scaleFactor,
            child: Container(
              width: gridWidth,
              height: gridHeight,
              decoration: BoxDecoration(
                color: AppColors.boardGreen.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.kenteGoldDim.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: tileW / tileH,
                  crossAxisSpacing: gapH,
                  mainAxisSpacing: gapV,
                ),
                itemCount: cols * rows,
                itemBuilder: (context, index) {
                  final row = index ~/ cols;
                  final col = index % cols;
                  final tile = gameState.tiles.firstWhere(
                    (t) => t.row == row && t.col == col,
                    orElse: () => throw StateError('No tile at $row,$col'),
                  );

                  if (tile.isMatched) {
                    // Empty slot after match
                    return TileWidget(
                      key: ValueKey(tile.uid),
                      tile: tile,
                      width: tileW,
                      height: tileH,
                    );
                  }

                  return TileWidget(
                    key: ValueKey(tile.uid),
                    tile: tile,
                    width: tileW,
                    height: tileH,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
