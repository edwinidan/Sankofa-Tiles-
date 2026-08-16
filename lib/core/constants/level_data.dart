import 'layout_data.dart';
import 'batch_b_layout_data.dart';
import 'chapter2_layout_data.dart';
import 'tile_data.dart';
import 'levels_41_80_candidate_data.dart';
import 'levels_201_240_candidate_data.dart';
import 'levels_241_280_candidate_data.dart';

class SymbolCopyPlan {
  final int symbolPoolSize;
  final int preferredCopies;

  const SymbolCopyPlan({
    required this.symbolPoolSize,
    this.preferredCopies = 4,
  });

  List<int> copyCountsForTileCount(int tileCount) {
    if (tileCount.isOdd) {
      throw ArgumentError.value(tileCount, 'tileCount', 'Must be even');
    }
    if (symbolPoolSize <= 0) {
      throw ArgumentError.value(symbolPoolSize, 'symbolPoolSize');
    }
    final effectivePoolSize = symbolPoolSize.clamp(1, tileCount ~/ 2);

    var remaining = tileCount;
    final counts = <int>[];
    for (var i = 0; i < effectivePoolSize; i++) {
      final remainingSymbols = effectivePoolSize - i;
      final minForLater = (remainingSymbols - 1) * 2;
      var copies = remaining - minForLater;
      if (copies > preferredCopies) copies = preferredCopies;
      if (copies.isOdd) copies--;
      if (copies < 2) copies = 2;
      counts.add(copies);
      remaining -= copies;
    }
    if (remaining != 0) {
      throw StateError('Invalid symbol copy distribution remainder $remaining');
    }
    return List.unmodifiable(counts);
  }

  String describeForTileCount(int tileCount) {
    final grouped = <int, int>{};
    for (final count in copyCountsForTileCount(tileCount)) {
      grouped[count] = (grouped[count] ?? 0) + 1;
    }
    final parts = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return parts.map((entry) => '${entry.value}x${entry.key}').join(' + ');
  }
}

class LevelDefinition {
  final int id;
  final String name;
  final String chapter;
  final NamedLayout namedLayout;
  final int unlockRequirement;
  final SymbolCopyPlan symbolPlan;
  final String difficultyCategory;
  final int symbolStartIndex;

  const LevelDefinition({
    required this.id,
    required this.name,
    required this.chapter,
    required this.namedLayout,
    required this.unlockRequirement,
    required this.symbolPlan,
    required this.difficultyCategory,
    this.symbolStartIndex = 0,
  });

  List<TilePosition> get layout => namedLayout.positions;
  String get layoutName => namedLayout.id;
  LayoutStats get stats => namedLayout.stats;
  int get tileCount => stats.tileCount;
  int get pairCount => stats.pairCount;
  int get layerCount => stats.layerCount;
  int get boardRows => stats.boardHeight;
  int get boardCols => stats.boardWidth;
  int get symbolPoolSize => symbolPlan.symbolPoolSize.clamp(1, pairCount);

  List<int> get symbolCopyCounts =>
      symbolPlan.copyCountsForTileCount(tileCount);

  String get symbolDistributionLabel =>
      symbolPlan.describeForTileCount(tileCount);

  List<String> get tileIds {
    return _progressiveTileIds(
      symbolPoolSize,
      startIndex: symbolStartIndex,
    );
  }

  List<int> get starThresholds {
    final coveredTiles = tileCount - stats.startingFreeTileCount;
    final complexity = tileCount * 36 +
        layerCount * 180 +
        coveredTiles * 9 +
        symbolPoolSize * 22 +
        stats.maxLayer * 120;
    final oneStar = ((complexity * 0.72) / 50).round() * 50;
    final twoStar = ((complexity * 1.02) / 50).round() * 50;
    final threeStar = ((complexity * 1.28) / 50).round() * 50;
    return [oneStar, twoStar, threeStar];
  }
}

List<String> _progressiveTileIds(
  int count, {
  required int startIndex,
}) {
  final ids = <String>[];
  final anchorCount = count >= 20 ? 10 : count ~/ 2;
  ids.addAll(kTileIds.take(anchorCount));

  var cursor = startIndex.clamp(0, kTileIds.length - 1);
  while (ids.length < count) {
    final id = kTileIds[cursor % kTileIds.length];
    if (!ids.contains(id)) ids.add(id);
    cursor++;
  }
  return List.unmodifiable(ids);
}

