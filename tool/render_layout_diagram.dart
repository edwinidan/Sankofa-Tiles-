// ignore_for_file: avoid_print

// Renders a NamedLayout as an ASCII diagram and coordinate listing.
// Usage: dart run tool/render_layout_diagram.dart
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  final layout = pilotSmallDiamondLayout;
  final positions = layout.positions;
  final stats = layout.stats;

  // --- Technical statistics ---
  print('═══════════════════════════════════════════');
  print('  PILOT LAYOUT: ${layout.name}');
  print('  ID: ${layout.id}');
  print('═══════════════════════════════════════════');
  print('');
  print('TECHNICAL STATISTICS');
  print('────────────────────');
  print('Tile count:       ${stats.tileCount}');
  print('Pair count:       ${stats.pairCount}');
  print('Layer count:      ${stats.layerCount}');
  print('Board width:      ${stats.boardWidth} cols');
  print('Board height:     ${stats.boardHeight} rows');
  print('Min col:          ${stats.minCol}');
  print('Max col:          ${stats.maxCol}');
  print('Min row:          ${stats.minRow}');
  print('Max row:          ${stats.maxRow}');
  print('Max layer:        ${stats.maxLayer}');
  print('Start free tiles: ${stats.startingFreeTileCount}');

  // Odd coordinate count
  final oddRows = positions.where((p) => p.row.isOdd).map((p) => p.row).toSet();
  final oddCols = positions.where((p) => p.col.isOdd).map((p) => p.col).toSet();
  final sortedOddRows = oddRows.toList()..sort();
  final sortedOddCols = oddCols.toList()..sort();
  print('Odd row values:   ${oddRows.length} ($sortedOddRows)');
  print('Odd col values:   ${oddCols.length} ($sortedOddCols)');
  final oddRowTiles = positions.where((p) => p.row.isOdd).length;
  final oddColTiles = positions.where((p) => p.col.isOdd).length;
  print('Tiles w/ odd row: $oddRowTiles');
  print('Tiles w/ odd col: $oddColTiles');

  // Support validation
  int unsupported = 0;
  for (final pos in positions.where((p) => p.layer > 0)) {
    final hasSupport = positions.any((other) =>
        other.layer == pos.layer - 1 &&
        _overlaps(pos.row, pos.col, other.row, other.col));
    if (!hasSupport) {
      unsupported++;
      print('WARNING: Floating tile at (${pos.row},${pos.col},L${pos.layer})');
    }
  }
  print('Unsupported tiles: $unsupported');
  print('Support validation: ${unsupported == 0 ? "PASS" : "FAIL"}');

  // Opening geometry
  final openingTiles = List.generate(
    positions.length,
    (i) => TileModel(
      def: kAllTiles.first,
      row: positions[i].row,
      col: positions[i].col,
      layer: positions[i].layer,
      uid: 'diag_$i',
    ),
  );
  final free = BoardSolver.getFreeTiles(openingTiles);
  final freeUids = free.map((t) => t.uid).toSet();
  print('Starting free:    ${free.length}');
  print('');

  // --- Per-layer coordinate listing ---
  for (var layer = 0; layer <= stats.maxLayer; layer++) {
    final layerPositions = positions.where((p) => p.layer == layer).toList()
      ..sort((a, b) {
        final r = a.row.compareTo(b.row);
        if (r != 0) return r;
        return a.col.compareTo(b.col);
      });

    print('Layer $layer (${layerPositions.length} tiles):');
    print('─' * 50);

    // Mark which are free (not covered from above, not boxed in).
    for (final pos in layerPositions) {
      final tile = openingTiles.firstWhere(
        (t) => t.row == pos.row && t.col == pos.col && t.layer == pos.layer,
      );
      final isFree = freeUids.contains(tile.uid);
      final marker = pos.row.isOdd || pos.col.isOdd ? ' ◀ half-offset' : '';
      final freeMark = isFree ? ' [FREE]' : ' [BLOCKED]';
      print(
          '  (r=${pos.row.toString().padLeft(2)}, c=${pos.col.toString().padLeft(2)})$freeMark$marker');
    }
    print('');
  }

  // --- Opening matching moves ---
  final pairs = BoardSolver.findAvailableMatchingPairs(openingTiles);
  final freePairs = pairs
      .where((p) =>
          freeUids.contains(p.first.uid) && freeUids.contains(p.second.uid))
      .toList();
  print(
      'Starting matching pairs (all use same symbol in test): ${freePairs.length}');
  print('');

  // --- ASCII top-down diagram ---
  print('═══ ASCII TOP-DOWN DIAGRAM ═══');
  print('Legend: 0/1/2 = layer, · = empty, [F] = free');
  print('');
  for (var layer = 0; layer <= stats.maxLayer; layer++) {
    print('─── Layer $layer ───');
    _renderLayer(positions, layer, freeUids, openingTiles);
    print('');
  }

  // --- Combined multi-layer ASCII ---
  print('═══ COMBINED VIEW (all layers) ═══');
  print('Legend: digit = layer, · = empty, _ = multiple layers');
  _renderCombined(positions);

  // --- Viewport fit report ---
  print('');
  print('═══ VIEWPORT FIT ═══');
  final geometry = BoardLayoutGeometry.fromPositions(positions);
  for (final vp in kRequiredBoardViewports) {
    final fit = geometry.fit(
      availableWidth: vp.width,
      availableHeight: vp.height,
    );
    print('${vp.name} (${vp.width}x${vp.height}):');
    print(
        '  Tile: ${fit.tileWidth.toStringAsFixed(1)}x${fit.tileHeight.toStringAsFixed(1)} px');
    print(
        '  Board: ${fit.boardWidth.toStringAsFixed(1)}x${fit.boardHeight.toStringAsFixed(1)} px');
    print('  Fits: ${fit.fitsSafely ? "YES" : "NO"}');
  }

  // --- Solvability simulation ---
  print('');
  print('═══ SOLVABILITY ═══');

  // Simple check: build a board with all-same-symbol and verify free tiles exist
  final allSame = List.generate(
    positions.length,
    (i) => TileModel(
      def: kAllTiles.first,
      row: positions[i].row,
      col: positions[i].col,
      layer: positions[i].layer,
      uid: 'solv_$i',
    ),
  );
  final profile = BoardSolver.profileSolvability(allSame);
  print('All-same-symbol solvable: ${profile.isSolvable}');
  print('Search nodes: ${profile.nodesVisited}');
  print('Search time: ${profile.elapsed.inMilliseconds} ms');
}

