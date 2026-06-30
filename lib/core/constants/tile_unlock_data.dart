import 'tile_data.dart';

class TileUnlockRule {
  final String tileId;
  final int levelId;

  const TileUnlockRule({
    required this.tileId,
    required this.levelId,
  });
}

const int kStarterTileUnlockCount = 10;
const int kCommonTileUnlockEndIndex = 50;
const int kAdvancedTileUnlockEndIndex = 80;
const int kFinalCampaignUnlockLevel = 200;

final List<TileUnlockRule> kTileUnlockRules = _buildTileUnlockRules();

List<String> tileIdsUnlockedAtLevel(int levelId) {
  return [
    for (final rule in kTileUnlockRules)
      if (rule.levelId == levelId) rule.tileId,
  ];
}

List<String> tileIdsUnlockedThroughLevel(int completedLevelId) {
  return [
    for (final rule in kTileUnlockRules)
      if (rule.levelId <= completedLevelId) rule.tileId,
  ];
}

int? unlockLevelForTileId(String tileId) {
  for (final rule in kTileUnlockRules) {
    if (rule.tileId == tileId) return rule.levelId;
  }
  return null;
}

List<TileUnlockRule> _buildTileUnlockRules() {
  final rules = <TileUnlockRule>[];

  for (final tileId in kTileIds.take(kStarterTileUnlockCount)) {
    rules.add(TileUnlockRule(tileId: tileId, levelId: 1));
  }

  _addSpreadUnlocks(
    rules,
    tileIds: kTileIds.sublist(
      kStarterTileUnlockCount,
      kCommonTileUnlockEndIndex,
    ),
    firstLevel: 2,
    lastLevel: 80,
  );

  _addSpreadUnlocks(
    rules,
    tileIds: kTileIds.sublist(
      kCommonTileUnlockEndIndex,
      kAdvancedTileUnlockEndIndex,
    ),
    firstLevel: 81,
    lastLevel: 150,
  );

  _addSpreadUnlocks(
    rules,
    tileIds: kTileIds.sublist(kAdvancedTileUnlockEndIndex),
    firstLevel: 151,
    lastLevel: kFinalCampaignUnlockLevel,
  );

  rules.sort((a, b) {
    final levelCompare = a.levelId.compareTo(b.levelId);
    if (levelCompare != 0) return levelCompare;
    return kTileIds.indexOf(a.tileId).compareTo(kTileIds.indexOf(b.tileId));
  });

  return List.unmodifiable(rules);
}

void _addSpreadUnlocks(
  List<TileUnlockRule> rules, {
  required List<String> tileIds,
  required int firstLevel,
  required int lastLevel,
}) {
  if (tileIds.isEmpty) return;
  if (tileIds.length == 1) {
    rules.add(TileUnlockRule(tileId: tileIds.single, levelId: firstLevel));
    return;
  }

  final span = lastLevel - firstLevel;
  for (var index = 0; index < tileIds.length; index++) {
    final level = firstLevel + (index * span / (tileIds.length - 1)).round();
    rules.add(TileUnlockRule(tileId: tileIds[index], levelId: level));
  }
}
