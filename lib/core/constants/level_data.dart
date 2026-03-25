
class LevelDefinition {
  final int id;
  final String name;
  final int boardRows;
  final int boardCols;
  final int tileCount; // must be even
  final List<String> tileIds; // which TileDefinition ids to use
  final int unlockRequirement; // previous level id, 0 = always unlocked
  final List<int> starThresholds; // [1star, 2star, 3star]

  const LevelDefinition({
    required this.id,
    required this.name,
    required this.boardRows,
    required this.boardCols,
    required this.tileCount,
    required this.tileIds,
    required this.unlockRequirement,
    required this.starThresholds,
  });
}

// Helper: wisdom tile ids
const _wisdomIds = [
  'nyansapo', 'nkyinkyim', 'mate_masie', 'hwehwemudua',
  'nea_onnim', 'ananse', 'ese_tekrema', 'nteasee', 'sankofa',
];

const _earthIds = [
  'aya', 'denkyem', 'asase', 'mframadan',
  'osram', 'okuafo', 'abe_dua', 'akoko_nan', 'nyame_dua',
];

const _royaltyIds = [
  'adinkrahene', 'akofena', 'pempamsie', 'aban',
  'fawohodie', 'funtumfunefu', 'mpuannum', 'okodee', 'nyame_nwu',
];

const _honorIds = [
  'gye_nyame', 'bi_nka_bi', 'dwennimmen', 'mpatapo',
  'hye_wo_nhye', 'tabono', 'akoma',
];

const List<LevelDefinition> kLevels = [
  // Level 1 — 8 pairs (16 tiles), 4×4, Wisdom only
  LevelDefinition(
    id: 1,
    name: 'Awakening',
    boardRows: 4,
    boardCols: 4,
    tileCount: 16,
    tileIds: ['nyansapo', 'nkyinkyim', 'mate_masie', 'hwehwemudua',
               'nea_onnim', 'ananse', 'ese_tekrema', 'nteasee'],
    unlockRequirement: 0,
    starThresholds: [400, 650, 800],
  ),

  // Level 2 — 10 pairs (20 tiles), 4×5, Wisdom
  LevelDefinition(
    id: 2,
    name: 'Roots',
    boardRows: 4,
    boardCols: 5,
    tileCount: 20,
    tileIds: _wisdomIds,
    unlockRequirement: 1,
    starThresholds: [500, 800, 1000],
  ),

  // Level 3 — 12 pairs (24 tiles), 4×6, Wisdom + 3 Earth
  LevelDefinition(
    id: 3,
    name: 'Harvest',
    boardRows: 4,
    boardCols: 6,
    tileCount: 24,
    tileIds: [..._wisdomIds, 'aya', 'denkyem', 'asase'],
    unlockRequirement: 2,
    starThresholds: [600, 950, 1200],
  ),

  // Level 4 — 14 pairs (28 tiles), 4×7, Wisdom + 5 Earth
  LevelDefinition(
    id: 4,
    name: 'River',
    boardRows: 4,
    boardCols: 7,
    tileCount: 28,
    tileIds: [..._wisdomIds, 'aya', 'denkyem', 'asase', 'mframadan', 'osram'],
    unlockRequirement: 3,
    starThresholds: [700, 1100, 1400],
  ),

  // Level 5 — 18 pairs (36 tiles), 6×6, Wisdom + Earth
  LevelDefinition(
    id: 5,
    name: 'Confluence',
    boardRows: 6,
    boardCols: 6,
    tileCount: 36,
    tileIds: [..._wisdomIds, ..._earthIds],
    unlockRequirement: 4,
    starThresholds: [900, 1400, 1800],
  ),

  // Level 6 — 20 pairs (40 tiles), 5×8, Wisdom + Earth + 2 Royalty
  LevelDefinition(
    id: 6,
    name: 'Kingdom',
    boardRows: 5,
    boardCols: 8,
    tileCount: 40,
    tileIds: [..._wisdomIds, ..._earthIds, 'adinkrahene', 'akofena'],
    unlockRequirement: 5,
    starThresholds: [1000, 1600, 2000],
  ),

  // Level 7 — 22 pairs (44 tiles), 4×11, all three main suits partial
  LevelDefinition(
    id: 7,
    name: 'Council',
    boardRows: 4,
    boardCols: 11,
    tileCount: 44,
    tileIds: [..._wisdomIds, ..._earthIds, 'adinkrahene', 'akofena',
               'pempamsie', 'aban', 'fawohodie', 'funtumfunefu'],
    unlockRequirement: 6,
    starThresholds: [1100, 1750, 2200],
  ),

  // Level 8 — 24 pairs (48 tiles), 6×8, all three main suits
  LevelDefinition(
    id: 8,
    name: 'Heritage',
    boardRows: 6,
    boardCols: 8,
    tileCount: 48,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds,
               'gye_nyame', 'bi_nka_bi', 'dwennimmen', 'mpatapo',
               'hye_wo_nhye', 'tabono'],
    unlockRequirement: 7,
    starThresholds: [1200, 1900, 2400],
  ),

  // Level 9 — 26 pairs (52 tiles), 4×13, all suits
  LevelDefinition(
    id: 9,
    name: 'Ancestors',
    boardRows: 4,
    boardCols: 13,
    tileCount: 52,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds,
               'nyansapo', 'aya', 'gye_nyame', 'adinkrahene'],
    unlockRequirement: 8,
    starThresholds: [1300, 2100, 2600],
  ),

  // Level 10 — 28 pairs (56 tiles), 7×8, all suits + extra
  LevelDefinition(
    id: 10,
    name: 'Sankofa',
    boardRows: 7,
    boardCols: 8,
    tileCount: 56,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds,
               'nyansapo', 'sankofa', 'gye_nyame', 'akoma',
               'adinkrahene', 'aya', 'fawohodie', 'bi_nka_bi',
               'nteasee', 'nyame_dua'],
    unlockRequirement: 9,
    starThresholds: [1400, 2300, 2800],
  ),
];

LevelDefinition? getLevelById(int id) {
  try {
    return kLevels.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}
