import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_81_160_candidate_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';

import '../tool/levels_81_160_visual_analysis.dart';

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

  test('visual pass changes exactly the 20 requested candidate anchors', () {
    expect(anchors, hasLength(20));
    expect(
      anchors.map((candidate) => candidate.level).toSet(),
      kLevels81To160VisualRedesignAnchors,
    );
    for (var index = 0; index < kLevels81To160Candidates.length; index++) {
      final current = kLevels81To160Candidates[index];
      final legacy = kLevels81To160LegacyCandidates[index];
      expect(current.level, legacy.level);
      expect(current.layout.id, legacy.layout.id);
      if (kLevels81To160VisualRedesignAnchors.contains(current.level)) {
        expect(current.layout.positions, isNot(legacy.layout.positions),
            reason: 'anchor ${current.level} must change');
      } else {
        expect(current.layout.positions, orderedEquals(legacy.layout.positions),
            reason: 'non-anchor ${current.level} must stay frozen');
      }
    }
  });

  test(
      'visual anchors remain isolated, supported, compatible, and portrait-fit',
      () {
    for (final candidate in anchors) {
      final production = getLevelById(candidate.level)!;
      expect(production.layoutName, isNot(candidate.layout.id));
      final validation =
          validateLayout(candidate.layout, minimumOpeningTiles: 6);
      expect(validation.issues, isEmpty,
          reason:
              '${candidate.level}: ${validation.issues.map((issue) => issue.message).join('; ')}');
      expect(validation.unsupportedTileCount, 0);
      expect(candidate.layout.stats.layerCount, 3);
      expect(
          candidate.layout.positions.any(
            (position) => position.layer == 1 && position.row.isOdd,
          ),
          isTrue);
      final copies = production.symbolPlan
          .copyCountsForTileCount(candidate.layout.stats.tileCount);
      expect(copies.fold<int>(0, (sum, value) => sum + value),
          candidate.layout.stats.tileCount);
      expect(copies.every((value) => value.isEven), isTrue);

      final geometry =
          BoardLayoutGeometry.fromPositions(candidate.layout.positions);
      final standard = geometry.fit(availableWidth: 374, availableHeight: 804);
      expect(standard.tileWidth, greaterThanOrEqualTo(52));
      expect(standard.boardWidth / 374, inInclusiveRange(.50, .82));
      expect(standard.boardHeight / 804, inInclusiveRange(.59, .80));
      for (final viewport in const [
        (344.0, 600.0),
        (374.0, 804.0),
        (414.0, 892.0),
      ]) {
        expect(
          geometry
              .fit(availableWidth: viewport.$1, availableHeight: viewport.$2)
              .fitsBounds,
          isTrue,
          reason: '${candidate.level} at $viewport',
        );
      }
    }
  });

  test('coarse silhouette gates expose human-perceived repetition', () {
    expect(kLevels81To160AnchorClasses.values.toSet().length,
        greaterThanOrEqualTo(12));
    final classCounts = <String, int>{};
    for (final value in kLevels81To160AnchorClasses.values) {
      classCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    expect(classCounts.values.every((count) => count <= 4), isTrue);
    expect(kLevels81To160OpenVisualAnchors.length, greaterThanOrEqualTo(8));
    expect(
        kLevels81To160AsymmetricVisualAnchors.length, greaterThanOrEqualTo(4));
    expect(kLevels81To160WideVisualAnchors.length, greaterThanOrEqualTo(3));
    expect(
        metrics.values.any((value) => value.coarseClass == 'Solid rectangle'),
        isFalse);

    for (final current in metrics.values) {
      final sameEnvelope = metrics.values
          .where((other) =>
              (current.widthOccupancy - other.widthOccupancy).abs() <= .02 &&
              (current.heightOccupancy - other.heightOccupancy).abs() <= .02)
          .length;
      expect(sameEnvelope, lessThanOrEqualTo(4),
          reason:
              '${current.widthOccupancy}/${current.heightOccupancy} envelope');
    }

    for (var index = 0; index < anchors.length - 1; index++) {
      final current = anchors[index];
      final next = anchors[index + 1];
      final comparison = compareCoarseSilhouettes(
        metrics[current.level]!,
        metrics[next.level]!,
        familyA: current.family,
        familyB: next.family,
      );
      expect(comparison.score, lessThan(.78),
          reason:
              'adjacent anchors ${current.level}/${next.level}: ${comparison.warnings.join(', ')}');
    }

    for (var index = 0; index < anchors.length; index++) {
      for (var otherIndex = index + 1;
          otherIndex < anchors.length;
          otherIndex++) {
        final current = anchors[index];
        final other = anchors[otherIndex];
        if (kLevels81To160AnchorClasses[current.level] !=
            kLevels81To160AnchorClasses[other.level]) {
          continue;
        }
        final comparison = compareCoarseSilhouettes(
          metrics[current.level]!,
          metrics[other.level]!,
        );
        expect(comparison.score, lessThan(.82),
            reason:
                'same-class anchors ${current.level}/${other.level} need transformation');
      }
    }
    for (final level in const [100, 120, 140, 160]) {
      expect(metrics[level]!.coarseClass, isNot('Solid rectangle'));
    }
  });

  test('production source does not import visual candidate catalogue', () {
    for (final path in const [
      'lib/core/constants/level_data.dart',
      'lib/core/constants/chapter_data.dart',
      'lib/core/router/app_router.dart',
      'lib/screens/game/game_screen.dart',
      'lib/screens/journey/journey_screen.dart',
    ]) {
      final file = File(path);
      if (!file.existsSync()) continue;
      expect(
        file.readAsStringSync(),
        isNot(contains('levels_81_160_candidate_data')),
        reason: path,
      );
    }
  });

  test('visual redesign preview exports are complete and nonblank', () {
    const directory =
        'artifacts/layout-previews/levels-81-160-visual-redesign-pass-1';
    const additionalSizes = {
      81,
      100,
      110,
      120,
      121,
      135,
      140,
      141,
      145,
      155,
      160,
    };
    for (final candidate in anchors) {
      for (final suffix in const ['390x844', 'diagnostic', 'silhouette']) {
        _expectPng(
          File('$directory/${candidate.layout.id}_$suffix.png'),
          expectedWidth: 390,
          expectedHeight: 844,
        );
      }
      if (additionalSizes.contains(candidate.level)) {
        _expectPng(
          File('$directory/${candidate.layout.id}_360x640.png'),
          expectedWidth: 360,
          expectedHeight: 640,
        );
        _expectPng(
          File('$directory/${candidate.layout.id}_430x932.png'),
          expectedWidth: 430,
          expectedHeight: 932,
        );
      }
    }
    for (final name in const [
      'levels-81-160-visual-redesign-pass-1-overview.png',
      'levels-81-160-visual-redesign-pass-1-silhouette-overview.png',
      'chapter-5-anchor-overview.png',
      'chapter-6-anchor-overview.png',
      'chapter-7-anchor-overview.png',
      'chapter-8-anchor-overview.png',
      'old-vs-new-anchor-comparison.png',
      'finale-comparison-levels-20-160.png',
      'envelope-distribution.png',
      'coarse-silhouette-classification.png',
    ]) {
      _expectPng(File('$directory/$name'));
    }
  });
}

void _expectPng(
  File file, {
  int? expectedWidth,
  int? expectedHeight,
}) {
  expect(file.existsSync(), isTrue, reason: file.path);
  final decoded = image.decodePng(file.readAsBytesSync());
  expect(decoded, isNotNull, reason: file.path);
  if (expectedWidth != null) {
    expect(decoded!.width, expectedWidth, reason: file.path);
  }
  if (expectedHeight != null) {
    expect(decoded!.height, expectedHeight, reason: file.path);
  }
  final sampledColors = <int>{};
  for (var y = 0; y < 24; y++) {
    for (var x = 0; x < 24; x++) {
      final pixel = decoded!.getPixel(
        x * (decoded.width - 1) ~/ 23,
        y * (decoded.height - 1) ~/ 23,
      );
      sampledColors.add(
        (pixel.r.toInt() ~/ 8) << 10 |
            (pixel.g.toInt() ~/ 8) << 5 |
            pixel.b.toInt() ~/ 8,
      );
    }
  }
  expect(file.lengthSync(), greaterThan(2000), reason: file.path);
  expect(sampledColors.length, greaterThan(1), reason: file.path);
}
