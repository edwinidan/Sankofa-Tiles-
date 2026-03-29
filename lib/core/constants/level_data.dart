import 'layout_data.dart';

class LevelDefinition {
  final int id;
  final String name;
  final int boardRows;
  final int boardCols;
  final int tileCount; // must equal layout.length
  final List<String> tileIds;
  final int unlockRequirement;
  final List<int> starThresholds;
  final List<TilePosition> layout;

  const LevelDefinition({
    required this.id,
    required this.name,
    required this.boardRows,
    required this.boardCols,
    required this.tileCount,
    required this.tileIds,
    required this.unlockRequirement,
    required this.starThresholds,
    required this.layout,
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
  // Level 1 — 16 tiles, 2 layers (4×3 base + 2×2 cap)
  LevelDefinition(
    id: 1,
    name: 'Awakening',
    boardRows: 4,
    boardCols: 3,
    tileCount: 16,
    tileIds: ['nyansapo', 'nkyinkyim', 'mate_masie', 'hwehwemudua',
               'nea_onnim', 'ananse', 'ese_tekrema', 'nteasee', 'gye_nyame'],
    unlockRequirement: 0,
    starThresholds: [400, 650, 800],
    layout: level1Layout,
  ),

  // Level 2 — 20 tiles, 2 layers (4×4 base + 2×2 cap)
  LevelDefinition(
    id: 2,
    name: 'Roots',
    boardRows: 4,
    boardCols: 4,
    tileCount: 20,
    tileIds: [..._wisdomIds, 'gye_nyame'],
    unlockRequirement: 1,
    starThresholds: [500, 800, 1000],
    layout: level2Layout,
  ),

  // Level 3 — 24 tiles, 2 layers (4×5 base + 2×2 cap)
  LevelDefinition(
    id: 3,
    name: 'Harvest',
    boardRows: 4,
    boardCols: 5,
    tileCount: 24,
    tileIds: [..._wisdomIds, 'aya', 'denkyem', 'asase', 'gye_nyame'],
    unlockRequirement: 2,
    starThresholds: [600, 950, 1200],
    layout: level3Layout,
  ),

  // Level 4 — 28 tiles, 3 layers (4×6 base + column tower)
  LevelDefinition(
    id: 4,
    name: 'River',
    boardRows: 4,
    boardCols: 6,
    tileCount: 28,
    tileIds: [..._wisdomIds, 'aya', 'denkyem', 'asase', 'mframadan', 'osram', 'gye_nyame'],
    unlockRequirement: 3,
    starThresholds: [700, 1100, 1400],
    layout: level4Layout,
  ),

  // Level 5 — 36 tiles, 3 layers (5×6 base + 2×2 + 1×2 peak)
  LevelDefinition(
    id: 5,
    name: 'Confluence',
    boardRows: 5,
    boardCols: 6,
    tileCount: 36,
    tileIds: [..._wisdomIds, ..._earthIds, 'gye_nyame'],
    unlockRequirement: 4,
    starThresholds: [900, 1400, 1800],
    layout: level5Layout,
  ),

  // Level 6 — 40 tiles, 3 layers (5×6 base + 3×2 + 2×2 peak)
  LevelDefinition(
    id: 6,
    name: 'Kingdom',
    boardRows: 5,
    boardCols: 6,
    tileCount: 40,
    tileIds: [..._wisdomIds, ..._earthIds, 'adinkrahene', 'akofena', 'gye_nyame'],
    unlockRequirement: 5,
    starThresholds: [1000, 1600, 2000],
    layout: level6Layout,
  ),

  // Level 7 — 44 tiles, 3 layers (5×7 base + 4×2 + 1 peak)
  LevelDefinition(
    id: 7,
    name: 'Council',
    boardRows: 5,
    boardCols: 7,
    tileCount: 44,
    tileIds: [..._wisdomIds, ..._earthIds, 'adinkrahene', 'akofena',
               'pempamsie', 'aban', 'fawohodie', 'funtumfunefu', 'gye_nyame'],
    unlockRequirement: 6,
    starThresholds: [1100, 1750, 2200],
    layout: level7Layout,
  ),

  // Level 8 — 48 tiles, 4 layers (5×6 base + 3×4 + 2×2 + 2 peak)
  LevelDefinition(
    id: 8,
    name: 'Heritage',
    boardRows: 5,
    boardCols: 6,
    tileCount: 48,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds,
               'gye_nyame', 'bi_nka_bi', 'dwennimmen', 'mpatapo',
               'hye_wo_nhye', 'tabono'],
    unlockRequirement: 7,
    starThresholds: [1200, 1900, 2400],
    layout: level8Layout,
  ),

  // Level 9 — 52 tiles, 4 layers (5×7 base + 3×4 + 2×2 + 1 peak)
  LevelDefinition(
    id: 9,
    name: 'Ancestors',
    boardRows: 5,
    boardCols: 7,
    tileCount: 52,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds,
               'nyansapo', 'aya', 'gye_nyame', 'adinkrahene'],
    unlockRequirement: 8,
    starThresholds: [1300, 2100, 2600],
    layout: level9Layout,
  ),

  // Level 10 — 56 tiles, 4 layers (5×7 base + 3×4 + 3×2 + 3 peak)
  LevelDefinition(
    id: 10,
    name: 'Sankofa',
    boardRows: 5,
    boardCols: 7,
    tileCount: 56,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds,
               'nyansapo', 'sankofa', 'gye_nyame', 'akoma',
               'adinkrahene', 'aya', 'fawohodie', 'bi_nka_bi',
               'nteasee', 'nyame_dua'],
    unlockRequirement: 9,
    starThresholds: [1400, 2300, 2800],
    layout: level10Layout,
  ),
];

LevelDefinition? getLevelById(int id) {
  try {
    return kLevels.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}
