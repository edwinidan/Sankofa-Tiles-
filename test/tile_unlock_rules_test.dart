import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';

void main() {
  test('all 97 definitions are collectible and IDs are one-to-one', () {
    expect(kTileIds, hasLength(97));
    expect(kAllTiles, hasLength(97));
    expect(kTileIds.toSet(), hasLength(kTileIds.length));
    expect(kAllTiles.map((tile) => tile.id).toSet(), kTileIds.toSet());
  });

  test('every collectible occurs exactly once in starter or milestones', () {
    final scheduledIds = [
      ...kStarterTileIds,
      ...kTileUnlockMilestones.map((milestone) => milestone.tileId),
    ];
    expect(kStarterTileIds, orderedEquals(kTileIds.take(10)));
    expect(scheduledIds, hasLength(kTileIds.length));
    expect(scheduledIds.toSet(), hasLength(kTileIds.length));
    expect(scheduledIds.toSet(), kTileIds.toSet());
  });

  test('later milestones are ordered, individual, and span 4 to 400', () {
    final levels =
        kTileUnlockMilestones.map((milestone) => milestone.completedLevel);
    expect(kTileUnlockMilestones, hasLength(87));
    expect(levels.first, 4);
    expect(levels.last, kCollectionScheduleFinalLevel);
    expect(levels, orderedEquals(levels.toList()..sort()));
    expect(levels.toSet(), hasLength(levels.length));
    expect(
      kTileUnlockMilestones,
      everyElement(
        isA<TileUnlockMilestone>().having(
          (milestone) => milestone.rewardType,
          'reward type',
          UnlockRewardType.ordinary,
        ),
      ),
    );
  });

  test('starter collection is available before completing Level 1', () {
    expect(tileIdsUnlockedThroughLevel(0), orderedEquals(kStarterTileIds));
    expect(tileIdsUnlockedAtLevel(1), isEmpty);
    expect(unlockLevelForTileId(kStarterTileIds.first), 0);
  });

  test('legacy entitlement lookup remains frozen for migration', () {
    expect(legacyV1TileIdsUnlockedThroughLevel(0), isEmpty);
    expect(legacyV1TileIdsUnlockedThroughLevel(1), hasLength(10));
    expect(
      legacyV1TileIdsUnlockedThroughLevel(200),
      orderedEquals(kTileIds),
    );
  });
}
