import 'layout_data.dart';
import 'tile_data.dart';

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
  String chapter,
  NamedLayout layout,
  int symbols,
  String difficulty, {
  int preferredCopies = 4,
  int symbolStart = 0,
}) {
  return LevelDefinition(
    id: id,
    name: name,
    chapter: chapter,
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
          '${chapters[chapterIndex].chapter} ${motifs[slot]}',
          chapters[chapterIndex].chapter,
          chapterIndex == chapters.length - 1 && slot == motifs.length - 1
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

final List<LevelDefinition> kLevels = [
  _level(1, 'First Symbols', 'Accra', compactDiamondLayout, 7, 'Novice'),
  _level(2, 'New Roots', 'Accra', beginnerBridgeLayout, 8, 'Novice'),
  _level(3, 'Side Paths', 'Accra', firstCrossLayout, 9, 'Novice'),
  _level(4, 'Small Turtle', 'Accra', smallTurtleLayout, 10, 'Novice'),
  _level(5, 'Shrine Steps', 'Accra', smallShrineLayout, 11, 'Novice'),
  _level(6, 'Open Courtyard', 'Accra', openCourtyardLayout, 12, 'Novice'),
  _level(7, 'River Lesson', 'Accra', riverPathLayout, 12, 'Novice'),
  _level(8, 'Wisdom House', 'Accra', wisdomHouseLayout, 13, 'Novice'),
  _level(9, 'Gathering Wings', 'Accra', gatheringWingsLayout, 14, 'Novice'),
  _level(10, 'Elder Bridge', 'Accra', elderBridgeLayout, 15, 'Novice'),
  _level(
      11, 'Heritage Turtle', 'Kumasi', heritageTurtleLayout, 16, 'Apprentice',
      symbolStart: 8),
  _level(12, 'Butterfly Path', 'Kumasi', butterflyLayout, 17, 'Apprentice',
      symbolStart: 10),
  _level(13, 'Temple Steps', 'Kumasi', templeStepsLayout, 18, 'Apprentice',
      symbolStart: 12),
  _level(
      14, 'Wisdom Staircase', 'Kumasi', wisdomStaircaseLayout, 18, 'Apprentice',
      symbolStart: 14),
  _level(15, 'Ancestral Crown', 'Kumasi', crownLayout, 19, 'Apprentice',
      symbolStart: 16),
  _level(16, 'Sacred Grove', 'Kumasi', sacredGroveLayout, 20, 'Apprentice',
      symbolStart: 18),
  _level(17, 'Golden Stool', 'Kumasi', royalStoolLayout, 21, 'Apprentice',
      symbolStart: 20),
  _level(18, 'Ancestral Gate', 'Kumasi', ancestralGateLayout, 22, 'Apprentice',
      symbolStart: 22),
  _level(19, 'Twin Houses', 'Kumasi', twinTowersLayout, 23, 'Apprentice',
      symbolStart: 24),
  _level(
      20, 'Raised Courtyard', 'Kumasi', raisedCourtyardLayout, 24, 'Apprentice',
      symbolStart: 26),
  _level(21, 'Split Islands', 'Sekondi-Takoradi', splitIslandsLayout, 25,
      'Strategic',
      symbolStart: 28),
  _level(
      22, 'Fortress Gate', 'Sekondi-Takoradi', fortressLayout, 26, 'Strategic',
      symbolStart: 30),
  _level(23, 'Hidden Center', 'Sekondi-Takoradi', hiddenCenterLayout, 27,
      'Strategic',
      symbolStart: 32),
  _level(24, 'Festival Archive', 'Sekondi-Takoradi', festivalArchiveLayout, 28,
      'Strategic',
      symbolStart: 34),
  _level(25, 'Layered Courtyard', 'Sekondi-Takoradi', layeredCourtyardLayout,
      29, 'Strategic',
      symbolStart: 36),
  _level(26, 'Winding Path', 'Sekondi-Takoradi', windingPathLayoutA, 24,
      'Strategic',
      symbolStart: 38),
  _level(27, 'Grand Turtle', 'Sekondi-Takoradi', grandTurtleLayout, 30,
      'Strategic',
      symbolStart: 40),
  _level(28, 'Layered Shrine', 'Sekondi-Takoradi', layeredShrineLayout, 31,
      'Strategic',
      symbolStart: 42),
  _level(29, 'Many Peaks', 'Sekondi-Takoradi', multiPeakLayout, 32, 'Strategic',
      symbolStart: 44),
  _level(30, 'Complex Fortress', 'Sekondi-Takoradi', complexFortressLayout, 33,
      'Strategic',
      symbolStart: 46),
  _level(31, 'Sacred Bridge', 'Obuasi', sacredBridgeLayout, 34, 'Advanced',
      symbolStart: 48),
  _level(32, 'Crown Trial', 'Obuasi', ancestralCrownLayout, 35, 'Advanced',
      symbolStart: 50),
  _level(33, 'Treasury Gate', 'Obuasi', grandTreasuryLayout, 36, 'Advanced',
      symbolStart: 52),
  _level(34, 'Temple Complex', 'Obuasi', templeComplexLayout, 37, 'Advanced',
      symbolStart: 54),
  _level(35, 'Living Archive', 'Obuasi', finalArchiveLayout, 38, 'Advanced',
      symbolStart: 56),
  _level(36, 'Royal Crossing', 'Obuasi', sacredBridgeLayout, 36, 'Advanced',
      symbolStart: 58),
  _level(37, 'Elders Assembly', 'Obuasi', complexFortressLayout, 38, 'Advanced',
      symbolStart: 60),
  _level(38, 'Path of Renewal', 'Obuasi', layeredShrineLayout, 38, 'Advanced',
      symbolStart: 62),
  _level(39, 'Steadfast Spirits', 'Obuasi', multiPeakLayout, 39, 'Advanced',
      symbolStart: 64),
  _level(40, 'Ancestral Trial', 'Obuasi', ancestralCrownLayout, 40, 'Advanced',
      symbolStart: 66),
  _level(41, 'Grand Treasury', 'Ho', grandTreasuryLayout, 42, 'Master',
      symbolStart: 68),
  _level(42, 'Royal Courtyard', 'Ho', templeComplexLayout, 43, 'Master',
      symbolStart: 70),
  _level(43, 'Golden Archive', 'Ho', finalArchiveLayout, 44, 'Master',
      symbolStart: 72),
  _level(44, 'Ancestral Map', 'Ho', complexFortressLayout, 42, 'Master',
      symbolStart: 74),
  _level(45, 'Complete Heritage', 'Ho', grandTurtleLayout, 40, 'Master',
      symbolStart: 76),
  _level(46, 'Sacred Crown', 'Ho', ancestralCrownLayout, 42, 'Master',
      symbolStart: 78),
  _level(47, 'Temple of Memory', 'Ho', templeComplexLayout, 44, 'Master',
      symbolStart: 80),
  _level(48, 'Treasury Wings', 'Ho', multiPeakLayout, 40, 'Master',
      symbolStart: 82),
  _level(49, 'Grand Archive', 'Ho', grandTreasuryLayout, 44, 'Master',
      symbolStart: 84),
  _level(50, 'Ancestral Treasury', 'Ho', finalArchiveLayout, 46, 'Master',
      symbolStart: 86),
  ..._extendedCampaignLevels(),
];

int get kCampaignLevelCount => kLevels.length;
int get kFinalCampaignLevelId => kLevels.last.id;
int get kMaximumCampaignStars => kCampaignLevelCount * 3;

LevelDefinition? getLevelById(int id) {
  try {
    return kLevels.firstWhere((level) => level.id == id);
  } catch (_) {
    return null;
  }
}