LevelDefinition _level(
  int id,
  String name,
  String _,
  NamedLayout layout,
  int symbols,
  String difficulty, {
  int preferredCopies = 4,
  int symbolStart = 0,
}) {
  return LevelDefinition(
    id: id,
    name: name,
    chapter: kJourneyCityNames[(id - 1) ~/ 10],
    namedLayout: layout,
    unlockRequirement: id - 1,
    symbolPlan: SymbolCopyPlan(
      symbolPoolSize: symbols,
      preferredCopies: preferredCopies,
    ),
    difficultyCategory: difficulty,
    symbolStartIndex: symbolStart,
  );
}

/// Ghana Journey destinations ordered to grow from smaller communities into
/// the country's largest urban centres as the campaign progresses.
const kJourneyCityNames = [
  'Kokrobite',
  'Ada Foah',
  'Aburi',
  'Axim',
  'Akosombo',
  'Elmina',
  'Winneba',
  'Ho',
  'Wa',
  'Bolgatanga',
  'Cape Coast',
  'Koforidua',
  'Techiman',
  'Sunyani',
  'Obuasi',
  'Amanfrom',
  'Sekondi-Takoradi',
  'Tamale',
  'Kumasi',
  'Accra',
];

List<LevelDefinition> _extendedCampaignLevels() {
  final chapters = <({String chapter, String difficulty})>[
    (chapter: 'Kokrobite', difficulty: 'Expert'),
    (chapter: 'Amanfrom', difficulty: 'Elder'),
    (chapter: 'Cape Coast', difficulty: 'Elder'),
    (chapter: 'Tamale', difficulty: 'Legendary'),
    (chapter: 'Koforidua', difficulty: 'Legendary'),
    (chapter: 'Ada Foah', difficulty: 'Legendary'),
    (chapter: 'Sunyani', difficulty: 'Legendary'),
    (chapter: 'Techiman', difficulty: 'Legendary'),
    (chapter: 'Wa', difficulty: 'Legendary'),
    (chapter: 'Elmina', difficulty: 'Legendary'),
    (chapter: 'Axim', difficulty: 'Mythic'),
    (chapter: 'Bolgatanga', difficulty: 'Mythic'),
    (chapter: 'Winneba', difficulty: 'Mythic'),
    (chapter: 'Akosombo', difficulty: 'Mythic'),
    (chapter: 'Aburi', difficulty: 'Mythic'),
  ];

  final layouts = <NamedLayout>[
    sacredBridgeLayout,
    layeredShrineLayout,
    ancestralCrownLayout,
    templeComplexLayout,
    grandTurtleLayout,
    multiPeakLayout,
    finalArchiveLayout,
    grandTreasuryLayout,
    layeredCourtyardLayout,
    hiddenCenterLayout,
    royalStoolLayout,
    festivalArchiveLayout,
    complexFortressLayout,
    splitIslandsLayout,
    raisedCourtyardLayout,
    fortressLayout,
    twinTowersLayout,
    wisdomStaircaseLayout,
    crownLayout,
    riverPathLayout,
  ];

  const motifs = [
    'Gate',
    'Shrine',
    'Crown',
    'Temple',
    'Crossing',
    'Peaks',
    'Archive',
    'Treasury',
    'Courtyard',
    'Trial',
  ];

  return List.unmodifiable([
    for (var chapterIndex = 0; chapterIndex < chapters.length; chapterIndex++)
      for (var slot = 0; slot < motifs.length; slot++)
        _level(
          51 + chapterIndex * motifs.length + slot,
          chapterIndex < 3
              ? kLevels41To80Candidates[
                      10 + chapterIndex * motifs.length + slot]
                  .proposedName
              : '${chapters[chapterIndex].chapter} ${motifs[slot]}',
          chapters[chapterIndex].chapter,
          chapterIndex < 3
              ? kLevels41To80Candidates[
                      10 + chapterIndex * motifs.length + slot]
                  .layout
              : chapterIndex == chapters.length - 1 && slot == motifs.length - 1
                  ? finalArchiveLayout
                  : layouts[(chapterIndex * 3 + slot) % layouts.length],
          34 + chapterIndex * 3 + slot,
          chapters[chapterIndex].difficulty,
          symbolStart:
              chapterIndex == chapters.length - 1 && slot == motifs.length - 1
                  ? kTileIds.length - 1
                  : 88 + chapterIndex * 7 + slot * 3,
        ),
  ]);
}

