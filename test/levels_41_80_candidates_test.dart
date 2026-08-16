import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_41_80_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  test('Levels 1-80 stay contiguous and every production assignment generates',
      () {
    expect(kLevels.take(80).map((level) => level.id),
        orderedEquals(List.generate(80, (index) => index + 1)));
    for (final level in kLevels.take(80)) {
      expect(validateLayout(level.namedLayout, minimumOpeningTiles: 4).issues,
          isEmpty,
          reason: 'Level ${level.id}');
      expect(level.symbolCopyCounts.reduce((a, b) => a + b), level.tileCount);
      expect(level.symbolCopyCounts.every((count) => count.isEven), isTrue);
    }
  });

  test(
      'Levels 41-80 production assignments remain exact and structurally valid',
      () {
    expect(kLevels41To80Candidates, hasLength(40));
    expect(kLevels41To80Candidates.map((c) => c.family).toSet().length,
        greaterThanOrEqualTo(24));
    for (final candidate in kLevels41To80Candidates) {
      expect(getLevelById(candidate.level)!.layoutName, candidate.layout.id);
      expect(getLevelById(candidate.level)!.name, candidate.proposedName);
      final validation =
          validateLayout(candidate.layout, minimumOpeningTiles: 4);
      expect(validation.issues, isEmpty,
          reason:
              '${candidate.layout.id}: ${validation.issues.map((e) => e.message).join('; ')}');
      final geometry =
          BoardLayoutGeometry.fromPositions(candidate.layout.positions);
      final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
      expect(fit.tileWidth, greaterThanOrEqualTo(52),
          reason: candidate.layout.id);
      expect(fit.boardHeight / 804, inInclusiveRange(.60, .82),
          reason: candidate.layout.id);
      expect(fit.boardWidth / 374, lessThanOrEqualTo(.85),
          reason: candidate.layout.id);
      final level = getLevelById(candidate.level)!;
      final counts = level.symbolPlan
          .copyCountsForTileCount(candidate.layout.positions.length);
      expect(counts.reduce((a, b) => a + b), candidate.layout.positions.length);
      expect(counts.every((count) => count.isEven), isTrue);
    }
  });

  test('Levels 41-80 adjacent candidates stay below similarity warning', () {
    for (var i = 0; i < kLevels41To80Candidates.length - 1; i++) {
      final a = kLevels41To80Candidates[i];
      final b = kLevels41To80Candidates[i + 1];
      expect(compareLayoutSilhouettes(a.layout, b.layout).score, lessThan(.90),
          reason: 'Levels ${a.level}/${b.level}');
      expect(a.layout.positions, isNot(equals(b.layout.positions)));
    }
  });

  test('Chapter 4 does not repeat the Chapter 3 mask twenty levels later', () {
    for (var index = 0; index < 20; index++) {
      final chapter3 = kLevels41To80Candidates[index];
      final chapter4 = kLevels41To80Candidates[index + 20];
      final similarity =
          compareLayoutSilhouettes(chapter3.layout, chapter4.layout);
      expect(similarity.score, lessThan(.80),
          reason: 'Levels ${chapter3.level}/${chapter4.level}');
      expect(
          chapter3.layout.positions, isNot(equals(chapter4.layout.positions)));
    }
  });

  for (final candidate in kLevels41To80Candidates) {
    test('${candidate.layout.id} generates and solves for 100 seeds', () {
      final level = getLevelById(candidate.level)!;
      final minimumOpeningPairs =
          const {60, 80}.contains(candidate.level) ? 5 : 3;
      for (var seed = 0; seed < 100; seed++) {
        final tiles = _generate(
            candidate.layout.positions, level, seed, minimumOpeningPairs);
        expect(tiles, isNotNull, reason: 'seed=$seed');
        expect(BoardSolver.isSolvable(tiles!), isTrue, reason: 'seed=$seed');
        final legal = BoardSolver.findAvailableMatchingPairs(tiles);
        final safe = legal
            .where((pair) => BoardSolver.isSafeMove(
                tiles, pair.first, pair.second,
                maxSearchNodes: 25000))
            .length;
        expect(legal.length, greaterThanOrEqualTo(minimumOpeningPairs),
            reason: 'legal seed=$seed');
        expect(safe, greaterThanOrEqualTo(minimumOpeningPairs),
            reason: 'safe seed=$seed');
      }
    });
  }
}

List<TileModel>? _generate(List<TilePosition> positions, LevelDefinition level,
    int seed, int minimumOpeningPairs) {
  final rng = Random(seed);
  final maximumAttempts = minimumOpeningPairs >= 5 ? 1000 : 100;
  for (var attempt = 0; attempt < maximumAttempts; attempt++) {
    var remaining = <TileModel>[
      for (var i = 0; i < positions.length; i++)
        TileModel(
          uid: 'r${attempt}_$i',
          def: kAllTiles.first,
          row: positions[i].row,
          col: positions[i].col,
          layer: positions[i].layer,
        ),
    ];
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final gone = {free[0].uid, free[1].uid};
      remaining = remaining.where((tile) => !gone.contains(tile.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    final counts = level.symbolPlan.copyCountsForTileCount(order.length);
    final definitions = <TileDefinition>[];
    for (var i = 0; i < counts.length; i++) {
      definitions
          .addAll(List.filled(counts[i], kAllTiles[i % kAllTiles.length]));
    }
    final generated = [
      for (var i = 0; i < order.length; i++)
        TileModel(
          uid: 'g$i',
          def: definitions[i],
          row: order[i].row,
          col: order[i].col,
          layer: order[i].layer,
        ),
    ];
    final legal = BoardSolver.findAvailableMatchingPairs(generated);
    if (legal.length < minimumOpeningPairs) continue;
    final safe = legal
        .where((pair) => BoardSolver.isSafeMove(
            generated, pair.first, pair.second,
            maxSearchNodes: 25000))
        .length;
    if (safe < minimumOpeningPairs) continue;
    return generated;
  }
  return null;
}
