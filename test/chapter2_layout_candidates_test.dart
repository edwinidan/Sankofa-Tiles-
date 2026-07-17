import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/chapter2_layout_data.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  test('Chapter 2 production layouts are portrait and structurally valid', () {
    expect(kChapter2LayoutCandidates, hasLength(20));
    for (final c in kChapter2LayoutCandidates) {
      expect(getLevelById(c.level)!.layoutName, c.layout.id);
      final v = validateLayout(c.layout, minimumOpeningTiles: 4);
      expect(v.issues, isEmpty,
          reason:
              '${c.layout.id}: ${v.issues.map((e) => e.message).join(';')}');
      final g = BoardLayoutGeometry.fromPositions(c.layout.positions);
      final f = g.fit(availableWidth: 374, availableHeight: 804);
      expect(f.tileWidth, greaterThanOrEqualTo(52), reason: c.layout.id);
      expect(f.boardHeight / 804, inInclusiveRange(.60, .80),
          reason: c.layout.id);
      expect(f.boardWidth / 374, lessThanOrEqualTo(.85), reason: c.layout.id);
    }
  });
  test('Chapter 2 adjacent silhouettes stay below the warning threshold', () {
    for (var i = 0; i < kChapter2LayoutCandidates.length - 1; i++) {
      final a = kChapter2LayoutCandidates[i];
      final b = kChapter2LayoutCandidates[i + 1];
      final similarity = compareLayoutSilhouettes(a.layout, b.layout);
      expect(similarity.score, lessThan(.90),
          reason: 'Levels ${a.level}/${b.level}: ${similarity.score}');
      expect(a.layout.positions, isNot(equals(b.layout.positions)));
    }
  });
  for (final c in kChapter2LayoutCandidates) {
    test('${c.layout.id} solves 100 seeds', () {
      final level = getLevelById(c.level)!;
      for (var seed = 0; seed < 100; seed++) {
        final minimum = c.level == 40
            ? 5
            : const {28, 30}.contains(c.level)
                ? 4
                : 3;
        final tiles = _generate(c.layout.positions, level, seed, minimum);
        expect(tiles, isNotNull, reason: 'seed=$seed');
        expect(BoardSolver.isSolvable(tiles!), isTrue, reason: 'seed=$seed');
        final legal = BoardSolver.findAvailableMatchingPairs(tiles);
        final safe = legal
            .where((p) => BoardSolver.isSafeMove(tiles, p.first, p.second,
                maxSearchNodes: 25000))
            .length;
        expect(legal.length, greaterThanOrEqualTo(minimum),
            reason: 'legal seed=$seed');
        expect(safe, greaterThanOrEqualTo(minimum), reason: 'safe seed=$seed');
      }
    });
  }
}

List<TileModel>? _generate(List<TilePosition> positions, LevelDefinition level,
    int seed, int minimumOpeningPairs) {
  final rng = Random(seed);
  for (var attempt = 0; attempt < 100; attempt++) {
    var remaining = <TileModel>[
      for (var i = 0; i < positions.length; i++)
        TileModel(
            uid: 'r${attempt}_$i',
            def: kAllTiles.first,
            row: positions[i].row,
            col: positions[i].col,
            layer: positions[i].layer)
    ];
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final gone = {free[0].uid, free[1].uid};
      remaining = remaining.where((t) => !gone.contains(t.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    final counts = level.symbolPlan.copyCountsForTileCount(order.length);
    final defs = <TileDefinition>[];
    for (var i = 0; i < counts.length; i++) {
      defs.addAll(List.filled(counts[i], kAllTiles[i % kAllTiles.length]));
    }
    final generated = [
      for (var i = 0; i < order.length; i++)
        TileModel(
            uid: 'g$i',
            def: defs[i],
            row: order[i].row,
            col: order[i].col,
            layer: order[i].layer)
    ];
    final legal = BoardSolver.findAvailableMatchingPairs(generated);
    if (legal.length < minimumOpeningPairs) continue;
    final safe = legal
        .where((p) => BoardSolver.isSafeMove(generated, p.first, p.second,
            maxSearchNodes: 25000))
        .length;
    if (safe < minimumOpeningPairs) continue;
    return generated;
  }
  return null;
}
