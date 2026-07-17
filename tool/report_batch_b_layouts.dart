// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/batch_b_layout_data.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  final output = StringBuffer()
    ..writeln(
      'level,layout_id,tiles,pairs,layers,free,generation_success,'
      'solvability_success,min_legal,max_legal,mean_legal,min_safe,max_safe,'
      'mean_safe,forced_seeds,max_attempts,max_generation_us,'
      'layer0_center,layer1_center,layer2_center,full_center,'
      'max_center_difference,pixel_difference_390x844,visible_lean,valid',
    );
  for (final candidate in kBatchBLayoutCandidates) {
    final layout = candidate.layout;
    final level = getLevelById(candidate.intendedLevel)!;
    var generationSuccess = 0;
    var solvabilitySuccess = 0;
    var maxAttempts = 0;
    var maxGenerationUs = 0;
    final legalCounts = <int>[];
    final safeCounts = <int>[];
    for (var seed = 0; seed < 100; seed++) {
      final watch = Stopwatch()..start();
      final generated = _reverseSolved(layout, level, seed);
      watch.stop();
      maxGenerationUs = max(maxGenerationUs, watch.elapsedMicroseconds);
      maxAttempts = max(maxAttempts, generated.attempts);
      final tiles = generated.tiles;
      if (tiles == null) continue;
      generationSuccess++;
      if (BoardSolver.isSolvable(tiles)) solvabilitySuccess++;
      final legal = BoardSolver.findAvailableMatchingPairs(tiles);
      final safe = legal
          .where((pair) => BoardSolver.isSafeMove(
                tiles,
                pair.first,
                pair.second,
                maxSearchNodes: 25000,
              ))
          .length;
      legalCounts.add(legal.length);
      safeCounts.add(safe);
    }
    final centers = [
      for (var layer = 0; layer < 3; layer++) _centre(layout, layer: layer),
    ];
    final full = _centre(layout);
    final maxDifference =
        centers.map((centre) => (centre.x - full.x).abs()).reduce(max);
    final fit = BoardLayoutGeometry.fromPositions(layout.positions).fit(
      availableWidth: 374,
      availableHeight: 780,
    );
    final pixelDifference = maxDifference * fit.tileWidth;
    final validation = validateLayout(layout, minimumOpeningTiles: 4);
    output.writeln([
      candidate.intendedLevel,
      layout.id,
      layout.stats.tileCount,
      layout.stats.pairCount,
      layout.stats.layerCount,
      layout.stats.startingFreeTileCount,
      generationSuccess,
      solvabilitySuccess,
      legalCounts.reduce(min),
      legalCounts.reduce(max),
      _mean(legalCounts).toStringAsFixed(2),
      safeCounts.reduce(min),
      safeCounts.reduce(max),
      _mean(safeCounts).toStringAsFixed(2),
      safeCounts.where((count) => count == 1).length,
      maxAttempts,
      maxGenerationUs,
      _label(centers[0]),
      _label(centers[1]),
      _label(centers[2]),
      _label(full),
      maxDifference.toStringAsFixed(3),
      pixelDifference.toStringAsFixed(1),
      pixelDifference > 18 ? 'review' : 'no',
      validation.isValid,
    ].join(','));
  }
  final file = File('artifacts/layout-previews/batch-b/metrics.csv');
  file.writeAsStringSync(output.toString());
  print(output);
}

({double x, double y}) _centre(NamedLayout layout, {int? layer}) {
  final positions = layer == null
      ? layout.positions
      : layout.positions.where((position) => position.layer == layer).toList();
  return (
    x: positions
            .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer) + .5)
            .reduce((a, b) => a + b) /
        positions.length,
    y: positions
            .map((p) =>
                BoardLayoutGeometry.projectY(p.row, p.layer) +
                kTileAspectRatio / 2)
            .reduce((a, b) => a + b) /
        positions.length,
  );
}

String _label(({double x, double y}) point) =>
    '${point.x.toStringAsFixed(3)};${point.y.toStringAsFixed(3)}';

double _mean(List<int> values) =>
    values.reduce((a, b) => a + b) / values.length;

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
    final counts =
        level.symbolPlan.copyCountsForTileCount(layout.positions.length);
    final definitions = <TileDefinition>[];
    for (var symbol = 0; symbol < counts.length; symbol++) {
      definitions.addAll(
        List.filled(counts[symbol], kAllTiles[symbol % kAllTiles.length]),
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
