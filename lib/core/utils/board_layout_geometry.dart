import 'dart:math';

import '../constants/layout_data.dart';

const double kTileAspectRatio = 85 / 64;
const double kPreferredTileWidth = 64;
const double kMinimumTileWidth = 44;
const double kBoardStepX = 0.425;
const double kBoardStepY = kTileAspectRatio * 0.425;
const double kLayerOffsetX = 0.14;
const double kLayerOffsetY = kTileAspectRatio * 0.10;
const double kBoardSafetyInset = 8;

class BoardLayoutGeometry {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const BoardLayoutGeometry({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  double get widthInTileUnits => maxX - minX;
  double get heightInTileUnits => maxY - minY;

  factory BoardLayoutGeometry.fromPositions(
    Iterable<TilePosition> positions,
  ) {
    final tiles = positions.toList(growable: false);
    if (tiles.isEmpty) {
      return const BoardLayoutGeometry(
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: kTileAspectRatio,
      );
    }

    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;

    for (final tile in tiles) {
      final left = projectX(tile.col, tile.layer);
      final top = projectY(tile.row, tile.layer);
      minX = min(minX, left);
      maxX = max(maxX, left + 1);
      minY = min(minY, top);
      maxY = max(maxY, top + kTileAspectRatio);
    }

    return BoardLayoutGeometry(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }

  BoardFit fit({
    required double availableWidth,
    required double availableHeight,
  }) {
    final safeWidth = max(0.0, availableWidth - kBoardSafetyInset * 2);
    final safeHeight = max(0.0, availableHeight - kBoardSafetyInset * 2);
    final widthFit = safeWidth / widthInTileUnits;
    final heightFit = safeHeight / heightInTileUnits;
    final fittedWidth = min(kPreferredTileWidth, min(widthFit, heightFit));
    final tileWidth = max(0.0, fittedWidth);

    return BoardFit(
      tileWidth: tileWidth,
      tileHeight: tileWidth * kTileAspectRatio,
      boardWidth: widthInTileUnits * tileWidth,
      boardHeight: heightInTileUnits * tileWidth,
      availableWidth: safeWidth,
      availableHeight: safeHeight,
    );
  }

  BoardPoint project(TilePosition position, double tileWidth) {
    return BoardPoint(
      projectX(position.col, position.layer) * tileWidth,
      projectY(position.row, position.layer) * tileWidth,
    );
  }

  static double projectX(int col, int layer) {
    return col * kBoardStepX - layer * kLayerOffsetX;
  }

  static double projectY(int row, int layer) {
    return row * kBoardStepY - layer * kLayerOffsetY;
  }
}

class BoardPoint {
  final double x;
  final double y;

  const BoardPoint(this.x, this.y);
}

class BoardFit {
  final double tileWidth;
  final double tileHeight;
  final double boardWidth;
  final double boardHeight;
  final double availableWidth;
  final double availableHeight;

  const BoardFit({
    required this.tileWidth,
    required this.tileHeight,
    required this.boardWidth,
    required this.boardHeight,
    required this.availableWidth,
    required this.availableHeight,
  });

  bool get fitsBounds =>
      boardWidth <= availableWidth + 0.01 &&
      boardHeight <= availableHeight + 0.01;

  bool get meetsMinimumTileSize => tileWidth >= kMinimumTileWidth - 0.01;

  bool get fitsSafely => fitsBounds && meetsMinimumTileSize;
}

class BoardViewportPreset {
  final String name;
  final double width;
  final double height;

  const BoardViewportPreset(this.name, this.width, this.height);
}

const List<BoardViewportPreset> kRequiredBoardViewports = [
  BoardViewportPreset('compact phone', 304, 390),
  BoardViewportPreset('standard phone', 344, 460),
  BoardViewportPreset('tall phone', 384, 520),
];
