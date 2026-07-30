// ignore_for_file: avoid_print

import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';

import 'levels_81_160_visual_analysis.dart';

void main() {
  final anchors = [
    for (final candidate in kLevels81To160Candidates)
      if (kLevels81To160VisualRedesignAnchors.contains(candidate.level))
        candidate,
  ];
  final metrics = {
    for (final candidate in anchors)
      candidate.level: analyzeCoarseSilhouette(candidate.layout),
  };
  var maximumAdjacent = 0.0;
  var maximumPair = 0.0;
  var maximumPairLabel = '';
  for (var index = 0; index < anchors.length; index++) {
    final candidate = anchors[index];
    final current = metrics[candidate.level]!;
    print(
      '${candidate.level} ${kLevels81To160AnchorClasses[candidate.level]} '
      'detected=${current.coarseClass} '
      'tiles=${candidate.layout.stats.tileCount} '
      'w=${(current.widthOccupancy * 100).toStringAsFixed(1)} '
      'h=${(current.heightOccupancy * 100).toStringAsFixed(1)} '
      'empty=${(current.emptyAreaPercentage * 100).toStringAsFixed(1)} '
      'holes=${current.holeCount} large=${current.largeOpeningCount} '
      'mass=${current.connectedMassCount}',
    );
    for (var otherIndex = index + 1;
        otherIndex < anchors.length;
        otherIndex++) {
      final other = anchors[otherIndex];
      final comparison = compareCoarseSilhouettes(
        current,
        metrics[other.level]!,
        familyA: candidate.family,
        familyB: other.family,
      );
      if (otherIndex == index + 1 && comparison.score > maximumAdjacent) {
        maximumAdjacent = comparison.score;
      }
      if (comparison.score > maximumPair) {
        maximumPair = comparison.score;
        maximumPairLabel = '${candidate.level}/${other.level}';
      }
    }
  }
  print(
    'maxAdjacent=${maximumAdjacent.toStringAsFixed(3)} '
    'maxPair=${maximumPair.toStringAsFixed(3)} ($maximumPairLabel)',
  );
}