void _renderLayer(
  List<TilePosition> positions,
  int layer,
  Set<String> freeUids,
  List<TileModel> tiles,
) {
  final layerPositions = positions.where((p) => p.layer == layer).toList();
  if (layerPositions.isEmpty) {
    print('  (empty)');
    return;
  }

  final minRow =
      layerPositions.map((p) => p.row).reduce((a, b) => a < b ? a : b);
  final maxRow =
      layerPositions.map((p) => p.row).reduce((a, b) => a > b ? a : b);
  final minCol =
      layerPositions.map((p) => p.col).reduce((a, b) => a < b ? a : b);
  final maxCol =
      layerPositions.map((p) => p.col).reduce((a, b) => a > b ? a : b);

  final posSet = <String>{};
  for (final p in layerPositions) {
    posSet.add('${p.row},${p.col}');
  }

  // Header row
  var header = '     ';
  for (var col = minCol; col <= maxCol; col++) {
    if (col.isEven) {
      header += col.toString().padLeft(2);
    } else {
      header += '  ';
    }
  }
  print(header);

  for (var row = minRow; row <= maxRow; row++) {
    var line = 'r${row.toString().padLeft(2)}  ';
    for (var col = minCol; col <= maxCol; col++) {
      if (posSet.contains('$row,$col')) {
        final tile = tiles.firstWhere(
          (t) => t.row == row && t.col == col && t.layer == layer,
          orElse: () => tiles.first,
        );
        final isFree = freeUids.contains(tile.uid);
        line += isFree ? '▓▓' : '██';
      } else {
        line += '··';
      }
    }
    print(line);
  }
  print('     ▓▓ = free/selectable, ██ = blocked');
}

void _renderCombined(List<TilePosition> positions) {
  final minRow = positions.map((p) => p.row).reduce((a, b) => a < b ? a : b);
  final maxRow = positions.map((p) => p.row).reduce((a, b) => a > b ? a : b);
  final minCol = positions.map((p) => p.col).reduce((a, b) => a < b ? a : b);
  final maxCol = positions.map((p) => p.col).reduce((a, b) => a > b ? a : b);

  // Build lookup: (row, col) -> [layers]
  final map = <String, List<int>>{};
  for (final p in positions) {
    final key = '${p.row},${p.col}';
    map.putIfAbsent(key, () => []).add(p.layer);
  }

  var header = '     ';
  for (var col = minCol; col <= maxCol; col += 2) {
    header += col.toString().padLeft(3);
  }
  print(header);

  for (var row = minRow; row <= maxRow; row++) {
    var line = 'r${row.toString().padLeft(2)}  ';
    for (var col = minCol; col <= maxCol; col++) {
      final key = '$row,$col';
      final layers = map[key];
      if (layers == null || layers.isEmpty) {
        line += ' · ';
      } else if (layers.length == 1) {
        final l = layers.first;
        // Visual distinction for odd-offset tiles
        if (row.isOdd || col.isOdd) {
          line += '\x1b[33m $l \x1b[0m'; // Yellow for half-tile
        } else {
          line += ' $l ';
        }
      } else {
        line += '\x1b[36m${layers.length}\x1b[0m'; // Cyan for multi-layer stack
      }
    }
    print(line);
  }
  print('     Digit = layer number, · = empty');
  print('     Yellow = half-tile offset (odd row/col)');
  print('     Cyan = multi-layer stack');
}

bool _overlaps(int rowA, int colA, int rowB, int colB) {
  return _axisOverlaps(rowA, rowB) && _axisOverlaps(colA, colB);
}

bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
}
