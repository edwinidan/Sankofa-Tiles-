import 'dart:math';

import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';

const int kSilhouetteRasterSize = 32;
const int kCoarseSilhouetteSize = 12;

class CoarseSilhouetteMetrics {
  const CoarseSilhouetteMetrics({
    required this.raster,
    required this.coarseMask,
    required this.outerContour,
    required this.rowProfile,
    required this.columnProfile,
    required this.negativeSpaceDistribution,
    required this.holeCount,
    required this.largeOpeningCount,
    required this.connectedMassCount,
    required this.leftRightMassBalance,
    required this.topBottomMassBalance,
    required this.aspectRatio,
    required this.widthOccupancy,
    required this.heightOccupancy,
    required this.baseLayerFootprint,
    required this.topLayerFootprint,
    required this.convexHullFillRatio,
    required this.emptyAreaPercentage,
    required this.coarseClass,
  });

  final List<bool> raster;
  final List<bool> coarseMask;
  final List<bool> outerContour;
  final List<double> rowProfile;
  final List<double> columnProfile;
  final List<double> negativeSpaceDistribution;
  final int holeCount;
  final int largeOpeningCount;
  final int connectedMassCount;
  final double leftRightMassBalance;
  final double topBottomMassBalance;
  final double aspectRatio;
  final double widthOccupancy;
  final double heightOccupancy;
  final double baseLayerFootprint;
  final double topLayerFootprint;
  final double convexHullFillRatio;
  final double emptyAreaPercentage;
  final String coarseClass;
}

class CoarseSilhouetteComparison {
  const CoarseSilhouetteComparison({
    required this.score,
    required this.occupancyMaskSimilarity,
    required this.outerContourSimilarity,
    required this.rowProfileSimilarity,
    required this.columnProfileSimilarity,
    required this.negativeSpaceSimilarity,
    required this.warnings,
  });

  final double score;
  final double occupancyMaskSimilarity;
  final double outerContourSimilarity;
  final double rowProfileSimilarity;
  final double columnProfileSimilarity;
  final double negativeSpaceSimilarity;
  final List<String> warnings;
}

CoarseSilhouetteMetrics analyzeCoarseSilhouette(NamedLayout layout) {
  final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
  final raster = _rasterize(layout.positions);
  final contour = _contour(raster, kSilhouetteRasterSize);
  final coarse = _downsample(raster);
  final rowProfile = _rowProfile(raster, kSilhouetteRasterSize);
  final columnProfile = _columnProfile(raster, kSilhouetteRasterSize);
  final emptyComponents =
      _components(raster.map((occupied) => !occupied).toList());
  final holes =
      emptyComponents.where((component) => !component.touchesEdge).toList();
  final largeOpenings = holes
      .where(
          (component) => component.cells.length >= kSilhouetteRasterSize * 1.5)
      .length;
  final occupiedComponents = _components(raster)
      .where((component) => component.cells.isNotEmpty)
      .length;
  final occupiedCount = raster.where((occupied) => occupied).length;
  final hullCount = _convexHullCellCount(raster);
  final baseFootprint = _layerFootprint(layout, 0);
  final topFootprint = _layerFootprint(layout, layout.stats.maxLayer);
  final negative = _negativeSpaceDistribution(raster);
  final left = _occupiedInRect(raster, 0, 0, 16, 32);
  final right = _occupiedInRect(raster, 16, 0, 32, 32);
  final top = _occupiedInRect(raster, 0, 0, 32, 16);
  final bottom = _occupiedInRect(raster, 0, 16, 32, 32);

  final provisional = CoarseSilhouetteMetrics(
    raster: raster,
    coarseMask: coarse,
    outerContour: contour,
    rowProfile: rowProfile,
    columnProfile: columnProfile,
    negativeSpaceDistribution: negative,
    holeCount: holes.length,
    largeOpeningCount: largeOpenings,
    connectedMassCount: occupiedComponents,
    leftRightMassBalance: _balance(left, right),
    topBottomMassBalance: _balance(top, bottom),
    aspectRatio: geometry.widthInTileUnits / geometry.heightInTileUnits,
    widthOccupancy:
        geometry.fit(availableWidth: 374, availableHeight: 804).boardWidth /
            374,
    heightOccupancy:
        geometry.fit(availableWidth: 374, availableHeight: 804).boardHeight /
            804,
    baseLayerFootprint: baseFootprint,
    topLayerFootprint: topFootprint,
    convexHullFillRatio: hullCount == 0 ? 0 : occupiedCount / hullCount,
    emptyAreaPercentage: 1 - occupiedCount / raster.length,
    coarseClass: '',
  );
  return CoarseSilhouetteMetrics(
    raster: provisional.raster,
    coarseMask: provisional.coarseMask,
    outerContour: provisional.outerContour,
    rowProfile: provisional.rowProfile,
    columnProfile: provisional.columnProfile,
    negativeSpaceDistribution: provisional.negativeSpaceDistribution,
    holeCount: provisional.holeCount,
    largeOpeningCount: provisional.largeOpeningCount,
    connectedMassCount: provisional.connectedMassCount,
    leftRightMassBalance: provisional.leftRightMassBalance,
    topBottomMassBalance: provisional.topBottomMassBalance,
    aspectRatio: provisional.aspectRatio,
    widthOccupancy: provisional.widthOccupancy,
    heightOccupancy: provisional.heightOccupancy,
    baseLayerFootprint: provisional.baseLayerFootprint,
    topLayerFootprint: provisional.topLayerFootprint,
    convexHullFillRatio: provisional.convexHullFillRatio,
    emptyAreaPercentage: provisional.emptyAreaPercentage,
    coarseClass: _classify(provisional),
  );
}

