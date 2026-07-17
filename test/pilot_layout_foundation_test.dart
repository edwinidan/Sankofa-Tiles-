import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  group('layout validator', () {
    test('accepts direct, bridge, multiple, partial, and edge support', () {
      const layout = NamedLayout(
        id: 'supportCases',
        name: 'Support cases',
        positions: [
          TilePosition(0, 0, 0),
          TilePosition(0, 2, 0),
          TilePosition(2, 0, 0),
          TilePosition(2, 2, 0),
          TilePosition(0, 0, 1),
          TilePosition(1, 1, 1),
        ],
      );
      final result = validateLayout(layout, viewports: const []);
      expect(
        result.issues
            .where((issue) => issue.kind == LayoutIssueKind.floatingTile),
        isEmpty,
      );
    });

    test('rejects support that skips the immediately lower layer', () {
      const layout = NamedLayout(
        id: 'wrongLayerSupport',
        name: 'Wrong layer support',
        positions: [
          TilePosition(0, 0, 0),
          TilePosition(0, 2, 0),
          TilePosition(0, 0, 2),
          TilePosition(0, 2, 2),
        ],
      );
      final result = validateLayout(layout, viewports: const []);
      expect(result.unsupportedTileCount, 2);
      expect(result.issues.any((i) => i.kind == LayoutIssueKind.missingLayer),
          isTrue);
    });

    test('rejects same-layer half-grid overlap and negative layers', () {
      const layout = NamedLayout(
        id: 'invalidOverlap',
        name: 'Invalid overlap',
        positions: [
          TilePosition(0, 0, 0),
          TilePosition(0, 1, 0),
          TilePosition(4, 0, -1),
          TilePosition(4, 2, -1),
        ],
      );
      final result = validateLayout(layout, viewports: const []);
      expect(
          result.issues.any((i) => i.kind == LayoutIssueKind.sameLayerOverlap),
          isTrue);
      expect(result.issues.any((i) => i.kind == LayoutIssueKind.invalidLayer),
          isTrue);
    });
  });

  for (final layout in [
    pilotOpenDiamondLayout,
    pilotLayeredDiamondLayout,
    earlyOpenDiamond01Layout,
    earlyOpenDiamond02Layout,
    earlyShrine01Layout,
    earlyBridge01Layout,
    earlyLayeredDiamond01Layout,
  ]) {
    group(layout.id, () {
      test('is isolated from production campaign and structurally valid', () {
        final result = validateLayout(layout, minimumOpeningTiles: 4);
        expect(result.issues, isEmpty,
            reason: result.issues.map((i) => i.message).join('\n'));
      });

      test('has genuine half-grid positions and valid projected bounds', () {
        expect(layout.positions.any((p) => p.row.isOdd || p.col.isOdd), isTrue);
        final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
        expect(geometry.widthInTileUnits, greaterThan(0));
        expect(geometry.heightInTileUnits, greaterThan(0));
        for (final viewport in kRequiredBoardViewports) {
          expect(
            geometry
                .fit(
                    availableWidth: viewport.width,
                    availableHeight: viewport.height)
                .fitsSafely,
            isTrue,
          );
        }
      });

      test('reverse-solved construction succeeds for 20 deterministic seeds',
          () {
        for (var seed = 0; seed < 20; seed++) {
          final tiles = _reverseSolved(layout, seed);
          expect(tiles, isNotNull, reason: 'seed=$seed');
          expect(BoardSolver.isSolvable(tiles!), isTrue, reason: 'seed=$seed');
          expect(
            tiles.map((t) => '${t.row}:${t.col}:${t.layer}').toSet(),
            layout.positions.map((p) => '${p.row}:${p.col}:${p.layer}').toSet(),
          );
        }
      });
    });
  }

  test(
      'earlyOpenDiamond02 has at least two legal and safe openings for 100 seeds',
      () {
    for (var seed = 0; seed < 100; seed++) {
      final tiles = _reverseSolved(
        earlyOpenDiamond02Layout,
        seed,
        copiesPerSymbol: 4,
      )!;
      final legal = BoardSolver.findAvailableMatchingPairs(tiles);
      final safe = legal
          .where(
              (pair) => BoardSolver.isSafeMove(tiles, pair.first, pair.second))
          .length;
      expect(legal.length, greaterThanOrEqualTo(2), reason: 'legal seed=$seed');
      expect(safe, greaterThanOrEqualTo(2), reason: 'safe seed=$seed');
    }
  });

  test('campaign levels 1-5 use approved layouts with compatible symbol plans',
      () {
    final expected = <int, NamedLayout>{
      1: earlyOpenDiamond01Layout,
      2: earlyOpenDiamond02Layout,
      3: earlyBridge01Layout,
      4: earlyShrine01Layout,
      5: earlyLayeredDiamond01Layout,
    };
    for (final entry in expected.entries) {
      final level = getLevelById(entry.key)!;
      expect(level.id, entry.key);
      expect(level.namedLayout.id, entry.value.id);
      expect(
        level.symbolCopyCounts.fold<int>(0, (sum, count) => sum + count),
        level.tileCount,
      );
      expect(level.symbolCopyCounts.every((count) => count.isEven), isTrue);
    }
  });
}

List<TileModel>? _reverseSolved(
  NamedLayout layout,
  int seed, {
  int copiesPerSymbol = 2,
}) {
  final rng = Random(seed);
  for (var attempt = 0; attempt < 100; attempt++) {
    var remaining = <TileModel>[
      for (var i = 0; i < layout.positions.length; i++)
        TileModel(
          uid: 'remaining_${attempt}_$i',
          def: kAllTiles.first,
          row: layout.positions[i].row,
          col: layout.positions[i].col,
          layer: layout.positions[i].layer,
        ),
    ];
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final removed = {free[0].uid, free[1].uid};
      remaining =
          remaining.where((tile) => !removed.contains(tile.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    return <TileModel>[
      for (var i = 0; i < order.length; i++)
        TileModel(
          uid: 'generated_$i',
          def: kAllTiles[(i ~/ copiesPerSymbol) % kAllTiles.length],
          row: order[i].row,
          col: order[i].col,
          layer: order[i].layer,
        ),
    ];
  }
  return null;
}
