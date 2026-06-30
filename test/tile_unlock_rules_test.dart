import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';

void main() {
  test('every Adinkra symbol has exactly one campaign unlock level', () {
    expect(kTileUnlockRules, hasLength(kTileIds.length));
    expect(kTileUnlockRules.map((rule) => rule.tileId).toSet(),
        equals(kTileIds.toSet()));

    for (final tileId in kTileIds) {
      expect(
        kTileUnlockRules.where((rule) => rule.tileId == tileId),
        hasLength(1),
        reason: '$tileId should have exactly one unlock rule',
      );
    }
  });

  test('unlock levels follow starter, steady, and advanced campaign pacing',
      () {
    expect(
      tileIdsUnlockedAtLevel(1),
      orderedEquals(kTileIds.take(kStarterTileUnlockCount)),
    );

    for (final rule in kTileUnlockRules) {
      expect(rule.levelId, inInclusiveRange(1, kFinalCampaignUnlockLevel));
    }

    final commonRules = kTileUnlockRules.where(
      (rule) =>
          kTileIds.indexOf(rule.tileId) >= kStarterTileUnlockCount &&
          kTileIds.indexOf(rule.tileId) < kCommonTileUnlockEndIndex,
    );
    expect(
      commonRules.map((rule) => rule.levelId),
      everyElement(inInclusiveRange(2, 80)),
    );

    final advancedRules = kTileUnlockRules.where(
      (rule) =>
          kTileIds.indexOf(rule.tileId) >= kCommonTileUnlockEndIndex &&
          kTileIds.indexOf(rule.tileId) < kAdvancedTileUnlockEndIndex,
    );
    expect(
      advancedRules.map((rule) => rule.levelId),
      everyElement(inInclusiveRange(81, 150)),
    );

    final rareRules = kTileUnlockRules.where(
      (rule) => kTileIds.indexOf(rule.tileId) >= kAdvancedTileUnlockEndIndex,
    );
    expect(
      rareRules.map((rule) => rule.levelId),
      everyElement(inInclusiveRange(151, 200)),
    );
  });

  test('through-level lookup returns deterministic campaign progress', () {
    final level1Unlocks = tileIdsUnlockedThroughLevel(1);
    final level80Unlocks = tileIdsUnlockedThroughLevel(80);
    final level150Unlocks = tileIdsUnlockedThroughLevel(150);
    final level200Unlocks = tileIdsUnlockedThroughLevel(200);

    expect(level1Unlocks, orderedEquals(kTileIds.take(10)));
    expect(level80Unlocks.toSet(), containsAll(kTileIds.take(50)));
    expect(level80Unlocks.toSet(), isNot(contains(kTileIds.last)));
    expect(level150Unlocks.toSet(), containsAll(kTileIds.take(80)));
    expect(level150Unlocks.toSet(), isNot(contains(kTileIds.last)));
    expect(level200Unlocks, orderedEquals(kTileIds));
  });
}
