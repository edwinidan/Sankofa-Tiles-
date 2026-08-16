import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/chapter_data.dart';
import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

import '../tool/levels_201_240_bulk_analysis.dart';
import '../tool/levels_81_160_visual_analysis.dart';

void main() {
  test('human-approved Levels 201-240 signatures are frozen', () {
    const expected = <int, int>{
      201: 4170019391,
      202: 947696718,
      203: 594760393,
      204: 2543445373,
      205: 966061273,
      206: 4221629122,
      207: 4196980353,
      208: 3787606130,
      209: 3291677559,
      210: 3431364856,
      211: 1988032632,
      212: 3154111884,
      213: 269878294,
      214: 941856897,
      215: 2259476902,
      216: 2088196681,
      217: 1124340873,
      218: 2352920899,
      219: 3094933285,
      220: 588547095,
      221: 2186108095,
      222: 686480789,
      223: 3041645923,
      224: 1517723457,
      225: 2013843733,
      226: 81027112,
      227: 2927096191,
      228: 3562658226,
      229: 3899773812,
      230: 2315596393,
      231: 1428466664,
      232: 1209096597,
      233: 2906048808,
      234: 3013977599,
      235: 1414615048,
      236: 3106811640,
      237: 578655126,
      238: 1075593026,
      239: 1432364313,
      240: 1142337356,
    };
    for (final candidate in kLevels201To240Candidates) {
      expect(
        _candidateSignature(candidate),
        expected[candidate.level],
        reason: 'Level ${candidate.level} changed after human approval',
      );
    }
  });

  test('201-240 catalogue is complete, unique, and exactly production-assigned',
      () {
    expect(kLevels201To240Candidates, hasLength(40));
    expect(
      kLevels201To240Candidates.map((candidate) => candidate.level),
      orderedEquals(List.generate(40, (index) => index + 201)),
    );
    expect(
      kLevels201To240Candidates.map((candidate) => candidate.layout.id).toSet(),
      hasLength(40),
    );
    expect(
      kLevels201To240Candidates.map((candidate) => candidate.family).toSet(),
      hasLength(40),
    );
    expect(kImplementedFinalLevelId, 280);
    expect(kLevels, hasLength(280));
    for (final candidate in kLevels201To240Candidates) {
      final production = getLevelById(candidate.level)!;
      expect(production.name, candidate.proposedName);
      expect(production.layoutName, candidate.layout.id);
      expect(production.layout, orderedEquals(candidate.layout.positions));
      expect(production.tileCount, candidate.layout.stats.tileCount);
      expect(
        chapterForLevel(production.id).index,
        production.id <= 220 ? 11 : 12,
      );
      expect(
        production.symbolCopyCounts.fold<int>(0, (sum, value) => sum + value),
        production.tileCount,
      );
      expect(candidate.features, hasLength(greaterThanOrEqualTo(2)));
    }
    expect(getLevelById(241), isNotNull);
  });

  test('bulky redesign preserves identity while replacing every footprint', () {
    expect(kLevels201To240LegacyCandidates, hasLength(40));
    for (var index = 0; index < kLevels201To240Candidates.length; index++) {
      final current = kLevels201To240Candidates[index];
      final legacy = kLevels201To240LegacyCandidates[index];
      expect(current.level, legacy.level);
      expect(current.proposedName, legacy.proposedName);
      expect(current.family, legacy.family);
      expect(
          current.symbolPlan.symbolPoolSize, legacy.symbolPlan.symbolPoolSize);
      expect(
        legacy.symbolPlan.copyCountsForTileCount(
          current.layout.stats.tileCount,
        ),
        current.symbolPlan.copyCountsForTileCount(
          current.layout.stats.tileCount,
        ),
      );
      expect(current.difficultyCategory, legacy.difficultyCategory);
      expect(current.isBreather, legacy.isBreather);
      expect(current.layout.id, isNot(legacy.layout.id));
      expect(
        current.layout.positions,
        isNot(orderedEquals(legacy.layout.positions)),
        reason: 'level ${current.level}',
      );
    }
  });

  test('batch fullness shifts from thin portrait to bulky portrait', () {
    Map<BulkClass, int> distribution(
      List<ExpansionLayoutCandidate> candidates,
    ) {
      final counts = {for (final value in BulkClass.values) value: 0};
      for (final candidate in candidates) {
        final category = analyzeBulk(candidate.layout).classification;
        counts[category] = counts[category]! + 1;
      }
      return counts;
    }

    final old = distribution(kLevels201To240LegacyCandidates);
    final current = distribution(kLevels201To240Candidates);
    final solidRectangles = kLevels201To240Candidates
        .where((candidate) =>
            analyzeBulk(candidate.layout).coarse.coarseClass ==
            'Solid rectangle')
        .map((candidate) => candidate.level)
        .toList();
    expect(solidRectangles, isEmpty);
    final adjacentCoarseViolations = <String>[];
    for (var index = 0; index < kLevels201To240Candidates.length - 1; index++) {
      final first = kLevels201To240Candidates[index];
      final second = kLevels201To240Candidates[index + 1];
      final similarity = compareCoarseSilhouettes(
        analyzeBulk(first.layout).coarse,
        analyzeBulk(second.layout).coarse,
        familyA: first.family,
        familyB: second.family,
      ).score;
      if (similarity >= .78) {
        adjacentCoarseViolations.add(
          '${first.level}/${second.level}=${similarity.toStringAsFixed(3)}',
        );
      }
    }
    expect(adjacentCoarseViolations, isEmpty);
    expect(current[BulkClass.thin]!, lessThan(old[BulkClass.thin]!));
    expect(current[BulkClass.thin]!, lessThanOrEqualTo(4));
    expect(current[BulkClass.bulky]!, greaterThanOrEqualTo(24));
    for (final level in kLevels201To240Finales) {
      final candidate = kLevels201To240Candidates[level - 201];
      expect(analyzeBulk(candidate.layout).classification, BulkClass.bulky);
    }
  });

  test('Level 240 is a distinct monumental finale beside Level 220', () {
    final level220 = analyzeBulk(kLevels201To240Candidates[19].layout);
    final level240 = analyzeBulk(kLevels201To240Candidates[39].layout);
    final comparison = compareCoarseSilhouettes(
      level220.coarse,
      level240.coarse,
      familyA: 'Horizon palace',
      familyB: 'Living archive',
    );
    expect(level240.classification, BulkClass.bulky);
    expect(level240.coarse.holeCount, greaterThanOrEqualTo(3));
    expect(level240.coarse.widthOccupancy, inInclusiveRange(.76, .82));
    expect(level240.coarse.heightOccupancy, inInclusiveRange(.72, .80));
    expect(comparison.score, lessThan(.78));
  });

  test('all candidates pass structure, support, symbol, and viewport gates',
      () {
    for (final candidate in kLevels201To240Candidates) {
      final validation = validateLayout(
        candidate.layout,
        minimumOpeningTiles:
            kLevels201To240Finales.contains(candidate.level) ? 10 : 6,
      );
      expect(
        validation.issues,
        isEmpty,
        reason: '${candidate.level}: '
            '${validation.issues.map((issue) => issue.message).join('; ')}',
      );
      expect(validation.unsupportedTileCount, 0);
      expect(candidate.layout.stats.layerCount, 3);
      expect(candidate.layout.stats.tileCount.isEven, isTrue);
      final coordinates = candidate.layout.positions
          .map(
              (position) => '${position.row}:${position.col}:${position.layer}')
          .toSet();
      expect(coordinates, hasLength(candidate.layout.stats.tileCount));
      final copies = candidate.symbolPlan
          .copyCountsForTileCount(candidate.layout.stats.tileCount);
      expect(
        copies.fold<int>(0, (sum, value) => sum + value),
        candidate.layout.stats.tileCount,
      );
      expect(copies.every((value) => value.isEven), isTrue);

      final geometry =
          BoardLayoutGeometry.fromPositions(candidate.layout.positions);
      final standard = geometry.fit(availableWidth: 374, availableHeight: 804);
      expect(standard.tileWidth, greaterThanOrEqualTo(52),
          reason: 'level ${candidate.level}');
      for (final viewport in const [
        (344.0, 600.0),
        (374.0, 804.0),
        (414.0, 892.0),
      ]) {
        expect(
          geometry
              .fit(availableWidth: viewport.$1, availableHeight: viewport.$2)
              .fitsBounds,
          isTrue,
          reason: '${candidate.level} at $viewport',
        );
      }
    }
  });

  test('candidate geometry is unique and avoids obvious production clones', () {
    for (var index = 0; index < kLevels201To240Candidates.length; index++) {
      final candidate = kLevels201To240Candidates[index];
      for (var otherIndex = index + 1;
          otherIndex < kLevels201To240Candidates.length;
          otherIndex++) {
        final other = kLevels201To240Candidates[otherIndex];
        expect(candidate.layout.positions,
            isNot(orderedEquals(other.layout.positions)),
            reason: '${candidate.level}/${other.level}');
        if (otherIndex == index + 1) {
          expect(
            compareLayoutSilhouettes(candidate.layout, other.layout).score,
            lessThan(.78),
            reason: 'adjacent ${candidate.level}/${other.level}',
          );
        }
      }
      for (final production in kLevels.take(200)) {
        expect(
          compareLayoutSilhouettes(candidate.layout, production.namedLayout)
              .score,
          lessThan(.90),
          reason: 'candidate ${candidate.level}/production ${production.id}',
        );
      }
    }
  });

  for (final candidate in kLevels201To240Candidates) {
    test('${candidate.layout.id} generates and solves 100 seeds', () {
      final minimum = kLevels201To240Finales.contains(candidate.level) ? 5 : 3;
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

  test('candidate preview exports are complete, sized, and nonblank', () {
    const directory = 'artifacts/layout-previews/levels-201-240-candidates';
    for (final candidate in kLevels201To240Candidates) {
      for (final suffix in const ['390x844', 'diagnostic', 'silhouette']) {
        _expectPng(File('$directory/${candidate.layout.id}_$suffix.png'),
            width: 390, height: 844);
      }
      if (kLevels201To240WideOrBorderline.contains(candidate.level)) {
        _expectPng(File('$directory/${candidate.layout.id}_360x640.png'),
            width: 360, height: 640);
        _expectPng(File('$directory/${candidate.layout.id}_430x932.png'),
            width: 430, height: 932);
      }
    }
    for (final name in const [
      'levels-201-210-contact-sheet.png',
      'levels-211-220-contact-sheet.png',
      'levels-221-230-contact-sheet.png',
      'levels-231-240-contact-sheet.png',
      'chapter-11-overview.png',
      'chapter-12-overview.png',
      'levels-201-240-visual-overview.png',
      'levels-201-240-silhouette-overview.png',
      'coarse-classification-overview.png',
      'envelope-distribution-overview.png',
      'levels-181-240-comparison.png',
      'finale-comparison-levels-200-220-240.png',
      'levels-201-240-bulky-portrait-overview.png',
      'levels-201-240-bulky-silhouette-overview.png',
      'old-vs-new-bulk-silhouette-comparison.png',
      'bulk-fullness-distribution.png',
      'breather-boards.png',
      'showcase-boards.png',
    ]) {
      _expectPng(File('$directory/$name'));
    }
  });
}

int _candidateSignature(ExpansionLayoutCandidate candidate) {
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
  ExpansionLayoutCandidate candidate,
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

void _expectPng(File file, {int? width, int? height}) {
  expect(file.existsSync(), isTrue, reason: file.path);
  expect(file.lengthSync(), greaterThan(10000), reason: file.path);
  final decoded = image.decodePng(file.readAsBytesSync());
  expect(decoded, isNotNull, reason: file.path);
  if (width != null) expect(decoded!.width, width, reason: file.path);
  if (height != null) expect(decoded!.height, height, reason: file.path);
}
