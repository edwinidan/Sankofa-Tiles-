import 'tile_data.dart';

enum UnlockRewardType { starter, ordinary }

class TileUnlockMilestone {
  final int completedLevel;
  final String tileId;
  final UnlockRewardType rewardType;

  const TileUnlockMilestone({
    required this.completedLevel,
    required this.tileId,
    required this.rewardType,
  });
}

/// Planning horizon only; it does not make missing campaign levels playable.
const int kCollectionScheduleFinalLevel = 400;
const int kStarterTileUnlockCount = 10;

final List<String> kStarterTileIds =
    List.unmodifiable(kTileIds.take(kStarterTileUnlockCount));

/// Adinkra rewards retain their original schedule. Heritage rewards are
/// additive at their debut levels and can share a level with an Adinkra reward.
final List<TileUnlockMilestone> kTileUnlockMilestones =
    List.unmodifiable(_buildTileUnlockMilestones());

List<String> tileIdsUnlockedAtLevel(int levelId) => [
      for (final milestone in kTileUnlockMilestones)
        if (milestone.completedLevel == levelId) milestone.tileId,
    ];

List<String> tileIdsUnlockedThroughLevel(int completedLevelId) => [
      ...kStarterTileIds,
      for (final milestone in kTileUnlockMilestones)
        if (milestone.completedLevel <= completedLevelId) milestone.tileId,
    ];

int? unlockLevelForTileId(String tileId) {
  if (kStarterTileIds.contains(tileId)) return 0;
  for (final milestone in kTileUnlockMilestones) {
    if (milestone.tileId == tileId) return milestone.completedLevel;
  }
  return null;
}

List<TileUnlockMilestone> _buildTileUnlockMilestones() {
  final laterIds = kAdinkraTileIds.skip(kStarterTileUnlockCount).toList();
  const firstLevel = 4;
  const span = kCollectionScheduleFinalLevel - firstLevel;
  final milestones = [
    for (var index = 0; index < laterIds.length; index++)
      TileUnlockMilestone(
        completedLevel:
            firstLevel + (index * span / (laterIds.length - 1)).round(),
        tileId: laterIds[index],
        rewardType: UnlockRewardType.ordinary,
      ),
    for (final entry in kHeritageIntroductions.entries)
      TileUnlockMilestone(
        completedLevel: entry.value,
        tileId: entry.key,
        rewardType: UnlockRewardType.ordinary,
      ),
  ];
  milestones.sort((a, b) => a.completedLevel != b.completedLevel
      ? a.completedLevel.compareTo(b.completedLevel)
      : kTileIds.indexOf(a.tileId).compareTo(kTileIds.indexOf(b.tileId)));
  return milestones;
}

/// Frozen version-1 entitlement calculation used only by migration. Never
/// alter it when the live schedule changes: old earnings are permanent.
List<String> legacyV1TileIdsUnlockedThroughLevel(int completedLevelId) {
  final rules = <({String tileId, int levelId})>[
    for (final tileId in kAdinkraTileIds.take(10)) (tileId: tileId, levelId: 1),
    ..._legacySpread(kAdinkraTileIds.sublist(10, 50), 2, 80),
    ..._legacySpread(kAdinkraTileIds.sublist(50, 80), 81, 150),
    ..._legacySpread(kAdinkraTileIds.sublist(80), 151, 200),
  ];
  return [
    for (final rule in rules)
      if (rule.levelId <= completedLevelId) rule.tileId,
  ];
}

List<({String tileId, int levelId})> _legacySpread(
  List<String> tileIds,
  int firstLevel,
  int lastLevel,
) {
  final span = lastLevel - firstLevel;
  return [
    for (var index = 0; index < tileIds.length; index++)
      (
        tileId: tileIds[index],
        levelId: firstLevel + (index * span / (tileIds.length - 1)).round(),
      ),
  ];
}
