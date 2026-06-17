import 'dart:math';

class TilePosition {
  final int row;
  final int col;
  final int layer;

  const TilePosition(this.row, this.col, this.layer);

  @override
  bool operator ==(Object other) {
    return other is TilePosition &&
        row == other.row &&
        col == other.col &&
        layer == other.layer;
  }

  @override
  int get hashCode => Object.hash(row, col, layer);
}

class NamedLayout {
  final String id;
  final String name;
  final List<TilePosition> positions;

  const NamedLayout({
    required this.id,
    required this.name,
    required this.positions,
  });

  LayoutStats get stats => LayoutStats.fromPositions(positions);
}

class LayoutStats {
  final int tileCount;
  final int pairCount;
  final int layerCount;
  final int minRow;
  final int maxRow;
  final int minCol;
  final int maxCol;
  final int maxLayer;
  final int boardWidth;
  final int boardHeight;
  final int startingFreeTileCount;

  const LayoutStats({
    required this.tileCount,
    required this.pairCount,
    required this.layerCount,
    required this.minRow,
    required this.maxRow,
    required this.minCol,
    required this.maxCol,
    required this.maxLayer,
    required this.boardWidth,
    required this.boardHeight,
    required this.startingFreeTileCount,
  });

  factory LayoutStats.fromPositions(List<TilePosition> positions) {
    if (positions.isEmpty) {
      return const LayoutStats(
        tileCount: 0,
        pairCount: 0,
        layerCount: 0,
        minRow: 0,
        maxRow: 0,
        minCol: 0,
        maxCol: 0,
        maxLayer: 0,
        boardWidth: 0,
        boardHeight: 0,
        startingFreeTileCount: 0,
      );
    }

    final layers = positions.map((position) => position.layer).toSet();
    final minRow = positions.map((position) => position.row).reduce(min);
    final maxRow = positions.map((position) => position.row).reduce(max);
    final minCol = positions.map((position) => position.col).reduce(min);
    final maxCol = positions.map((position) => position.col).reduce(max);
    final maxLayer = positions.map((position) => position.layer).reduce(max);

    return LayoutStats(
      tileCount: positions.length,
      pairCount: positions.length ~/ 2,
      layerCount: layers.length,
      minRow: minRow,
      maxRow: maxRow,
      minCol: minCol,
      maxCol: maxCol,
      maxLayer: maxLayer,
      boardWidth: maxCol - minCol + 2,
      boardHeight: maxRow - minRow + 2,
      startingFreeTileCount: positions
          .where((position) => _isPositionFree(position, positions))
          .length,
    );
  }
}

class LayoutBuildError extends Error {
  final String message;

  LayoutBuildError(this.message);

  @override
  String toString() => 'LayoutBuildError: $message';
}

class TileLayoutBuilder {
  final Set<TilePosition> _positions = {};

  TileLayoutBuilder add(TilePosition position) {
    if (!_positions.add(position)) {
      throw LayoutBuildError(
        'Duplicate tile coordinate '
        '(${position.row}, ${position.col}, ${position.layer})',
      );
    }
    return this;
  }

  TileLayoutBuilder addRow({
    required int row,
    required int startCol,
    required int count,
    int layer = 0,
    int step = 2,
  }) {
    for (var i = 0; i < count; i++) {
      add(TilePosition(row, startCol + i * step, layer));
    }
    return this;
  }

  TileLayoutBuilder addCenteredRows(
    List<int> rowCounts, {
    int centerCol = 20,
    int rowStart = 0,
    int layer = 0,
    int rowStep = 2,
  }) {
    for (var rowIndex = 0; rowIndex < rowCounts.length; rowIndex++) {
      final count = rowCounts[rowIndex];
      addRow(
        row: rowStart + rowIndex * rowStep,
        startCol: centerCol - (count - 1),
        count: count,
        layer: layer,
      );
    }
    return this;
  }

  TileLayoutBuilder addRectangle({
    required int rowStart,
    required int colStart,
    required int rows,
    required int cols,
    int layer = 0,
  }) {
    for (var row = 0; row < rows; row++) {
      addRow(
        row: rowStart + row * 2,
        startCol: colStart,
        count: cols,
        layer: layer,
      );
    }
    return this;
  }

  TileLayoutBuilder addTower({
    required int row,
    required int col,
    required int height,
    int width = 2,
  }) {
    for (var layer = 1; layer <= height; layer++) {
      addRow(
        row: row - layer,
        startCol: col - (width - 1),
        count: width,
        layer: layer,
      );
    }
    return this;
  }

