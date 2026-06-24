import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/economy/economy_models.dart';
import '../core/economy/economy_service.dart';
import '../core/utils/analytics_service.dart';
import '../models/game_state.dart';
import 'settings_provider.dart';

final economyServiceProvider = Provider<EconomyService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return EconomyService(storage);
});

final economyProvider =
    StateNotifierProvider<EconomyNotifier, EconomyState>((ref) {
  final service = ref.watch(economyServiceProvider);
  return EconomyNotifier(service);
});

class EconomyNotifier extends StateNotifier<EconomyState> {
  EconomyNotifier(this._service) : super(_service.loadState());

  final EconomyService _service;

  void refresh() {
    state = _service.loadState();
  }

  Future<bool> addCowries(
    int amount, {
    required String reason,
    String? transactionId,
  }) async {
    final result = await _service.addCowries(
      amount,
      reason: reason,
      transactionId: transactionId,
    );
    if (result) AnalyticsService.logWalletChanged(reason, amount);
    refresh();
    return result;
  }

  Future<bool> spendCowries(int amount, {required String reason}) async {
    final result = await _service.spendCowries(amount, reason: reason);
    if (result) AnalyticsService.logWalletChanged(reason, -amount);
    refresh();
    return result;
  }

  Future<bool> addBooster(
    BoosterType type,
    int count, {
    required String reason,
    String? transactionId,
  }) async {
    final result = await _service.addBooster(
      type,
      count,
      reason: reason,
      transactionId: transactionId,
    );
    if (result) {
      AnalyticsService.logBoosterChanged(type.name, reason, count);
    }
    refresh();
    return result;
  }

  Future<bool> spendBooster(BoosterType type) async {
    final result = await _service.spendBooster(type);
    if (result) {
      AnalyticsService.logBoosterChanged(type.name, 'spend', -1);
    }
    refresh();
    return result;
  }

  bool canClaimDailyReward([DateTime? now]) {
    return _service.canClaimDailyReward(now);
  }

  DailyReward get currentDailyReward => _service.getCurrentDailyReward();

  Future<RewardGrantSummary> claimDailyReward([DateTime? now]) async {
    final claimedDay = currentDailyReward.day;
    final summary = await _service.claimDailyReward(now);
    if (summary.hasRewards) {
      AnalyticsService.logDailyRewardClaimed(claimedDay);
    }
    refresh();
    return summary;
  }

  Future<RewardGrantSummary> grantLevelRewards({
    required GameState gameState,
    required int previousStars,
    required bool wasCompleted,
  }) async {
    final summary = await _service.grantLevelRewards(
      gameState: gameState,
      previousStars: previousStars,
      wasCompleted: wasCompleted,
    );
    for (final symbol in summary.unlockedSymbols) {
      AnalyticsService.logCollectionUnlocked(symbol);
    }
    for (final achievement in summary.achievements) {
      AnalyticsService.logAchievementUnlocked(achievement);
    }
    refresh();
    return summary;
  }
}
