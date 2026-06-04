import 'dart:math';
import 'dart:io';

import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

const _maxGenerationAttempts = 12;
const _maxReverseSolvedAttempts = 100;
const _generationSearchNodes = 6000;
const _reverseSolvedTileThreshold = 40;

void main() {
  for (final levelId in [1, 5, 6, 10, 15, 20]) {
    _benchmarkLevel(levelId);
  }
}

void _benchmarkLevel(int levelId) {
  final total = Stopwatch()..start();
  final level = getLevelById(levelId)!;
  final definitionsById = {for (final tile in kAllTiles) tile.id: tile};
  final tileDefs = level.tileIds
      .map((id) => definitionsById[id])
      .whereType<TileDefinition>()
      .toList();
  final selectedPairs = [
    for (var i = 0; i < level.tileCount ~/ 2; i++)
      tileDefs[i % tileDefs.length],
  ];
  final rng = Random(1000 + levelId);

  var attempts = 0;
  var solverMs = 0;
  var solverNodes = 0;
  var fallback = false;
  var strategy = 'random';
  List<TileModel>? tiles;

  final generation = Stopwatch()..start();
  if (level.tileCount >= _reverseSolvedTileThreshold) {
    strategy = 'reverseSolved';
    tiles = _buildReverseSolvedBoard(selectedPairs, level.layout, rng);
  } else {
    for (var attempt = 1; attempt <= _maxGenerationAttempts; attempt++) {
      attempts = attempt;
      final candidate = _buildRandomBoard(selectedPairs, level.layout, rng);
      final profile = BoardSolver.profileSolvability(
        candidate,
        maxSearchNodes: _generationSearchNodes,
      );
      solverMs += profile.elapsed.inMilliseconds;
      solverNodes += profile.nodesVisited;
      if (profile.isSolvable) {
        tiles = candidate;
        break;
      }
    }

    if (tiles == null) {
      fallback = true;
      strategy = 'reverseSolved';
      tiles = _buildReverseSolvedBoard(selectedPairs, level.layout, rng);
    }
  }
  generation.stop();

  final finalProfile = BoardSolver.profileSolvability(tiles);
  total.stop();
  stdout.writeln(
    '[LEVEL_LOAD] level=$levelId tiles=${tiles.length} '
    'generateBoard=${generation.elapsedMilliseconds}ms '
    'solvabilityChecks=${solverMs}ms nodes=$solverNodes attempts=$attempts '
    'strategy=$strategy fallback=$fallback '
    'finalCheck=${finalProfile.elapsed.inMilliseconds}ms '
    'finalNodes=${finalProfile.nodesVisited} total=${total.elapsedMilliseconds}ms',
  );
}

List<TileModel> _buildRandomBoard(
  List<TileDefinition> selectedPairs,
  List<TilePosition> layout,
  Random rng,
) {
  final finalDefs = [...selectedPairs, ...selectedPairs]..shuffle(rng);
  final safeLength = layout.length.clamp(0, finalDefs.length);
  return List.generate(
    safeLength,
    (i) => TileModel(
      def: finalDefs[i],
      row: layout[i].row,
      col: layout[i].col,
      layer: layout[i].layer,
    ),
  );
}

List<TileModel> _buildReverseSolvedBoard(
  List<TileDefinition> selectedPairs,
  List<TilePosition> layout,
  Random rng,
) {
  final seedDef = selectedPairs.first;
  for (var attempt = 1; attempt <= _maxReverseSolvedAttempts; attempt++) {
    var remaining = [
      for (final position in layout)
        TileModel(
          def: seedDef,
          row: position.row,
          col: position.col,
          layer: position.layer,
        ),
    ];
    final removalOrder = <({int row, int col, int layer})>[];

    while (remaining.isNotEmpty) {
      final freeTiles = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (freeTiles.length < 2) break;
      final first = freeTiles[0];
      final second = freeTiles[1];
      removalOrder.add((row: first.row, col: first.col, layer: first.layer));
      removalOrder.add((row: second.row, col: second.col, layer: second.layer));
      remaining = remaining
          .where((tile) => tile.uid != first.uid && tile.uid != second.uid)
          .toList();
    }

    if (remaining.isNotEmpty) continue;

    final shuffledPairs = [...selectedPairs]..shuffle(rng);
    return [
      for (var i = 0; i < shuffledPairs.length; i++) ...[
        TileModel(
          def: shuffledPairs[i],
          row: removalOrder[i * 2].row,
          col: removalOrder[i * 2].col,
          layer: removalOrder[i * 2].layer,
        ),
        TileModel(
          def: shuffledPairs[i],
          row: removalOrder[i * 2 + 1].row,
          col: removalOrder[i * 2 + 1].col,
          layer: removalOrder[i * 2 + 1].layer,
        ),
      ],
    ];
  }

  throw StateError('Layout has no reverse-solved removal order.');
}