CoarseSilhouetteComparison compareCoarseSilhouettes(
  CoarseSilhouetteMetrics a,
  CoarseSilhouetteMetrics b, {
  String? familyA,
  String? familyB,
}) {
  final mask = _jaccard(a.coarseMask, b.coarseMask);
  final contour = _jaccard(a.outerContour, b.outerContour);
  final rows = _profileSimilarity(a.rowProfile, b.rowProfile);
  final columns = _profileSimilarity(a.columnProfile, b.columnProfile);
  final negative = _profileSimilarity(
    a.negativeSpaceDistribution,
    b.negativeSpaceDistribution,
  );
  final score =
      mask * .34 + contour * .26 + rows * .16 + columns * .16 + negative * .08;
  final warnings = <String>[];
  if ((a.widthOccupancy - b.widthOccupancy).abs() <= .02 &&
      (a.heightOccupancy - b.heightOccupancy).abs() <= .02) {
    warnings.add('nearly identical width-height occupancy');
  }
  if (rows >= .88 && columns >= .88) {
    warnings.add('similar row and column profiles');
  }
  if (contour >= .82) {
    warnings.add('similar normalised outer contours');
  }
  if (a.convexHullFillRatio >= .72 &&
      b.convexHullFillRatio >= .72 &&
      a.largeOpeningCount == 0 &&
      b.largeOpeningCount == 0) {
    warnings.add('dense rectangles differentiated only by small voids');
  }
  if (a.topLayerFootprint / max(.001, a.baseLayerFootprint) >= .42 &&
      b.topLayerFootprint / max(.001, b.baseLayerFootprint) >= .42 &&
      a.topBottomMassBalance >= .82 &&
      b.topBottomMassBalance >= .82) {
    warnings.add('repeated top-crown and solid-base construction');
  }
  if ({'H-frame', 'Solid rectangle'}.contains(a.coarseClass) &&
      a.coarseClass == b.coarseClass) {
    warnings.add('repeated H-like or E-like structure');
  }
  if (a.holeCount > 0 &&
      b.holeCount > 0 &&
      a.largeOpeningCount == 0 &&
      b.largeOpeningCount == 0) {
    warnings.add('repeated narrow vertical slots');
  }
  if (familyA != null &&
      familyB != null &&
      familyA != familyB &&
      a.coarseClass == b.coarseClass) {
    warnings.add('different family labels share one coarse geometry class');
  }
  return CoarseSilhouetteComparison(
    score: score,
    occupancyMaskSimilarity: mask,
    outerContourSimilarity: contour,
    rowProfileSimilarity: rows,
    columnProfileSimilarity: columns,
    negativeSpaceSimilarity: negative,
    warnings: List.unmodifiable(warnings),
  );
}

