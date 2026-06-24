import 'economy_models.dart';

class EconomyConfig {
  const EconomyConfig._();

  static const firstClearCowries = 40;
  static const starImprovementCowries = 12;
  static const chapterCompletionCowries = 120;
  static const replayCowries = 0;

  static const dailyRewards = [
    DailyReward(day: 1, cowries: 40, label: '40 Cowries'),
    DailyReward(day: 2, boosters: {BoosterType.hint: 1}, label: '1 Hint'),
    DailyReward(day: 3, cowries: 55, label: '55 Cowries'),
    DailyReward(day: 4, boosters: {BoosterType.shuffle: 1}, label: '1 Shuffle'),
    DailyReward(day: 5, cowries: 75, label: '75 Cowries'),
    DailyReward(
      day: 6,
      boosters: {BoosterType.hint: 1, BoosterType.shuffle: 1},
      label: 'Booster Chest',
    ),
    DailyReward(
      day: 7,
      cowries: 120,
      boosters: {BoosterType.openPath: 1},
      label: 'Archive Chest',
    ),
  ];

  static const achievements = [
    AchievementDefinition(
      id: 'first_level',
      title: 'First Step',
      description: 'Complete your first level.',
      cowries: 50,
    ),
    AchievementDefinition(
      id: 'first_three_star',
      title: 'Golden Insight',
      description: 'Earn three stars on a level.',
      cowries: 75,
    ),
    AchievementDefinition(
      id: 'five_match_streak',
      title: 'Flow of Wisdom',
      description: 'Reach a five-match streak.',
      boosters: {BoosterType.hint: 1},
    ),
    AchievementDefinition(
      id: 'ten_levels',
      title: 'Archive Walker',
      description: 'Complete ten levels.',
      cowries: 100,
    ),
    AchievementDefinition(
      id: 'no_hint_clear',
      title: 'Clear Sight',
      description: 'Complete a level without using Hint.',
      cowries: 60,
    ),
    AchievementDefinition(
      id: 'no_shuffle_clear',
      title: 'Steady Path',
      description: 'Complete a level without using Shuffle.',
      cowries: 60,
    ),
    AchievementDefinition(
      id: 'chapter_complete',
      title: 'Chapter Keeper',
      description: 'Complete a chapter.',
      cowries: 120,
    ),
    AchievementDefinition(
      id: 'discover_20_symbols',
      title: 'Symbol Seeker',
      description: 'Discover twenty Adinkra symbols.',
      boosters: {BoosterType.openPath: 1},
    ),
    AchievementDefinition(
      id: 'earn_50_stars',
      title: 'Star Gatherer',
      description: 'Earn fifty total stars.',
      cowries: 150,
    ),
    AchievementDefinition(
      id: 'complete_campaign',
      title: 'Grand Archivist',
      description: 'Complete all 50 levels.',
      cowries: 300,
    ),
  ];
}
