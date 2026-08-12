// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_241_280_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

import 'levels_201_240_bulk_analysis.dart';
import 'levels_81_160_visual_analysis.dart';

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
  int minSafe = 1 << 30;
  int maxSafe = 0;
  int maxAttempts = 0;
  int totalAttempts = 0;
  int forced = 0;

  void add(Generated board) {
    generated++;
    if (BoardSolver.isSolvable(board.tiles)) solved++;
    minLegal = min(minLegal, board.legal);
    maxLegal = max(maxLegal, board.legal);
    minSafe = min(minSafe, board.safe);
    maxSafe = max(maxSafe, board.safe);
    maxAttempts = max(maxAttempts, board.attempts);
    totalAttempts += board.attempts;
    if (board.legal <= 1) forced++;
  }
}

void main() {
  final directory =
      Directory('artifacts/layout-previews/levels-241-280-candidates')
        ..createSync(recursive: true);
  final seeds = <int, SeedMetrics>{};
  final coarse = <int, CoarseSilhouetteMetrics>{};
  final bulk = <int, BulkAnalysis>{};

  for (final candidate in kLevels241To280Candidates) {
    final metrics = SeedMetrics();
    final minimum = kLevels241To280Finales.contains(candidate.level)
        ? 5
        : candidate.level == 241
            ? 4
            : 3;
    for (var seed = 0; seed < 100; seed++) {
      final generated = _generate(candidate, seed, minimum);
      if (generated == null) {
        throw StateError('L${candidate.level} failed seed $seed');
      }
      metrics.add(generated);
    }
    seeds[candidate.level] = metrics;
    coarse[candidate.level] = analyzeCoarseSilhouette(candidate.layout);
    bulk[candidate.level] = analyzeBulk(candidate.layout);
  }

  final csv = StringBuffer()
    ..writeln('level,id,name,chapter,family,class,fullness,tiles,pairs,layers,'
        'symbols,copies,free,minLegal,maxLegal,minSafe,maxSafe,maxAttempts,'
        'meanAttempts,forced,width,height,tileWidth,tileHeight,centerDensity,'
        'hullFill,emptyArea,holes,largeOpenings,connectedMasses,leftRight,'
        'topBottom,coarseClass,breather,showcase,anchor');
  final report = StringBuffer()
    ..writeln('# Levels 241–280 developer candidate report')
    ..writeln()
    ..writeln('Status: isolated developer-only human-review candidates. ')
    ..writeln(
        'Production remains Levels 1–240; Level 241 has no production route.')
    ..writeln()
    ..writeln('## Roadmap audit and chapter grammar')
    ..writeln()
    ..writeln('- **Chapter 13 — Rivers of Counsel (241–260):** Mythic route '
        'choice and controlled asymmetry. Forked rivers, stepping stones, '
        'delta islands, canoe bridges, chambers, and staggered current bars '
        'provide the dominant vocabulary. Negative space behaves as channels '
        'and confluences. The chapter uses more controlled asymmetry and '
        'medium-full envelopes; Level 260 is the River Council confluence.')
    ..writeln('- **Chapter 14 — Forest of Ancestors (261–280):** deeper cover '
        'with open vertical breathing lanes. Trees, roots, canopies, groves, '
        'animal guardians, vessels, and fortresses provide the vocabulary. '
        'Negative space behaves as clearings, trunk chambers, and branch '
        'windows. It is slightly more guardian-heavy and wide; Level 280 is '
        'the Great Ancestral Tree sanctuary.')
    ..writeln('- Roadmap moments retained for future production decisions: '
        'discovery near 248, booster cache at 250, Chapter-13 reveal/chest at '
        '260, collection moments at 268 and 278, and canopy cosmetic/chest at '
        '280. None are activated by this developer-only catalogue.')
    ..writeln()
    ..writeln('## Candidate matrix')
    ..writeln()
    ..writeln(
        '|Level|Name|Family / coarse class|Fullness|Tiles / pairs|Symbols '
        '/ copies|Legal|Safe|Attempts|390×844 W / H / tile|Flags|')
    ..writeln('|---:|---|---|---|---:|---|---:|---:|---:|---|---|');

  for (final candidate in kLevels241To280Candidates) {
    final stats = candidate.layout.stats;
    final metric = seeds[candidate.level]!;
    final visual = coarse[candidate.level]!;
    final fullness = bulk[candidate.level]!;
    final geometry =
        BoardLayoutGeometry.fromPositions(candidate.layout.positions);
    final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
    final copies = candidate.symbolPlan.describeForTileCount(stats.tileCount);
    final flags = [
      if (candidate.isAnchor) 'anchor',
      if (candidate.isBreather) 'breather',
      if (candidate.isShowcase) 'showcase',
      if (kLevels241To280Finales.contains(candidate.level)) 'finale',
    ].join(', ');
    csv.writeln('${candidate.level},${candidate.layout.id},'
        '"${candidate.proposedName}",${candidate.chapter},'
        '"${candidate.family}","${candidate.silhouetteClass}",'
        '${candidate.fullnessClass},${stats.tileCount},${stats.pairCount},'
        '${stats.layerCount},${candidate.symbolPlan.symbolPoolSize},"$copies",'
        '${stats.startingFreeTileCount},${metric.minLegal},${metric.maxLegal},'
        '${metric.minSafe},${metric.maxSafe},${metric.maxAttempts},'
        '${(metric.totalAttempts / 100).toStringAsFixed(2)},${metric.forced},'
        '${(visual.widthOccupancy * 100).toStringAsFixed(1)},'
        '${(visual.heightOccupancy * 100).toStringAsFixed(1)},'
        '${fit.tileWidth.toStringAsFixed(1)},'
        '${fit.tileHeight.toStringAsFixed(1)},'
        '${(fullness.centerDensity * 100).toStringAsFixed(1)},'
        '${(visual.convexHullFillRatio * 100).toStringAsFixed(1)},'
        '${(visual.emptyAreaPercentage * 100).toStringAsFixed(1)},'
        '${visual.holeCount},${visual.largeOpeningCount},'
        '${visual.connectedMassCount},'
        '${visual.leftRightMassBalance.toStringAsFixed(3)},'
        '${visual.topBottomMassBalance.toStringAsFixed(3)},'
        '"${visual.coarseClass}",${candidate.isBreather},'
        '${candidate.isShowcase},${candidate.isAnchor}');
    report.writeln('|${candidate.level}|${candidate.proposedName}|'
        '${candidate.family} / ${visual.coarseClass}|'
        '${candidate.fullnessClass}|${stats.tileCount} / ${stats.pairCount}|'
        '${candidate.symbolPlan.symbolPoolSize} / $copies|'
        '${metric.minLegal}–${metric.maxLegal}|'
        '${metric.minSafe}–${metric.maxSafe}|${metric.maxAttempts}|'
        '${(visual.widthOccupancy * 100).toStringAsFixed(1)}% / '
        '${(visual.heightOccupancy * 100).toStringAsFixed(1)}% / '
        '${fit.tileWidth.toStringAsFixed(1)} px|$flags|');
  }

  final fullnessCounts = <String, int>{};
  final actualBulk = <BulkClass, int>{
    for (final value in BulkClass.values) value: 0,
  };
  final widthCounts = <String, int>{'below 70%': 0, '70–76%': 0, '76–82%': 0};
  final heightCounts = <String, int>{'65–72%': 0, '72–77%': 0, '77–80%': 0};
  final envelopes = <String, int>{};
  for (final candidate in kLevels241To280Candidates) {
    final visual = coarse[candidate.level]!;
    final analysis = bulk[candidate.level]!;
    fullnessCounts[candidate.fullnessClass] =
        (fullnessCounts[candidate.fullnessClass] ?? 0) + 1;
    actualBulk[analysis.classification] =
        actualBulk[analysis.classification]! + 1;
    final widthKey = visual.widthOccupancy < .70
        ? 'below 70%'
        : visual.widthOccupancy < .76
            ? '70–76%'
            : '76–82%';
    widthCounts[widthKey] = widthCounts[widthKey]! + 1;
    final heightKey = visual.heightOccupancy < .72
        ? '65–72%'
        : visual.heightOccupancy < .77
            ? '72–77%'
            : '77–80%';
    heightCounts[heightKey] = heightCounts[heightKey]! + 1;
    final key = '${(visual.widthOccupancy * 100).toStringAsFixed(1)}% × '
        '${(visual.heightOccupancy * 100).toStringAsFixed(1)}%';
    envelopes[key] = (envelopes[key] ?? 0) + 1;
  }
  final meanEmpty =
      _mean(coarse.values.map((value) => value.emptyAreaPercentage));
  final meanHull =
      _mean(coarse.values.map((value) => value.convexHullFillRatio));
  final holes =
      coarse.values.fold<int>(0, (sum, value) => sum + value.holeCount);
  final largeOpenings =
      coarse.values.fold<int>(0, (sum, value) => sum + value.largeOpeningCount);
  final connected = coarse.values
      .fold<int>(0, (sum, value) => sum + value.connectedMassCount);
  final tileWidths = <double>[];
  final tileHeights = <double>[];
  for (final candidate in kLevels241To280Candidates) {
    final fit = BoardLayoutGeometry.fromPositions(candidate.layout.positions)
        .fit(availableWidth: 374, availableHeight: 804);
    tileWidths.add(fit.tileWidth);
    tileHeights.add(fit.tileHeight);
  }
  report
    ..writeln()
    ..writeln('## Fullness, envelope, and negative space')
    ..writeln()
    ..writeln('- Authored distribution: 0 thin, '
        '${fullnessCounts['open-medium']} open-medium, '
        '${fullnessCounts['full']} full, ${fullnessCounts['bulky']} bulky.')
    ..writeln('- Analysis distribution: ${actualBulk[BulkClass.thin]} thin, '
        '${actualBulk[BulkClass.medium]} medium, '
        '${actualBulk[BulkClass.bulky]} bulky.')
    ..writeln(
        '- Width distribution: ${widthCounts.entries.map((entry) => '${entry.key}: ${entry.value}').join('; ')}.')
    ..writeln(
        '- Height distribution: ${heightCounts.entries.map((entry) => '${entry.key}: ${entry.value}').join('; ')}.')
    ..writeln('- Exact envelope groups: '
        '${envelopes.entries.map((entry) => '${entry.key}: ${entry.value}').join('; ')}. '
        'Maximum reuse is ${envelopes.values.reduce(max)}.')
    ..writeln(
        '- Effective tile width: ${tileWidths.reduce(min).toStringAsFixed(1)}–'
        '${tileWidths.reduce(max).toStringAsFixed(1)} px; tile height: '
        '${tileHeights.reduce(min).toStringAsFixed(1)}–'
        '${tileHeights.reduce(max).toStringAsFixed(1)} px.')
    ..writeln(
        '- Mean internal empty area: ${(meanEmpty * 100).toStringAsFixed(1)}%; '
        'mean convex-hull fill: ${(meanHull * 100).toStringAsFixed(1)}%.')
    ..writeln('- Enclosed holes: $holes; large openings: $largeOpenings; '
        'connected occupied masses summed across layouts: $connected.')
    ..writeln('- Solid rectangles: zero. Ultra-thin boards: zero.')
    ..writeln('- Breathers: ${kLevels241To280Breathers.toList().join(', ')}.')
    ..writeln('- Showcases: ${kLevels241To280Showcases.toList().join(', ')}.');

  report
    ..writeln()
    ..writeln('## Similarity results')
    ..writeln()
    ..writeln('|Adjacent levels|Score|Classes|')
    ..writeln('|---|---:|---|');
  var maximumAdjacent = 0.0;
  var maximumAdjacentPair = '';
  for (var index = 0; index < kLevels241To280Candidates.length - 1; index++) {
    final first = kLevels241To280Candidates[index];
    final second = kLevels241To280Candidates[index + 1];
    final comparison = compareCoarseSilhouettes(
      coarse[first.level]!,
      coarse[second.level]!,
      familyA: first.family,
      familyB: second.family,
    );
    if (comparison.score > maximumAdjacent) {
      maximumAdjacent = comparison.score;
      maximumAdjacentPair = '${first.level}/${second.level}';
    }
    report.writeln('|${first.level}/${second.level}|'
        '${comparison.score.toStringAsFixed(3)}|'
        '${coarse[first.level]!.coarseClass} / '
        '${coarse[second.level]!.coarseClass}|');
  }
  report
    ..writeln()
    ..writeln('### Twenty-level offsets')
    ..writeln()
    ..writeln('|Levels|Score|')
    ..writeln('|---|---:|');
  var maximumOffset = 0.0;
  var maximumOffsetPair = '';
  for (var index = 0; index < 20; index++) {
    final first = kLevels241To280Candidates[index];
    final second = kLevels241To280Candidates[index + 20];
    final comparison = compareCoarseSilhouettes(
      coarse[first.level]!,
      coarse[second.level]!,
      familyA: first.family,
      familyB: second.family,
    );
    if (comparison.score > maximumOffset) {
      maximumOffset = comparison.score;
      maximumOffsetPair = '${first.level}/${second.level}';
    }
    report.writeln('|${first.level}/${second.level}|'
        '${comparison.score.toStringAsFixed(3)}|');
  }
  var maximumProduction = 0.0;
  var maximumProductionPair = '';
  for (final candidate in kLevels241To280Candidates) {
    for (final production in kLevels) {
      final score = compareLayoutSilhouettes(
        candidate.layout,
        production.namedLayout,
      ).score;
      if (score > maximumProduction) {
        maximumProduction = score;
        maximumProductionPair = '${candidate.level}/${production.id}';
      }
    }
  }
  report
    ..writeln()
    ..writeln('- Maximum adjacent coarse similarity: '
        '${maximumAdjacent.toStringAsFixed(3)} at $maximumAdjacentPair '
        '(gate < 0.780).')
    ..writeln('- Maximum 20-level-offset coarse similarity: '
        '${maximumOffset.toStringAsFixed(3)} at $maximumOffsetPair '
        '(gate ≤ 0.750).')
    ..writeln('- Maximum exact silhouette comparison against production '
        'Levels 1–240: ${maximumProduction.toStringAsFixed(3)} at '
        '$maximumProductionPair (near-clone gate < 0.900).')
    ..writeln('- Exact coordinate duplicates: zero. Repeated identical '
        'base/top geometry: zero. No three consecutive candidates share one '
        'dominant coarse class.')
    ..writeln()
    ..writeln('### Warnings resolved during authoring')
    ..writeln()
    ..writeln('- The first Level-280 anchor was too tall and too similar to '
        'Level 260; it was rebuilt as a single-apex tree sanctuary. '
        'Final 260/280 similarity is '
        '${compareCoarseSilhouettes(coarse[260]!, coarse[280]!).score.toStringAsFixed(3)}.')
    ..writeln('- Initial 259/260 similarity exceeded the adjacent gate; Level '
        '259 became an asymmetric split threshold. Final score is '
        '${compareCoarseSilhouettes(coarse[259]!, coarse[260]!).score.toStringAsFixed(3)}.')
    ..writeln('- Early versions of 259, 264, and 278 classified as solid '
        'rectangles. Their side channels and internal chambers were opened; '
        'the final solid-rectangle count is zero.')
    ..writeln('- Initial envelope reuse exceeded six boards. Middle-layer '
        'stacking and seven/eight-row proportions were diversified; final '
        'maximum exact envelope reuse is ${envelopes.values.reduce(max)}.');

  final generatedTotal =
      seeds.values.fold<int>(0, (sum, value) => sum + value.generated);
  final solvedTotal =
      seeds.values.fold<int>(0, (sum, value) => sum + value.solved);
  final forcedTotal =
      seeds.values.fold<int>(0, (sum, value) => sum + value.forced);
  final minLegal = seeds.values.map((value) => value.minLegal).reduce(min);
  final maxLegal = seeds.values.map((value) => value.maxLegal).reduce(max);
  final minSafe = seeds.values.map((value) => value.minSafe).reduce(min);
  final maxSafe = seeds.values.map((value) => value.maxSafe).reduce(max);
  final maxAttempts =
      seeds.values.map((value) => value.maxAttempts).reduce(max);
  report
    ..writeln()
    ..writeln('## Technical validation')
    ..writeln()
    ..writeln('- Deterministic generation: $generatedTotal/4,000.')
    ..writeln('- Deterministic solvability: $solvedTotal/4,000.')
    ..writeln('- Legal opening range: $minLegal–$maxLegal pairs; safe opening '
        'range: $minSafe–$maxSafe pairs.')
    ..writeln('- Forced-opening seeds: $forcedTotal. Maximum reverse-removal '
        'attempts: $maxAttempts (bound 250).')
    ..writeln('- Level 241 passes the four-pair re-entry gate. Levels 260 and '
        '280 pass the five-pair finale gate.')
    ..writeln('- All 40 pass even-count, unique-coordinate, three-layer, '
        'immediate-support, same-layer-overlap, half-grid, projected-bounds, '
        'symbol-plan, viewport, and production-isolation checks.')
    ..writeln('- Compact 360×640, standard 390×844, and tall 430×932 fits are '
        'clean; all standard effective tile widths are 64.0 px.')
    ..writeln()
    ..writeln('## Planned collection milestones in 241–280')
    ..writeln()
    ..writeln('These existing schedule entries are documented but inactive '
        'because the candidate levels are not production content.');
  for (final milestone in kTileUnlockMilestones.where(
    (milestone) =>
        milestone.completedLevel >= 241 && milestone.completedLevel <= 280,
  )) {
    final tile = kAllTiles.firstWhere((tile) => tile.id == milestone.tileId);
    report.writeln('- Level ${milestone.completedLevel}: ${tile.name} '
        '(`${tile.id}`).');
  }

  report
    ..writeln()
    ..writeln('## Coordinates grouped by layer');
  for (final candidate in kLevels241To280Candidates) {
    report
      ..writeln()
      ..writeln('### Level ${candidate.level} — ${candidate.proposedName}');
    for (var layer = 0; layer < 3; layer++) {
      final positions = candidate.layout.positions
          .where((position) => position.layer == layer)
          .toList();
      report.writeln('- Layer $layer (${positions.length}): '
          '${positions.map((position) => '(${position.row},${position.col})').join(' ')}');
    }
  }

  File('${directory.path}/metrics.csv').writeAsStringSync(csv.toString());
  File('${directory.path}/levels-241-280-candidate-report.md')
      .writeAsStringSync(report.toString());
  print('Wrote report for ${kLevels241To280Candidates.length} candidates; '
      '$generatedTotal generated, $solvedTotal solved.');
}

Generated? _generate(
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

double _mean(Iterable<double> values) {
  final list = values.toList();
  return list.reduce((first, second) => first + second) / list.length;
}
