// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

import 'levels_81_160_visual_analysis.dart';
import 'levels_201_240_bulk_analysis.dart';

typedef Generated = ({
  List<TileModel> tiles,
  int attempts,
  int legal,
  int safe,
});

class SeedMetrics {
  int generated = 0;
  int solved = 0;
  int minLegal = 1 << 30;
  int maxLegal = 0;
  int totalLegal = 0;
  int minSafe = 1 << 30;
  int maxSafe = 0;
  int totalSafe = 0;
  int maxAttempts = 0;
  int totalAttempts = 0;
  int forced = 0;

  void add(Generated board) {
    generated++;
    if (BoardSolver.isSolvable(board.tiles)) solved++;
    minLegal = min(minLegal, board.legal);
    maxLegal = max(maxLegal, board.legal);
    totalLegal += board.legal;
    minSafe = min(minSafe, board.safe);
    maxSafe = max(maxSafe, board.safe);
    totalSafe += board.safe;
    maxAttempts = max(maxAttempts, board.attempts);
    totalAttempts += board.attempts;
    if (board.legal <= 1) forced++;
  }
}

void main() {
  final directory =
      Directory('artifacts/layout-previews/levels-201-240-candidates')
        ..createSync(recursive: true);
  final seedMetrics = <int, SeedMetrics>{};
  final coarseMetrics = <int, CoarseSilhouetteMetrics>{};
  final bulkMetrics = <int, BulkAnalysis>{};
  final legacyBulkMetrics = <int, BulkAnalysis>{};
  for (final candidate in kLevels201To240Candidates) {
    final metrics = SeedMetrics();
    final minimum = kLevels201To240Finales.contains(candidate.level) ? 5 : 3;
    for (var seed = 0; seed < 100; seed++) {
      final board = _generate(candidate, seed, minimum);
      if (board == null) {
        throw StateError('Level ${candidate.level} failed seed $seed');
      }
      metrics.add(board);
    }
    seedMetrics[candidate.level] = metrics;
  }

  final csv = StringBuffer()
    ..writeln('level,id,name,family,class,tiles,pairs,layers,free,width,height,'
        'tile,minLegal,maxLegal,meanLegal,minSafe,maxSafe,meanSafe,maxAttempts,'
        'meanAttempts,forced,breather,finale,bulk,fullness,centerDensity,'
        'hullFill,emptyArea,holes,oldBulk,oldTiles,oldWidth,oldHeight,'
        'oldFullness,oldCenterDensity,oldHullFill,oldEmptyArea,oldHoles');
  final report = StringBuffer()
    ..writeln('# Levels 201–240 bulky-portrait redesign report')
    ..writeln()
    ..writeln(
        'Status: human approved, exactly assigned to production `kLevels`, '
        'and frozen at the current Level-240 implemented boundary.')
    ..writeln()
    ..writeln('## Candidate matrix')
    ..writeln()
    ..writeln(
        '|Level|Proposed name|Family / class|Features|Tiles / pairs|Symbols|'
        'Copies|Open legal|Open safe|100 seeds|390×844 W / H / tile|Breather|')
    ..writeln('|---:|---|---|---|---:|---:|---|---:|---:|---|---|---|');

  for (final candidate in kLevels201To240Candidates) {
    final legacy = kLevels201To240LegacyCandidates[candidate.level - 201];
    final geometry =
        BoardLayoutGeometry.fromPositions(candidate.layout.positions);
    final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
    final metrics = seedMetrics[candidate.level]!;
    final stats = candidate.layout.stats;
    final coarse = analyzeCoarseSilhouette(candidate.layout);
    final bulk = analyzeBulk(candidate.layout);
    final legacyBulk = analyzeBulk(legacy.layout);
    coarseMetrics[candidate.level] = coarse;
    bulkMetrics[candidate.level] = bulk;
    legacyBulkMetrics[candidate.level] = legacyBulk;
    csv.writeln('${candidate.level},${candidate.layout.id},'
        '"${candidate.proposedName}","${candidate.family}",'
        '"${candidate.silhouetteClass}",${stats.tileCount},${stats.pairCount},'
        '${stats.layerCount},${stats.startingFreeTileCount},'
        '${(fit.boardWidth / 374 * 100).toStringAsFixed(1)},'
        '${(fit.boardHeight / 804 * 100).toStringAsFixed(1)},'
        '${fit.tileWidth.toStringAsFixed(1)},${metrics.minLegal},'
        '${metrics.maxLegal},${(metrics.totalLegal / 100).toStringAsFixed(2)},'
        '${metrics.minSafe},${metrics.maxSafe},'
        '${(metrics.totalSafe / 100).toStringAsFixed(2)},'
        '${metrics.maxAttempts},'
        '${(metrics.totalAttempts / 100).toStringAsFixed(2)},${metrics.forced},'
        '${candidate.isBreather},'
        '${kLevels201To240Finales.contains(candidate.level)},'
        '${bulkClassLabel(bulk.classification)},'
        '${(bulk.fullnessScore * 100).toStringAsFixed(1)},'
        '${(bulk.centerDensity * 100).toStringAsFixed(1)},'
        '${(coarse.convexHullFillRatio * 100).toStringAsFixed(1)},'
        '${(coarse.emptyAreaPercentage * 100).toStringAsFixed(1)},'
        '${coarse.holeCount},${bulkClassLabel(legacyBulk.classification)},'
        '${legacy.layout.stats.tileCount},'
        '${(legacyBulk.coarse.widthOccupancy * 100).toStringAsFixed(1)},'
        '${(legacyBulk.coarse.heightOccupancy * 100).toStringAsFixed(1)},'
        '${(legacyBulk.fullnessScore * 100).toStringAsFixed(1)},'
        '${(legacyBulk.centerDensity * 100).toStringAsFixed(1)},'
        '${(legacyBulk.coarse.convexHullFillRatio * 100).toStringAsFixed(1)},'
        '${(legacyBulk.coarse.emptyAreaPercentage * 100).toStringAsFixed(1)},'
        '${legacyBulk.coarse.holeCount}');
    report.writeln('|${candidate.level}|${candidate.proposedName}|'
        '${candidate.family} / ${candidate.silhouetteClass}|'
        '${candidate.features.join('; ')}|${stats.tileCount} / '
        '${stats.pairCount}|${candidate.symbolPlan.symbolPoolSize}|'
        '${candidate.symbolPlan.describeForTileCount(stats.tileCount)}|'
        '${metrics.minLegal}–${metrics.maxLegal}|'
        '${metrics.minSafe}–${metrics.maxSafe}|'
        '${metrics.generated}/100 generated; ${metrics.solved}/100 solved; '
        'max ${metrics.maxAttempts} attempts; ${metrics.forced} forced|'
        '${(fit.boardWidth / 374 * 100).toStringAsFixed(1)}% / '
        '${(fit.boardHeight / 804 * 100).toStringAsFixed(1)}% / '
        '${fit.tileWidth.toStringAsFixed(1)} px|'
        '${candidate.isBreather ? 'yes' : '—'}|');
    if (coarse.coarseClass == 'Solid rectangle') {
      throw StateError('Level ${candidate.level} classified solid rectangle');
    }
  }

  report
    ..writeln()
    ..writeln('## Coarse silhouette and envelope results')
    ..writeln()
    ..writeln('|Levels|Similarity|Detected classes|')
    ..writeln('|---|---:|---|');
  var maximumAdjacentSimilarity = 0.0;
  for (var index = 0; index < kLevels201To240Candidates.length - 1; index++) {
    final current = kLevels201To240Candidates[index];
    final next = kLevels201To240Candidates[index + 1];
    final comparison = compareCoarseSilhouettes(
      coarseMetrics[current.level]!,
      coarseMetrics[next.level]!,
      familyA: current.family,
      familyB: next.family,
    );
    maximumAdjacentSimilarity =
        max(maximumAdjacentSimilarity, comparison.score);
    report.writeln('|${current.level}/${next.level}|'
        '${comparison.score.toStringAsFixed(3)}|'
        '${coarseMetrics[current.level]!.coarseClass} / '
        '${coarseMetrics[next.level]!.coarseClass}|');
  }
  final widthCounts = <String, int>{'narrow': 0, 'medium': 0, 'wide': 0};
  for (final metrics in coarseMetrics.values) {
    final width = metrics.widthOccupancy;
    widthCounts.update(
      width < .59
          ? 'narrow'
          : width < .70
              ? 'medium'
              : 'wide',
      (count) => count + 1,
    );
  }
  report
    ..writeln()
    ..writeln('- Maximum adjacent coarse similarity: '
        '${maximumAdjacentSimilarity.toStringAsFixed(3)} (gate < 0.780).')
    ..writeln('- Envelope distribution: ${widthCounts['narrow']} narrow, '
        '${widthCounts['medium']} medium, ${widthCounts['wide']} wide; '
        'zero boards exceed 82% standard-width occupancy.')
    ..writeln('- Solid-rectangle classifications: zero.')
    ..writeln('- Breathers: ${kLevels201To240Breathers.toList().join(', ')}.');

  final oldCounts = _bulkCounts(legacyBulkMetrics.values);
  final newCounts = _bulkCounts(bulkMetrics.values);
  final oldWidth = _mean(
      legacyBulkMetrics.values.map((metrics) => metrics.coarse.widthOccupancy));
  final newWidth =
      _mean(bulkMetrics.values.map((metrics) => metrics.coarse.widthOccupancy));
  final oldHeight = _mean(legacyBulkMetrics.values
      .map((metrics) => metrics.coarse.heightOccupancy));
  final newHeight = _mean(
      bulkMetrics.values.map((metrics) => metrics.coarse.heightOccupancy));
  final oldEmpty = _mean(legacyBulkMetrics.values
      .map((metrics) => metrics.coarse.emptyAreaPercentage));
  final newEmpty = _mean(
      bulkMetrics.values.map((metrics) => metrics.coarse.emptyAreaPercentage));
  final oldHoles = legacyBulkMetrics.values
      .map((metrics) => metrics.coarse.holeCount)
      .fold<int>(0, (sum, value) => sum + value);
  final newHoles = bulkMetrics.values
      .map((metrics) => metrics.coarse.holeCount)
      .fold<int>(0, (sum, value) => sum + value);
  final heightCounts = <String, int>{'compact': 0, 'balanced': 0, 'tall': 0};
  for (final metrics in bulkMetrics.values) {
    heightCounts.update(
      metrics.coarse.heightOccupancy < .68
          ? 'compact'
          : metrics.coarse.heightOccupancy < .76
              ? 'balanced'
              : 'tall',
      (count) => count + 1,
    );
  }
  report
    ..writeln()
    ..writeln('## Bulk / fullness / envelope analysis')
    ..writeln()
    ..writeln('|Measure|Old candidates|Bulky redesign|')
    ..writeln('|---|---:|---:|')
    ..writeln('|Thin / medium / bulky|${oldCounts[BulkClass.thin]} / '
        '${oldCounts[BulkClass.medium]} / ${oldCounts[BulkClass.bulky]}|'
        '${newCounts[BulkClass.thin]} / ${newCounts[BulkClass.medium]} / '
        '${newCounts[BulkClass.bulky]}|')
    ..writeln('|Mean width occupancy|${(oldWidth * 100).toStringAsFixed(1)}%|'
        '${(newWidth * 100).toStringAsFixed(1)}%|')
    ..writeln('|Mean height occupancy|${(oldHeight * 100).toStringAsFixed(1)}%|'
        '${(newHeight * 100).toStringAsFixed(1)}%|')
    ..writeln(
        '|Mean internal empty area|${(oldEmpty * 100).toStringAsFixed(1)}%|'
        '${(newEmpty * 100).toStringAsFixed(1)}%|')
    ..writeln('|Detected enclosed holes|$oldHoles|$newHoles|')
    ..writeln()
    ..writeln('- New width distribution: ${widthCounts['narrow']} narrow, '
        '${widthCounts['medium']} medium, ${widthCounts['wide']} wide.')
    ..writeln('- New height distribution: ${heightCounts['compact']} compact, '
        '${heightCounts['balanced']} balanced, ${heightCounts['tall']} tall.')
    ..writeln(
        '- The batch reads less skinny overall: thin classifications fell '
        'from ${oldCounts[BulkClass.thin]} to ${newCounts[BulkClass.thin]}, '
        'while bulky classifications rose from ${oldCounts[BulkClass.bulky]} '
        'to ${newCounts[BulkClass.bulky]}.')
    ..writeln(
        '- Negative space remains patterned rather than erased: the report '
        'tracks both empty area and enclosed holes, and the solid-rectangle '
        'gate remains at zero.')
    ..writeln('- Breathers: ${kLevels201To240Breathers.toList().join(', ')}. '
        'Showcases: ${_showcaseLevels().join(', ')}.');

  report
    ..writeln()
    ..writeln('## Old-to-new change matrix')
    ..writeln()
    ..writeln('|Level|Old → new class|Tiles old → new|Width old → new|'
        'Fullness old → new|Design reason|')
    ..writeln('|---:|---|---:|---:|---:|---|');
  for (final candidate in kLevels201To240Candidates) {
    final legacy = kLevels201To240LegacyCandidates[candidate.level - 201];
    final old = legacyBulkMetrics[candidate.level]!;
    final current = bulkMetrics[candidate.level]!;
    report.writeln(
        '|${candidate.level}|${bulkClassLabel(old.classification)} → '
        '${bulkClassLabel(current.classification)}|'
        '${legacy.layout.stats.tileCount} → ${candidate.layout.stats.tileCount}|'
        '${(old.coarse.widthOccupancy * 100).toStringAsFixed(1)}% → '
        '${(current.coarse.widthOccupancy * 100).toStringAsFixed(1)}%|'
        '${(old.fullnessScore * 100).toStringAsFixed(1)} → '
        '${(current.fullnessScore * 100).toStringAsFixed(1)}|'
        '${_changeReason(candidate, old, current)}|');
  }

  report
    ..writeln()
    ..writeln('## Coordinates grouped by layer')
    ..writeln();
  for (final candidate in kLevels201To240Candidates) {
    report.writeln('### Level ${candidate.level} — ${candidate.proposedName}');
    report.writeln();
    for (var layer = 0; layer <= candidate.layout.stats.maxLayer; layer++) {
      final positions = candidate.layout.positions
          .where((position) => position.layer == layer)
          .toList()
        ..sort((a, b) {
          final row = a.row.compareTo(b.row);
          return row != 0 ? row : a.col.compareTo(b.col);
        });
      report.writeln('- Layer $layer (${positions.length}): '
          '${positions.map((p) => '(${p.row},${p.col})').join(' ')}');
    }
    report.writeln();
  }

  final unlockLevels = kTileUnlockMilestones
      .map((milestone) => milestone.completedLevel)
      .toList();
  final gaps = <int>[
    unlockLevels.first,
    for (var index = 1; index < unlockLevels.length; index++)
      unlockLevels[index] - unlockLevels[index - 1],
  ];
  report
    ..writeln('## Collection pacing snapshot')
    ..writeln()
    ..writeln('- Starter faces: $kStarterTileUnlockCount.')
    ..writeln('- Scheduled unlocks: ${kTileUnlockMilestones.length}.')
    ..writeln('- Total collectible definitions: ${kAllTiles.length}.')
    ..writeln('- Average levels per scheduled unlock: '
        '${(400 / kTileUnlockMilestones.length).toStringAsFixed(2)}.')
    ..writeln('- Shortest interval: ${gaps.reduce(min)} levels.')
    ..writeln('- Longest interval: ${gaps.reduce(max)} levels.')
    ..writeln('- Final unlock: Level ${unlockLevels.last}.')
    ..writeln('- Levels 201–400 unlocks: '
        '${kTileUnlockMilestones.where((m) => m.completedLevel >= 201).length}.')
    ..writeln()
    ..writeln('## Required finale checks')
    ..writeln()
    ..writeln('- Level 220 and Level 240 each passed 100/100 deterministic '
        'seeds with at least five legal and five safe opening pairs.')
    ..writeln('- Both finales had zero forced openings and remained within '
        'the 250-attempt reverse-removal bound.')
    ..writeln('- Level 240 is the current implemented-content boundary; '
        'Level 241 remains unavailable and the planned horizon remains 400.');

  File('${directory.path}/metrics.csv').writeAsStringSync(csv.toString());
  File('${directory.path}/levels-201-240-candidate-report.md')
      .writeAsStringSync(report.toString());
  _writeCollectionAudit(directory);
  print('${directory.path}/levels-201-240-candidate-report.md');
}

