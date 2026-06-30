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
    meaning: 'Faith, memory, and mastery open the next archive.',
  ),
  ChapterDefinition(
    index: 6,
    title: 'Memory Keepers',
    levelStart: 51,
    levelEnd: 60,
    featuredSymbol: 'Akoma Ntoaso',
    meaning: 'Shared hearts keep wisdom alive across generations.',
  ),
  ChapterDefinition(
    index: 7,
    title: 'Royal Paths',
    levelStart: 61,
    levelEnd: 70,
    featuredSymbol: 'Dwennimmen',
    meaning: 'Strength and humility guide the royal road.',
  ),
  ChapterDefinition(
    index: 8,
    title: 'Spirit Trials',
    levelStart: 71,
    levelEnd: 80,
    featuredSymbol: 'Nsoromma',
    meaning: 'The stars remind every traveler that guidance remains above.',
  ),
  ChapterDefinition(
    index: 9,
    title: 'Living Archive',
    levelStart: 81,
    levelEnd: 90,
    featuredSymbol: 'Woforo Dua Pa A',
    meaning: 'A strong tree welcomes those who climb with purpose.',
  ),
  ChapterDefinition(
    index: 10,
    title: 'Eternal Sankofa',
    levelStart: 91,
    levelEnd: 100,
    featuredSymbol: 'Sankofa',
    meaning: 'Return, remember, and carry wisdom forward.',
  ),
  ChapterDefinition(
    index: 11,
    title: 'River Archives',
    levelStart: 101,
    levelEnd: 110,
    featuredSymbol: 'Mframadan',
    meaning: 'Strong houses hold memory through changing seasons.',
  ),
  ChapterDefinition(
    index: 12,
    title: 'Golden Lineage',
    levelStart: 111,
    levelEnd: 120,
    featuredSymbol: 'Bese Saka',
    meaning: 'Abundance grows when heritage is carefully tended.',
  ),
  ChapterDefinition(
    index: 13,
    title: 'Ancestral Maps',
    levelStart: 121,
    levelEnd: 130,
    featuredSymbol: 'Nkyinkyim',
    meaning: 'The winding path teaches adaptability and patience.',
  ),
  ChapterDefinition(
    index: 14,
    title: 'Moonlit Courtyards',
    levelStart: 131,
    levelEnd: 140,
    featuredSymbol: 'Osram Ne Nsoromma',
    meaning: 'Moon and star keep quiet watch over the archive.',
  ),
  ChapterDefinition(
    index: 15,
    title: 'Hidden Libraries',
    levelStart: 141,
    levelEnd: 150,
    featuredSymbol: 'Mate Masie',
    meaning: 'What is heard and remembered becomes wisdom.',
  ),
  ChapterDefinition(
    index: 16,
    title: 'Royal Constellations',
    levelStart: 151,
    levelEnd: 160,
    featuredSymbol: 'Adinkrahene',
    meaning: 'The chief symbol gathers many meanings into one center.',
  ),
  ChapterDefinition(
    index: 17,
    title: 'Spirit Labyrinths',
    levelStart: 161,
    levelEnd: 170,
    featuredSymbol: 'Sunsum',
    meaning: 'Spirit moves through every hidden path.',
  ),
  ChapterDefinition(
    index: 18,
    title: 'Crown of Memory',
    levelStart: 171,
    levelEnd: 180,
    featuredSymbol: 'Akofena',
    meaning: 'Courage and honor protect the memory of a people.',
  ),
  ChapterDefinition(
    index: 19,
    title: 'The Deep Archive',
    levelStart: 181,
    levelEnd: 190,
    featuredSymbol: 'Nyansapo',
    meaning: 'The wisdom knot rewards careful thought.',
  ),
  ChapterDefinition(
    index: 20,
    title: 'Sankofa Forever',
    levelStart: 191,
    levelEnd: 200,
    featuredSymbol: 'Sankofa',
    meaning: 'The journey returns to its source and carries it onward.',
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