  TileLayoutBuilder addBridge({
    required int row,
    required int fromCol,
    required int toCol,
    int layer = 0,
  }) {
    final start = min(fromCol, toCol);
    final end = max(fromCol, toCol);
    for (var col = start; col <= end; col += 2) {
      add(TilePosition(row, col, layer));
    }
    return this;
  }

  TileLayoutBuilder addAll(Iterable<TilePosition> positions) {
    for (final position in positions) {
      add(position);
    }
    return this;
  }

  List<TilePosition> build() {
    final positions = _positions.toList()
      ..sort((a, b) {
        final layerCompare = a.layer.compareTo(b.layer);
        if (layerCompare != 0) return layerCompare;
        final rowCompare = a.row.compareTo(b.row);
        if (rowCompare != 0) return rowCompare;
        return a.col.compareTo(b.col);
      });
    return List.unmodifiable(positions);
  }
}

List<TilePosition> translate(
  Iterable<TilePosition> positions, {
  int rows = 0,
  int cols = 0,
  int layers = 0,
}) {
  return [
    for (final position in positions)
      TilePosition(
        position.row + rows,
        position.col + cols,
        position.layer + layers,
      ),
  ];
}

List<TilePosition> mirrorHorizontally(
  Iterable<TilePosition> positions, {
  required int axisCol,
}) {
  return [
    for (final position in positions)
      TilePosition(position.row, axisCol * 2 - position.col, position.layer),
  ];
}

List<TilePosition> combineLayouts(Iterable<Iterable<TilePosition>> layouts) {
  final builder = TileLayoutBuilder();
  for (final layout in layouts) {
    builder.addAll(layout);
  }
  return builder.build();
}

List<TilePosition> centeredPyramid(
  List<List<int>> layerRows, {
  int centerCol = 20,
}) {
  final builder = TileLayoutBuilder();
  final baseRowCount = layerRows.first.length;
  for (var layer = 0; layer < layerRows.length; layer++) {
    builder.addCenteredRows(
      layerRows[layer],
      centerCol: centerCol,
      rowStart: baseRowCount - layerRows[layer].length,
      layer: layer,
    );
  }
  return builder.build();
}

List<TilePosition> splitIslands({
  required List<int> islandRows,
  required int gap,
  int centerCol = 20,
  int upperLayer = 1,
}) {
  final builder = TileLayoutBuilder();
  for (var rowIndex = 0; rowIndex < islandRows.length; rowIndex++) {
    final row = rowIndex * 2;
    final count = islandRows[rowIndex];
    builder
      ..addRow(row: row, startCol: centerCol - gap - count * 2, count: count)
      ..addRow(row: row, startCol: centerCol + gap, count: count);
  }
  final bridgeEnd = centerCol + gap - (gap.isEven ? 2 : 0);
  builder
    ..addBridge(
        row: islandRows.length * 2, fromCol: centerCol - gap, toCol: bridgeEnd)
    ..addCenteredRows([2, 2],
        centerCol: centerCol, rowStart: 2, layer: upperLayer);
  return builder.build();
}

List<TilePosition> wingedLayout({
  required List<int> bodyRows,
  required int wingRows,
  int centerCol = 20,
  int layerCount = 3,
}) {
  final builder = TileLayoutBuilder()
    ..addCenteredRows(bodyRows, centerCol: centerCol);

  for (var row = 0; row < wingRows; row++) {
    final y = 2 + row * 2;
    builder
      ..addRow(row: y, startCol: centerCol - 15 - row, count: 3)
      ..addRow(row: y, startCol: centerCol + 11 + row, count: 3);
  }

  for (var layer = 1; layer < layerCount; layer++) {
    builder.addCenteredRows(
      layer == 1 ? [4, 4, 4] : [2, 2],
      centerCol: centerCol,
      rowStart: 2 + layer,
      layer: layer,
    );
  }
  return builder.build();
}

List<TilePosition> courtyardLayout({
  required int width,
  required int height,
  int centerCol = 20,
  int towers = 2,
}) {
  final builder = TileLayoutBuilder();
  final left = centerCol - width + 1;
  final right = centerCol + width - 1;
  for (var row = 0; row < height; row++) {
    final y = row * 2;
    builder
      ..add(TilePosition(y, left, 0))
      ..add(TilePosition(y, right, 0));
    if (row == 0 || row == height - 1) {
      builder.addRow(row: y, startCol: left + 2, count: width - 2);
    }
  }
  builder
      .addCenteredRows([4, 6, 4], centerCol: centerCol, rowStart: 2, layer: 1);
  for (var i = 0; i < towers; i++) {
    final inset = 2 + (i ~/ 2) * 2;
    final col = i.isEven ? left + inset : right - inset;
    builder.addTower(row: height * 2, col: col, height: 2, width: 1);
  }
  return builder.build();
}

