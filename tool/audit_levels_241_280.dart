// ignore_for_file: avoid_print

import 'dart:math';

import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_241_280_candidate_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';

import 'levels_201_240_bulk_analysis.dart';
import 'levels_81_160_visual_analysis.dart';

void main() {
  final candidates = kLevels241To280Candidates;
  final coarse = {
    for (final candidate in candidates)
      candidate.level: analyzeCoarseSilhouette(candidate.layout),
  };
  final failures = <String>[];
  final fullness = <String, int>{
    'open-medium': 0,
    'full': 0,
    'bulky': 0,
  };
  final bulk = <BulkClass, int>{for (final value in BulkClass.values) value: 0};
  final widths = <String, int>{'below70': 0, '70to76': 0, '76to82': 0};
  final envelopeCounts = <String, int>{};

  for (final candidate in candidates) {
    final minimumTiles = kLevels241To280Finales.contains(candidate.level)
        ? 10
        : candidate.level == 241
            ? 8
            : 6;
    final validation = validateLayout(
      candidate.layout,
      minimumOpeningTiles: minimumTiles,
    );
    if (validation.issues.isNotEmpty) {
      failures.add('L${candidate.level} structure: '
          '${validation.issues.map((issue) => issue.message).join('; ')}');
    }
    final analysis = analyzeBulk(candidate.layout);
    bulk[analysis.classification] = bulk[analysis.classification]! + 1;
    fullness[candidate.fullnessClass] = fullness[candidate.fullnessClass]! + 1;
    final width = analysis.coarse.widthOccupancy;
    widths[width < .70
        ? 'below70'
        : width < .76
            ? '70to76'
            : '76to82'] = widths[width < .70
            ? 'below70'
            : width < .76
                ? '70to76'
                : '76to82']! +
        1;
    final fit = BoardLayoutGeometry.fromPositions(candidate.layout.positions)
        .fit(availableWidth: 374, availableHeight: 804);
    final envelope =
        '${(analysis.coarse.widthOccupancy * 100).toStringAsFixed(1)}/'
        '${(analysis.coarse.heightOccupancy * 100).toStringAsFixed(1)}';
    envelopeCounts[envelope] = (envelopeCounts[envelope] ?? 0) + 1;
    if (fit.tileWidth < 52) {
      failures.add('L${candidate.level} tile width ${fit.tileWidth}');
    }
    if (analysis.coarse.widthOccupancy > .82) {
      failures
          .add('L${candidate.level} width ${analysis.coarse.widthOccupancy}');
    }
    if (analysis.coarse.coarseClass == 'Solid rectangle') {
      failures.add('L${candidate.level} is a solid rectangle');
    }
    print('L${candidate.level} ${candidate.fullnessClass.padRight(11)} '
        '${candidate.layout.stats.tileCount.toString().padLeft(2)} tiles '
        '${(analysis.coarse.widthOccupancy * 100).toStringAsFixed(1)}%W '
        '${(analysis.coarse.heightOccupancy * 100).toStringAsFixed(1)}%H '
        '${fit.tileWidth.toStringAsFixed(1)}px '
        '${bulkClassLabel(analysis.classification)} '
        '${analysis.coarse.coarseClass} holes=${analysis.coarse.holeCount} '
        'large=${analysis.coarse.largeOpeningCount} '
        'free=${candidate.layout.stats.startingFreeTileCount}');
  }

  var maxAdjacent = 0.0;
  var maxAdjacentPair = '';
  for (var index = 0; index < candidates.length - 1; index++) {
    final first = candidates[index];
    final second = candidates[index + 1];
    final score = compareCoarseSilhouettes(
      coarse[first.level]!,
      coarse[second.level]!,
      familyA: first.family,
      familyB: second.family,
    ).score;
    if (score > maxAdjacent) {
      maxAdjacent = score;
      maxAdjacentPair = '${first.level}/${second.level}';
    }
    if (score >= .78) {
      failures.add('adjacent ${first.level}/${second.level} '
          '${score.toStringAsFixed(3)}');
    }
  }

  var maxOffset = 0.0;
  var maxOffsetPair = '';
  for (var index = 0; index < 20; index++) {
    final first = candidates[index];
    final second = candidates[index + 20];
    final score = compareCoarseSilhouettes(
      coarse[first.level]!,
      coarse[second.level]!,
      familyA: first.family,
      familyB: second.family,
    ).score;
    if (score > maxOffset) {
      maxOffset = score;
      maxOffsetPair = '${first.level}/${second.level}';
    }
    if (score > .75) {
      failures.add('20-offset ${first.level}/${second.level} '
          '${score.toStringAsFixed(3)}');
    }
  }

  var maxProduction = 0.0;
  var maxProductionPair = '';
  for (final candidate in candidates) {
    for (final production in kLevels) {
      final exact = compareLayoutSilhouettes(
        candidate.layout,
        production.namedLayout,
      ).score;
      if (exact >= .90) {
        failures.add('near clone ${candidate.level}/${production.id} '
            '${exact.toStringAsFixed(3)}');
      }
      final score = compareCoarseSilhouettes(
        coarse[candidate.level]!,
        analyzeCoarseSilhouette(production.namedLayout),
        familyA: candidate.family,
        familyB: production.name,
      ).score;
      if (score > maxProduction) {
        maxProduction = score;
        maxProductionPair = '${candidate.level}/${production.id}';
      }
    }
  }

  for (var index = 0; index < candidates.length - 2; index++) {
    final classes = candidates
        .skip(index)
        .take(3)
        .map((candidate) => coarse[candidate.level]!.coarseClass)
        .toSet();
    if (classes.length == 1) {
      failures.add('three repeated coarse classes at '
          '${candidates[index].level}-${candidates[index + 2].level}: '
          '${classes.single}');
    }
  }

  final largestEnvelopeGroup = envelopeCounts.values.fold<int>(0, max);
  if (largestEnvelopeGroup > 6) {
    failures.add('identical envelope group contains $largestEnvelopeGroup');
  }
  print('fullness=$fullness actualBulk=$bulk widths=$widths');
  print('envelopes=$envelopeCounts');
  print('maxAdjacent=${maxAdjacent.toStringAsFixed(3)} at $maxAdjacentPair');
  print('maxOffset=${maxOffset.toStringAsFixed(3)} at $maxOffsetPair');
  print('maxProduction=${maxProduction.toStringAsFixed(3)} '
      'at $maxProductionPair');
  print('failures=${failures.length}');
  for (final failure in failures) {
    print('FAIL $failure');
  }
  print('signatures={');
  for (final candidate in candidates) {
    print('  ${candidate.level}: ${_candidateSignature(candidate)},');
  }
  print('}');
}

int _candidateSignature(RoadmapLayoutCandidate candidate) {
  final value = [
    candidate.level,
    candidate.layout.id,
    candidate.proposedName,
    candidate.layout.stats.tileCount,
    candidate.layout.positions
        .map((position) => '${position.row}:${position.col}:${position.layer}')
        .join(','),
  ].join('|');
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}
