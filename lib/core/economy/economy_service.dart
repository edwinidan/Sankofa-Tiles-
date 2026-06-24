import '../constants/chapter_data.dart';
import '../constants/level_data.dart';
import '../constants/tile_data.dart';
import '../utils/storage_service.dart';
import '../../models/game_state.dart';
import 'economy_config.dart';
import 'economy_models.dart';

class EconomyService {
  EconomyService(this._storage);

  final StorageService _storage;

  EconomyState loadState() {
    backfillCollectionUnlocks();
    return EconomyState(
      cowries: _storage.getCowries(),
      boosters: {
        for (final type in BoosterType.values) type: _storage.getBooster(type),
      },
      unlockedCollectionIds: _storage.getUnlockedCollectionIds(),
      claimedAchievementIds: _storage.getClaimedAchievementIds(),
      dailyRewardDay: _storage.getDailyRewardDay(),
      lastDailyClaimDate: _storage.getLastDailyClaimDate(),
    );
  }

  Future<bool> addCowries(
    int amount, {
    required String reason,
    String? transactionId,
  }) async {
    if (amount <= 0) return false;
    if (transactionId != null &&
        _storage.hasEconomyTransaction(transactionId)) {
      return false;
    }
    await _storage.setCowries(_storage.getCowries() + amount);
    if (transactionId != null) {
      await _storage.recordEconomyTransaction(transactionId);
    }
    return true;
  }

  Future<bool> spendCowries(int amount, {required String reason}) async {
    if (amount <= 0) return false;
    final balance = _storage.getCowries();
    if (balance < amount) return false;
    await _storage.setCowries(balance - amount);
    return true;
  }

  Future<bool> addBooster(
    BoosterType type,
    int count, {
    required String reason,
    String? transactionId,
  }) async {
    if (count <= 0) return false;
    if (transactionId != null &&
        _storage.hasEconomyTransaction(transactionId)) {
      return false;
    }
    await _storage.setBooster(type, _storage.getBooster(type) + count);
    if (transactionId != null) {
      await _storage.recordEconomyTransaction(transactionId);
    }
    return true;
  }

  Future<bool> spendBooster(BoosterType type) async {
    final current = _storage.getBooster(type);
    if (current <= 0) return false;
    await _storage.setBooster(type, current - 1);
    return true;
  }

  DailyReward getCurrentDailyReward() {
    final day = _storage.getDailyRewardDay().clamp(1, 7);
    return EconomyConfig.dailyRewards[day - 1];
  }

  bool canClaimDailyReward([DateTime? now]) {
    final today = _dateKey(now ?? DateTime.now());
    return _storage.getLastDailyClaimDate() != today;
  }

  Future<RewardGrantSummary> claimDailyReward([DateTime? now]) async {
    final claimDate = now ?? DateTime.now();
    if (!canClaimDailyReward(claimDate)) {
      return RewardGrantSummary(updatedBalance: _storage.getCowries());
    }
    final reward = getCurrentDailyReward();
    var cowries = 0;
    final boosters = <BoosterType, int>{};
    final txPrefix = 'daily:${_dateKey(claimDate)}:day${reward.day}';
    if (reward.cowries > 0) {
      final added = await addCowries(
        reward.cowries,
        reason: 'daily_reward',
        transactionId: '$txPrefix:cowries',
      );
      if (added) cowries += reward.cowries;
    }
    for (final entry in reward.boosters.entries) {
      final added = await addBooster(
        entry.key,
        entry.value,
        reason: 'daily_reward',
        transactionId: '$txPrefix:${entry.key.name}',
      );
      if (added) boosters[entry.key] = entry.value;
    }
    await _storage.setLastDailyClaimDate(_dateKey(claimDate));
    await _storage.setDailyRewardDay(reward.day == 7 ? 1 : reward.day + 1);
    return RewardGrantSummary(
      cowries: cowries,
      boosters: boosters,
      updatedBalance: _storage.getCowries(),
    );
  }

