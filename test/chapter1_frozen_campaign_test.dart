import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';

void main() {
  const expectedLayouts = <String>[
    'earlyOpenDiamond01',
    'earlyOpenDiamond02',
    'earlyBridge01',
    'earlyShrine01',
    'earlyLayeredDiamond01',
    'batchBOpenCourtyard01',
    'batchBRiverPath01',
    'batchBTempleGate01',
    'batchBGatheringWings01',
    'batchBTwinBridge01',
    'batchBSmallTurtle01',
    'batchBButterfly01',
    'batchBShrineSteps01',
    'batchBWisdomStaircase01',
    'batchBCrown01',
    'batchBOpenRing01',
    'batchBRoyalStool01',
    'batchBAncestralGate01',
    'batchBTwinTowers01',
    'batchBRaisedCourtyard01',
  ];

  test('Levels 1-20 retain their frozen production layout IDs', () {
    final levels = [for (var id = 1; id <= 20; id++) getLevelById(id)!];
    expect(levels.map((level) => level.id),
        orderedEquals(List.generate(20, (i) => i + 1)));
    expect(levels.map((level) => level.layoutName),
        orderedEquals(expectedLayouts));
    for (final level in levels) {
      expect(level.symbolCopyCounts.reduce((a, b) => a + b), level.tileCount);
      expect(level.symbolCopyCounts.every((count) => count.isEven), isTrue);
      expect(validateLayout(level.namedLayout).issues, isEmpty,
          reason: 'Level ${level.id}');
    }
  });

  test('Level 20 unlocks Level 21 without ending the campaign', () {
    expect(getLevelById(20)!.unlockRequirement, 19);
    expect(getLevelById(21), isNotNull);
    expect(getLevelById(21)!.unlockRequirement, 20);
    expect(kLevels.last.id, greaterThan(20));
  });

  test('collection milestones remain independent of gameplay layouts', () {
    expect(kCollectionScheduleFinalLevel, 400);
    for (var id = 1; id <= 20; id++) {
      expect(
          tileIdsUnlockedAtLevel(id),
          kTileUnlockMilestones
              .where((m) => m.completedLevel == id)
              .map((m) => m.tileId));
    }
  });
}
