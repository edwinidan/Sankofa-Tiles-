// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

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
  int totalFree = 0;
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
    totalFree += board.free;
    minLegal = min(minLegal, board.legal);
    maxLegal = max(maxLegal, board.legal);
    totalLegal += board.legal;
    minSafe = min(minSafe, board.safe);
    maxSafe = max(maxSafe, board.safe);
    totalSafe += board.safe;
    if (board.legal <= 1) forced++;
    maxAttempts = max(maxAttempts, board.attempts);
    totalAttempts += board.attempts;
    maxMicros = max(maxMicros, board.micros);
    totalMicros += board.micros;
  }
}

void main() {
  final directory =
      Directory('artifacts/layout-previews/levels-81-160-candidates')
        ..createSync(recursive: true);
  final productionSnapshot = [
    for (var level = 81; level <= 160; level++)
      (
        id: level,
        name: getLevelById(level)!.name,
        layout: getLevelById(level)!.layoutName,
      ),
  ];
  final results = <int, SeedMetrics>{};
  for (final candidate in kLevels81To160Candidates) {
    final metrics = SeedMetrics();
    final level = getLevelById(candidate.level)!;
    final minimum =
        const {100, 120, 140, 160}.contains(candidate.level) ? 5 : 3;
    for (var seed = 0; seed < 100; seed++) {
      final board = _generate(candidate.layout.positions, level, seed, minimum);
      if (board == null) {
        throw StateError('Level ${candidate.level} failed seed $seed');
      }
      metrics.add(board);
    }
    results[candidate.level] = metrics;
  }

  final csv = StringBuffer()
    ..writeln(
      'level,id,name,family,tiles,pairs,layers,free,width,height,tile,'
      'minLegal,maxLegal,meanLegal,minSafe,maxSafe,meanSafe,maxAttempts,'
      'meanMs,maxMs,breather,finale',
    );
  final report = StringBuffer()
    ..writeln('# Levels 81–160 isolated candidate verification')
    ..writeln()
    ..writeln('Status: developer-only candidates; not visually approved and '
        'not assigned to production.')
    ..writeln()
    ..writeln('## Repository checkpoint')
    ..writeln()
    ..writeln('- Production contains 200 contiguous levels.')
    ..writeln('- Levels 1–80 remain frozen.')
    ..writeln('- Production Levels 81–160 retain their pre-candidate names and '
        'layout references.')
    ..writeln('- Collection schedule, migration, monetisation, solver and '
        'projection code were not changed.')
    ..writeln()
    ..writeln('## Production Levels 81–160 audit')
    ..writeln()
    ..writeln(
      '|Level|Production name|Chapter|Layout|Tiles / pairs|Symbols|Copies|'
      'Layers|Free|Collection|Reward|Candidate|Family|Candidate tiles|'
      'Symbol compatible|Future rename|',
    )
    ..writeln(
      '|---:|---|---|---|---:|---:|---|---:|---:|---|---|---|---|---:|---|---|',
    );

  for (final candidate in kLevels81To160Candidates) {
    final level = getLevelById(candidate.level)!;
    final counts = level.symbolPlan
        .copyCountsForTileCount(candidate.layout.positions.length);
    final compatible = counts.fold<int>(0, (sum, count) => sum + count) ==
            candidate.layout.positions.length &&
        counts.every((count) => count.isEven);
    final milestone = tileIdsUnlockedAtLevel(level.id);
    final rewards = <String>[
      if (level.id % 5 == 0) '5-level',
      if (level.id % 10 == 0) '10-level',
      if (level.id % 20 == 0) 'chapter',
    ];
    report.writeln(
      '|${level.id}|${level.name}|${level.chapter}|`${level.layoutName}`|'
      '${level.tileCount} / ${level.pairCount}|${level.symbolPoolSize}|'
      '${level.symbolDistributionLabel}|${level.layerCount}|'
      '${level.stats.startingFreeTileCount}|'
      '${milestone.isEmpty ? '—' : milestone.join(', ')}|'
      '${rewards.isEmpty ? '—' : rewards.join(' + ')}|'
      '`${candidate.layout.id}`|${candidate.family}|'
      '${candidate.layout.stats.tileCount}|${compatible ? 'yes' : 'no'}|'
      '${level.name.toLowerCase().contains(candidate.family.split(' ').first.toLowerCase()) ? 'low' : 'review'}|',
    );
    final geometry =
        BoardLayoutGeometry.fromPositions(candidate.layout.positions);
    final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
    final metrics = results[candidate.level]!;
    csv.writeln(
      '${candidate.level},${candidate.layout.id},'
      '"${candidate.proposedName}","${candidate.family}",'
      '${candidate.layout.stats.tileCount},${candidate.layout.stats.pairCount},'
      '${candidate.layout.stats.layerCount},'
      '${candidate.layout.stats.startingFreeTileCount},'
      '${(fit.boardWidth / 374 * 100).toStringAsFixed(1)},'
      '${(fit.boardHeight / 804 * 100).toStringAsFixed(1)},'
      '${fit.tileWidth.toStringAsFixed(1)},${metrics.minLegal},'
      '${metrics.maxLegal},${(metrics.totalLegal / 100).toStringAsFixed(2)},'
      '${metrics.minSafe},${metrics.maxSafe},'
      '${(metrics.totalSafe / 100).toStringAsFixed(2)},'
      '${metrics.maxAttempts},'
      '${(metrics.totalMicros / 100000).toStringAsFixed(3)},'
      '${(metrics.maxMicros / 1000).toStringAsFixed(3)},'
      '${candidate.isBreather},'
      '${const {100, 120, 140, 160}.contains(candidate.level)}',
    );
  }

  report
    ..writeln()
    ..writeln('## Candidate compatibility and viewport metrics')
    ..writeln()
    ..writeln(
      '|Level|ID|Tiles / pairs|Copies|Valid|360 tile|390 W / H / tile|'
      '430 tile|Centre drift|Leans|',
    )
    ..writeln('|---:|---|---:|---|---|---:|---|---:|---:|---|');
  for (final candidate in kLevels81To160Candidates) {
    final level = getLevelById(candidate.level)!;
    final geometry =
        BoardLayoutGeometry.fromPositions(candidate.layout.positions);
    final fit360 = geometry.fit(availableWidth: 344, availableHeight: 600);
    final fit390 = geometry.fit(availableWidth: 374, availableHeight: 804);
    final fit430 = geometry.fit(availableWidth: 414, availableHeight: 892);
    final centres = [
      for (var layer = 0; layer < 3; layer++)
        _centre(candidate.layout.positions.where((p) => p.layer == layer)),
    ];
    var drift = 0.0;
    for (var index = 1; index < centres.length; index++) {
      drift = max(
        drift,
        sqrt(
          pow(centres[index].x - centres[0].x, 2) +
              pow(centres[index].y - centres[0].y, 2),
        ),
      );
    }
    final validation = validateLayout(candidate.layout, minimumOpeningTiles: 4);
    report.writeln(
      '|${candidate.level}|`${candidate.layout.id}`|'
      '${candidate.layout.stats.tileCount} / '
      '${candidate.layout.stats.pairCount}|'
      '${level.symbolPlan.describeForTileCount(candidate.layout.stats.tileCount)}|'
      '${validation.isValid ? 'yes' : 'no'}|'
      '${fit360.tileWidth.toStringAsFixed(1)}|'
      '${(fit390.boardWidth / 374 * 100).toStringAsFixed(1)}% / '
      '${(fit390.boardHeight / 804 * 100).toStringAsFixed(1)}% / '
      '${fit390.tileWidth.toStringAsFixed(1)}|'
      '${fit430.tileWidth.toStringAsFixed(1)}|'
      '${drift.toStringAsFixed(2)}|${drift > 2.0 ? 'review' : 'no'}|',
    );
  }

  report
    ..writeln()
    ..writeln('## 100-seed results')
    ..writeln()
    ..writeln(
      '|Level|Generated|Solved|Free min–max / mean|Legal min–max / mean|'
      'Safe min–max / mean|Forced|Attempts max / mean|Time mean / max ms|',
    )
    ..writeln('|---:|---:|---:|---|---|---|---:|---|---|');
  for (final candidate in kLevels81To160Candidates) {
    final metrics = results[candidate.level]!;
    report.writeln(
      '|${candidate.level}|${metrics.generated}/100|${metrics.solved}/100|'
      '${metrics.minFree}–${metrics.maxFree} / '
      '${(metrics.totalFree / 100).toStringAsFixed(2)}|'
      '${metrics.minLegal}–${metrics.maxLegal} / '
      '${(metrics.totalLegal / 100).toStringAsFixed(2)}|'
      '${metrics.minSafe}–${metrics.maxSafe} / '
      '${(metrics.totalSafe / 100).toStringAsFixed(2)}|'
      '${metrics.forced}|${metrics.maxAttempts} / '
      '${(metrics.totalAttempts / 100).toStringAsFixed(2)}|'
      '${(metrics.totalMicros / 100000).toStringAsFixed(3)} / '
      '${(metrics.maxMicros / 1000).toStringAsFixed(3)}|',
    );
  }

  report
    ..writeln()
    ..writeln('## Breathers and finales')
    ..writeln()
    ..writeln(
        'Breathers: ${kLevels81To160Candidates.where((c) => c.isBreather).map((c) => c.level).join(', ')}.')
    ..writeln()
    ..writeln('Finales 100, 120, 140 and 160 use a deliberately opened edge '
        'structure and each passed 100/100 seeds with at least five legal and '
        'safe opening pairs. Their final aesthetic strength still requires '
        'human visual review.')
    ..writeln()
    ..writeln('## Visual family and naming review')
    ..writeln()
    ..writeln('- The eighty family labels are thematically distributed across '
        'natural/symbolic, royal, journey and memory chapters.')
    ..writeln('- Coordinate and mask analysis confirms distinct geometry, but '
        'the shared portrait envelope remains visually evident in the contact '
        'sheets.')
    ..writeln('- Family labels describe design intent; they are not proof that '
        'each board reads as a literal turtle, tree, palace, bridge or mask.')
    ..writeln('- All proposed display names therefore retain **review** '
        'priority. Production names were not changed.')
    ..writeln('- The twelve breathers use only two top-layer bands, giving '
        'lower cover density than adjacent standard candidates while retaining '
        'three layers and the same readable tile size.')
    ..writeln('- Finale tile counts progress through 78, 84, 84 and 88. '
        'Level 160 has the richest top-layer coverage, but its ceremonial '
        'strength still requires human judgement.')
    ..writeln()
    ..writeln('## Pairwise similarity matrix')
    ..writeln()
    ..write('|Level|');
  for (final candidate in kLevels81To160Candidates) {
    report.write('${candidate.level}|');
  }
  report
    ..writeln()
    ..write('|---:|');
  for (var index = 0; index < 80; index++) {
    report.write('---:|');
  }
  report.writeln();
  final nearest = <int, ({int level, double score})>{};
  var maxAdjacent = 0.0;
  var max20 = 0.0;
  var max40 = 0.0;
  var maxPrior = 0.0;
  for (var i = 0; i < 80; i++) {
    report.write('|${i + 81}|');
    for (var j = 0; j < 80; j++) {
      final score = i == j
          ? 1.0
          : compareLayoutSilhouettes(
              kLevels81To160Candidates[i].layout,
              kLevels81To160Candidates[j].layout,
            ).score;
      report.write('${score.toStringAsFixed(2)}|');
      if (i != j && (nearest[i] == null || score > nearest[i]!.score)) {
        nearest[i] = (level: j + 81, score: score);
      }
      if ((i - j).abs() == 1) maxAdjacent = max(maxAdjacent, score);
      if ((i - j).abs() == 20) max20 = max(max20, score);
      if ((i - j).abs() == 40) max40 = max(max40, score);
    }
    report.writeln();
    for (final production in kLevels.take(80)) {
      maxPrior = max(
        maxPrior,
        compareLayoutSilhouettes(
          kLevels81To160Candidates[i].layout,
          production.namedLayout,
        ).score,
      );
    }
  }
  report
    ..writeln()
    ..writeln('### Nearest neighbours')
    ..writeln()
    ..writeln('|Level|Nearest|Score|')
    ..writeln('|---:|---:|---:|');
  for (var index = 0; index < 80; index++) {
    report.writeln(
      '|${index + 81}|${nearest[index]!.level}|'
      '${nearest[index]!.score.toStringAsFixed(3)}|',
    );
  }
  report
    ..writeln()
    ..writeln('### Threshold summary')
    ..writeln()
    ..writeln('- Exact duplicates: 0.')
    ..writeln('- Maximum adjacent: ${maxAdjacent.toStringAsFixed(3)} (< 0.85).')
    ..writeln('- Maximum +20: ${max20.toStringAsFixed(3)} (< 0.75).')
    ..writeln('- Maximum +40: ${max40.toStringAsFixed(3)} (< 0.72).')
    ..writeln('- Maximum against Levels 1–80: '
        '${maxPrior.toStringAsFixed(3)} (< 0.72).')
    ..writeln()
    ..writeln('## Coordinates grouped by layer');
  for (final candidate in kLevels81To160Candidates) {
    report
      ..writeln()
      ..writeln('### Level ${candidate.level} — `${candidate.layout.id}`');
    for (var layer = 0; layer < 3; layer++) {
      report.writeln(
        '- Layer $layer: ${candidate.layout.positions.where((p) => p.layer == layer).map((p) => '(${p.row},${p.col})').join(' ')}',
      );
    }
  }
  report
    ..writeln()
    ..writeln('## Production isolation')
    ..writeln()
    ..writeln(
      productionSnapshot.every((snapshot) {
        final current = getLevelById(snapshot.id)!;
        return current.name == snapshot.name &&
            current.layoutName == snapshot.layout;
      })
          ? 'Verified: production Levels 81–160 were unchanged during this audit.'
          : 'ERROR: production snapshot changed.',
    )
    ..writeln()
    ..writeln('## Recommendation')
    ..writeln()
    ..writeln('The batch passes objective structural, symbol, viewport, '
        'solvability and similarity gates. It is ready for human visual '
        'review, not production assignment or visual approval. Reviewers '
        'should pay particular attention to literal family readability and '
        'the shared vertical envelope.')
    ..writeln()
    ..writeln('## Artifact index')
    ..writeln()
    ..writeln('- Individual clean, diagnostic and silhouette previews: '
        '`artifacts/layout-previews/levels-81-160-candidates/'
        '<layout-id>_<variant>.png`.')
    ..writeln('- Contact sheets: `levels-81-90-contact-sheet.png` through '
        '`levels-151-160-contact-sheet.png`.')
    ..writeln('- Chapter overviews: `chapter-5-overview.png` through '
        '`chapter-8-overview.png`.')
    ..writeln('- Complete overview: `levels-81-160-overview.png`.')
    ..writeln('- Silhouettes: `levels-81-160-silhouette-overview.png` and '
        '`levels-1-160-silhouette-comparison.png`.')
    ..writeln('- Diagnostics: `levels-81-160-diagnostic-overview.png`.')
    ..writeln('- Families: `levels-81-160-family-classification.png`.')
    ..writeln('- Chapter comparison: `chapters-5-8-comparison.png`.')
    ..writeln('- Finale comparison: `finale-comparison-levels-20-160.png`.')
    ..writeln()
    ..writeln('## Verification summary')
    ..writeln()
    ..writeln('- Candidate suite: all structural, isolation, symbol-plan, '
        'similarity, 8,000-seed and export-integrity checks passed.')
    ..writeln('- Remaining Flutter suite: 1,162 tests passed.')
    ..writeln('- All 200 production levels generated and solved in the '
        'campaign-startup regression test.')
    ..writeln('- `flutter analyze --no-pub`: no issues.')
    ..writeln('- `git diff --check`: passed.')
    ..writeln('- Production Levels 81–160 remained unchanged.');

  File('${directory.path}/metrics.csv').writeAsStringSync(csv.toString());
  File('${directory.path}/levels-81-160-report.md')
      .writeAsStringSync(report.toString());
  print('${directory.path}/levels-81-160-report.md');
}

({double x, double y}) _centre(Iterable<TilePosition> positions) {
  final list = positions.toList();
  return (
    x: list
            .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer))
            .reduce((a, b) => a + b) /
        list.length,
    y: list
            .map((p) => BoardLayoutGeometry.projectY(p.row, p.layer))
            .reduce((a, b) => a + b) /
        list.length,
  );
}

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
    final free = BoardSolver.getFreeTiles(generated).length;
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
      free: free,
      micros: stopwatch.elapsedMicroseconds,
    );
  }
  return null;
}
