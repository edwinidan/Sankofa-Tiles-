import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/economy/economy_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new installs receive the explicit ten-face starter collection',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    expect(storage.getUnlockedCollectionIds(), kStarterTileIds.toSet());
    expect(storage.getHighestCompletedLevel(), 0);
  });

  test('fresh player gets no batch at 1-3 and one persisted face at 4',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    final economy = EconomyService(storage);
    expect(economy.loadState().unlockedCollectionIds, hasLength(10));

    for (var level = 1; level <= 4; level++) {
      final summary = await economy.grantLevelRewards(
        gameState: _wonLevel(level),
        previousStars: 0,
        wasCompleted: false,
      );
      await storage.saveLevelResult(level, 999999, 3);
      expect(summary.unlockedSymbols, hasLength(level == 4 ? 1 : 0));
    }
    expect(storage.getUnlockedCollectionIds(), hasLength(11));
    expect(storage.isCollectionUnlocked(tileIdsUnlockedAtLevel(4).single),
        isTrue);

    final restarted = EconomyService(storage);
    expect(restarted.loadState().unlockedCollectionIds, hasLength(11));
    final replay = await restarted.grantLevelRewards(
      gameState: _wonLevel(4),
      previousStars: 3,
      wasCompleted: true,
    );
    expect(replay.unlockedSymbols, isEmpty);
    expect(storage.getUnlockedCollectionIds(), hasLength(11));
  });

  test('v4 migration unions explicit, legacy, and starter unlocks', () async {
    const explicitlyUnlocked = 'woforo_dua_pa_a';
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 3,
      'highest_completed_level': 5,
      'completed_5': true,
      'collection_unlocked_$explicitlyUnlocked': true,
      'economy_cowries': 777,
      'monetization_entitlement_remove_ads': true,
      'monetization_purchase_supporter_pack': true,
    });
    final storage = StorageService();
    await storage.init();

    expect(
      storage.getUnlockedCollectionIds(),
      containsAll({
        ...kStarterTileIds,
        ...legacyV1TileIdsUnlockedThroughLevel(5),
        explicitlyUnlocked,
      }),
    );
    expect(storage.getCowries(), 777);
    expect(storage.hasMonetizationEntitlement('remove_ads'), isTrue);
    expect(storage.hasMonetizationPurchase('supporter_pack'), isTrue);
    expect(storage.getHighestCompletedLevel(), 5);
  });

  test('migration is idempotent', () async {
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 3,
      'highest_completed_level': 80,
    });
    final first = StorageService();
    await first.init();
    final firstIds = first.getUnlockedCollectionIds();

    final second = StorageService();
    await second.init();
    expect(second.getUnlockedCollectionIds(), firstIds);
    expect(
      second.getUnlockedCollectionIds(),
      containsAll(legacyV1TileIdsUnlockedThroughLevel(80)),
    );
  });
}

GameState _wonLevel(int levelId) => GameState(
      tiles: const [],
      status: GameStatus.won,
      difficulty: DifficultyMode.normal,
      score: 999999,
      moves: 10,
      hintsUsed: 0,
      secondsElapsed: 30,
      levelId: levelId,
    );
