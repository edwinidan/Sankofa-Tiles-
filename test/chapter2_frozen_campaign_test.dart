import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/chapter2_layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';

void main() {
  test('Levels 21-40 retain exact approved Chapter 2 assignments', () {
    expect(kChapter2LayoutCandidates.map((c) => c.level),
        orderedEquals(List.generate(20, (index) => index + 21)));
    for (final candidate in kChapter2LayoutCandidates) {
      final level = getLevelById(candidate.level)!;
      expect(level.layoutName, candidate.layout.id,
          reason: 'Level ${candidate.level}');
      expect(level.name, candidate.proposedName,
          reason: 'Level ${candidate.level}');
      expect(level.namedLayout.positions,
          orderedEquals(candidate.layout.positions));
      expect(level.symbolCopyCounts.reduce((a, b) => a + b), level.tileCount);
      expect(level.symbolCopyCounts.every((count) => count.isEven), isTrue);
      expect(validateLayout(level.namedLayout, minimumOpeningTiles: 4).issues,
          isEmpty,
          reason: 'Level ${candidate.level}');
    }
  });

  test('Level 40 unlocks Level 41 and is not full campaign completion', () {
    expect(getLevelById(40)!.unlockRequirement, 39);
    expect(getLevelById(41), isNotNull);
    expect(getLevelById(41)!.unlockRequirement, 40);
    expect(kImplementedFinalLevelId, greaterThan(40));
  });
}
