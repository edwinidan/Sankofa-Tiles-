import 'dart:math';

import 'package:sankofa_tiles/core/constants/layout_data.dart';

import 'levels_81_160_visual_analysis.dart';

enum BulkClass { thin, medium, bulky }

class BulkAnalysis {
  const BulkAnalysis({
    required this.coarse,
    required this.centerDensity,
    required this.fullnessScore,
    required this.classification,
  });

  final CoarseSilhouetteMetrics coarse;
  final double centerDensity;
  final double fullnessScore;
  final BulkClass classification;
}

BulkAnalysis analyzeBulk(NamedLayout layout) {
  final coarse = analyzeCoarseSilhouette(layout);
  final centerDensity = _centerDensity(coarse.raster);
  final normalizedWidth = min(1.0, coarse.widthOccupancy / .82);
  final score = normalizedWidth * .35 +
      coarse.convexHullFillRatio * .35 +
      centerDensity * .30;
  final classification = coarse.widthOccupancy < .59 || score < .55
      ? BulkClass.thin
      : coarse.widthOccupancy >= .70 && score >= .68
          ? BulkClass.bulky
          : BulkClass.medium;
  return BulkAnalysis(
    coarse: coarse,
    centerDensity: centerDensity,
    fullnessScore: score,
    classification: classification,
  );
}

double _centerDensity(List<bool> raster) {
  var occupied = 0;
  var total = 0;
  for (var y = 5; y < 27; y++) {
    for (var x = 8; x < 24; x++) {
      total++;
      if (raster[y * kSilhouetteRasterSize + x]) occupied++;
    }
  }
  return occupied / total;
}

String bulkClassLabel(BulkClass classification) => switch (classification) {
      BulkClass.thin => 'thin',
      BulkClass.medium => 'medium',
      BulkClass.bulky => 'bulky',
    };
