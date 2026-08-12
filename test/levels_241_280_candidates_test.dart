import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_241_280_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

import '../tool/levels_201_240_bulk_analysis.dart';
import '../tool/levels_81_160_visual_analysis.dart';

void main() {
  test('Levels 241-280 human-review candidate signatures are stable', () {
    const expected = <int, int>{
      241: 2501970009,
      242: 4122648015,
      243: 1582914199,
      244: 2137017509,
      245: 2466806732,
      246: 1439721694,
      247: 2564070301,
      248: 3496932863,
      249: 2440584906,
      250: 1492084329,
      251: 2475214732,
      252: 1521322317,
      253: 1510584380,
      254: 344159664,
      255: 3358774263,
      256: 3010846297,
      257: 1941680656,
      258: 2313984766,
      259: 4239440079,
      260: 678908562,
      261: 2633056046,
      262: 3410104095,
      263: 2869611891,
      264: 2439651717,
      265: 2901238935,
      266: 1147530254,
      267: 3562867853,
      268: 1626419687,
      269: 3609590293,
      270: 3845634920,
      271: 1314666694,
      272: 1703716220,
      273: 2453481284,
      274: 26248698,
      275: 2108449109,
      276: 2121034698,
      277: 1032844585,
      278: 1768193732,
      279: 3969233314,
      280: 570270175,
    };
    for (final candidate in kLevels241To280Candidates) {
      expect(
        _candidateSignature(candidate),
        expected[candidate.level],
        reason: 'L${candidate.level} changed after review package generation',
      );
    }
  });

  test('production remains frozen at 240 and roadmap candidates are isolated',
      () {
    expect(kLevels, hasLength(240));
    expect(kImplementedCampaignLevelCount, 240);
    expect(kImplementedFinalLevelId, 240);
    expect(kPlannedCampaignLevelCount, 400);
    expect(getLevelById(241), isNull);
    expect(kLevels241To280Candidates, hasLength(40));
    expect(
      kLevels241To280Candidates.map((candidate) => candidate.level),
      orderedEquals(List.generate(40, (index) => 241 + index)),
    );
    for (final candidate in kLevels241To280Candidates) {
      expect(getLevelById(candidate.level), isNull);
    }
  });

  test('two-stage authoring contains the ten required anchors', () {
    expect(kLevels241To280AnchorCandidates, hasLength(10));
    expect(kLevels241To280ComplementCandidates, hasLength(30));
    expect(
      kLevels241To280AnchorCandidates.map((candidate) => candidate.level),
      unorderedEquals(kLevels241To280Anchors),
    );
    expect(
      kLevels241To280AnchorCandidates.every((candidate) => candidate.isAnchor),
      isTrue,
    );
    expect(
      kLevels241To280ComplementCandidates
          .every((candidate) => !candidate.isAnchor),
      isTrue,
    );
  });

  test('chapter identities, families, breathers, and showcases are complete',
      () {
    expect(
      kLevels241To280Candidates.map((candidate) => candidate.family).toSet(),
      hasLength(40),
    );
    expect(
      kLevels241To280Candidates
          .where((candidate) => candidate.chapter == 13)
          .map((candidate) => candidate.level),
      orderedEquals(List.generate(20, (index) => 241 + index)),
    );
    expect(
      kLevels241To280Candidates
          .where((candidate) => candidate.chapter == 14)
          .map((candidate) => candidate.level),
      orderedEquals(List.generate(20, (index) => 261 + index)),
    );
    expect(
      kLevels241To280Candidates
          .where((candidate) => candidate.isBreather)
          .map((candidate) => candidate.level),
      unorderedEquals(kLevels241To280Breathers),
    );
    expect(
      kLevels241To280Candidates
          .where((candidate) => candidate.isShowcase)
          .map((candidate) => candidate.level),
      unorderedEquals(kLevels241To280Showcases),
    );
  });

  test('fullness and envelope distribution meets visual design targets', () {
    final fullness = <String, int>{};
    final widths = <String, int>{'below70': 0, '70to76': 0, '76to82': 0};
    final envelopes = <String, int>{};
    var thin = 0;
    for (final candidate in kLevels241To280Candidates) {
      fullness[candidate.fullnessClass] =
          (fullness[candidate.fullnessClass] ?? 0) + 1;
      final analysis = analyzeBulk(candidate.layout);
      if (analysis.classification == BulkClass.thin) thin++;
      final width = analysis.coarse.widthOccupancy;
      final key = width < .70
          ? 'below70'
          : width < .76
              ? '70to76'
              : '76to82';
      widths[key] = widths[key]! + 1;
      final envelope = '${analysis.coarse.widthOccupancy.toStringAsFixed(3)}/'
          '${analysis.coarse.heightOccupancy.toStringAsFixed(3)}';
      envelopes[envelope] = (envelopes[envelope] ?? 0) + 1;
      expect(analysis.coarse.widthOccupancy, lessThanOrEqualTo(.82));
      expect(analysis.coarse.coarseClass, isNot('Solid rectangle'));
    }
    expect(fullness, {'open-medium': 9, 'full': 14, 'bulky': 17});
    expect(thin, 0);
    expect(widths['below70'], greaterThanOrEqualTo(8));
    expect(widths['70to76'], greaterThanOrEqualTo(10));
    expect(widths['76to82'], greaterThanOrEqualTo(14));
    expect(envelopes.values.reduce(max), lessThanOrEqualTo(6));
  });

  test('all candidate geometry passes structure, support, and viewport gates',
      () {
    for (final candidate in kLevels241To280Candidates) {
      final minimumOpeningTiles =
          kLevels241To280Finales.contains(candidate.level)
              ? 10
              : candidate.level == 241
                  ? 8
                  : 6;
      final validation = validateLayout(
        candidate.layout,
        minimumOpeningTiles: minimumOpeningTiles,
      );
      expect(
        validation.issues,
        isEmpty,
        reason: 'L${candidate.level}: '
            '${validation.issues.map((issue) => issue.message).join('; ')}',
      );
      expect(validation.unsupportedTileCount, 0);
      expect(candidate.layout.stats.layerCount, 3);
      expect(candidate.layout.stats.tileCount.isEven, isTrue);
      expect(
        candidate.layout.positions
            .map((position) =>
                '${position.row}:${position.col}:${position.layer}')
            .toSet(),
        hasLength(candidate.layout.stats.tileCount),
      );
      final copies = candidate.symbolPlan
          .copyCountsForTileCount(candidate.layout.stats.tileCount);
      expect(copies.fold<int>(0, (sum, count) => sum + count),
          candidate.layout.stats.tileCount);
      expect(copies.every((count) => count.isEven), isTrue);
      final geometry =
          BoardLayoutGeometry.fromPositions(candidate.layout.positions);
      final standard = geometry.fit(availableWidth: 374, availableHeight: 804);
      expect(standard.tileWidth, greaterThanOrEqualTo(52));
      for (final viewport in const [
        (344.0, 600.0),
        (374.0, 804.0),
        (414.0, 892.0),
      ]) {
        final fit = geometry.fit(
          availableWidth: viewport.$1,
          availableHeight: viewport.$2,
        );
        expect(fit.fitsBounds, isTrue,
            reason: 'L${candidate.level} at $viewport');
        expect(fit.tileWidth, greaterThanOrEqualTo(52),
            reason: 'L${candidate.level} at $viewport');
      }
    }
  });

  test('candidate silhouettes are distinct from neighbors and production', () {
    final coarse = {
      for (final candidate in kLevels241To280Candidates)
        candidate.level: analyzeCoarseSilhouette(candidate.layout),
    };
    for (var index = 0; index < kLevels241To280Candidates.length; index++) {
      final candidate = kLevels241To280Candidates[index];
      for (var otherIndex = index + 1;
          otherIndex < kLevels241To280Candidates.length;
          otherIndex++) {
        final other = kLevels241To280Candidates[otherIndex];
        expect(candidate.layout.positions,
            isNot(orderedEquals(other.layout.positions)));
      }
      if (index < kLevels241To280Candidates.length - 1) {
        final next = kLevels241To280Candidates[index + 1];
        final score = compareCoarseSilhouettes(
          coarse[candidate.level]!,
          coarse[next.level]!,
          familyA: candidate.family,
          familyB: next.family,
        ).score;
        expect(score, lessThan(.78),
            reason: '${candidate.level}/${next.level}: $score');
      }
      if (index < 20) {
        final offset = kLevels241To280Candidates[index + 20];
        final score = compareCoarseSilhouettes(
          coarse[candidate.level]!,
          coarse[offset.level]!,
          familyA: candidate.family,
          familyB: offset.family,
        ).score;
        expect(score, lessThanOrEqualTo(.75),
            reason: '${candidate.level}/${offset.level}: $score');
      }
      for (final production in kLevels) {
        expect(
          compareLayoutSilhouettes(candidate.layout, production.namedLayout)
              .score,
          lessThan(.90),
          reason: '${candidate.level}/${production.id}',
        );
      }
    }
    for (var index = 0; index < kLevels241To280Candidates.length - 2; index++) {
      final classes = kLevels241To280Candidates
          .skip(index)
          .take(3)
          .map((candidate) => coarse[candidate.level]!.coarseClass)
          .toSet();
      expect(classes, hasLength(greaterThan(1)),
          reason: '${241 + index}-${243 + index}');
    }
  });

  test('re-entry and finales retain the intended hierarchy', () {
    final level241 = kLevels241To280Candidates.first;
    final level260 = kLevels241To280Candidates[19];
    final level280 = kLevels241To280Candidates.last;
    expect(level241.isBreather, isTrue);
    expect(level241.layout.stats.tileCount, inInclusiveRange(40, 58));
    expect(level260.isShowcase, isTrue);
    expect(level280.isShowcase, isTrue);
    expect(level280.layout.stats.tileCount,
        greaterThanOrEqualTo(level260.layout.stats.tileCount));
    expect(analyzeBulk(level260.layout).classification, BulkClass.bulky);
    expect(analyzeBulk(level280.layout).classification, BulkClass.bulky);
    expect(
      analyzeCoarseSilhouette(level280.layout).holeCount,
      greaterThanOrEqualTo(2),
    );
    expect(
      compareCoarseSilhouettes(
        analyzeCoarseSilhouette(level260.layout),
        analyzeCoarseSilhouette(level280.layout),
        familyA: level260.family,
        familyB: level280.family,
      ).score,
      lessThanOrEqualTo(.75),
    );
  });

  for (final candidate in kLevels241To280Candidates) {
    test('${candidate.layout.id} generates and solves 100 seeds', () {
      final minimum = kLevels241To280Finales.contains(candidate.level)
          ? 5
          : candidate.level == 241
              ? 4
              : 3;
      for (var seed = 0; seed < 100; seed++) {
        final generated = _generate(candidate, seed, minimum);
        expect(generated, isNotNull,
            reason: 'level=${candidate.level} seed=$seed');
        expect(generated!.attempts, lessThanOrEqualTo(250));
        expect(generated.legal, greaterThanOrEqualTo(minimum));
        expect(generated.safe, greaterThanOrEqualTo(minimum));
        expect(generated.legal, greaterThan(1));
        expect(BoardSolver.isSolvable(generated.tiles), isTrue);
        expect(
          generated.tiles
              .map((tile) => '${tile.row}:${tile.col}:${tile.layer}')
              .toSet(),
          equals(candidate.layout.positions
              .map((position) =>
                  '${position.row}:${position.col}:${position.layer}')
              .toSet()),
        );
      }
    });
  }
}

int _candidateSignature(RoadmapLayoutCandidate candidate) {
  final value = [
    candidate.level,
    candidate.layout.id,
    candidate.proposedName,
    candidate.layout.stats.tileCount,
    candidate.layout.positions
        .map((position) => '${position.row}:${position.col}:${position.layer}')
        .join(','),
  ].join('|');
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

typedef _Generated = ({
  List<TileModel> tiles,
  int attempts,
  int legal,
  int safe,
});

_Generated? _generate(
  RoadmapLayoutCandidate candidate,
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
        List.filled(counts[index], kAllTiles[index % kAllTiles.length]),
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