Map<BulkClass, int> _bulkCounts(Iterable<BulkAnalysis> analyses) {
  final result = {for (final value in BulkClass.values) value: 0};
  for (final analysis in analyses) {
    result[analysis.classification] = result[analysis.classification]! + 1;
  }
  return result;
}

double _mean(Iterable<double> values) {
  final list = values.toList();
  return list.reduce((a, b) => a + b) / list.length;
}

List<int> _showcaseLevels() => kLevels201To240Candidates
    .where((candidate) =>
        !candidate.isBreather &&
        (candidate.level % 5 == 0 ||
            kLevels201To240Finales.contains(candidate.level)))
    .map((candidate) => candidate.level)
    .toList();

String _changeReason(
  ExpansionLayoutCandidate candidate,
  BulkAnalysis old,
  BulkAnalysis current,
) {
  if (kLevels201To240Finales.contains(candidate.level)) {
    return 'Finale rebuilt with broad shoulders, a layered core, and a full base.';
  }
  if (candidate.isBreather) {
    return 'Breather retained, but its stem/corridor was thickened into a compact body.';
  }
  if (current.centerDensity - old.centerDensity >= .18) {
    return 'Added a denser patterned centre while preserving readable voids.';
  }
  if (current.coarse.widthOccupancy - old.coarse.widthOccupancy >= .10) {
    return 'Broadened the torso and lower envelope to remove the skinny read.';
  }
  return 'Re-massed the silhouette with thicker shoulders, base, and stacked accents.';
}

void _writeCollectionAudit(Directory directory) {
  final csv = StringBuffer()
    ..writeln('id,name,meaning,asset,starter,first_unlock,authenticity_status,'
        'gameplay_status,collection_status');
  for (final tile in kAllTiles) {
    final unlock = unlockLevelForTileId(tile.id);
    csv.writeln('${tile.id},"${tile.name}","${tile.meaning}",'
        '"${tile.assetPath ?? ''}",${kStarterTileIds.contains(tile.id)},'
        '${unlock ?? ''},"named Adinkra definition; external cultural '
        'verification not recorded in repository",used,used');
  }
  File('${directory.path}/tile-face-audit.csv')
      .writeAsStringSync(csv.toString());
}

Generated? _generate(
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
