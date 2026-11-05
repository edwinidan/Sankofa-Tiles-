import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/chapter_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_321_360_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import '../tool/levels_201_240_bulk_analysis.dart';

void main() {
  test('40 production boards retain chapters 17 and 18 as the campaign expands',
      () {
    expect(kImplementedCampaignLevelCount, 380);
    expect(kImplementedFinalLevelId, 380);
    expect(kPlannedCampaignLevelCount, 400);
    expect(getLevelById(381), isNull);
    expect(kLevels.map((level) => level.id),
        orderedEquals(List.generate(380, (index) => index + 1)));
    expect(kLevels321To360Designs, hasLength(40));
    expect(kLevels321To360Designs.where((board) => board.isBreather),
        hasLength(8));
    expect(kLevels321To360Designs.where((board) => board.isShowcase),
        hasLength(8));
    for (final board in kLevels321To360Designs) {
      final level = getLevelById(board.level)!;
      expect(level.namedLayout, same(board.layout));
      expect(level.unlockRequirement, board.level - 1);
      expect(level.name, board.name);
      expect(level.chapter, board.chapterTitle);
      expect(chapterForLevel(board.level).index, board.chapter);
      expect(level.tileIds.toSet(), hasLength(level.symbolPoolSize));
      expect(level.symbolCopyCounts.fold<int>(0, (a, b) => a + b),
          level.tileCount);
    }
    expect(chapterForLevel(321).levels, hasLength(20));
    expect(chapterForLevel(341).levels, hasLength(20));
    expect(isChapterFinalLevel(340), isTrue);
    expect(isChapterFinalLevel(360), isTrue);
  });

  test(
      'every board has broad masses, supported stacks, and readable gameplay fit',
      () {
    for (final board in kLevels321To360Designs) {
      final validation = validateLayout(board.layout, minimumOpeningTiles: 10);
      expect(validation.issues, isEmpty,
          reason:
              'L${board.level}: ${validation.issues.map((i) => i.message).join('; ')}');
      expect(board.layout.stats.layerCount, 3);
      expect(board.layout.stats.tileCount, inInclusiveRange(48, 96));
      // Broad runs on the two main layers rule out one-tile towers/bridges.
      for (final row in board.baseMask) {
        for (final run in RegExp(r'X+').allMatches(row)) {
          expect(run.group(0)!.length, greaterThanOrEqualTo(2),
              reason: 'L${board.level}: thin row $row');
        }
      }
      final bulk = analyzeBulk(board.layout);
      expect(bulk.classification, BulkClass.bulky, reason: 'L${board.level}');
      final geometry =
          BoardLayoutGeometry.fromPositions(board.layout.positions);
      for (final viewport in kRequiredBoardViewports) {
        final fit = geometry.fit(
            availableWidth: viewport.width, availableHeight: viewport.height);
        expect(fit.fitsSafely, isTrue,
            reason: 'L${board.level} on ${viewport.name}: ${fit.tileWidth}');
      }
    }
  });

  test('new boards avoid near clones throughout the entire campaign', () {
    for (final board in kLevels321To360Designs) {
      for (final other in kLevels.where((level) => level.id != board.level)) {
        expect(compareLayoutSilhouettes(board.layout, other.namedLayout).score,
            lessThan(.90),
            reason: 'L${board.level} / L${other.id}');
      }
    }
  });

  for (final candidate in kLevels321To360Designs) {
    test('L${candidate.level} generates and solves 100 seeds with safe choices',
        () {
      final minimum = candidate.isShowcase
          ? 5
          : candidate.isBreather
              ? 4
              : 3;
      for (var seed = 0; seed < 100; seed++) {
        final generated = _generate(candidate, seed, minimum);
        expect(generated, isNotNull, reason: 'L${candidate.level} seed $seed');
        expect(generated!.legal, greaterThanOrEqualTo(minimum));
        expect(generated.safe, greaterThanOrEqualTo(minimum));
        expect(BoardSolver.isSolvable(generated.tiles), isTrue,
            reason: 'L${candidate.level} seed $seed');
        expect(
            generated.tiles
                .map((tile) => '${tile.row}:${tile.col}:${tile.layer}')
                .toSet(),
            equals(candidate.layout.positions
                .map((p) => '${p.row}:${p.col}:${p.layer}')
                .toSet()));
      }
    });
  }
}

typedef _Generated = ({
  List<TileModel> tiles,
  int attempts,
  int legal,
  int safe,
});

_Generated? _generate(
  CampaignBoardDesign candidate,
  int seed,
  int minimumPairs,
) {
  final random = Random(seed);
  final positions = candidate.layout.positions;
  for (var attempt = 1; attempt <= 250; attempt++) {
    var remaining = <TileModel>[
      for (var index = 0; index < positions.length; index++)
        TileModel(
          uid: 'r${attempt}_$index',
          def: kAllTiles.first,
          row: positions[index].row,
          col: positions[index].col,
          layer: positions[index].layer,
        ),
    ];
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(random);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final removed = {free[0].uid, free[1].uid};
      remaining =
          remaining.where((tile) => !removed.contains(tile.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    final counts = candidate.symbolPlan.copyCountsForTileCount(order.length);
    final definitions = <TileDefinition>[];
    for (var index = 0; index < counts.length; index++) {
      definitions.addAll(
        List.filled(
            counts[index],
            kAllTiles.firstWhere((tile) =>
                tile.id == getLevelById(candidate.level)!.tileIds[index])),
      );
    }
    final generated = [
      for (var index = 0; index < order.length; index++)
        TileModel(
          uid: 'g$index',
          def: definitions[index],
          row: order[index].row,
          col: order[index].col,
          layer: order[index].layer,
        ),
    ];
    final legal = BoardSolver.findAvailableMatchingPairs(generated);
    if (legal.length < minimumPairs) continue;
    final safe = legal
        .where((pair) => BoardSolver.isSafeMove(
              generated,
              pair.first,
              pair.second,
              maxSearchNodes: 25000,
            ))
        .length;
    if (safe < minimumPairs) continue;
    return (
      tiles: generated,
      attempts: attempt,
      legal: legal.length,
      safe: safe,
    );
  }
  return null;
}
