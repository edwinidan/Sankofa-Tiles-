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
    title: 'Accra',
    levelStart: 1,
    levelEnd: 10,
    featuredSymbol: 'Sankofa',
    meaning: 'Begin in the capital, where old memory and new energy meet.',
  ),
  ChapterDefinition(
    index: 2,
    title: 'Kumasi',
    levelStart: 11,
    levelEnd: 20,
    featuredSymbol: 'Nyansapo',
    meaning: 'Walk the Ashanti heartland, guided by craft and wisdom.',
  ),
  ChapterDefinition(
    index: 3,
    title: 'Sekondi-Takoradi',
    levelStart: 21,
    levelEnd: 30,
    featuredSymbol: 'Fawohodie',
    meaning:
        'Follow the twin-city coast where trade, sea air, and industry meet.',
  ),
  ChapterDefinition(
    index: 4,
    title: 'Obuasi',
    levelStart: 31,
    levelEnd: 40,
    featuredSymbol: 'Dwennimmen',
    meaning: 'Search the golden hills with strength, humility, and care.',
  ),
  ChapterDefinition(
    index: 5,
    title: 'Ho',
    levelStart: 41,
    levelEnd: 50,
    featuredSymbol: 'Gye Nyame',
    meaning: 'Climb toward the Volta highlands with faith and steady focus.',
  ),
  ChapterDefinition(
    index: 6,
    title: 'Kokrobite',
    levelStart: 51,
    levelEnd: 60,
    featuredSymbol: 'Akoma Ntoaso',
    meaning:
        'Let rhythm, beach light, and shared hearts carry the journey onward.',
  ),
  ChapterDefinition(
    index: 7,
    title: 'Amanfrom',
    levelStart: 61,
    levelEnd: 70,
    featuredSymbol: 'Dwennimmen',
    meaning:
        'Move through a growing town where daily paths become royal roads.',
  ),
  ChapterDefinition(
    index: 8,
    title: 'Cape Coast',
    levelStart: 71,
    levelEnd: 80,
    featuredSymbol: 'Nsoromma',
    meaning: 'Stand by the Atlantic, remembering history beneath the stars.',
  ),
  ChapterDefinition(
    index: 9,
    title: 'Tamale',
    levelStart: 81,
    levelEnd: 90,
    featuredSymbol: 'Woforo Dua Pa A',
    meaning: 'Cross the northern savanna with purpose, warmth, and resilience.',
  ),
  ChapterDefinition(
    index: 10,
    title: 'Koforidua',
    levelStart: 91,
    levelEnd: 100,
    featuredSymbol: 'Sankofa',
    meaning: 'Travel through eastern ridges where memory returns as renewal.',
  ),
  ChapterDefinition(
    index: 11,
    title: 'Ada Foah',
    levelStart: 101,
    levelEnd: 110,
    featuredSymbol: 'Mframadan',
    meaning: 'Where river meets sea, strong houses hold memory through change.',
  ),
  ChapterDefinition(
    index: 12,
    title: 'Sunyani',
    levelStart: 111,
    levelEnd: 120,
    featuredSymbol: 'Bese Saka',
    meaning:
        'Tend abundance in a green city known for calm and careful growth.',
  ),
  ChapterDefinition(
    index: 13,
    title: 'Techiman',
    levelStart: 121,
    levelEnd: 130,
    featuredSymbol: 'Nkyinkyim',
    meaning: 'Navigate a market crossroads where winding paths teach patience.',
  ),
  ChapterDefinition(
    index: 14,
    title: 'Wa',
    levelStart: 131,
    levelEnd: 140,
    featuredSymbol: 'Osram Ne Nsoromma',
    meaning: 'Under northern moonlight, old courtyards keep quiet watch.',
  ),
  ChapterDefinition(
    index: 15,
    title: 'Elmina',
    levelStart: 141,
    levelEnd: 150,
    featuredSymbol: 'Mate Masie',
    meaning: 'Listen by the historic harbor; what is heard becomes wisdom.',
  ),
  ChapterDefinition(
    index: 16,
    title: 'Axim',
    levelStart: 151,
    levelEnd: 160,
    featuredSymbol: 'Adinkrahene',
    meaning: 'Follow the western shoreline where many meanings gather as one.',
  ),
  ChapterDefinition(
    index: 17,
    title: 'Bolgatanga',
    levelStart: 161,
    levelEnd: 170,
    featuredSymbol: 'Sunsum',
    meaning: 'Trace basket paths and painted walls where spirit moves quietly.',
  ),
  ChapterDefinition(
    index: 18,
    title: 'Winneba',
    levelStart: 171,
    levelEnd: 180,
    featuredSymbol: 'Akofena',
    meaning:
        'Carry courage along the festival coast and protect memory with honor.',
  ),
  ChapterDefinition(
    index: 19,
    title: 'Akosombo',
    levelStart: 181,
    levelEnd: 190,
    featuredSymbol: 'Nyansapo',
    meaning: 'Pause by the great lake and let careful thought unlock the knot.',
  ),
  ChapterDefinition(
    index: 20,
    title: 'Aburi',
    levelStart: 191,
    levelEnd: 200,
    featuredSymbol: 'Sankofa',
    meaning:
        'End among cool hills and gardens, returning with wisdom to carry on.',
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
