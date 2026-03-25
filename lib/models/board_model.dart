import 'tile_model.dart';

class BoardModel {
  final int rows;
  final int cols;
  final List<TileModel> tiles;

  const BoardModel({
    required this.rows,
    required this.cols,
    required this.tiles,
  });

  TileModel? tileAt(int row, int col) {
    try {
      return tiles.firstWhere((t) => t.row == row && t.col == col);
    } catch (_) {
      return null;
    }
  }
}
