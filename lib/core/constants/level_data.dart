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
  'nea_onnim', 'ese_tekrema', 'nteasee', 'sankofa',
];

const _earthIds = [
  'denkyem', 'abe_dua', 'nyame_dua',
];

const _royaltyIds = [
  'adinkrahene', 'akofena', 'aban',
  'fawohodie', 'funtumfunefu', 'mpuannum', 'nyame_nwu',
];

const _honorIds = [
  'gye_nyame', 'dwennimmen', 'mpatapo', 'hye_wo_nhye',
  'akoben', 'nsoromma', 'adwo', 'abusua_pa',
  'agyindawuru', 'abode_santann', 'odo_nnyew_fie_kwan',
];

const _newIds = [
  'nsaa', 'nyame_nti', 'nyame_biribi_wo_soro', 'nkyemu', 'nkotimsefo_mpua',
  'nkrabea', 'mmeranmubere', 'nea_ope_se_obedi_hene', 'mmere_dane', 'mako',
];

const _extendedIds = [
  'fafanto', 'fihankra', 'fofo', 'kete_pa', 'kokuromotie',
  'kramo_bone', 'krapa_musuyidee', 'kwatakye_atiko', 'kyemfere', 'mekyea_wo',
  'menso_wo_kenten', 'mmeremutene', 'nea_oretwa_sa', 'nserewa', 'nyame_baatanpa',
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
               'nea_onnim', 'ese_tekrema', 'nteasee', 'gye_nyame'],
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
    tileIds: [..._wisdomIds, 'denkyem', 'gye_nyame'],
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
    tileIds: [..._wisdomIds, ..._earthIds, 'gye_nyame'],
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
               'aban', 'fawohodie', 'funtumfunefu', 'gye_nyame'],
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
               'gye_nyame', 'dwennimmen', 'mpatapo', 'hye_wo_nhye'],
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
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'nyansapo', 'gye_nyame', 'adinkrahene'],
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
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene',
               'fawohodie', 'nteasee', 'nyame_dua'],
    unlockRequirement: 9,
    starThresholds: [1400, 2300, 2800],
    layout: level10Layout,
  ),


  // Level 11 — 60 tiles, 5×8 base + 3 layers above
  LevelDefinition(
    id: 11,
    name: 'Legacy',
    boardRows: 5,
    boardCols: 8,
    tileCount: 60,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'fafanto', 'fihankra', 'fofo', 'kete_pa', 'kokuromotie',
               'nyansapo', 'gye_nyame'],
    unlockRequirement: 10,
    starThresholds: [1600, 2600, 3200],
    layout: level11Layout,
  ),

  // Level 12 — 64 tiles, 6×7 base + 3 layers above
  LevelDefinition(
    id: 12,
    name: 'Covenant',
    boardRows: 6,
    boardCols: 7,
    tileCount: 64,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'fafanto', 'fihankra', 'fofo', 'kete_pa', 'kokuromotie',
               'kramo_bone', 'krapa_musuyidee', 'kwatakye_atiko',
               'nyansapo', 'adinkrahene'],
    unlockRequirement: 11,
    starThresholds: [1800, 2900, 3600],
    layout: level12Layout,
  ),

  // Level 13 — 68 tiles, 6×7 base + 3 layers above
  LevelDefinition(
    id: 13,
    name: 'Shrine',
    boardRows: 6,
    boardCols: 7,
    tileCount: 68,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'fafanto', 'fihankra', 'fofo', 'kete_pa', 'kokuromotie',
               'kramo_bone', 'krapa_musuyidee', 'kwatakye_atiko', 'kyemfere', 'mekyea_wo',
               'nyansapo', 'gye_nyame', 'adinkrahene'],
    unlockRequirement: 12,
    starThresholds: [2000, 3200, 4000],
    layout: level13Layout,
  ),

  // Level 14 — 72 tiles, 6×7 base + 4 layers above
  LevelDefinition(
    id: 14,
    name: 'Elders',
    boardRows: 6,
    boardCols: 7,
    tileCount: 72,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               'fafanto', 'fihankra', 'fofo', 'kete_pa', 'kokuromotie',
               'kramo_bone', 'krapa_musuyidee', 'kwatakye_atiko', 'kyemfere', 'mekyea_wo',
               'menso_wo_kenten', 'mmeremutene',
               'nyansapo', 'gye_nyame', 'adinkrahene'],
    unlockRequirement: 13,
    starThresholds: [2200, 3500, 4400],
    layout: level14Layout,
  ),

  // Level 15 — 76 tiles, 6×8 base + 4 layers above
  LevelDefinition(
    id: 15,
    name: 'Oracle',
    boardRows: 6,
    boardCols: 8,
    tileCount: 76,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'gye_nyame'],
    unlockRequirement: 14,
    starThresholds: [2400, 3900, 4800],
    layout: level15Layout,
  ),

  // Level 16 — 80 tiles, 6×8 base + 4 layers above
  LevelDefinition(
    id: 16,
    name: 'Throne',
    boardRows: 6,
    boardCols: 8,
    tileCount: 80,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene'],
    unlockRequirement: 15,
    starThresholds: [2600, 4200, 5200],
    layout: level16Layout,
  ),

  // Level 17 — 84 tiles, 6×8 base + 4 layers above (tall center)
  LevelDefinition(
    id: 17,
    name: 'Genesis',
    boardRows: 6,
    boardCols: 8,
    tileCount: 84,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene',
               'fawohodie', 'nteasee'],
    unlockRequirement: 16,
    starThresholds: [2800, 4600, 5600],
    layout: level17Layout,
  ),

  // Level 18 — 88 tiles, 6×9 base + 4 layers above
  LevelDefinition(
    id: 18,
    name: 'Cosmos',
    boardRows: 6,
    boardCols: 9,
    tileCount: 88,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene',
               'fawohodie', 'nteasee', 'nyame_dua'],
    unlockRequirement: 17,
    starThresholds: [3000, 5000, 6000],
    layout: level18Layout,
  ),

  // Level 19 — 92 tiles, 6×9 base + 4 layers above (tall center)
  LevelDefinition(
    id: 19,
    name: 'Triumph',
    boardRows: 6,
    boardCols: 9,
    tileCount: 92,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene',
               'fawohodie', 'nteasee', 'nyame_dua', 'nkyinkyim'],
    unlockRequirement: 18,
    starThresholds: [3200, 5400, 6600],
    layout: level19Layout,
  ),

  // Level 20 — 96 tiles, 6×9 base + 5 layers above (ultimate)
  LevelDefinition(
    id: 20,
    name: 'Eternal',
    boardRows: 6,
    boardCols: 9,
    tileCount: 96,
    tileIds: [..._wisdomIds, ..._earthIds, ..._royaltyIds, ..._honorIds, ..._newIds,
               ..._extendedIds, 'nyansapo', 'sankofa', 'gye_nyame', 'adinkrahene',
               'fawohodie', 'nteasee', 'nyame_dua', 'nkyinkyim', 'mate_masie'],
    unlockRequirement: 19,
    starThresholds: [3500, 5800, 7200],
    layout: level20Layout,
  ),
];

LevelDefinition? getLevelById(int id) {
  try {
    return kLevels.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
}
