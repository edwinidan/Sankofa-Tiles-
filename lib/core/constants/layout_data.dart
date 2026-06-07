class TilePosition {
  final int row;
  final int col;
  final int layer;
  const TilePosition(this.row, this.col, this.layer);
}

// Layout coordinates use half-cell units: one tile spans 2 rows × 2 columns.
// Odd row/column values create natural Mahjong-style staggering.
List<TilePosition> _mahjongLayout(List<List<int>> layerRows) {
  final baseRowCount = layerRows.first.length;

  return [
    for (var layer = 0; layer < layerRows.length; layer++)
      ..._layer(
        layerRows[layer],
        layer: layer,
        rowStart: baseRowCount - layerRows[layer].length,
      ),
  ];
}

List<TilePosition> _layer(
  List<int> rowCounts, {
  required int layer,
  required int rowStart,
}) {
  const centerCol = 10;

  return [
    for (var rowIndex = 0; rowIndex < rowCounts.length; rowIndex++)
      for (var col = centerCol - (rowCounts[rowIndex] - 1);
          col <= centerCol + (rowCounts[rowIndex] - 1);
          col += 2)
        TilePosition(rowStart + rowIndex * 2, col, layer),
  ];
}

// Level 1 — compact diamond with a centered cap
final level1Layout = _mahjongLayout([
  [2, 4, 4, 2],
  [2, 2],
]);

// Level 2 — small turtle base
final level2Layout = _mahjongLayout([
  [2, 4, 4, 4, 2],
  [2, 2],
]);

// Level 3 — beginner pyramid
final level3Layout = _mahjongLayout([
  [2, 4, 6, 4, 2],
  [2, 2, 2],
]);

// Level 4 — three-tier river diamond
final level4Layout = _mahjongLayout([
  [2, 4, 6, 6, 4],
  [2, 2],
  [2],
]);

// Level 5 — wider stepped pyramid
final level5Layout = _mahjongLayout([
  [2, 4, 6, 6, 6, 4],
  [2, 2, 2],
  [2],
]);

// Level 6 — turtle body with raised bridge
final level6Layout = _mahjongLayout([
  [2, 4, 6, 6, 6, 4, 2],
  [2, 4, 2],
  [2],
]);

// Level 7 — broad council diamond
final level7Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 4, 2],
  [2, 4, 2],
  [2],
]);

// Level 8 — balanced heritage turtle
final level8Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 6, 2],
  [2, 4, 2],
  [2, 2],
]);

// Level 9 — elongated ancestor diamond
final level9Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 6, 4],
  [2, 4, 4],
  [2, 2],
]);

// Level 10 — classic four-tier Sankofa pyramid
final level10Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 6, 4, 2],
  [2, 4, 4],
  [2, 2],
  [2],
]);

// Level 11 — long turtle with a centered spine
final level11Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 8, 4, 2],
  [4, 4, 4],
  [2, 2],
  [2],
]);

// Level 12 — tall covenant pyramid
final level12Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 8, 6, 2],
  [4, 4, 4],
  [2, 2, 2],
  [2],
]);

// Level 13 — shrine diamond with broad shoulders
final level13Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 8, 6, 2],
  [4, 6, 4],
  [2, 2, 2],
  [2],
]);

// Level 14 — elder turtle with a flat center
final level14Layout = _mahjongLayout([
  [2, 4, 6, 8, 8, 8, 8, 4],
  [4, 6, 4],
  [2, 2, 2],
  [2, 2],
]);

// Level 15 — oracle pyramid
final level15Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 6, 4],
  [4, 4, 4, 4],
  [2, 2, 2],
  [2, 2],
]);

// Level 16 — throne turtle with stacked crown
final level16Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 8, 4],
  [4, 4, 4, 4],
  [2, 4, 2],
  [2, 2],
]);

// Level 17 — tall genesis diamond
final level17Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 8, 6],
  [4, 6, 4, 4],
  [2, 4, 2],
  [2, 2],
]);

// Level 18 — cosmos tower with five layers
final level18Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 8, 6, 2],
  [4, 6, 4, 4],
  [2, 4, 2],
  [2, 2],
  [2],
]);

// Level 19 — triumph turtle with a high crown
final level19Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 8, 6, 4],
  [4, 6, 6, 4],
  [2, 4, 2],
  [2, 2],
  [2],
]);

// Level 20 — final eternal pyramid
final level20Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 8, 6, 4, 2],
  [4, 6, 6, 4],
  [2, 4, 4],
  [2, 2],
  [2],
]);

// Level 21 — full symbol archive
final level21Layout = _mahjongLayout([
  [2, 4, 6, 8, 10, 10, 10, 8, 6, 4, 2],
  [4, 6, 6, 4],
  [2, 4, 4],
  [2],
]);

List<TilePosition> _archiveGridLayout(int tileCount) {
  const columns = 12;
  final fullRows = tileCount ~/ columns;
  final remainder = tileCount % columns;
  final rows = <int>[
    for (var row = 0; row < fullRows; row++) columns,
    if (remainder > 0) remainder,
  ];
  return _mahjongLayout([rows]);
}

// Expanded archive levels use broad, single-layer displays so the complete
// symbol collection remains readable and every pair is immediately playable.
final level22Layout = _archiveGridLayout(110);
final level23Layout = _archiveGridLayout(118);
final level24Layout = _archiveGridLayout(126);
final level25Layout = _archiveGridLayout(134);
final level26Layout = _archiveGridLayout(142);
final level27Layout = _archiveGridLayout(150);
final level28Layout = _archiveGridLayout(158);
final level29Layout = _archiveGridLayout(168);
