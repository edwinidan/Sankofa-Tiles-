import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/batch_b_layout_data.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  test('Batch B candidates are isolated and structurally valid', () {
    expect(kBatchBLayoutCandidates, hasLength(15));
    expect(
      kBatchBLayoutCandidates.map((candidate) => candidate.intendedLevel),
      orderedEquals(List.generate(15, (index) => index + 6)),
    );
    final productionIds = kLevels.map((level) => level.layoutName).toSet();
    final coordinateHashes = <String>{};
    final validationMessages = <String>[];
    for (final candidate in kBatchBLayoutCandidates) {
      final layout = candidate.layout;
      expect(productionIds, contains(layout.id));
      expect(layout.stats.tileCount, inInclusiveRange(32, 68));
      expect(layout.stats.layerCount, 3);
      expect(layout.stats.startingFreeTileCount, greaterThanOrEqualTo(4));
      expect(layout.positions.any((p) => p.row.isOdd || p.col.isOdd), isTrue);
      final validation = validateLayout(layout, minimumOpeningTiles: 4);
      if (validation.issues.isNotEmpty) {
        validationMessages.add(
          '${layout.id}: '
          '${validation.issues.map((issue) => issue.message).join('; ')}',
        );
      }
      final hash =
          layout.positions.map((p) => '${p.row}:${p.col}:${p.layer}').join('|');
      expect(coordinateHashes.add(hash), isTrue,
          reason: '${layout.id} duplicates another candidate');
    }
    expect(validationMessages, isEmpty, reason: validationMessages.join('\n'));
  });

  test('production Levels 6-20 use the frozen portrait assignments', () {
    const expected = {
      6: 'batchBOpenCourtyard01',
      7: 'batchBRiverPath01',
      8: 'batchBTempleGate01',
      9: 'batchBGatheringWings01',
      10: 'batchBTwinBridge01',
      11: 'batchBSmallTurtle01',
      12: 'batchBButterfly01',
      13: 'batchBShrineSteps01',
      14: 'batchBWisdomStaircase01',
      15: 'batchBCrown01',
      16: 'batchBOpenRing01',
      17: 'batchBRoyalStool01',
      18: 'batchBAncestralGate01',
      19: 'batchBTwinTowers01',
      20: 'batchBRaisedCourtyard01',
    };
    for (final entry in expected.entries) {
      expect(getLevelById(entry.key)!.layoutName, entry.value);
    }
    expect(
        kLevels
            .where((level) => level.id > 20)
            .any((level) => level.layoutName.startsWith('batchB')),
        isFalse);
  });

  test('portrait anchor layouts meet viewport occupancy and tile-size gates',
      () {
    const anchorLevels = {6, 8, 13, 14, 16, 18, 20};
    for (final candidate in kBatchBLayoutCandidates
        .where((candidate) => anchorLevels.contains(candidate.intendedLevel))) {
      final geometry =
          BoardLayoutGeometry.fromPositions(candidate.layout.positions);
      final standard = geometry.fit(
        availableWidth: 374,
        availableHeight: 804,
      );
      final widthOccupancy = standard.boardWidth / 374;
      final heightOccupancy = standard.boardHeight / 804;
      expect(standard.tileWidth, greaterThanOrEqualTo(44),
          reason: candidate.layout.id);
      expect(widthOccupancy, inInclusiveRange(0.50, 0.85),
          reason: candidate.layout.id);
      expect(heightOccupancy, inInclusiveRange(0.60, 0.80),
          reason: candidate.layout.id);
      expect(geometry.heightInTileUnits, greaterThan(geometry.widthInTileUnits),
          reason: candidate.layout.id);

      final compact = geometry.fit(
        availableWidth: 344,
        availableHeight: 600,
      );
      expect(compact.tileWidth, greaterThanOrEqualTo(40),
          reason: candidate.layout.id);
      expect(compact.fitsBounds, isTrue, reason: candidate.layout.id);
    }
  });

  for (final candidate in kBatchBLayoutCandidates) {
    test('${candidate.layout.id} generates and solves for 100 seeds', () {
      final level = getLevelById(candidate.intendedLevel)!;
      for (var seed = 0; seed < 100; seed++) {
        final result = _reverseSolved(
          candidate.layout,
          level,
          seed,
        );
        expect(result.tiles, isNotNull, reason: 'seed=$seed');
        final tiles = result.tiles!;
        expect(BoardSolver.isSolvable(tiles), isTrue, reason: 'seed=$seed');
        final legal = BoardSolver.findAvailableMatchingPairs(tiles);
        final safe = legal
            .where((pair) => BoardSolver.isSafeMove(
                  tiles,
                  pair.first,
                  pair.second,
                  maxSearchNodes: 25000,
                ))
            .length;
        final minimum = candidate.intendedLevel <= 15 ? 2 : 1;
        expect(legal.length, greaterThanOrEqualTo(minimum),
            reason: 'legal seed=$seed');
        expect(safe, greaterThanOrEqualTo(minimum), reason: 'safe seed=$seed');
      }
    });
  }
}

({List<TileModel>? tiles, int attempts}) _reverseSolved(
  NamedLayout layout,
  LevelDefinition level,
  int seed,
) {
  final rng = Random(seed);
  for (var attempt = 1; attempt <= 100; attempt++) {
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

    final copyCounts =
        level.symbolPlan.copyCountsForTileCount(layout.positions.length);
    final definitions = <TileDefinition>[];
    for (var symbol = 0; symbol < copyCounts.length; symbol++) {
      definitions.addAll(
        List.filled(copyCounts[symbol], kAllTiles[symbol % kAllTiles.length]),
      );
    }
    return (
      attempts: attempt,
      tiles: [
        for (var i = 0; i < order.length; i++)
          TileModel(
            uid: 'generated_$i',
            def: definitions[i],
            row: order[i].row,
            col: order[i].col,
            layer: order[i].layer,
          ),
      ],
    );
  }
  return (tiles: null, attempts: 100);
}
