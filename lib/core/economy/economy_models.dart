enum BoosterType {
  hint,
  shuffle,
  openPath,
}

extension BoosterTypeLabel on BoosterType {
  String get label => switch (this) {
        BoosterType.hint => 'Hint',
        BoosterType.shuffle => 'Shuffle',
        BoosterType.openPath => 'Open Path',
      };
}

class EconomyState {
  const EconomyState({
    required this.cowries,
    required this.boosters,
    required this.unlockedCollectionIds,
    required this.claimedAchievementIds,
    this.dailyRewardDay = 1,
    this.lastDailyClaimDate,
  });

  final int cowries;
  final Map<BoosterType, int> boosters;
  final Set<String> unlockedCollectionIds;
  final Set<String> claimedAchievementIds;
  final int dailyRewardDay;
  final String? lastDailyClaimDate;

  int boosterCount(BoosterType type) => boosters[type] ?? 0;
}

class RewardGrantSummary {
  const RewardGrantSummary({
    this.cowries = 0,
    this.boosters = const {},
    this.unlockedSymbols = const [],
    this.achievements = const [],
    this.newBest = false,
    this.chapterCompleted = false,
    this.updatedBalance = 0,
  });

  final int cowries;
  final Map<BoosterType, int> boosters;
  final List<String> unlockedSymbols;
  final List<String> achievements;
  final bool newBest;
  final bool chapterCompleted;
  final int updatedBalance;

  bool get hasRewards =>
      cowries > 0 ||
      boosters.isNotEmpty ||
      unlockedSymbols.isNotEmpty ||
      achievements.isNotEmpty ||
      newBest ||
      chapterCompleted;
}

class DailyReward {
  const DailyReward({
    required this.day,
    this.cowries = 0,
    this.boosters = const {},
    this.label = '',
  });

  final int day;
  final int cowries;
  final Map<BoosterType, int> boosters;
  final String label;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    this.cowries = 0,
    this.boosters = const {},
  });

  final String id;
  final String title;
  final String description;
  final int cowries;
  final Map<BoosterType, int> boosters;
}
