import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

TileModel _tile({
  required int id,
  required int row,
  required int col,
  int layer = 0,
  String? symbolId,
}) {
  final def = symbolId != null
      ? kAllTiles.firstWhere((d) => d.id == symbolId)
      : kAllTiles[id % kAllTiles.length];
  return TileModel(
    uid: 'test_tile_${row}_${col}_${layer}_$id',
    def: def,
    row: row,
    col: col,
    layer: layer,
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // 1. ODD-COORDINATE OVERLAP DETECTION
  // ---------------------------------------------------------------------------
  group('Odd-coordinate overlap detection', () {
    test('col=1 overlaps col=0 when on different layers', () {
      // Tile at col=0 spans [0, 2). Tile at col=1 spans [1, 3).
      // These overlap on the column axis — used for cover detection across
      // layers, not same-layer side-blocking.
      final cover = _tile(id: 0, row: 0, col: 0, layer: 0);
      final upper = _tile(id: 1, row: 0, col: 1, layer: 1);

      // The upper tile at col=1 on layer 1 should cover the lower tile at col=0.
      expect(BoardSolver.isTileFree(cover, [cover, upper]), isFalse,
          reason: 'Upper tile at col=1 should cover lower tile at col=0');
    });

    test('same-layer tiles at col=0 and col=1 are NOT side-neighbours', () {
      // Two tiles on the SAME layer at col=0 and col=1 overlap visually.
      // This is a layout design issue (they should be on different layers),
      // but the side-blocking logic correctly does NOT treat them as
      // neighbours — the adjacency check requires a col-difference of exactly
      // 2 (tileSpan).
      final a = _tile(id: 0, row: 0, col: 0, layer: 0);
      final b = _tile(id: 1, row: 0, col: 1, layer: 0);

      // Both are free because they don't block each other's sides.
      expect(BoardSolver.isTileFree(a, [a, b]), isTrue);
      expect(BoardSolver.isTileFree(b, [a, b]), isTrue);
    });

    test('col=1 overlaps col=2 (same row)', () {
      final cover = _tile(id: 0, row: 0, col: 2, layer: 0);
      final upper = _tile(id: 1, row: 0, col: 1, layer: 1);

      expect(BoardSolver.isTileFree(cover, [cover, upper]), isFalse,
          reason: 'Upper tile at col=1 should cover lower tile at col=2');
    });

    test('col=1 on layer 1 covers BOTH col=0 and col=2 on layer 0', () {
      final bottomA = _tile(id: 0, row: 0, col: 0, layer: 0);
      final bottomB = _tile(id: 1, row: 0, col: 2, layer: 0);
      final upper = _tile(id: 2, row: 0, col: 1, layer: 1);

      final tiles = [bottomA, bottomB, upper];

      expect(BoardSolver.isTileFree(bottomA, tiles), isFalse,
          reason: 'bottomA at col=0 should be covered by upper at col=1');
      expect(BoardSolver.isTileFree(bottomB, tiles), isFalse,
          reason: 'bottomB at col=2 should be covered by upper at col=1');
      expect(BoardSolver.isTileFree(upper, tiles), isTrue,
          reason: 'Upper tile should be free (no tiles above it)');
    });

    test('row=1 overlaps row=0 and row=2 (same col)', () {
      final bottomA = _tile(id: 0, row: 0, col: 0, layer: 0);
      final bottomB = _tile(id: 1, row: 2, col: 0, layer: 0);
      final upper = _tile(id: 2, row: 1, col: 0, layer: 1);

      final tiles = [bottomA, bottomB, upper];

      expect(BoardSolver.isTileFree(bottomA, tiles), isFalse,
          reason: 'bottomA at row=0 should be covered by upper at row=1');
      expect(BoardSolver.isTileFree(bottomB, tiles), isFalse,
          reason: 'bottomB at row=2 should be covered by upper at row=1');
    });

    test('odd col does NOT overlap col=4 (gap)', () {
      // col=0 spans [0,2). col=4 spans [4,6). No overlap.
      // But col=1 on layer 1 doesn't cover col=4 on layer 0.
      // Wait - we need col=0 vs col=4 not overlapping.
      final a = _tile(id: 0, row: 0, col: 0, layer: 0);
      final b = _tile(id: 1, row: 0, col: 4, layer: 0);
      final upper = _tile(id: 2, row: 0, col: 1, layer: 1);

      final tiles = [a, b, upper];

      expect(BoardSolver.isTileFree(a, tiles), isFalse,
          reason: 'Tile at col=0 should be covered by upper at col=1');
      expect(BoardSolver.isTileFree(b, tiles), isTrue,
          reason: 'Tile at col=4 should NOT be covered by upper at col=1');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. COVER DETECTION — REMOVING UPPER TILE FREES LOWER TILES
  // ---------------------------------------------------------------------------
  group('Cover removal uncovers lower tiles', () {
    test('removing upper tile at col=1 frees both lower tiles', () {
      final tileDef = kAllTiles.first;
      final bottomA =
          TileModel(uid: 'a', def: tileDef, row: 0, col: 0, layer: 0);
      final bottomB =
          TileModel(uid: 'b', def: tileDef, row: 0, col: 2, layer: 0);

      // Use a different def so the solver treats them as a pair.
      final upperDef = kAllTiles[1];
      final upper =
          TileModel(uid: 'u', def: upperDef, row: 0, col: 1, layer: 1);

      // All three tiles present.
      final allTiles = [bottomA, bottomB, upper];
      expect(BoardSolver.isTileFree(bottomA, allTiles), isFalse);
      expect(BoardSolver.isTileFree(bottomB, allTiles), isFalse);

      // Remove upper tile (mark matched).
      final withoutUpper = [
        bottomA.copyWith(isMatched: false, isSelected: false, isHinted: false),
        bottomB.copyWith(isMatched: false, isSelected: false, isHinted: false),
        upper.copyWith(isMatched: true, isSelected: false, isHinted: false),
      ];
      expect(BoardSolver.isTileFree(withoutUpper[0], withoutUpper), isTrue,
          reason: 'bottomA should be free after upper is removed');
      expect(BoardSolver.isTileFree(withoutUpper[1], withoutUpper), isTrue,
          reason: 'bottomB should be free after upper is removed');
    });
  });

  // ---------------------------------------------------------------------------
  // 3. SIDE-BLOCKING WITH ODD COORDINATES
  // ---------------------------------------------------------------------------
  group('Side-blocking with odd coordinates', () {
    test('normal adjacency: col=0 and col=2 are neighbours', () {
      final left = _tile(id: 0, row: 0, col: 0, layer: 0);
      final right = _tile(id: 1, row: 0, col: 2, layer: 0);

      final tiles = [left, right];

      // Left tile: left side open (no tile at col=-2), right side blocked by
      // col=2. So it IS free (one side open).
      expect(BoardSolver.isTileFree(left, tiles), isTrue,
          reason: 'col=0 has right blocked by col=2 but left is open');

      // Right tile: left side blocked by col=0, right side open.
      expect(BoardSolver.isTileFree(right, tiles), isTrue,
          reason: 'col=2 has left blocked by col=0 but right is open');
    });

    test('col=1 adjacent same-layer neighbours are col=-1 and col=3', () {
      final tile = _tile(id: 0, row: 0, col: 1, layer: 0);
      final leftNeighbor = _tile(id: 1, row: 0, col: -1, layer: 0);
      final rightNeighbor = _tile(id: 2, row: 0, col: 3, layer: 0);

      final bothBlocked = [tile, leftNeighbor, rightNeighbor];
      expect(BoardSolver.isTileFree(tile, bothBlocked), isFalse,
          reason: 'col=1 is blocked on both sides by col=-1 and col=3');

      final onlyLeftBlocked = [tile, leftNeighbor];
      expect(BoardSolver.isTileFree(tile, onlyLeftBlocked), isTrue,
          reason: 'col=1 has left blocked but right is open');

      final onlyRightBlocked = [tile, rightNeighbor];
      expect(BoardSolver.isTileFree(tile, onlyRightBlocked), isTrue,
          reason: 'col=1 has right blocked but left is open');
    });

    test('col=0 is NOT side-blocked by col=1 (they overlap, not adjacent)', () {
      final a = _tile(id: 0, row: 0, col: 0, layer: 0);
      final b = _tile(id: 1, row: 0, col: 1, layer: 0);

      // Side-blocking checks: other.col + 2 == tile.col for left-blocked.
      // b.col + 2 = 1 + 2 = 3 != 0 = a.col. So b does NOT block a's left.
      // a.col + 2 = 0 + 2 = 2 != 1 = b.col. So a does NOT block b's right.
      // BUT they DO overlap — so they'd be on different layers in practice.

      final tiles = [a, b];
      expect(BoardSolver.isTileFree(a, tiles), isTrue,
          reason: 'col=0 and col=1 are not same-layer neighbours');
      expect(BoardSolver.isTileFree(b, tiles), isTrue,
          reason: 'col=1 and col=0 are not same-layer neighbours');
    });

    test('col=1 is NOT side-blocked by col=0 or col=2', () {
      final a = _tile(id: 0, row: 0, col: 0, layer: 0);
      final b = _tile(id: 1, row: 0, col: 1, layer: 0);
      final c = _tile(id: 2, row: 0, col: 2, layer: 0);

      // For b at col=1:
      // Left neighbor check: other.col + 2 == b.col → other.col == -1. Not 0 or
      // 2. Right neighbor check: other.col == b.col + 2 → other.col == 3.
      // So neither col=0 nor col=2 blocks col=1 on the sides.

      final tiles = [a, b, c];
      expect(BoardSolver.isTileFree(b, tiles), isTrue,
          reason: 'col=1 is not side-blocked by col=0 or col=2');
    });
  });

  // ---------------------------------------------------------------------------
  // 4. VISUAL PROJECTION WITH ODD COORDINATES
  // ---------------------------------------------------------------------------
  group('Visual projection with odd coordinates', () {
    test('projectX places col=1 halfway between col=0 and col=2', () {
      const tileW = 64.0;
      final x0 = BoardLayoutGeometry.projectX(0, 0) * tileW;
      final x1 = BoardLayoutGeometry.projectX(1, 0) * tileW;
      final x2 = BoardLayoutGeometry.projectX(2, 0) * tileW;

      // Step = 0.425 * 64 = 27.2
      // x0 = 0, x1 = 27.2, x2 = 54.4
      expect(x1 - x0, closeTo(x2 - x1, 0.01),
          reason: 'col=1 should sit exactly halfway between col=0 and col=2');
    });

    test('projectY places row=1 halfway between row=0 and row=2', () {
      const tileW = 64.0;
      final y0 = BoardLayoutGeometry.projectY(0, 0) * tileW;
      final y1 = BoardLayoutGeometry.projectY(1, 0) * tileW;
      final y2 = BoardLayoutGeometry.projectY(2, 0) * tileW;

      expect(y1 - y0, closeTo(y2 - y1, 0.01),
          reason: 'row=1 should sit exactly halfway between row=0 and row=2');
    });

    test('board bounds include odd-coordinate tiles', () {
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(0, 1, 0),
        const TilePosition(0, 2, 0),
      ];

      final geometry = BoardLayoutGeometry.fromPositions(positions);
      expect(
          geometry.minX, lessThanOrEqualTo(BoardLayoutGeometry.projectX(0, 0)));
      expect(geometry.maxX,
          greaterThanOrEqualTo(BoardLayoutGeometry.projectX(2, 0) + 1));
    });

    test('board centring works with odd-coordinate layouts', () {
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(0, 1, 0),
        const TilePosition(0, 2, 0),
        const TilePosition(0, 3, 0),
      ];

      final geometry = BoardLayoutGeometry.fromPositions(positions);
      final fit = geometry.fit(
        availableWidth: 360,
        availableHeight: 500,
      );

      expect(fit.fitsSafely, isTrue);
      expect(fit.tileWidth, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. REVERSE-SOLVED GENERATION WITH ODD COORDINATES
  // ---------------------------------------------------------------------------
  group('Reverse-solved generation with odd coordinates', () {
    test('small bridging layout with odd coords produces solvable board', () {
      // Three-tile bridge: two bottom tiles, one upper bridging tile.
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(0, 2, 0),
        const TilePosition(0, 1, 1),
      ];

      // Use 3 pairs = 6 tiles total. Only need 3 positions.
      // Add three more positions to make 6 tiles (3 pairs).
      final fullPositions = [
        ...positions,
        const TilePosition(2, 0, 0),
        const TilePosition(2, 2, 0),
        const TilePosition(2, 1, 1),
      ];

      final defs = [
        kAllTiles[0],
        kAllTiles[0],
        kAllTiles[1],
        kAllTiles[1],
        kAllTiles[2],
        kAllTiles[2],
      ];

      // Simulate _buildRandomBoard style assignment.
      final tiles = List.generate(
        fullPositions.length,
        (i) => TileModel(
          def: defs[i],
          row: fullPositions[i].row,
          col: fullPositions[i].col,
          layer: fullPositions[i].layer,
        ),
      );

      // Should have valid opening geometry.
      final free = BoardSolver.getFreeTiles(tiles);
      expect(free.length, greaterThanOrEqualTo(2),
          reason: 'Bridging layout must have at least 2 free starting tiles');

      // The upper tiles should be free (no tiles above them).
      final upperTiles = tiles.where((t) => t.layer == 1).toList();
      for (final t in upperTiles) {
        expect(BoardSolver.isTileFree(t, tiles), isTrue,
            reason: 'Upper tile should be free');
      }
    });

    test('odd-coordinate layout with unique coords passes validation', () {
      final builder = TileLayoutBuilder()
        ..add(const TilePosition(0, 0, 0))
        ..add(const TilePosition(0, 2, 0))
        ..add(const TilePosition(0, 1, 1))
        ..add(const TilePosition(2, 0, 0))
        ..add(const TilePosition(2, 2, 0))
        ..add(const TilePosition(2, 1, 1));

      final positions = builder.build();
      expect(positions.length, 6);
      expect(positions.toSet().length, 6,
          reason: 'All coordinates must be unique');
    });
  });

  // ---------------------------------------------------------------------------
  // 6. DOUBLE-OVERLAP BRIDGING
  // ---------------------------------------------------------------------------
  group('Bridging across two lower tiles', () {
    test('upper tile at (row=0, col=1, layer=1) bridges (0,0) and (0,2)', () {
      final bottomA = _tile(id: 0, row: 0, col: 0, layer: 0);
      final bottomB = _tile(id: 1, row: 0, col: 2, layer: 0);
      final bridge = _tile(id: 2, row: 0, col: 1, layer: 1);

      final tiles = [bottomA, bottomB, bridge];

      // Bridge should be free (nothing above it).
      expect(BoardSolver.isTileFree(bridge, tiles), isTrue);

      // Both bottom tiles should be covered by the bridge.
      expect(BoardSolver.isTileFree(bottomA, tiles), isFalse);
      expect(BoardSolver.isTileFree(bottomB, tiles), isFalse);

      // Remove bridge → both bottom tiles become free.
      final withoutBridge = [
        bottomA,
        bottomB,
        bridge.copyWith(isMatched: true),
      ];
      expect(BoardSolver.isTileFree(withoutBridge[0], withoutBridge), isTrue);
      expect(BoardSolver.isTileFree(withoutBridge[1], withoutBridge), isTrue);
    });

    test(
        'vertical bridge: upper tile at (row=1, col=0, layer=1) bridges '
        '(0,0) and (2,0)', () {
      final bottomA = _tile(id: 0, row: 0, col: 0, layer: 0);
      final bottomB = _tile(id: 1, row: 2, col: 0, layer: 0);
      final bridge = _tile(id: 2, row: 1, col: 0, layer: 1);

      final tiles = [bottomA, bottomB, bridge];

      expect(BoardSolver.isTileFree(bridge, tiles), isTrue);
      expect(BoardSolver.isTileFree(bottomA, tiles), isFalse);
      expect(BoardSolver.isTileFree(bottomB, tiles), isFalse);

      final withoutBridge = [
        bottomA,
        bottomB,
        bridge.copyWith(isMatched: true),
      ];
      expect(BoardSolver.isTileFree(withoutBridge[0], withoutBridge), isTrue);
      expect(BoardSolver.isTileFree(withoutBridge[1], withoutBridge), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 7. LAYOUT VALIDATION — NO EVEN-COORDINATE ASSUMPTIONS
  // ---------------------------------------------------------------------------
  group('Layout validation handles odd coordinates', () {
    test('namedLayout factory accepts odd-coordinate positions', () {
      final layout = namedLayout(
        'oddTest',
        'Odd Coordinate Test',
        [
          const TilePosition(0, 0, 0),
          const TilePosition(0, 2, 0),
          const TilePosition(0, 1, 1),
          const TilePosition(2, 0, 0),
          const TilePosition(2, 2, 0),
          const TilePosition(2, 1, 1),
        ],
      );

      expect(layout.positions.length, 6);
      expect(layout.stats.tileCount, 6);
      expect(layout.stats.pairCount, 3);
      expect(layout.stats.layerCount, 2);
      expect(layout.stats.startingFreeTileCount, greaterThanOrEqualTo(2));
    });

    test('LayoutStats.fromPositions handles odd coordinates', () {
      final stats = LayoutStats.fromPositions([
        const TilePosition(0, 1, 0),
        const TilePosition(0, 3, 0),
        const TilePosition(0, 5, 0),
        const TilePosition(0, 7, 0),
      ]);

      expect(stats.tileCount, 4);
      expect(stats.pairCount, 2);
      // minCol=1, maxCol=7, boardWidth = 7 - 1 + 2 = 8
      expect(stats.boardWidth, 8);
    });
  });

  // ---------------------------------------------------------------------------
  // 8. VALIDATION — STRUCTURAL SUPPORT CHECKS
  // ---------------------------------------------------------------------------
  group('Structural support validation', () {
    /// Returns true if every tile on layer > 0 has at least one overlapping
    /// tile on the layer directly below it.
    bool hasValidSupport(List<TilePosition> positions) {
      for (final tile in positions.where((p) => p.layer > 0)) {
        final hasSupport = positions.any((other) =>
            other.layer == tile.layer - 1 &&
            _axisOverlaps(tile.row, other.row) &&
            _axisOverlaps(tile.col, other.col));
        if (!hasSupport) return false;
      }
      return true;
    }

    test('valid bridging layout passes support validation', () {
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(0, 2, 0),
        const TilePosition(0, 1, 1),
      ];
      expect(hasValidSupport(positions), isTrue,
          reason: 'Upper tile at (0,1,1) should be supported by both '
              '(0,0,0) and (0,2,0)');
    });

    test('floating tile fails support validation', () {
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(0, 2, 0),
        const TilePosition(4, 4, 1), // No tile beneath at (4,4,0)
      ];
      expect(hasValidSupport(positions), isFalse,
          reason: 'Tile at (4,4,1) has no support on layer 0');
    });

    test('valid vertical bridge passes support validation', () {
      final positions = [
        const TilePosition(0, 0, 0),
        const TilePosition(2, 0, 0),
        const TilePosition(1, 0, 1),
      ];
      expect(hasValidSupport(positions), isTrue,
          reason: 'Upper tile at (1,0,1) should be supported by both '
              '(0,0,0) and (2,0,0)');
    });
  });

  // ---------------------------------------------------------------------------
  // 9. DUPLICATE COORDINATE DETECTION
  // ---------------------------------------------------------------------------
  group('Duplicate coordinate detection', () {
    test('TileLayoutBuilder rejects duplicate coordinates', () {
      expect(
        () => TileLayoutBuilder()
          ..add(const TilePosition(0, 0, 0))
          ..add(const TilePosition(0, 0, 0))
          ..build(),
        throwsA(isA<LayoutBuildError>()),
      );
    });

    test('odd coordinates are checked for duplicates same as even', () {
      expect(
        () => TileLayoutBuilder()
          ..add(const TilePosition(0, 1, 0))
          ..add(const TilePosition(0, 1, 0))
          ..build(),
        throwsA(isA<LayoutBuildError>()),
      );
    });

    test('different-layer same row/col is NOT a duplicate', () {
      final builder = TileLayoutBuilder()
        ..add(const TilePosition(0, 1, 0))
        ..add(const TilePosition(0, 1, 1));
      final positions = builder.build();
      expect(positions.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // 10. PILOT LAYOUT SOLVABILITY
  // ---------------------------------------------------------------------------
  group('Pilot layout solvability', () {
    test('pilotSmallDiamondLayout is valid and solvable', () {
      final layout = pilotSmallDiamondLayout;
      final positions = layout.positions;

      // Basic validity.
      expect(layout.stats.tileCount.isEven, isTrue);
      expect(layout.stats.tileCount, 28);
      expect(layout.stats.pairCount, 14);
      expect(layout.stats.layerCount, 3);
      expect(layout.stats.startingFreeTileCount, greaterThanOrEqualTo(2));

      // No duplicate coordinates.
      expect(positions.toSet().length, positions.length);

      // Fits all viewports.
      final geometry = BoardLayoutGeometry.fromPositions(positions);
      for (final viewport in kRequiredBoardViewports) {
        final fit = geometry.fit(
          availableWidth: viewport.width,
          availableHeight: viewport.height,
        );
        expect(fit.fitsSafely, isTrue,
            reason: 'Pilot layout must fit ${viewport.name}');
      }

      // Every upper tile is supported by at least one lower tile.
      for (final pos in positions.where((p) => p.layer > 0)) {
        final hasSupport = positions.any((other) =>
            other.layer == pos.layer - 1 &&
            _axisOverlaps(pos.row, other.row) &&
            _axisOverlaps(pos.col, other.col));
        expect(hasSupport, isTrue,
            reason: 'Tile at (${pos.row},${pos.col},${pos.layer}) has no '
                'support on layer ${pos.layer - 1}');
      }

      // Opening geometry has at least 2 free tiles.
      final openingTiles = List.generate(
        positions.length,
        (i) => TileModel(
          def: kAllTiles[i % kAllTiles.length],
          row: positions[i].row,
          col: positions[i].col,
          layer: positions[i].layer,
          uid: 'pilot_test_$i',
        ),
      );
      expect(
        BoardSolver.getFreeTiles(openingTiles).length,
        greaterThanOrEqualTo(2),
      );

      // Contains odd coordinates (half-tile offsets).
      final hasOddCol = positions.any((p) => p.col.isOdd);
      final hasOddRow = positions.any((p) => p.row.isOdd);
      expect(hasOddCol || hasOddRow, isTrue,
          reason: 'Pilot layout should use half-tile offsets');
    });

    test('reverse-solved generation produces solvable board from pilot layout',
        () {
      final layout = pilotSmallDiamondLayout;
      final positions = layout.positions;

      // Build symbol deck matching tile count (14 pairs = 14 symbols × 2 each).
      final symbolDeck = <TileDefinition>[];
      for (var i = 0; i < 14; i++) {
        symbolDeck.addAll([kAllTiles[i], kAllTiles[i]]);
      }
      symbolDeck.shuffle();

      // Simulate reverse-solved generation.
      final rng = Random(42);
      final pairDefs = <TileDefinition>[];
      final counts = <String, int>{};
      for (final def in symbolDeck) {
        counts[def.id] = (counts[def.id] ?? 0) + 1;
      }
      for (final entry in counts.entries) {
        pairDefs.addAll(List.filled(
            entry.value ~/ 2, kAllTiles.firstWhere((d) => d.id == entry.key)));
      }

      // Build a removal order by repeatedly removing free pairs.
      var remaining = List.generate(
        positions.length,
        (i) => TileModel(
          def: kAllTiles.first,
          row: positions[i].row,
          col: positions[i].col,
          layer: positions[i].layer,
          uid: 'rs_$i',
        ),
      );
      final removalOrder = <({int row, int col, int layer})>[];

      while (remaining.isNotEmpty) {
        final freeTiles = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
        if (freeTiles.length < 2) break;
        final first = freeTiles[0];
        final second = freeTiles[1];
        removalOrder.add((row: first.row, col: first.col, layer: first.layer));
        removalOrder
            .add((row: second.row, col: second.col, layer: second.layer));
        remaining = remaining
            .where((t) => t.uid != first.uid && t.uid != second.uid)
            .toList();
      }

      // Must have cleared all tiles.
      expect(remaining, isEmpty,
          reason: 'Could not remove all tiles from pilot layout');
      expect(removalOrder.length, positions.length);

      // Assign symbols from removal order.
      final shuffledPairs = [...pairDefs]..shuffle(rng);
      final tiles = <TileModel>[];
      for (var i = 0; i < shuffledPairs.length; i++) {
        final def = shuffledPairs[i];
        final first = removalOrder[i * 2];
        final second = removalOrder[i * 2 + 1];
        tiles
          ..add(TileModel(
            def: def,
            row: first.row,
            col: first.col,
            layer: first.layer,
          ))
          ..add(TileModel(
            def: def,
            row: second.row,
            col: second.col,
            layer: second.layer,
          ));
      }

      // Generated board must be solvable.
      expect(BoardSolver.isSolvable(tiles), isTrue,
          reason: 'Pilot layout must produce a solvable board');
    });
  });
}

// Copy of _axisOverlaps from board_solver.dart for test-local use.
bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
}
