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

const kLegacyTenLevelChapters = [
  ChapterDefinition(
    index: 1,
    title: 'Kokrobite',
    levelStart: 1,
    levelEnd: 10,
    featuredSymbol: 'Sankofa',
    meaning:
        'Begin by the beach, where rhythm and community welcome the journey.',
  ),
  ChapterDefinition(
    index: 2,
    title: 'Ada Foah',
    levelStart: 11,
    levelEnd: 20,
    featuredSymbol: 'Nyansapo',
    meaning: 'At the meeting of river and sea, learn to move with change.',
  ),
  ChapterDefinition(
    index: 3,
    title: 'Aburi',
    levelStart: 21,
    levelEnd: 30,
    featuredSymbol: 'Fawohodie',
    meaning: 'Climb the cool green hills and gather wisdom among the gardens.',
  ),
  ChapterDefinition(
    index: 4,
    title: 'Axim',
    levelStart: 31,
    levelEnd: 40,
    featuredSymbol: 'Dwennimmen',
    meaning: 'Follow the western shoreline where history and community endure.',
  ),
  ChapterDefinition(
    index: 5,
    title: 'Akosombo',
    levelStart: 41,
    levelEnd: 50,
    featuredSymbol: 'Gye Nyame',
    meaning: 'Pause beside the great lake and unlock each knot with patience.',
  ),
  ChapterDefinition(
    index: 6,
    title: 'Elmina',
    levelStart: 51,
    levelEnd: 60,
    featuredSymbol: 'Akoma Ntoaso',
    meaning: 'Listen by the historic harbor; what is heard becomes wisdom.',
  ),
  ChapterDefinition(
    index: 7,
    title: 'Winneba',
    levelStart: 61,
    levelEnd: 70,
    featuredSymbol: 'Dwennimmen',
    meaning:
        'Carry courage along the festival coast and protect memory with honor.',
  ),
  ChapterDefinition(
    index: 8,
    title: 'Ho',
    levelStart: 71,
    levelEnd: 80,
    featuredSymbol: 'Nsoromma',
    meaning: 'Climb toward the Volta highlands with faith and steady focus.',
  ),
  ChapterDefinition(
    index: 9,
    title: 'Wa',
    levelStart: 81,
    levelEnd: 90,
    featuredSymbol: 'Woforo Dua Pa A',
    meaning: 'Under northern moonlight, old courtyards keep quiet watch.',
  ),
  ChapterDefinition(
    index: 10,
    title: 'Bolgatanga',
    levelStart: 91,
    levelEnd: 100,
    featuredSymbol: 'Sankofa',
    meaning: 'Trace basket paths and painted walls where spirit moves quietly.',
  ),
  ChapterDefinition(
    index: 11,
    title: 'Cape Coast',
    levelStart: 101,
    levelEnd: 110,
    featuredSymbol: 'Mframadan',
    meaning: 'Stand by the Atlantic, remembering history beneath the stars.',
  ),
  ChapterDefinition(
    index: 12,
    title: 'Koforidua',
    levelStart: 111,
    levelEnd: 120,
    featuredSymbol: 'Bese Saka',
    meaning: 'Travel through eastern ridges where memory returns as renewal.',
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
    title: 'Sunyani',
    levelStart: 131,
    levelEnd: 140,
    featuredSymbol: 'Osram Ne Nsoromma',
    meaning:
        'Tend abundance in a green city known for calm and careful growth.',
  ),
  ChapterDefinition(
    index: 15,
    title: 'Obuasi',
    levelStart: 141,
    levelEnd: 150,
    featuredSymbol: 'Mate Masie',
    meaning: 'Search the golden hills with strength, humility, and care.',
  ),
  ChapterDefinition(
    index: 16,
    title: 'Amanfrom',
    levelStart: 151,
    levelEnd: 160,
    featuredSymbol: 'Adinkrahene',
    meaning:
        'Move through a growing city where daily paths become royal roads.',
  ),
  ChapterDefinition(
    index: 17,
    title: 'Sekondi-Takoradi',
    levelStart: 161,
    levelEnd: 170,
    featuredSymbol: 'Sunsum',
    meaning:
        'Follow the twin-city coast where trade, sea air, and industry meet.',
  ),
  ChapterDefinition(
    index: 18,
    title: 'Tamale',
    levelStart: 171,
    levelEnd: 180,
    featuredSymbol: 'Akofena',
    meaning: 'Cross the northern savanna with purpose, warmth, and resilience.',
  ),
  ChapterDefinition(
    index: 19,
    title: 'Kumasi',
    levelStart: 181,
    levelEnd: 190,
    featuredSymbol: 'Nyansapo',
    meaning: 'Walk the Ashanti heartland, guided by craft and wisdom.',
  ),
  ChapterDefinition(
    index: 20,
    title: 'Accra',
    levelStart: 191,
    levelEnd: 200,
    featuredSymbol: 'Sankofa',
    meaning:
        'Reach the capital, where old memory and new energy meet at journey’s end.',
  ),
];

