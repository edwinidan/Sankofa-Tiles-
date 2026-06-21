import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  test('all 50 boards fit supported gameplay areas above the tile minimum', () {
    expect(kLevels, hasLength(50));

    for (final level in kLevels) {
      final geometry = BoardLayoutGeometry.fromPositions(level.layout);
      for (final viewport in kRequiredBoardViewports) {
        final fit = geometry.fit(
          availableWidth: viewport.width,
          availableHeight: viewport.height,
        );

        expect(
          fit.fitsBounds,
          isTrue,
          reason: 'Level ${level.id} exceeds ${viewport.name}',
        );
        expect(
          fit.tileWidth,
          greaterThanOrEqualTo(kMinimumTileWidth),
          reason: 'Level ${level.id} is too small on ${viewport.name}',
        );
      }
    }
  });

  test('late-level tile scale stays close to the Level 6 standard', () {
    final reference = BoardLayoutGeometry.fromPositions(
      getLevelById(6)!.layout,
    ).fit(
      availableWidth: kRequiredBoardViewports.first.width,
      availableHeight: kRequiredBoardViewports.first.height,
    );

    for (final level in kLevels) {
      final fit = BoardLayoutGeometry.fromPositions(level.layout).fit(
        availableWidth: kRequiredBoardViewports.first.width,
        availableHeight: kRequiredBoardViewports.first.height,
      );
      expect(
        fit.tileWidth,
        greaterThanOrEqualTo(reference.tileWidth * 0.80),
        reason: 'Level ${level.id} differs too much from Level 6',
      );
    }
  });

  test('every layout has unique coordinates and valid opening geometry', () {
    for (final level in kLevels) {
      expect(
        level.layout.toSet(),
        hasLength(level.tileCount),
        reason: 'Level ${level.id} contains duplicate coordinates',
      );

      final tiles = [
        for (var i = 0; i < level.layout.length; i++)
          TileModel(
            def: kAllTiles.first,
            row: level.layout[i].row,
            col: level.layout[i].col,
            layer: level.layout[i].layer,
            uid: 'geometry_${level.id}_$i',
          ),
      ];

      expect(
        BoardSolver.getFreeTiles(tiles).length,
        greaterThanOrEqualTo(2),
        reason: 'Level ${level.id} has no playable opening geometry',
      );
    }
  });
}
