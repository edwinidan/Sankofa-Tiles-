import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/core/economy/economy_models.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/level_model.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/progress_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';

class _RecordingAudioService extends AudioService {
  _RecordingAudioService() : super(sound: false, music: false);

  int stopSfxCalls = 0;

  @override
  Future<void> stopSfx() async {
    stopSfxCalls++;
  }
}

class _RecordingStorage extends StorageService {
  int saveCalls = 0;
  int cowries = 0;
  final boosters = <BoosterType, int>{};
  final transactions = <String>{};
  final unlockedCollectionIds = <String>{};
  final claimedAchievementIds = <String>{};
  final monetizationEntitlements = <String>{};
  final monetizationPurchases = <String>{};
  final monetizationCallbacks = <String>{};
  int interstitialCompletedSinceLast = 0;
  int interstitialSessionCount = 0;
  DateTime? lastInterstitialAt;
  DateTime? lastRewardedAdAt;

  @override
  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    saveCalls++;
  }

  @override
  int getStars(int levelId) => 0;

  @override
  bool isLevelCompleted(int levelId) => false;

  @override
  int getHighestCompletedLevel() => 0;

  @override
  LevelResult? getLevelResult(int levelId) => null;

  @override
  int getCowries() => cowries;

  @override
  Future<void> setCowries(int amount) async {
    cowries = amount;
  }

  @override
  int getBooster(BoosterType type) => boosters[type] ?? 0;

  @override
  Future<void> setBooster(BoosterType type, int count) async {
    boosters[type] = count;
  }

  @override
  bool hasEconomyTransaction(String transactionId) =>
      transactions.contains(transactionId);

  @override
  Future<void> recordEconomyTransaction(String transactionId) async {
    transactions.add(transactionId);
  }

  @override
  int getDailyRewardDay() => 1;

  @override
  Future<void> setDailyRewardDay(int day) async {}

  @override
  String? getLastDailyClaimDate() => null;

  @override
  Future<void> setLastDailyClaimDate(String value) async {}

  @override
  bool isCollectionUnlocked(String tileId) =>
      unlockedCollectionIds.contains(tileId);

  @override
  Future<void> unlockCollectionId(String tileId) async {
    unlockedCollectionIds.add(tileId);
  }

  @override
  void unlockCollectionIdSync(String tileId) {
    unlockedCollectionIds.add(tileId);
  }

  @override
  Set<String> getUnlockedCollectionIds() => unlockedCollectionIds;

  @override
  bool isAchievementClaimed(String achievementId) =>
      claimedAchievementIds.contains(achievementId);

  @override
  Future<void> claimAchievement(String achievementId) async {
    claimedAchievementIds.add(achievementId);
  }

  @override
  Set<String> getClaimedAchievementIds() => claimedAchievementIds;

  @override
  bool hasMonetizationEntitlement(String entitlementId) =>
      monetizationEntitlements.contains(entitlementId);

  @override
  Future<void> setMonetizationEntitlement(String entitlementId) async {
    monetizationEntitlements.add(entitlementId);
  }

  @override
  Set<String> getMonetizationEntitlementIds() => monetizationEntitlements;

  @override
  bool hasMonetizationPurchase(String productId) =>
      monetizationPurchases.contains(productId);

  @override
  Future<void> recordMonetizationPurchase(String productId) async {
    monetizationPurchases.add(productId);
  }

  @override
  Set<String> getMonetizationPurchaseIds() => monetizationPurchases;

  @override
  bool hasMonetizationCallback(String callbackId) =>
      monetizationCallbacks.contains(callbackId);

  @override
  Future<void> recordMonetizationCallback(String callbackId) async {
    monetizationCallbacks.add(callbackId);
  }

  @override
  int getInterstitialCompletedSinceLast() => interstitialCompletedSinceLast;

  @override
  Future<void> setInterstitialCompletedSinceLast(int count) async {
    interstitialCompletedSinceLast = count;
  }

  @override
  int getInterstitialSessionCount() => interstitialSessionCount;

  @override
  Future<void> setInterstitialSessionCount(int count) async {
    interstitialSessionCount = count;
  }

  @override
  DateTime? getLastInterstitialAt() => lastInterstitialAt;

  @override
  Future<void> setLastInterstitialAt(DateTime value) async {
    lastInterstitialAt = value;
  }

  @override
  DateTime? getLastRewardedAdAt() => lastRewardedAdAt;

  @override
  Future<void> setLastRewardedAdAt(DateTime value) async {
    lastRewardedAdAt = value;
  }
}

void main() {
  testWidgets('disposing ResultScreen does not access a disposed ref',
      (tester) async {
    final audio = _RecordingAudioService();
    final storage = _RecordingStorage();
    const gameState = GameState(
      tiles: [],
      status: GameStatus.won,
      difficulty: DifficultyMode.relaxed,
      score: 1500,
      moves: 14,
      hintsUsed: 0,
      secondsElapsed: 42,
      levelId: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(audio),
          storageServiceProvider.overrideWithValue(storage),
          progressProvider.overrideWithValue(ProgressService(storage)),
        ],
        child: const MaterialApp(
          home: ResultScreen(
            gameState: gameState,
            launchConfig: GameLaunchConfig(
              levelId: 1,
              launchMode: GameLaunchMode.normalProgression,
            ),
          ),
        ),
      ),
    );

    expect(storage.saveCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(audio.stopSfxCalls, 1);
    expect(storage.saveCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