List<TilePosition> windingPathLayout({
  required int turns,
  int centerCol = 20,
}) {
  final builder = TileLayoutBuilder();
  var row = 0;
  var col = centerCol - 8;
  var direction = 1;
  for (var turn = 0; turn < turns; turn++) {
    builder.addBridge(row: row, fromCol: col, toCol: col + direction * 10);
    col += direction * 10;
    row += 2;
    builder.addRow(row: row, startCol: col, count: 2);
    direction *= -1;
    row += 2;
  }
  builder
    ..addCenteredRows([4, 4, 2], centerCol: centerCol, rowStart: 2, layer: 1)
    ..addCenteredRows([2, 2], centerCol: centerCol, rowStart: 4, layer: 2);
  return builder.build();
}

bool _isPositionFree(TilePosition position, List<TilePosition> positions) {
  const tileSpan = 2;
  final isCovered = positions.any(
    (other) =>
        other != position &&
        other.layer > position.layer &&
        _overlaps(position.row, position.col, other.row, other.col),
  );
  if (isCovered) return false;

  final leftBlocked = positions.any(
    (other) =>
        other != position &&
        other.layer == position.layer &&
        other.col + tileSpan == position.col &&
        _axisOverlaps(position.row, other.row),
  );
  final rightBlocked = positions.any(
    (other) =>
        other != position &&
        other.layer == position.layer &&
        other.col == position.col + tileSpan &&
        _axisOverlaps(position.row, other.row),
  );
  return !leftBlocked || !rightBlocked;
}

bool _overlaps(int rowA, int colA, int rowB, int colB) {
  return _axisOverlaps(rowA, rowB) && _axisOverlaps(colA, colB);
}

bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
}

NamedLayout namedLayout(String id, String name, List<TilePosition> positions) {
  final stats = LayoutStats.fromPositions(positions);
  if (stats.tileCount.isOdd) {
    throw LayoutBuildError('$id has an odd tile count: ${stats.tileCount}');
  }
  if (stats.startingFreeTileCount < 2) {
    throw LayoutBuildError('$id has no opening pair geometry');
  }
  return NamedLayout(id: id, name: name, positions: positions);
}

final compactDiamondLayout = namedLayout(
  'compactDiamond',
  'Compact Diamond',
  centeredPyramid([
    [2, 4, 6, 6, 4],
    [2, 2],
    [2],
  ]),
);

final beginnerBridgeLayout = namedLayout(
  'beginnerBridge',
  'Beginner Bridge',
  combineLayouts([
    splitIslands(islandRows: [2, 3, 3, 2], gap: 4),
    centeredPyramid([
      [2],
    ], centerCol: 20),
  ]),
);

final smallTurtleLayout = namedLayout(
  'smallTurtle',
  'Small Turtle',
  centeredPyramid([
    [2, 4, 6, 6, 4, 2],
    [2, 4, 2],
    [2],
  ]),
);

final firstCrossLayout = namedLayout(
  'firstCross',
  'First Cross',
  combineLayouts([
    centeredPyramid([
      [2, 4, 4, 4, 2],
      [2, 2],
    ]),
    [
      const TilePosition(4, 12, 0),
      const TilePosition(4, 28, 0),
      const TilePosition(4, 18, 2),
      const TilePosition(4, 22, 2),
    ],
  ]),
);

final smallShrineLayout = namedLayout(
  'smallShrine',
  'Small Shrine',
  centeredPyramid([
    [2, 4, 6, 8, 6, 4],
    [2, 4, 4],
    [2],
  ]),
);

final openCourtyardLayout = namedLayout(
  'openCourtyard',
  'Open Courtyard',
  courtyardLayout(width: 5, height: 4, towers: 1),
);

final riverPathLayout = namedLayout(
  'riverPath',
  'River Path',
  windingPathLayout(turns: 3),
);

final wisdomHouseLayout = namedLayout(
  'wisdomHouse',
  'Wisdom House',
  courtyardLayout(width: 6, height: 5, towers: 2),
);

final gatheringWingsLayout = namedLayout(
  'gatheringWings',
  'Gathering Wings',
  wingedLayout(bodyRows: [2, 4, 6, 6, 4, 2], wingRows: 2),
);

