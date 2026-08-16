import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/economy/economy_models.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/providers/progress_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('planned, implemented, and unavailable horizons stay separate', () {
    expect(kPlannedCampaignLevelCount, 400);
    expect(kImplementedCampaignLevelCount, 280);
    expect(kImplementedFinalLevelId, 280);
    expect(kLevels.map((level) => level.id),
        orderedEquals(List.generate(280, (index) => index + 1)));
    expect(kLevels201To240Candidates.map((candidate) => candidate.level),
        orderedEquals(List.generate(40, (index) => index + 201)));
    expect(getLevelById(201), isNotNull);
    expect(getLevelById(240), isNotNull);
    expect(getLevelById(241), isNotNull);
    expect(getLevelById(280), isNotNull);
    expect(getLevelById(281), isNull);
  });

  test('a schema-v4 Level-200 veteran retains progression and entitlements',
      () async {
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 200,
      'completed_199': true,
      'completed_200': true,
      'stars_200': 3,
      'best_score_200': 123456,
      'economy_cowries': 4321,
      'monetization_entitlement_remove_ads': true,
      'monetization_purchase_supporter_pack': true,
      'collection_unlocked_gye_nyame': true,
      'sound_enabled': false,
      'music_enabled': false,
      'music_volume': .35,
      'achievement_claimed_complete_campaign': true,
    });
    final storage = StorageService();
    await storage.init();

    expect(storage.getHighestCompletedLevel(), 200);
    expect(storage.isLevelCompleted(200), isTrue);
    expect(storage.getStars(200), 3);
    expect(storage.getBestScore(200), 123456);
    expect(storage.getCowries(), 4321);
    expect(storage.hasMonetizationEntitlement('remove_ads'), isTrue);
    expect(storage.hasMonetizationPurchase('supporter_pack'), isTrue);
    expect(storage.isCollectionUnlocked('gye_nyame'), isTrue);
    expect(storage.isSoundEnabled(), isFalse);
    expect(storage.isMusicEnabled(), isFalse);
    expect(storage.getMusicVolume(), .35);
    expect(storage.isAchievementClaimed('complete_campaign'), isTrue);
    expect(storage.isLevelUnlocked(201), isTrue,
        reason: 'Level 200 completion is the Level 201 predecessor gate');
    expect(getLevelById(201), isNotNull);
    final progress = ProgressService(storage);
    expect(progress.nextUnfinishedLevelId, 201);
    expect(progress.hasCompletedAllLevels, isFalse);
  });

  test('a Level-240 veteran continues at 241 without losing player state',
      () async {
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 240,
      'completed_239': true,
      'completed_240': true,
      'stars_240': 3,
      'best_score_240': 987654,
      'economy_cowries': 7654,
      'economy_booster_hint': 5,
      'economy_tx_chapter:12:complete': true,
      'monetization_entitlement_remove_ads': true,
      'monetization_purchase_supporter_pack': true,
      'collection_unlocked_gye_nyame': true,
      'achievement_claimed_complete_200': true,
      'sound_enabled': false,
      'music_enabled': false,
      'music_volume': .35,
      'show_tile_names': false,
      'haptic_intensity': 'low',
    });
    final storage = StorageService();
    await storage.init();
    final progress = ProgressService(storage);

    expect(progress.highestCompletedLevel, 240);
    expect(progress.nextUnfinishedLevelId, 241);
    expect(progress.hasCompletedAllLevels, isFalse);
    expect(storage.isLevelUnlocked(241), isTrue);
    expect(storage.isLevelCompleted(240), isTrue);
    expect(storage.getStars(240), 3);
    expect(storage.getBestScore(240), 987654);
    expect(storage.getCowries(), 7654);
    expect(storage.getBooster(BoosterType.hint), 5);
    expect(storage.hasEconomyTransaction('chapter:12:complete'), isTrue);
    expect(storage.hasMonetizationEntitlement('remove_ads'), isTrue);
    expect(storage.hasMonetizationPurchase('supporter_pack'), isTrue);
    expect(storage.isCollectionUnlocked('gye_nyame'), isTrue);
    expect(storage.isAchievementClaimed('complete_200'), isTrue);
    expect(storage.isSoundEnabled(), isFalse);
    expect(storage.isMusicEnabled(), isFalse);
    expect(storage.getMusicVolume(), .35);
    expect(storage.isShowTileNames(), isFalse);
    expect(storage.getHapticIntensity().name, 'low');
  });

  test('implemented transitions are contiguous and stop safely after 280', () {
    for (final transition in const [
      (199, 200),
      (200, 201),
      (219, 220),
      (220, 221),
      (239, 240),
      (240, 241),
      (259, 260),
      (260, 261),
      (279, 280),
    ]) {
      expect(getLevelById(transition.$1 + 1)?.id, transition.$2);
    }
    expect(getLevelById(281), isNull);
  });
}