List<bool> _rasterize(Iterable<TilePosition> positions) {
  final tiles = positions.toList();
  final geometry = BoardLayoutGeometry.fromPositions(tiles);
  final result =
      List<bool>.filled(kSilhouetteRasterSize * kSilhouetteRasterSize, false);
  for (var y = 0; y < kSilhouetteRasterSize; y++) {
    final worldY = geometry.minY +
        (y + .5) / kSilhouetteRasterSize * geometry.heightInTileUnits;
    for (var x = 0; x < kSilhouetteRasterSize; x++) {
      final worldX = geometry.minX +
          (x + .5) / kSilhouetteRasterSize * geometry.widthInTileUnits;
      result[y * kSilhouetteRasterSize + x] = tiles.any((tile) {
        final left = BoardLayoutGeometry.projectX(tile.col, tile.layer);
        final top = BoardLayoutGeometry.projectY(tile.row, tile.layer);
        return worldX >= left &&
            worldX <= left + 1 &&
            worldY >= top &&
            worldY <= top + kTileAspectRatio;
      });
    }
  }
  return result;
}

List<bool> _downsample(List<bool> raster) {
  final result =
      List<bool>.filled(kCoarseSilhouetteSize * kCoarseSilhouetteSize, false);
  for (var y = 0; y < kCoarseSilhouetteSize; y++) {
    for (var x = 0; x < kCoarseSilhouetteSize; x++) {
      var occupied = 0;
      var total = 0;
      final y0 = y * kSilhouetteRasterSize ~/ kCoarseSilhouetteSize;
      final y1 = (y + 1) * kSilhouetteRasterSize ~/ kCoarseSilhouetteSize;
      final x0 = x * kSilhouetteRasterSize ~/ kCoarseSilhouetteSize;
      final x1 = (x + 1) * kSilhouetteRasterSize ~/ kCoarseSilhouetteSize;
      for (var sy = y0; sy < y1; sy++) {
        for (var sx = x0; sx < x1; sx++) {
          total++;
          if (raster[sy * kSilhouetteRasterSize + sx]) occupied++;
        }
      }
      result[y * kCoarseSilhouetteSize + x] = occupied / total >= .28;
    }
  }
  return result;
}

List<bool> _contour(List<bool> raster, int size) {
  final result = List<bool>.filled(raster.length, false);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final index = y * size + x;
      if (!raster[index]) continue;
      for (final (dx, dy) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 ||
            ny < 0 ||
            nx >= size ||
            ny >= size ||
            !raster[ny * size + nx]) {
          result[index] = true;
          break;
        }
      }
    }
  }
  return result;
}

List<double> _rowProfile(List<bool> raster, int size) => [
      for (var y = 0; y < size; y++)
        raster.skip(y * size).take(size).where((cell) => cell).length / size,
    ];

List<double> _columnProfile(List<bool> raster, int size) => [
      for (var x = 0; x < size; x++)
        [
              for (var y = 0; y < size; y++) raster[y * size + x],
            ].where((cell) => cell).length /
            size,
    ];

List<double> _negativeSpaceDistribution(List<bool> raster) {
  final values = <double>[];
  for (var qy = 0; qy < 2; qy++) {
    for (var qx = 0; qx < 2; qx++) {
      final occupied =
          _occupiedInRect(raster, qx * 16, qy * 16, qx * 16 + 16, qy * 16 + 16);
      values.add(1 - occupied / 256);
    }
  }
  return values;
}

double _layerFootprint(NamedLayout layout, int layer) {
  final cells =
      layout.positions.where((position) => position.layer == layer).length;
  return cells / max(1, layout.positions.length);
}

int _occupiedInRect(
  List<bool> raster,
  int x0,
  int y0,
  int x1,
  int y1,
) {
  var result = 0;
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      if (raster[y * kSilhouetteRasterSize + x]) result++;
    }
  }
  return result;
}

double _balance(num a, num b) {
  final largest = max(a, b);
  return largest == 0 ? 1 : min(a, b) / largest;
}

double _jaccard(List<bool> a, List<bool> b) {
  var intersection = 0;
  var union = 0;
  for (var index = 0; index < a.length; index++) {
    if (a[index] || b[index]) union++;
    if (a[index] && b[index]) intersection++;
  }
  return union == 0 ? 1 : intersection / union;
}