final elderBridgeLayout = namedLayout(
  'elderBridge',
  'Elder Bridge',
  splitIslands(islandRows: [3, 4, 4, 3, 2], gap: 5, upperLayer: 2),
);

final heritageTurtleLayout = namedLayout(
  'heritageTurtle',
  'Heritage Turtle',
  centeredPyramid([
    [2, 4, 6, 8, 8, 6, 4],
    [4, 4, 4],
    [2, 2],
  ]),
);

final butterflyLayout = namedLayout(
  'butterfly',
  'Butterfly',
  wingedLayout(bodyRows: [2, 4, 6, 8, 6, 4, 2], wingRows: 3),
);

final templeStepsLayout = namedLayout(
  'templeSteps',
  'Temple Steps',
  centeredPyramid([
    [4, 6, 8, 8, 6, 4],
    [2, 4, 4, 2],
    [2, 2],
    [2],
  ]),
);

final wisdomStaircaseLayout = namedLayout(
  'wisdomStaircase',
  'Wisdom Staircase',
  combineLayouts([
    centeredPyramid([
      [2, 4, 6, 8, 8, 6],
      [2, 4, 4],
      [2, 2],
    ]),
    [
      const TilePosition(0, 30, 0),
      const TilePosition(2, 32, 0),
      const TilePosition(4, 34, 0),
      const TilePosition(6, 36, 0),
    ],
  ]),
);

final crownLayout = namedLayout(
  'crown',
  'Crown',
  combineLayouts([
    centeredPyramid([
      [2, 4, 6, 8, 8, 6],
      [4, 4, 4],
      [2, 2],
    ]),
    [
      const TilePosition(0, 14, 1),
      const TilePosition(0, 20, 2),
      const TilePosition(0, 26, 1),
      const TilePosition(2, 20, 2),
    ],
  ]),
);

final sacredGroveLayout = namedLayout(
  'sacredGrove',
  'Sacred Grove',
  splitIslands(islandRows: [3, 5, 5, 5, 3], gap: 4, upperLayer: 2),
);

final royalStoolLayout = namedLayout(
  'royalStool',
  'Royal Stool',
  combineLayouts([
    centeredPyramid([
      [4, 6, 8, 8, 8, 6, 4],
      [4, 6, 4],
      [2, 2],
    ]),
    [
      const TilePosition(12, 16, 0),
      const TilePosition(12, 24, 0),
    ],
  ]),
);

final ancestralGateLayout = namedLayout(
  'ancestralGate',
  'Ancestral Gate',
  courtyardLayout(width: 7, height: 5, towers: 2),
);

final twinTowersLayout = namedLayout(
  'twinTowers',
  'Twin Towers',
  combineLayouts([
    splitIslands(islandRows: [3, 4, 5, 4, 3], gap: 5, upperLayer: 1),
    [
      const TilePosition(3, 12, 2),
      const TilePosition(3, 14, 2),
      const TilePosition(3, 26, 2),
      const TilePosition(3, 28, 2),
    ],
  ]),
);

final raisedCourtyardLayout = namedLayout(
  'raisedCourtyard',
  'Raised Courtyard',
  courtyardLayout(width: 7, height: 6, towers: 3),
);

final splitIslandsLayout = namedLayout(
  'splitIslands',
  'Split Islands',
  splitIslands(islandRows: [4, 5, 5, 4, 3, 2], gap: 6, upperLayer: 2),
);

final fortressLayout = namedLayout(
  'fortress',
  'Fortress',
  combineLayouts([
    courtyardLayout(width: 8, height: 6, towers: 4),
    translate(
      centeredPyramid([
        [2, 4],
        [2],
      ], centerCol: 20),
      layers: 2,
    ),
  ]),
);

final hiddenCenterLayout = namedLayout(
  'hiddenCenter',
  'Hidden Center',
  centeredPyramid([
    [2, 4, 6, 8, 10, 8, 6, 4],
    [4, 6, 6, 4],
    [2, 4, 2],
    [2],
  ]),
);

final festivalArchiveLayout = namedLayout(
  'festivalArchive',
  'Festival Archive',
  centeredPyramid([
    [8, 10, 10, 10, 10, 8],
    [4, 4, 4],
  ]),
);

final layeredCourtyardLayout = namedLayout(
  'layeredCourtyard',
  'Layered Courtyard',
  courtyardLayout(width: 8, height: 7, towers: 4),
);

