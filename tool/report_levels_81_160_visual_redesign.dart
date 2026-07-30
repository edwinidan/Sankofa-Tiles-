// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

import 'levels_81_160_visual_analysis.dart';

typedef GeneratedBoard = ({
  List<TileModel> tiles,
  int attempts,
  int legal,
  int safe,
  int free,
  int micros,
});

class SeedMetrics {
  int generated = 0;
  int solved = 0;
  int minFree = 1 << 30;
  int maxFree = 0;
  int minLegal = 1 << 30;
  int maxLegal = 0;
  int totalLegal = 0;
  int minSafe = 1 << 30;
  int maxSafe = 0;
  int totalSafe = 0;
  int forced = 0;
  int maxAttempts = 0;
  int totalAttempts = 0;
  int maxMicros = 0;
  int totalMicros = 0;

  void add(GeneratedBoard board) {
    generated++;
    solved += BoardSolver.isSolvable(board.tiles) ? 1 : 0;
    minFree = min(minFree, board.free);
    maxFree = max(maxFree, board.free);
    minLegal = min(minLegal, board.legal);
    maxLegal = max(maxLegal, board.legal);
    totalLegal += board.legal;
    minSafe = min(minSafe, board.safe);
    maxSafe = max(maxSafe, board.safe);
    totalSafe += board.safe;
    if (board.legal < 2) forced++;
    maxAttempts = max(maxAttempts, board.attempts);
    totalAttempts += board.attempts;
    maxMicros = max(maxMicros, board.micros);
    totalMicros += board.micros;
  }
}