List<LevelDefinition> _approvedLevels201To240() => List.unmodifiable([
      for (var index = 0; index < kLevels201To240Candidates.length; index++)
        LevelDefinition(
          id: kLevels201To240Candidates[index].level,
          name: kLevels201To240Candidates[index].proposedName,
          chapter: index < 20 ? 'The Journey Reopens' : 'Living Memory',
          namedLayout: kLevels201To240Candidates[index].layout,
          unlockRequirement: kLevels201To240Candidates[index].level - 1,
          symbolPlan: kLevels201To240Candidates[index].symbolPlan,
          difficultyCategory:
              kLevels201To240Candidates[index].difficultyCategory,
          symbolStartIndex: 88 + index * 3,
        ),
    ]);

List<LevelDefinition> _approvedLevels241To280() => List.unmodifiable([
      for (var index = 0; index < kLevels241To280Candidates.length; index++)
        LevelDefinition(
          id: kLevels241To280Candidates[index].level,
          name: kLevels241To280Candidates[index].proposedName,
          chapter: index < 20 ? 'Rivers of Counsel' : 'Forest of Ancestors',
          namedLayout: kLevels241To280Candidates[index].layout,
          unlockRequirement: kLevels241To280Candidates[index].level - 1,
          symbolPlan: kLevels241To280Candidates[index].symbolPlan,
          difficultyCategory:
              kLevels241To280Candidates[index].difficultyCategory,
          symbolStartIndex: 208 + index * 3,
        ),
    ]);