final windingPathLayoutA = namedLayout(
  'windingPath',
  'Winding Path',
  windingPathLayout(turns: 4),
);

final grandTurtleLayout = namedLayout(
  'grandTurtle',
  'Grand Turtle',
  centeredPyramid([
    [2, 4, 6, 8, 10, 10, 8, 6, 4],
    [4, 6, 6, 4],
    [2, 4, 2],
    [2, 2],
  ]),
);

final layeredShrineLayout = namedLayout(
  'layeredShrine',
  'Layered Shrine',
  centeredPyramid([
    [4, 6, 8, 10, 10, 8, 6],
    [4, 6, 6, 4],
    [2, 4, 4],
    [2, 2],
    [2],
  ]),
);

final multiPeakLayout = namedLayout(
  'multiPeak',
  'Multi Peak',
  combineLayouts([
    wingedLayout(bodyRows: [4, 6, 8, 8, 6, 4], wingRows: 3, layerCount: 3),
    [
      const TilePosition(1, 14, 3),
      const TilePosition(1, 20, 3),
      const TilePosition(1, 26, 3),
      const TilePosition(3, 18, 4),
      const TilePosition(3, 20, 4),
      const TilePosition(3, 22, 4),
    ],
  ]),
);

final complexFortressLayout = namedLayout(
  'complexFortress',
  'Complex Fortress',
  combineLayouts([
    courtyardLayout(width: 9, height: 7, towers: 4),
    translate(
      centeredPyramid([
        [4, 4],
        [2, 2],
      ], centerCol: 20),
      layers: 2,
    ),
  ]),
);

final sacredBridgeLayout = namedLayout(
  'sacredBridge',
  'Sacred Bridge',
  splitIslands(islandRows: [4, 6, 6, 6, 4, 2], gap: 6, upperLayer: 3),
);

final ancestralCrownLayout = namedLayout(
  'ancestralCrown',
  'Ancestral Crown',
  combineLayouts([
    centeredPyramid([
      [4, 6, 8, 10, 10, 8, 6, 4],
      [4, 6, 6, 4],
      [2, 4, 2],
      [2, 2],
    ]),
    [
      const TilePosition(0, 12, 2),
      const TilePosition(0, 20, 3),
      const TilePosition(0, 28, 2),
      const TilePosition(2, 16, 4),
      const TilePosition(2, 20, 4),
      const TilePosition(2, 24, 4),
    ],
  ]),
);

final grandTreasuryLayout = namedLayout(
  'grandTreasury',
  'Grand Treasury',
  centeredPyramid([
    [4, 6, 8, 10, 12, 12, 10, 8, 6],
    [4, 6, 8, 8, 6, 4],
    [2, 4, 4, 2],
    [2, 2],
    [2],
  ]),
);

final templeComplexLayout = namedLayout(
  'templeComplex',
  'Temple Complex',
  combineLayouts([
    courtyardLayout(width: 9, height: 8, towers: 4),
    translate(
      centeredPyramid([
        [4, 6, 4],
        [2, 2],
      ], centerCol: 20),
      layers: 2,
    ),
  ]),
);

final finalArchiveLayout = namedLayout(
  'finalArchive',
  'Final Archive',
  centeredPyramid([
    [4, 6, 8, 10, 12, 10, 8, 6, 4],
    [4, 6, 8, 6, 4],
    [2, 4, 4, 2],
    [2, 4, 2],
    [2, 2],
    [2],
  ]),
);

final List<NamedLayout> kLayoutLibrary = [
  compactDiamondLayout,
  beginnerBridgeLayout,
  smallTurtleLayout,
  firstCrossLayout,
  smallShrineLayout,
  openCourtyardLayout,
  riverPathLayout,
  wisdomHouseLayout,
  gatheringWingsLayout,
  elderBridgeLayout,
  heritageTurtleLayout,
  butterflyLayout,
  templeStepsLayout,
  wisdomStaircaseLayout,
  crownLayout,
  sacredGroveLayout,
  royalStoolLayout,
  ancestralGateLayout,
  twinTowersLayout,
  raisedCourtyardLayout,
  splitIslandsLayout,
  fortressLayout,
  hiddenCenterLayout,
  festivalArchiveLayout,
  layeredCourtyardLayout,
  windingPathLayoutA,
  grandTurtleLayout,
  layeredShrineLayout,
  multiPeakLayout,
  complexFortressLayout,
  sacredBridgeLayout,
  ancestralCrownLayout,
  grandTreasuryLayout,
  templeComplexLayout,
  finalArchiveLayout,
];
