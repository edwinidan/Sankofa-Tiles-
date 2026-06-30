import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/economy/economy_config.dart';
import 'package:sankofa_tiles/core/economy/economy_models.dart';
import 'package:sankofa_tiles/core/economy/economy_service.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Map<String, Object> _allAchievementsClaimed() => {
      for (final achievement in EconomyConfig.achievements)
        'achievement_claimed_${achievement.id}': true,
    };

const _wonLevelOne = GameState(
  tiles: [],
  status: GameStatus.won,
  difficulty: DifficultyMode.normal,
  score: 999999,
  moves: 12,
  hintsUsed: 0,
  secondsElapsed: 30,
  levelId: 1,
  bestStreak: 5,
  shufflesUsed: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('adds and spends Cowries without allowing negative balances', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);

    expect(await economy.addCowries(100, reason: 'test'), isTrue);
    expect(storage.getCowries(), 100);
    expect(await economy.spendCowries(35, reason: 'test'), isTrue);
    expect(storage.getCowries(), 65);
    expect(await economy.spendCowries(999, reason: 'test'), isFalse);
    expect(storage.getCowries(), 65);
  });

  test('transaction IDs make wallet grants idempotent', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);

    expect(
      await economy.addCowries(
        50,
        reason: 'test',
        transactionId: 'same_tx',
      ),
      isTrue,
    );
    expect(
      await economy.addCowries(
        50,
        reason: 'test',
        transactionId: 'same_tx',
      ),
      isFalse,
    );
    expect(storage.getCowries(), 50);
  });

  test('booster inventory spends and rejects zero inventory', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);

    expect(await economy.spendBooster(BoosterType.hint), isFalse);
    expect(
      await economy.addBooster(BoosterType.hint, 2, reason: 'test'),
      isTrue,
    );
    expect(storage.getBooster(BoosterType.hint), 2);
    expect(await economy.spendBooster(BoosterType.hint), isTrue);
    expect(storage.getBooster(BoosterType.hint), 1);
  });

  test('daily rewards cannot be claimed twice on the same day', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);
    final day = DateTime(2026, 6, 24);

    final first = await economy.claimDailyReward(day);
    final second = await economy.claimDailyReward(day);

    expect(first.cowries, EconomyConfig.dailyRewards.first.cowries);
    expect(second.hasRewards, isFalse);
    expect(storage.getCowries(), EconomyConfig.dailyRewards.first.cowries);
  });

  test('level rewards grant first clear once and restrict replay farming',
      () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);

    final first = await economy.grantLevelRewards(
      gameState: _wonLevelOne,
      previousStars: 0,
      wasCompleted: false,
    );
    final replay = await economy.grantLevelRewards(
      gameState: _wonLevelOne,
      previousStars: 3,
      wasCompleted: true,
    );

    expect(first.cowries, greaterThan(0));
    expect(replay.cowries, 0);
    expect(first.unlockedSymbols, orderedEquals(tileIdsUnlockedAtLevel(1)));
    expect(replay.unlockedSymbols, isEmpty);
    expect(storage.getCowries(), first.cowries);
  });

  test('star improvement rewards only new stars', () async {
    final storage = await _storage(_allAchievementsClaimed());
    final economy = EconomyService(storage);

    final summary = await economy.grantLevelRewards(
      gameState: _wonLevelOne,
      previousStars: 1,
      wasCompleted: true,
    );

    expect(summary.cowries, EconomyConfig.starImprovementCowries * 2);
  });

  test('achievements are claim-once', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);

    final first = await economy.grantLevelRewards(
      gameState: _wonLevelOne,
      previousStars: 0,
      wasCompleted: false,
    );
    final second = await economy.grantLevelRewards(
      gameState: _wonLevelOne,
      previousStars: 3,
      wasCompleted: true,
    );

    expect(first.achievements, isNotEmpty);
    expect(second.achievements, isEmpty);
  });

  test('collection unlocks backfill from existing progress', () async {
    final storage = await _storage({'highest_completed_level': 5});
    final economy = EconomyService(storage);

    final state = economy.loadState();

    expect(
      state.unlockedCollectionIds,
      equals(tileIdsUnlockedThroughLevel(5).toSet()),
    );
  });

  test('collection unlock sources come from the unlock rule table', () async {
    final storage = await _storage({});
    final economy = EconomyService(storage);
    final level200Tile = tileIdsUnlockedAtLevel(200).last;

    expect(economy.collectionUnlockSource('aban'), 'Unlocked at Level 1');
    expect(
      economy.collectionUnlockSource(level200Tile),
      'Unlocked at Level 200',
    );
  });

  test('corrupted negative balances and boosters recover safely', () async {
    final storage = await _storage({
      'economy_cowries': -500,
      'economy_booster_hint': -2,
    });

    expect(storage.getCowries(), 0);
    expect(storage.getBooster(BoosterType.hint), 0);
  });
}
