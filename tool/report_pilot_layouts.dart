// ignore_for_file: avoid_print

import 'dart:math';

import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  for (final layout in [
    earlyOpenDiamond01Layout,
    earlyOpenDiamond02Layout,
    earlyShrine01Layout,
    earlyBridge01Layout,
    earlyLayeredDiamond01Layout,
  ]) {
    _report(layout);
  }
}

void _report(NamedLayout layout) {
  final validation = validateLayout(layout, minimumOpeningTiles: 4);
  final opening = _tiles(layout.positions, sameSymbol: true);
  final free = BoardSolver.getFreeTiles(opening);
  final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
  print('\n${layout.id}|${layout.name}');
  print(
      'tiles=${layout.positions.length} pairs=${layout.positions.length ~/ 2} '
      'layers=${layout.stats.layerCount} free=${free.length} '
      'oddRows=${layout.positions.where((p) => p.row.isOdd).length} '
      'oddCols=${layout.positions.where((p) => p.col.isOdd).length} '
      'valid=${validation.isValid}');
  print(
      'bounds=${geometry.minX.toStringAsFixed(3)},${geometry.minY.toStringAsFixed(3)} '
      '${geometry.maxX.toStringAsFixed(3)},${geometry.maxY.toStringAsFixed(3)} '
      'size=${geometry.widthInTileUnits.toStringAsFixed(3)}x'
      '${geometry.heightInTileUnits.toStringAsFixed(3)}');
  for (var layer = 0; layer <= layout.stats.maxLayer; layer++) {
    final positions = layout.positions.where((p) => p.layer == layer).toList();
    final xs =
        positions.map((p) => BoardLayoutGeometry.projectX(p.col, p.layer));
    final minX = xs.reduce(min);
    final maxX = positions
        .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer) + 1)
        .reduce(max);
    final meanCentre = positions
            .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer) + .5)
            .reduce((a, b) => a + b) /
        positions.length;
    print(
        'layer$layer count=${positions.length} minX=${minX.toStringAsFixed(3)} '
        'maxX=${maxX.toStringAsFixed(3)} boxCentre=${((minX + maxX) / 2).toStringAsFixed(3)} '
        'meanCentre=${meanCentre.toStringAsFixed(3)}');
    print(
        '  ${positions.map((p) => '(${p.row},${p.col},${p.layer})').join(' ')}');
  }
  final seedCount = layout.id == earlyOpenDiamond02Layout.id ? 100 : 20;
  for (var seed = 0; seed < seedCount; seed++) {
    final stopwatch = Stopwatch()..start();
    final result = _reverseSolved(layout, seed, copiesPerSymbol: 4);
    stopwatch.stop();
    final tiles = result.tiles!;
    final legal = BoardSolver.findAvailableMatchingPairs(tiles);
    final safe = legal
        .where((pair) => BoardSolver.isSafeMove(tiles, pair.first, pair.second))
        .length;
    final profile = BoardSolver.profileSolvability(tiles);
    print('seed=$seed attempt=${result.attempts} ok=${profile.isSolvable} '
        'free=${BoardSolver.getFreeTiles(tiles).length} legal=${legal.length} safe=$safe '
        'nodes=${profile.nodesVisited} us=${stopwatch.elapsedMicroseconds}');
  }
}

List<TileModel> _tiles(List<TilePosition> positions,
        {bool sameSymbol = false}) =>
    [
      for (var i = 0; i < positions.length; i++)
        TileModel(
          uid: 'tile_$i',
          def: kAllTiles[sameSymbol ? 0 : (i ~/ 2) % kAllTiles.length],
          row: positions[i].row,
          col: positions[i].col,
          layer: positions[i].layer,
        ),
    ];

({List<TileModel>? tiles, int attempts}) _reverseSolved(
  NamedLayout layout,
  int seed, {
  int copiesPerSymbol = 2,
}) {
  final rng = Random(seed);
  for (var attempt = 1; attempt <= 100; attempt++) {
    var remaining = _tiles(layout.positions, sameSymbol: true);
    final order = <TileModel>[];
    while (remaining.isNotEmpty) {
      final free = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (free.length < 2) break;
      order.addAll([free[0], free[1]]);
      final removed = {free[0].uid, free[1].uid};
      remaining = remaining.where((t) => !removed.contains(t.uid)).toList();
    }
    if (remaining.isNotEmpty) continue;
    return (
      attempts: attempt,
      tiles: [
        for (var i = 0; i < order.length; i++)
          TileModel(
            uid: 'generated_$i',
            def: kAllTiles[(i ~/ copiesPerSymbol) % kAllTiles.length],
            row: order[i].row,
            col: order[i].col,
            layer: order[i].layer,
          ),
      ],
    );
  }
  return (tiles: null, attempts: 100);
}
