// ignore_for_file: avoid_print

import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/levels_241_280_candidate_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';

import 'levels_201_240_bulk_analysis.dart';
import 'levels_81_160_visual_analysis.dart';

void main() {
  print('full candidate count=${kLevels241To280Candidates.length}');
  var maximumAnchorSimilarity = 0.0;
  var maximumProductionSimilarity = 0.0;
  var maximumAnchorPair = '';
  var maximumProductionPair = '';
  for (final candidate in kLevels241To280AnchorCandidates) {
    final validation = validateLayout(
      candidate.layout,
      minimumOpeningTiles: kLevels241To280Finales.contains(candidate.level)
          ? 10
          : candidate.level == 241
              ? 8
              : 6,
    );
    final fit = BoardLayoutGeometry.fromPositions(candidate.layout.positions)
        .fit(availableWidth: 374, availableHeight: 804);
    final bulk = analyzeBulk(candidate.layout);
    print('L${candidate.level} ${candidate.layout.stats.tileCount} tiles '
        '${(bulk.coarse.widthOccupancy * 100).toStringAsFixed(1)}%W '
        '${(bulk.coarse.heightOccupancy * 100).toStringAsFixed(1)}%H '
        '${fit.tileWidth.toStringAsFixed(1)}px ${bulkClassLabel(bulk.classification)} '
        'holes=${bulk.coarse.holeCount} large=${bulk.coarse.largeOpeningCount} '
        'free=${candidate.layout.stats.startingFreeTileCount} '
        'issues=${validation.issues.length}');
    if (validation.issues.isNotEmpty) {
      for (final issue in validation.issues) {
        print('  ${issue.kind}: ${issue.message}');
      }
    }
    for (final other in kLevels241To280AnchorCandidates) {
      if (other.level <= candidate.level) continue;
      final similarity = compareCoarseSilhouettes(
        bulk.coarse,
        analyzeCoarseSilhouette(other.layout),
        familyA: candidate.family,
        familyB: other.family,
      ).score;
      if (similarity > maximumAnchorSimilarity) {
        maximumAnchorSimilarity = similarity;
        maximumAnchorPair = '${candidate.level}/${other.level}';
      }
    }
    for (final production in kLevels201To240Candidates) {
      final similarity = compareCoarseSilhouettes(
        bulk.coarse,
        analyzeCoarseSilhouette(production.layout),
        familyA: candidate.family,
        familyB: production.family,
      ).score;
      if (similarity > maximumProductionSimilarity) {
        maximumProductionSimilarity = similarity;
        maximumProductionPair = '${candidate.level}/${production.level}';
      }
    }
  }
  print('max anchor similarity=${maximumAnchorSimilarity.toStringAsFixed(3)} '
      'at $maximumAnchorPair');
  print('max production similarity='
      '${maximumProductionSimilarity.toStringAsFixed(3)} at '
      '$maximumProductionPair');
  final byLevel = {
    for (final candidate in kLevels241To280AnchorCandidates)
      candidate.level: candidate,
  };
  for (final pair in const [
    (241, 261),
    (245, 265),
    (250, 270),
    (255, 275),
    (260, 280),
    (260, 261)
  ]) {
    final first = byLevel[pair.$1]!;
    final second = byLevel[pair.$2]!;
    final score = compareCoarseSilhouettes(
      analyzeCoarseSilhouette(first.layout),
      analyzeCoarseSilhouette(second.layout),
      familyA: first.family,
      familyB: second.family,
    ).score;
    print('${pair.$1}/${pair.$2}=${score.toStringAsFixed(3)}');
  }
}