final List<LevelDefinition> kLevels = [
  _level(1, 'First Symbols', 'Accra', earlyOpenDiamond01Layout, 7, 'Novice'),
  _level(2, 'New Roots', 'Accra', earlyOpenDiamond02Layout, 8, 'Novice'),
  _level(3, 'Side Paths', 'Accra', earlyBridge01Layout, 9, 'Novice'),
  _level(4, 'Small Turtle', 'Accra', earlyShrine01Layout, 10, 'Novice'),
  _level(5, 'Shrine Steps', 'Accra', earlyLayeredDiamond01Layout, 11, 'Novice'),
  _level(6, 'Open Courtyard', 'Accra', batchBOpenCourtyard01, 12, 'Novice'),
  _level(7, 'River Lesson', 'Accra', batchBRiverPath01, 12, 'Novice'),
  _level(8, 'Wisdom Gate', 'Accra', batchBTempleGate01, 13, 'Novice'),
  _level(9, 'Gathering Wings', 'Accra', batchBGatheringWings01, 14, 'Novice'),
  _level(10, 'Elder Bridge', 'Accra', batchBTwinBridge01, 15, 'Novice'),
  _level(11, 'Heritage Turtle', 'Kumasi', batchBSmallTurtle01, 16, 'Apprentice',
      symbolStart: 8),
  _level(12, 'Butterfly Path', 'Kumasi', batchBButterfly01, 17, 'Apprentice',
      symbolStart: 10),
  _level(13, 'Temple Steps', 'Kumasi', batchBShrineSteps01, 18, 'Apprentice',
      symbolStart: 12),
  _level(14, 'Wisdom Staircase', 'Kumasi', batchBWisdomStaircase01, 18,
      'Apprentice',
      symbolStart: 14),
  _level(15, 'Ancestral Crown', 'Kumasi', batchBCrown01, 19, 'Apprentice',
      symbolStart: 16),
  _level(16, 'Sacred Grove', 'Kumasi', batchBOpenRing01, 20, 'Apprentice',
      symbolStart: 18),
  _level(17, 'Golden Stool', 'Kumasi', batchBRoyalStool01, 21, 'Apprentice',
      symbolStart: 20),
  _level(
      18, 'Ancestral Gate', 'Kumasi', batchBAncestralGate01, 22, 'Apprentice',
      symbolStart: 22),
  _level(19, 'Twin Houses', 'Kumasi', batchBTwinTowers01, 23, 'Apprentice',
      symbolStart: 24),
  _level(20, 'Raised Courtyard', 'Kumasi', batchBRaisedCourtyard01, 24,
      'Apprentice',
      symbolStart: 26),
  _level(21, 'Grand Turtle', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[0].layout, 25, 'Strategic',
      symbolStart: 28),
  _level(22, 'Split Islands', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[1].layout, 26, 'Strategic',
      symbolStart: 30),
  _level(23, 'Royal Assembly', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[2].layout, 27, 'Strategic',
      symbolStart: 32),
  _level(24, 'Winding Path', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[3].layout, 28, 'Strategic',
      symbolStart: 34),
  _level(25, 'Ancestral Mask', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[4].layout, 29, 'Strategic',
      symbolStart: 36),
  _level(26, 'Fortress Spirits', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[5].layout, 24, 'Strategic',
      symbolStart: 38),
  _level(27, 'Hidden Center', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[6].layout, 30, 'Strategic',
      symbolStart: 40),
  _level(28, 'Butterfly Path', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[7].layout, 31, 'Strategic',
      symbolStart: 42),
  _level(29, 'Golden Foundation', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[8].layout, 32, 'Strategic',
      symbolStart: 44),
  _level(30, 'Sacred Crossing', 'Sekondi-Takoradi',
      kChapter2LayoutCandidates[9].layout, 33, 'Strategic',
      symbolStart: 46),
  _level(31, 'Path of Renewal', 'Obuasi', kChapter2LayoutCandidates[10].layout,
      34, 'Advanced',
      symbolStart: 48),
  _level(32, 'Hidden Wisdom', 'Obuasi', kChapter2LayoutCandidates[11].layout,
      35, 'Advanced',
      symbolStart: 50),
  _level(33, 'Gathered Emblem', 'Obuasi', kChapter2LayoutCandidates[12].layout,
      36, 'Advanced',
      symbolStart: 52),
  _level(34, 'Elders Assembly', 'Obuasi', kChapter2LayoutCandidates[13].layout,
      37, 'Advanced',
      symbolStart: 54),
  _level(35, 'Sacred Grove', 'Obuasi', kChapter2LayoutCandidates[14].layout, 38,
      'Advanced',
      symbolStart: 56),
  _level(36, 'Fortress Gate', 'Obuasi', kChapter2LayoutCandidates[15].layout,
      36, 'Advanced',
      symbolStart: 58),
  _level(37, 'Steadfast Spirits', 'Obuasi',
      kChapter2LayoutCandidates[16].layout, 38, 'Advanced',
      symbolStart: 60),
  _level(38, 'Twin Shrines', 'Obuasi', kChapter2LayoutCandidates[17].layout, 38,
      'Advanced',
      symbolStart: 62),
  _level(39, 'Ancestral Pillar', 'Obuasi', kChapter2LayoutCandidates[18].layout,
      39, 'Advanced',
      symbolStart: 64),
  _level(40, 'Ancestral Trial', 'Obuasi', kChapter2LayoutCandidates[19].layout,
      40, 'Advanced',
      symbolStart: 66),
  _level(41, 'Grand turtle Path', 'Ho', kLevels41To80Candidates[0].layout, 42,
      'Master',
      symbolStart: 68),
  _level(42, 'Twin sanctuary Path', 'Ho', kLevels41To80Candidates[1].layout, 43,
      'Master',
      symbolStart: 70),
  _level(43, 'Tall butterfly Path', 'Ho', kLevels41To80Candidates[2].layout, 44,
      'Master',
      symbolStart: 72),
  _level(44, 'Royal mask Path', 'Ho', kLevels41To80Candidates[3].layout, 42,
      'Master',
      symbolStart: 74),
  _level(45, 'Spiral courtyard Path', 'Ho', kLevels41To80Candidates[4].layout,
      40, 'Master',
      symbolStart: 76),
  _level(46, 'Layered bridges Path', 'Ho', kLevels41To80Candidates[5].layout,
      42, 'Master',
      symbolStart: 78),
  _level(47, 'Hollow fortress Path', 'Ho', kLevels41To80Candidates[6].layout,
      44, 'Master',
      symbolStart: 80),
  _level(48, 'Vertical fort Path', 'Ho', kLevels41To80Candidates[7].layout, 40,
      'Master',
      symbolStart: 82),
  _level(49, 'Ceremonial crown Path', 'Ho', kLevels41To80Candidates[8].layout,
      44, 'Master',
      symbolStart: 84),
  _level(50, 'Multi-arch gate Path', 'Ho', kLevels41To80Candidates[9].layout,
      46, 'Master',
      symbolStart: 86),
  ..._extendedCampaignLevels(),
  ..._approvedLevels201To240(),
  ..._approvedLevels241To280(),
];

/// Long-term target. Never use this to index [kLevels] or render level cards.
const int kPlannedCampaignLevelCount = 400;
const int kPlannedChapterCount = 20;
const int kPlannedLevelsPerChapter = 20;

int get kImplementedCampaignLevelCount => kLevels.length;
int get kImplementedFinalLevelId => kLevels.last.id;
int get kImplementedMaximumCampaignStars => kImplementedCampaignLevelCount * 3;

// Backwards-compatible derived names for existing callers.
int get kCampaignLevelCount => kImplementedCampaignLevelCount;
int get kFinalCampaignLevelId => kImplementedFinalLevelId;
int get kMaximumCampaignStars => kImplementedMaximumCampaignStars;

LevelDefinition? getLevelById(int id) {
  try {
    return kLevels.firstWhere((level) => level.id == id);
  } catch (_) {
    return null;
  }
}