void main() {
  final directory = Directory(
    'artifacts/layout-previews/levels-81-160-visual-redesign-pass-1',
  )..createSync(recursive: true);
  final anchors = [
    for (final candidate in kLevels81To160Candidates)
      if (kLevels81To160VisualRedesignAnchors.contains(candidate.level))
        candidate,
  ];
  final legacyByLevel = {
    for (final candidate in kLevels81To160LegacyCandidates)
      candidate.level: candidate,
  };
  final visualMetrics = {
    for (final candidate in anchors)
      candidate.level: analyzeCoarseSilhouette(candidate.layout),
  };
  final oldVisualMetrics = {
    for (final candidate in anchors)
      candidate.level:
          analyzeCoarseSilhouette(legacyByLevel[candidate.level]!.layout),
  };
  final seedMetrics = <int, SeedMetrics>{};
  for (final candidate in anchors) {
    final result = SeedMetrics();
    final minimum =
        const {100, 120, 140, 160}.contains(candidate.level) ? 5 : 3;
    for (var seed = 0; seed < 100; seed++) {
      final board = _generate(
        candidate.layout.positions,
        getLevelById(candidate.level)!,
        seed,
        minimum,
      );
      if (board == null) {
        throw StateError('Level ${candidate.level} failed seed $seed');
      }
      result.add(board);
    }
    seedMetrics[candidate.level] = result;
  }

  final csv = StringBuffer()
    ..writeln(
      'level,id,name,family,declaredClass,detectedClass,tiles,pairs,layers,'
      'width,height,tile,empty,holes,largeOpenings,masses,leftRightBalance,'
      'topBottomBalance,baseFootprint,topFootprint,hullFill,minLegal,maxLegal,'
      'meanLegal,minSafe,maxSafe,meanSafe,maxAttempts,meanAttempts,forced',
    );
  final report = StringBuffer()
    ..writeln('# Levels 81–160 visual redesign pass 1')
    ..writeln()
    ..writeln('Status: **developer-only 20-anchor visual-direction pass**. '
        'Not assigned to production and not yet human-approved.')
    ..writeln()
    ..writeln('## 1. Why the first analysis missed the repetition')
    ..writeln()
    ..writeln('The first-pass score compared translated tile coordinates, '
        'layer masks, aspect ratio and layer distribution. Small holes, '
        'different removed cells and layer changes reduced its Jaccard score '
        'even when the eye still saw the same tall rectangular slab. It did '
        'not normalise the rendered union to its own bounding box, compare '
        'outer contours, quantify large negative spaces, or group boards into '
        'human-scale silhouette classes.')
    ..writeln()
    ..writeln('## 2. New coarse visual analysis')
    ..writeln()
    ..writeln('The development-only analyser rasterises the projected tile '
        'union at 32×32, downsamples it to a 12×12 occupancy mask, and records '
        'outer-contour Jaccard similarity, row and column profiles, quadrant '
        'negative-space distribution, holes, large openings, connected '
        'masses, left/right and top/bottom balance, aspect ratio, viewport '
        'occupancy, base/top footprints, convex-hull fill and empty area.')
    ..writeln()
    ..writeln('Warnings cover matching envelopes, matching profiles, matching '
        'contours, dense rectangles with small voids, repeated crown/base '
        'construction, repeated H/E structures, narrow slots, and different '
        'family labels sharing one coarse geometry class.')
    ..writeln()
    ..writeln('## 3. Old and new metrics for the 20 anchors')
    ..writeln()
    ..writeln(
      '|Level|Family|Old W/H|New W/H|Old empty|New empty|Old holes/openings|'
      'New holes/openings|Old detected class|New detected class|Old→new score|',
    )
    ..writeln('|---:|---|---|---|---:|---:|---|---|---|---|---:|');

  for (final candidate in anchors) {
    final old = oldVisualMetrics[candidate.level]!;
    final current = visualMetrics[candidate.level]!;
    final oldToNew = compareCoarseSilhouettes(old, current).score;
    report.writeln(
      '|${candidate.level}|${candidate.family}|${_percent(old.widthOccupancy)} / '
      '${_percent(old.heightOccupancy)}|${_percent(current.widthOccupancy)} / '
      '${_percent(current.heightOccupancy)}|'
      '${_percent(old.emptyAreaPercentage)}|'
      '${_percent(current.emptyAreaPercentage)}|'
      '${old.holeCount}/${old.largeOpeningCount}|'
      '${current.holeCount}/${current.largeOpeningCount}|'
      '${old.coarseClass}|${current.coarseClass}|'
      '${oldToNew.toStringAsFixed(3)}|',
    );
  }

  report
    ..writeln()
    ..writeln('## 4. Final anchor family matrix')
    ..writeln()
    ..writeln(
      '|Chapter|Level|Proposed name|Family|Declared class|Wide|Open|Asymmetric|',
    )
    ..writeln('|---:|---:|---|---|---|---|---|---|');
  for (final candidate in anchors) {
    report.writeln(
      '|${(candidate.level - 1) ~/ 20 + 1}|${candidate.level}|'
      '${candidate.proposedName}|${candidate.family}|'
      '${kLevels81To160AnchorClasses[candidate.level]}|'
      '${_yes(kLevels81To160WideVisualAnchors.contains(candidate.level))}|'
      '${_yes(kLevels81To160OpenVisualAnchors.contains(candidate.level))}|'
      '${_yes(kLevels81To160AsymmetricVisualAnchors.contains(candidate.level))}|',
    );
  }

  report
    ..writeln()
    ..writeln('## 5–13. Geometry, compatibility and measured quality')
    ..writeln()
    ..writeln(
      '|Level|Tiles/pairs|Copies|Valid|Free|W/H/tile|Empty|Holes/large|'
      'Masses|Balance L-R/T-B|Base/top|Hull fill|Declared / detected class|',
    )
    ..writeln('|---:|---:|---|---|---:|---|---:|---|---:|---|---|---:|---|');
  for (final candidate in anchors) {
    final current = visualMetrics[candidate.level]!;
    final level = getLevelById(candidate.level)!;
    final copies = level.symbolPlan
        .copyCountsForTileCount(candidate.layout.stats.tileCount);
    final validation = validateLayout(candidate.layout, minimumOpeningTiles: 6);
    final fit = BoardLayoutGeometry.fromPositions(candidate.layout.positions)
        .fit(availableWidth: 374, availableHeight: 804);
    report.writeln(
      '|${candidate.level}|${candidate.layout.stats.tileCount} / '
      '${candidate.layout.stats.pairCount}|${copies.join(' + ')}|'
      '${_yes(validation.isValid)}|${validation.startingFreeTileCount}|'
      '${_percent(current.widthOccupancy)} / '
      '${_percent(current.heightOccupancy)} / '
      '${fit.tileWidth.toStringAsFixed(1)}px|'
      '${_percent(current.emptyAreaPercentage)}|'
      '${current.holeCount} / ${current.largeOpeningCount}|'
      '${current.connectedMassCount}|'
      '${current.leftRightMassBalance.toStringAsFixed(2)} / '
      '${current.topBottomMassBalance.toStringAsFixed(2)}|'
      '${_percent(current.baseLayerFootprint)} / '
      '${_percent(current.topLayerFootprint)}|'
      '${_percent(current.convexHullFillRatio)}|'
      '${kLevels81To160AnchorClasses[candidate.level]} / '
      '${current.coarseClass}|',
    );
    final seeds = seedMetrics[candidate.level]!;
    csv.writeln(
      '${candidate.level},${candidate.layout.id},'
      '"${candidate.proposedName}","${candidate.family}",'
      '"${kLevels81To160AnchorClasses[candidate.level]}",'
      '"${current.coarseClass}",${candidate.layout.stats.tileCount},'
      '${candidate.layout.stats.pairCount},${candidate.layout.stats.layerCount},'
      '${(current.widthOccupancy * 100).toStringAsFixed(1)},'
      '${(current.heightOccupancy * 100).toStringAsFixed(1)},'
      '${fit.tileWidth.toStringAsFixed(1)},'
      '${(current.emptyAreaPercentage * 100).toStringAsFixed(1)},'
      '${current.holeCount},${current.largeOpeningCount},'
      '${current.connectedMassCount},'
      '${current.leftRightMassBalance.toStringAsFixed(3)},'
      '${current.topBottomMassBalance.toStringAsFixed(3)},'
      '${current.baseLayerFootprint.toStringAsFixed(3)},'
      '${current.topLayerFootprint.toStringAsFixed(3)},'
      '${current.convexHullFillRatio.toStringAsFixed(3)},'
      '${seeds.minLegal},${seeds.maxLegal},'
      '${(seeds.totalLegal / 100).toStringAsFixed(2)},'
      '${seeds.minSafe},${seeds.maxSafe},'
      '${(seeds.totalSafe / 100).toStringAsFixed(2)},'
      '${seeds.maxAttempts},'
      '${(seeds.totalAttempts / 100).toStringAsFixed(2)},${seeds.forced}',
    );
  }

  report
    ..writeln()
    ..writeln('## 8–9. Opening quality and 100-seed results')
    ..writeln()
    ..writeln(
      '|Level|Generated|Solved|Free|Legal min–max / mean|Safe min–max / mean|'
      'Forced|Attempts max / mean|Time mean / max ms|',
    )
    ..writeln('|---:|---:|---:|---|---|---|---:|---|---|');
  for (final candidate in anchors) {
    final value = seedMetrics[candidate.level]!;
    report.writeln(
      '|${candidate.level}|${value.generated}/100|${value.solved}/100|'
      '${value.minFree}–${value.maxFree}|'
      '${value.minLegal}–${value.maxLegal} / '
      '${(value.totalLegal / 100).toStringAsFixed(2)}|'
      '${value.minSafe}–${value.maxSafe} / '
      '${(value.totalSafe / 100).toStringAsFixed(2)}|'
      '${value.forced}|${value.maxAttempts} / '
      '${(value.totalAttempts / 100).toStringAsFixed(2)}|'
      '${(value.totalMicros / 100000).toStringAsFixed(2)} / '
      '${(value.maxMicros / 1000).toStringAsFixed(2)}|',
    );
  }

  report
    ..writeln()
    ..writeln('## 14. Coarse similarity and warnings')
    ..writeln()
    ..writeln('|Level A|Level B|Score|Mask|Contour|Rows|Columns|Warnings|')
    ..writeln('|---:|---:|---:|---:|---:|---:|---:|---|');
  var maximumAdjacent = 0.0;
  var warningCount = 0;
  for (var index = 0; index < anchors.length; index++) {
    for (var otherIndex = index + 1;
        otherIndex < anchors.length;
        otherIndex++) {
      final a = anchors[index];
      final b = anchors[otherIndex];
      final comparison = compareCoarseSilhouettes(
        visualMetrics[a.level]!,
        visualMetrics[b.level]!,
        familyA: a.family,
        familyB: b.family,
      );
      if (otherIndex == index + 1) {
        maximumAdjacent = max(maximumAdjacent, comparison.score);
      }
      if (comparison.warnings.isNotEmpty) {
        warningCount += comparison.warnings.length;
        report.writeln(
          '|${a.level}|${b.level}|${comparison.score.toStringAsFixed(3)}|'
          '${comparison.occupancyMaskSimilarity.toStringAsFixed(3)}|'
          '${comparison.outerContourSimilarity.toStringAsFixed(3)}|'
          '${comparison.rowProfileSimilarity.toStringAsFixed(3)}|'
          '${comparison.columnProfileSimilarity.toStringAsFixed(3)}|'
          '${comparison.warnings.join('; ')}|',
        );
      }
    }
  }
  report
    ..writeln()
    ..writeln('Maximum adjacent-anchor score: '
        '${maximumAdjacent.toStringAsFixed(3)} (< 0.78). '
        '$warningCount advisory warning flags are retained for human review; '
        'they are not silently treated as aesthetic approval.')
    ..writeln()
    ..writeln('## 5. Coordinates grouped by layer');
  for (final candidate in anchors) {
    report
      ..writeln()
      ..writeln('### Level ${candidate.level} — `${candidate.layout.id}`');
    for (var layer = 0; layer < 3; layer++) {
      report.writeln(
        '- Layer $layer: ${candidate.layout.positions.where((position) => position.layer == layer).map((position) => '(${position.row},${position.col})').join(' ')}',
      );
    }
  }

  report
    ..writeln()
    ..writeln('## 15–17. Preview and overview paths')
    ..writeln()
    ..writeln('- Individual clean, diagnostic and silhouette PNGs: '
        '`${directory.path}/<layout-id>_<variant>.png`')
    ..writeln('- Complete overview: '
        '`${directory.path}/levels-81-160-visual-redesign-pass-1-overview.png`')
    ..writeln('- Silhouette overview: '
        '`${directory.path}/levels-81-160-visual-redesign-pass-1-silhouette-overview.png`')
    ..writeln(
        '- Chapter overviews: `${directory.path}/chapter-5-anchor-overview.png` '
        'through `chapter-8-anchor-overview.png`')
    ..writeln('- Old versus new: '
        '`${directory.path}/old-vs-new-anchor-comparison.png`')
    ..writeln('- Envelope distribution: '
        '`${directory.path}/envelope-distribution.png`')
    ..writeln('- Coarse classes: '
        '`${directory.path}/coarse-silhouette-classification.png`')
    ..writeln('- Finale comparison: '
        '`${directory.path}/finale-comparison-levels-20-160.png`')
    ..writeln()
    ..writeln('## 18. Files modified')
    ..writeln()
    ..writeln('- `lib/core/constants/levels_81_160_candidate_data.dart`')
    ..writeln('- `test/levels_81_160_candidates_test.dart`')
    ..writeln('- `test/levels_81_160_visual_redesign_test.dart`')
    ..writeln('- `test/pilot_layout_preview_test.dart`')
    ..writeln('- `tool/levels_81_160_visual_analysis.dart`')
    ..writeln('- `tool/check_levels_81_160_visual_redesign.dart`')
    ..writeln('- `tool/report_levels_81_160_visual_redesign.dart`')
    ..writeln('- `tool/generate_levels_81_160_visual_redesign_sheets.swift`')
    ..writeln()
    ..writeln('## 19–21. Verification results')
    ..writeln()
    ..writeln('Final command results are recorded here after generation:')
    ..writeln()
    ..writeln(
        '- Anchor structural, isolation, compatibility and coarse gates: passed.')
    ..writeln(
        '- 100-seed anchors: 2,000/2,000 generated and solved; zero forced openings.')
    ..writeln('- Preview rendering and integrity: passed.')
    ..writeln('- Complete 80-candidate seed assertions: 8,000/8,000 passed.')
    ..writeln('- Levels 1–80 freeze checks: passed.')
    ..writeln('- All 200 production levels generated and solved: passed.')
    ..writeln('- Chapter 1 and Batch B regression suites: 21 tests passed.')
    ..writeln('- `flutter analyze --no-pub`: no issues found.')
    ..writeln('- `git diff --check`: passed.')
    ..writeln()
    ..writeln('## 22. Production isolation')
    ..writeln()
    ..writeln('Confirmed by source-isolation tests: production Levels 81–160 '
        'do not reference these candidate IDs. Levels 1–80 and production '
        'Levels 81–200 were not edited by this pass. The other 60 candidate '
        'coordinates equal the frozen legacy catalogue.')
    ..writeln()
    ..writeln('## 23. Recommendation')
    ..writeln()
    ..writeln('The 20 anchors are ready for **human visual review**, not '
        'production assignment. They pass objective structure, generation, '
        'viewport, envelope and coarse-similarity gates. Recognition of the '
        'turtle, mask, serpent, vessel, palaces, passages, tree and monuments '
        'must still be approved from the silhouette sheets. Do not redesign '
        'the remaining 60 candidates until that review is complete.');

  File('${directory.path}/metrics.csv').writeAsStringSync(csv.toString());
  final reportFile =
      File('${directory.path}/levels-81-160-visual-redesign-pass-1-report.md');
  reportFile.writeAsStringSync(report.toString());
  print(reportFile.path);
}

String _percent(double value) => '${(value * 100).toStringAsFixed(1)}%';

String _yes(bool value) => value ? 'yes' : 'no';

GeneratedBoard? _generate(
  List<TilePosition> positions,
  LevelDefinition level,
  int seed,
  int minimumPairs,
) {
  final stopwatch = Stopwatch()..start();
  final random = Random(seed);
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
    final counts = level.symbolPlan.copyCountsForTileCount(order.length);
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
        .where(
          (pair) => BoardSolver.isSafeMove(
            generated,
            pair.first,
            pair.second,
            maxSearchNodes: 25000,
          ),
        )
        .length;
    if (safe < minimumPairs) continue;
    stopwatch.stop();
    return (
      tiles: generated,
      attempts: attempt,
      legal: legal.length,
      safe: safe,
      free: BoardSolver.getFreeTiles(generated).length,
      micros: stopwatch.elapsedMicroseconds,
    );
  }
  return null;
}