  Future<RewardGrantSummary> grantLevelRewards({
    required GameState gameState,
    required int previousStars,
    required bool wasCompleted,
  }) async {
    if (gameState.status != GameStatus.won) {
      return RewardGrantSummary(updatedBalance: _storage.getCowries());
    }

    final levelId = gameState.levelId;
    final stars = _computeStarsForLevel(gameState);
    var cowries = 0;
    var chapterCompleted = false;
    var newBest = false;
    final unlockedSymbols = <String>[];
    final achievements = <String>[];
    final boosters = <BoosterType, int>{};

    if (!wasCompleted) {
      const amount = EconomyConfig.firstClearCowries;
      final added = await addCowries(
        amount,
        reason: 'first_clear',
        transactionId: 'level:$levelId:first_clear',
      );
      if (added) cowries += amount;
    }

    if (stars > previousStars) {
      newBest = true;
      for (var star = previousStars + 1; star <= stars; star++) {
        const amount = EconomyConfig.starImprovementCowries;
        final added = await addCowries(
          amount,
          reason: 'star_improvement',
          transactionId: 'level:$levelId:star:$star',
        );
        if (added) cowries += amount;
      }
    }

    final level = getLevelById(levelId);
    if (level != null) {
      for (final id in level.tileIds.take(2)) {
        if (await _unlockCollection(id)) {
          unlockedSymbols.add(id);
        }
      }
    }

    if (isChapterFinalLevel(levelId) && !wasCompleted) {
      chapterCompleted = true;
      final added = await addCowries(
        EconomyConfig.chapterCompletionCowries,
        reason: 'chapter_complete',
        transactionId: 'chapter:${chapterForLevel(levelId).index}:complete',
      );
      if (added) cowries += EconomyConfig.chapterCompletionCowries;
    }

    final achievementRewards = await _grantEarnedAchievements(gameState);
    cowries += achievementRewards.cowries;
    boosters.addAll(achievementRewards.boosters);
    achievements.addAll(achievementRewards.achievements);

    return RewardGrantSummary(
      cowries: cowries,
      boosters: boosters,
      unlockedSymbols: unlockedSymbols,
      achievements: achievements,
      newBest: newBest,
      chapterCompleted: chapterCompleted,
      updatedBalance: _storage.getCowries(),
    );
  }

  void backfillCollectionUnlocks() {
    final completed =
        _storage.getHighestCompletedLevel().clamp(0, kLevels.length);
    for (final level in kLevels.where((level) => level.id <= completed)) {
      for (final id in level.tileIds.take(2)) {
        _storage.unlockCollectionIdSync(id);
      }
    }
  }

  Future<bool> _unlockCollection(String id) async {
    if (_storage.isCollectionUnlocked(id)) return false;
    await _storage.unlockCollectionId(id);
    return true;
  }

  Future<RewardGrantSummary> _grantEarnedAchievements(GameState state) async {
    var cowries = 0;
    final boosters = <BoosterType, int>{};
    final achievements = <String>[];
    for (final achievement in EconomyConfig.achievements) {
      if (_storage.isAchievementClaimed(achievement.id)) continue;
      if (!_isAchievementEarned(achievement, state)) continue;
      await _storage.claimAchievement(achievement.id);
      achievements.add(achievement.title);
      if (achievement.cowries > 0) {
        final added = await addCowries(
          achievement.cowries,
          reason: 'achievement',
          transactionId: 'achievement:${achievement.id}:cowries',
        );
        if (added) cowries += achievement.cowries;
      }
      for (final entry in achievement.boosters.entries) {
        final added = await addBooster(
          entry.key,
          entry.value,
          reason: 'achievement',
          transactionId: 'achievement:${achievement.id}:${entry.key.name}',
        );
        if (added) {
          boosters[entry.key] = (boosters[entry.key] ?? 0) + entry.value;
        }
      }
    }
    return RewardGrantSummary(
      cowries: cowries,
      boosters: boosters,
      achievements: achievements,
      updatedBalance: _storage.getCowries(),
    );
  }

  bool _isAchievementEarned(
      AchievementDefinition achievement, GameState state) {
    final completed = _storage.getHighestCompletedLevel() > state.levelId
        ? _storage.getHighestCompletedLevel()
        : state.levelId;
    final currentStars = _computeStarsForLevel(state);
    final totalStars = kLevels.fold(
      0,
      (sum, level) {
        final stored = _storage.getStars(level.id);
        if (level.id == state.levelId && currentStars > stored) {
          return sum + currentStars;
        }
        return sum + stored;
      },
    );
    return switch (achievement.id) {
      'first_level' => completed >= 1 || state.levelId >= 1,
      'first_three_star' => _computeStarsForLevel(state) >= 3 ||
          kLevels.any((level) => _storage.getStars(level.id) >= 3),
      'five_match_streak' => state.bestStreak >= 5,
      'ten_levels' => completed >= 10,
      'no_hint_clear' => state.hintsUsed == 0,
      'no_shuffle_clear' => state.shufflesUsed == 0,
      'chapter_complete' => isChapterFinalLevel(state.levelId),
      'discover_20_symbols' => _storage.getUnlockedCollectionIds().length >= 20,
      'earn_50_stars' => totalStars >= 50,
      'complete_campaign' => completed >= 50 || state.levelId >= 50,
      _ => false,
    };
  }

  int _computeStarsForLevel(GameState state) {
    final level = getLevelById(state.levelId);
    if (level == null) return 0;
    final thresholds = level.starThresholds;
    if (state.score >= thresholds[2]) return 3;
    if (state.score >= thresholds[1]) return 2;
    if (state.score >= thresholds[0]) return 1;
    return 0;
  }

  String collectionUnlockSource(String tileId) {
    for (final level in kLevels) {
      if (level.tileIds.take(2).contains(tileId)) {
        return 'Unlocked from Level ${level.id}';
      }
    }
    return 'Unlocked through the Grand Archive';
  }

  TileDefinition? tileById(String id) {
    for (final tile in kAllTiles) {
      if (tile.id == id) return tile;
    }
    return null;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
