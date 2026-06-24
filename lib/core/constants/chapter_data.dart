import 'level_data.dart';

class ChapterDefinition {
  const ChapterDefinition({
    required this.index,
    required this.title,
    required this.levelStart,
    required this.levelEnd,
    required this.featuredSymbol,
    required this.meaning,
  });

  final int index;
  final String title;
  final int levelStart;
  final int levelEnd;
  final String featuredSymbol;
  final String meaning;

  bool containsLevel(int levelId) =>
      levelId >= levelStart && levelId <= levelEnd;

  List<LevelDefinition> get levels => kLevels
      .where((level) => level.id >= levelStart && level.id <= levelEnd)
      .toList(growable: false);
}

const kChapters = [
  ChapterDefinition(
    index: 1,
    title: 'First Symbols',
    levelStart: 1,
    levelEnd: 10,
    featuredSymbol: 'Sankofa',
    meaning: 'Learn from the past and carry its wisdom forward.',
  ),
  ChapterDefinition(
    index: 2,
    title: 'Paths of Wisdom',
    levelStart: 11,
    levelEnd: 20,
    featuredSymbol: 'Nyansapo',
    meaning: 'Wisdom and patience guide every careful choice.',
  ),
  ChapterDefinition(
    index: 3,
    title: 'Heritage',
    levelStart: 21,
    levelEnd: 30,
    featuredSymbol: 'Fawohodie',
    meaning: 'Freedom grows with responsibility and self-knowledge.',
  ),
  ChapterDefinition(
    index: 4,
    title: 'Ancestral Trials',
    levelStart: 31,
    levelEnd: 40,
    featuredSymbol: 'Dwennimmen',
    meaning: 'Strength and humility can live side by side.',
  ),
  ChapterDefinition(
    index: 5,
    title: 'Grand Archive',
    levelStart: 41,
    levelEnd: 50,
    featuredSymbol: 'Gye Nyame',
    meaning: 'A final reflection on faith, memory, and mastery.',
  ),
];

ChapterDefinition chapterForLevel(int levelId) {
  return kChapters.firstWhere(
    (chapter) => chapter.containsLevel(levelId),
    orElse: () => kChapters.first,
  );
}

bool isChapterFinalLevel(int levelId) {
  return kChapters.any((chapter) => chapter.levelEnd == levelId);
}