/// Production journey chapters use the 20-level architecture reserved for the
/// 400-level campaign. Only chapters whose levels are currently implemented
/// are exposed here.
const kChapters = [
  ChapterDefinition(
    index: 1,
    title: 'Kokrobite to Ada Foah',
    levelStart: 1,
    levelEnd: 20,
    featuredSymbol: 'Sankofa',
    meaning: 'Begin at the coast, carrying memory from beach to river mouth.',
  ),
  ChapterDefinition(
    index: 2,
    title: 'Aburi to Axim',
    levelStart: 21,
    levelEnd: 40,
    featuredSymbol: 'Nyansapo',
    meaning: 'Carry highland wisdom westward along Ghana’s historic shore.',
  ),
  ChapterDefinition(
    index: 3,
    title: 'Akosombo to Elmina',
    levelStart: 41,
    levelEnd: 60,
    featuredSymbol: 'Gye Nyame',
    meaning: 'Travel from the great lake to the harbor through patient paths.',
  ),
  ChapterDefinition(
    index: 4,
    title: 'Winneba to Ho',
    levelStart: 61,
    levelEnd: 80,
    featuredSymbol: 'Dwennimmen',
    meaning: 'Follow festival rhythms inland toward the Volta highlands.',
  ),
  ChapterDefinition(
    index: 5,
    title: 'Wa to Bolgatanga',
    levelStart: 81,
    levelEnd: 100,
    featuredSymbol: 'Nsoromma',
    meaning: 'Cross northern courtyards beneath stars and woven paths.',
  ),
  ChapterDefinition(
    index: 6,
    title: 'Cape Coast to Koforidua',
    levelStart: 101,
    levelEnd: 120,
    featuredSymbol: 'Mframadan',
    meaning: 'Let coastal memory become renewal among the eastern ridges.',
  ),
  ChapterDefinition(
    index: 7,
    title: 'Techiman to Sunyani',
    levelStart: 121,
    levelEnd: 140,
    featuredSymbol: 'Nkyinkyim',
    meaning: 'Navigate crossroads and green abundance with steady judgment.',
  ),
  ChapterDefinition(
    index: 8,
    title: 'Obuasi to Amanfrom',
    levelStart: 141,
    levelEnd: 160,
    featuredSymbol: 'Adinkrahene',
    meaning: 'Turn golden paths into strong foundations for the road ahead.',
  ),
  ChapterDefinition(
    index: 9,
    title: 'Sekondi-Takoradi to Tamale',
    levelStart: 161,
    levelEnd: 180,
    featuredSymbol: 'Akofena',
    meaning: 'Carry purpose from the twin-city coast across the savanna.',
  ),
  ChapterDefinition(
    index: 10,
    title: 'Kumasi to Accra',
    levelStart: 181,
    levelEnd: 200,
    featuredSymbol: 'Sankofa',
    meaning: 'Join the Ashanti heartland to the capital’s living energy.',
  ),
  ChapterDefinition(
    index: 11,
    title: 'The Journey Reopens',
    levelStart: 201,
    levelEnd: 220,
    featuredSymbol: 'Sankofa',
    meaning: 'Return with wisdom and cross into a new layered frontier.',
  ),
  ChapterDefinition(
    index: 12,
    title: 'Living Memory',
    levelStart: 221,
    levelEnd: 240,
    featuredSymbol: 'Adinkrahene',
    meaning: 'Build living memory into a sanctuary for every path behind you.',
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