double _profileSimilarity(List<double> a, List<double> b) {
  var difference = 0.0;
  for (var index = 0; index < a.length; index++) {
    difference += (a[index] - b[index]).abs();
  }
  return max(0, 1 - difference / a.length);
}

class _Component {
  const _Component(this.cells, this.touchesEdge);

  final List<int> cells;
  final bool touchesEdge;
}

List<_Component> _components(List<bool> selected) {
  final visited = List<bool>.filled(selected.length, false);
  final result = <_Component>[];
  for (var start = 0; start < selected.length; start++) {
    if (!selected[start] || visited[start]) continue;
    final queue = <int>[start];
    final cells = <int>[];
    visited[start] = true;
    var touchesEdge = false;
    for (var cursor = 0; cursor < queue.length; cursor++) {
      final current = queue[cursor];
      cells.add(current);
      final x = current % kSilhouetteRasterSize;
      final y = current ~/ kSilhouetteRasterSize;
      if (x == 0 ||
          y == 0 ||
          x == kSilhouetteRasterSize - 1 ||
          y == kSilhouetteRasterSize - 1) {
        touchesEdge = true;
      }
      for (final (dx, dy) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 ||
            ny < 0 ||
            nx >= kSilhouetteRasterSize ||
            ny >= kSilhouetteRasterSize) {
          continue;
        }
        final next = ny * kSilhouetteRasterSize + nx;
        if (selected[next] && !visited[next]) {
          visited[next] = true;
          queue.add(next);
        }
      }
    }
    result.add(_Component(cells, touchesEdge));
  }
  return result;
}

int _convexHullCellCount(List<bool> raster) {
  final points = <Point<double>>[
    for (var index = 0; index < raster.length; index++)
      if (raster[index])
        Point<double>(
          (index % kSilhouetteRasterSize).toDouble(),
          (index ~/ kSilhouetteRasterSize).toDouble(),
        ),
  ];
  if (points.length < 3) return points.length;
  points.sort((a, b) {
    final x = a.x.compareTo(b.x);
    return x == 0 ? a.y.compareTo(b.y) : x;
  });
  double cross(Point<double> o, Point<double> a, Point<double> b) =>
      (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
  final hull = <Point<double>>[];
  for (final point in points) {
    while (hull.length >= 2 &&
        cross(hull[hull.length - 2], hull.last, point) <= 0) {
      hull.removeLast();
    }
    hull.add(point);
  }
  final lowerLength = hull.length;
  for (final point in points.reversed.skip(1)) {
    while (hull.length > lowerLength &&
        cross(hull[hull.length - 2], hull.last, point) <= 0) {
      hull.removeLast();
    }
    hull.add(point);
  }
  if (hull.length > 1) hull.removeLast();
  var count = 0;
  for (var y = 0; y < kSilhouetteRasterSize; y++) {
    for (var x = 0; x < kSilhouetteRasterSize; x++) {
      if (_insidePolygon(Point<double>(x.toDouble(), y.toDouble()), hull)) {
        count++;
      }
    }
  }
  return max(1, count);
}

bool _insidePolygon(Point<double> point, List<Point<double>> polygon) {
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final a = polygon[i];
    final b = polygon[j];
    if ((a.y > point.y) != (b.y > point.y) &&
        point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

String _classify(CoarseSilhouetteMetrics metrics) {
  if (metrics.connectedMassCount >= 2) return 'Split masses';
  if (metrics.aspectRatio <= .38) return 'Pillar';
  if (metrics.holeCount >= 3) return 'H-frame';
  if (metrics.holeCount == 2) return 'Animal or emblem';
  if (metrics.holeCount == 1 && metrics.largeOpeningCount >= 1) return 'Ring';
  if (metrics.convexHullFillRatio >= .86 &&
      metrics.emptyAreaPercentage <= .30) {
    return 'Solid rectangle';
  }
  if (metrics.leftRightMassBalance <= .62) return 'Asymmetric formation';
  if (metrics.topBottomMassBalance <= .62) return 'Tree';
  if (metrics.aspectRatio >= .62) return 'Bridge';
  if (metrics.emptyAreaPercentage >= .58) return 'Curved or winding';
  return 'Monument';
}
