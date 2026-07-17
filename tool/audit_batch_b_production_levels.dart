// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  final output = StringBuffer()
    ..writeln(
      'level,name,chapter,layout,tiles,pairs,symbols,copies,difficulty,layers,'
      'free,min_legal,max_legal,min_safe,max_safe,tile_milestone,reward',
    );
  for (var id = 6; id <= 20; id++) {
    final level = getLevelById(id)!;
    final legalCounts = <int>[];
    final safeCounts = <int>[];
    for (var seed = 0; seed < 20; seed++) {
      final tiles = _reverseSolved(level, seed)!;
      final legal = BoardSolver.findAvailableMatchingPairs(tiles);
      legalCounts.add(legal.length);
      safeCounts.add(legal
          .where((pair) => BoardSolver.isSafeMove(
                tiles,
                pair.first,
                pair.second,
                maxSearchNodes: 25000,
              ))
          .length);
    }
    final reward = [
      if (id % 5 == 0) '5-level',
      if (id % 10 == 0) '10-level',
      if (id == 20) 'chapter-proposed',
    ].join('+');
    output.writeln([
      id,
      level.name,
      level.chapter,
      level.layoutName,
      level.tileCount,
      level.pairCount,
      level.symbolPoolSize,
      level.symbolDistributionLabel,
      level.difficultyCategory,
      level.layerCount,
      level.stats.startingFreeTileCount,
      legalCounts.reduce(min),
      legalCounts.reduce(max),
      safeCounts.reduce(min),
      safeCounts.reduce(max),
      tileIdsUnlockedAtLevel(id).join('|'),
      reward.isEmpty ? 'normal' : reward,
    ].join(','));
  }
  final file = File('artifacts/layout-previews/batch-b/production-audit.csv');
  file.writeAsStringSync(output.toString());
  print(output);
}

List<TileModel>? _reverseSolved(LevelDefinition level, int seed) {
  final rng = Random(seed);
  for (var attempt = 0; attempt < 100; attempt++) {
    var remaining = <TileModel>[
      for (var i = 0; i < level.layout.length; i++)
        TileModel(
          uid: 'remaining_${attempt}_$i',
          def: kAllTiles.first,
          row: level.layout[i].row,
          col: level.layout[i].col,
          layer: level.layout[i].layer,
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
    final definitions = <TileDefinition>[];
    final counts = level.symbolCopyCounts;
    for (var symbol = 0; symbol < counts.length; symbol++) {
      definitions.addAll(List.filled(counts[symbol],
          kAllTiles[(level.symbolStartIndex + symbol) % kAllTiles.length]));
    }
    return [
      for (var i = 0; i < order.length; i++)
        TileModel(
          uid: 'generated_$i',
          def: definitions[i],
          row: order[i].row,
          col: order[i].col,
          layer: order[i].layer,
        ),
    ];
  }
  return null;
}
