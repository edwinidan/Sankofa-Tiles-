import '../constants/layout_data.dart';
import 'board_layout_geometry.dart';

class LayoutSimilarity {
  const LayoutSimilarity({
    required this.score,
    required this.occupiedMask,
    required this.baseMask,
    required this.topMask,
    required this.aspectRatio,
    required this.layerDistribution,
  });

  final double score;
  final double occupiedMask;
  final double baseMask;
  final double topMask;
  final double aspectRatio;
  final double layerDistribution;
}

LayoutSimilarity compareLayoutSilhouettes(NamedLayout a, NamedLayout b) {
  Set<String> mask(NamedLayout layout, {int? layer}) {
    final selected = layout.positions
        .where((position) => layer == null || position.layer == layer)
        .toList();
    final minRow = selected.map((p) => p.row).reduce((x, y) => x < y ? x : y);
    final minCol = selected.map((p) => p.col).reduce((x, y) => x < y ? x : y);
    return {
      for (final position in selected)
        '${position.row - minRow}:${position.col - minCol}:${layer == null ? position.layer : 0}',
    };
  }

  double jaccard(Set<String> x, Set<String> y) {
    final union = x.union(y);
    return union.isEmpty ? 1 : x.intersection(y).length / union.length;
  }

  final occupied = jaccard(mask(a), mask(b));
  final base = jaccard(mask(a, layer: 0), mask(b, layer: 0));
  final top = jaccard(mask(a, layer: 2), mask(b, layer: 2));
  final ga = BoardLayoutGeometry.fromPositions(a.positions);
  final gb = BoardLayoutGeometry.fromPositions(b.positions);
  final arA = ga.widthInTileUnits / ga.heightInTileUnits;
  final arB = gb.widthInTileUnits / gb.heightInTileUnits;
  final aspect = 1 - ((arA - arB).abs() / (arA > arB ? arA : arB));
  final countsA = [
    for (var layer = 0; layer < 3; layer++)
      a.positions.where((p) => p.layer == layer).length / a.positions.length,
  ];
  final countsB = [
    for (var layer = 0; layer < 3; layer++)
      b.positions.where((p) => p.layer == layer).length / b.positions.length,
  ];
  final distribution = 1 -
      (List.generate(3, (i) => (countsA[i] - countsB[i]).abs())
              .reduce((x, y) => x + y) /
          2);
  final score = occupied * .45 +
      base * .20 +
      top * .15 +
      aspect * .10 +
      distribution * .10;
  return LayoutSimilarity(
    score: score,
    occupiedMask: occupied,
    baseMask: base,
    topMask: top,
    aspectRatio: aspect,
    layerDistribution: distribution,
  );
}
