import 'layout_data.dart';
import 'level_data.dart';

/// Human-approved source catalogue for the first post-200 expansion.
///
/// Production assignments are made centrally by [kLevels]. The retained
/// candidate metadata and snapshots support exact freeze and visual-regression
/// checks without creating a second playable registry.
class ExpansionLayoutCandidate {
  const ExpansionLayoutCandidate({
    required this.level,
    required this.layout,
    required this.family,
    required this.silhouetteClass,
    required this.proposedName,
    required this.features,
    required this.symbolPlan,
    required this.difficultyCategory,
    required this.isBreather,
  });

  final int level;
  final NamedLayout layout;
  final String family;
  final String silhouetteClass;
  final String proposedName;
  final List<String> features;
  final SymbolCopyPlan symbolPlan;
  final String difficultyCategory;
  final bool isBreather;
}

const Set<int> kLevels201To240Breathers = {201, 206, 212, 217, 223, 229, 234};
const Set<int> kLevels201To240Finales = {220, 240};
const Set<int> kLevels201To240WideOrBorderline = {
  204,
  208,
  209,
  211,
  215,
  220,
  221,
  224,
  228,
  230,
  231,
  232,
  234,
  235,
  238,
  240,
};

const _families = <String>[
  'Journey bird',
  'Ancestral tree',
  'Royal shield',
  'Sacred bridge',
  'Guardian mask',
  'Open courtyard',
  'Winding serpent',
  'Split wings',
  'Grand arch',
  'Memory pillar',
  'River monument',
  'Twin drums',
  'Canopy shrine',
  'Forked path',
  'Royal stool',
  'Hollow citadel',
  'Calabash gate',
  'Stepped ascent',
  'Four winds',
  'Horizon palace',
  'Sankofa wings',
  'Ancestor mask',
  'Sacred grove',
  'Wide causeway',
  'Royal key',
  'Split sanctuary',
  'Serpent crown',
  'Open treasury',
  'Pilgrim tree',
  'Twin shields',
  'Grand courtyard',
  'River fan',
  'Memory arch',
  'Guardian wings',
  'Palace islands',
  'Spiral monument',
  'Ancestral canopy',
  'Royal passage',
  'Final threshold',
  'Living archive',
];

const _names = <String>[
  'The Journey Continues',
  'Roots Beyond the Horizon',
  'Shield of Returning',
  'Bridge into Morning',
  'Mask of the New Path',
  'Courtyard of Welcome',
  'Serpent of Renewal',
  'Wings Across the Water',
  'Gate of Far Memory',
  'Pillar of First Light',
  'Riverstone Monument',
  'Drums of the Crossing',
  'Shrine Beneath the Canopy',
  'The Forked Pilgrimage',
  'Seat of New Counsel',
  'Citadel of Open Sky',
  'Calabash of Passage',
  'Steps of the Ancestors',
  'Four Winds Assembly',
  'Palace at the Horizon',
  'Wings of Sankofa',
  'The Ancestor Watches',
  'Grove of Deep Roots',
  'Causeway of Gold',
  'Key to the Royal Path',
  'Sanctuaries Apart',
  'Crown of the Serpent',
  'Treasury Under Open Sky',
  'Tree of the Pilgrim',
  'Shields in Council',
  'The Great Open Court',
  'River Fan Procession',
  'Arch of Remembering',
  'Guardian Wings Unfurled',
  'Palaces Across the Water',
  'Spiral of the Elders',
  'Canopy of Ancestral Stars',
  'The Royal Passage',
  'Threshold of the Last Road',
  'The Living Archive',
];

const _classes = <String>[
  'Animal or emblem',
  'Tree',
  'Shield',
  'Bridge',
  'Mask',
  'Open centre',
  'Diagonal or winding',
  'Split masses',
  'Arch',
  'Pillar',
  'Monument',
  'Split masses',
  'Tree',
  'Diagonal or winding',
  'Royal structure',
  'Hollow structure',
  'Arch',
  'Staircase',
  'Asymmetric formation',
  'Monument',
  'Animal or emblem',
  'Mask',
  'Tree',
  'Bridge',
  'Asymmetric formation',
  'Split masses',
  'Diagonal or winding',
  'Open centre',
  'Tree',
  'Split masses',
  'Open centre',
  'Asymmetric formation',
  'Arch',
  'Animal or emblem',
  'Multi-island',
  'Diagonal or winding',
  'Tree',
  'Bridge',
  'Grand arch',
  'Monument',
];

/// Full-grid silhouette masks. `X` is a tile-sized half-grid coordinate.
/// Layer 1 repeats the readable footprint for immediate support; layer 2 uses
/// a deliberately sparse, supported accent mask so holes stay visibly open.
const _legacyMasks = <List<String>>[
  ['.X.', 'XXX', '.X.', 'X.X', '.X.', 'X.X', 'X.X', '.X.'],
  ['.X.', 'XXX', 'X.X', '.X.', 'XXX', '.X.', 'X.X', 'XXX'],
  ['XXX', 'X.X', 'XXX', '.X.', 'XXX', 'X.X', '.X.'],
  ['X...X', 'XX.XX', '.XXX.', '..X..', '.X.X.', 'XX.XX', 'X...X'],
  ['.XX.', 'X..X', 'XX.X', 'X.XX', '.XX.', '.X.X', 'X..X'],
  ['XXX', 'X.X', 'X.X', 'X.X', 'X.X', 'XXX', '.X.', 'X.X'],
  ['XX.', '.X.', '.XX', '..X', '.XX', '.X.', 'XX.', 'X..'],
  ['X.X', 'X.X', '.X.', 'X.X', '.X.', 'X.X', 'X.X'],
  ['.XXX.', 'XX.XX', 'X...X', 'X...X', 'X...X', 'XX.XX', 'X.X.X'],
  ['.X.', 'XXX', '.X.', '.X.', 'X.X', '.X.', 'XXX', 'X.X'],
  ['XXXX', 'X..X', 'X..X', 'XX.X', 'X..X', 'X..X', '.X.X'],
  ['X..X', 'X..X', '.XX.', 'X.XX', '.X.X', 'XX.X', 'X..X'],
  ['.X.', 'XXX', 'X.X', '.X.', 'XXX', '.X.', 'X.X', 'X.X'],
  ['...X', '..XX', '.XX.', 'XX..', '.XX.', '..XX', '.XX.', 'XX..'],
  ['.XX.', 'XX.X', '.XX.', '..X.', '.XXX', 'X.X.', 'XXXX'],
  ['XXXX', 'X..X', 'X..X', 'X..X', 'X..X', 'XX.X', 'X..X', 'XXXX'],
  ['.XX.', 'X..X', 'X..X', 'X..X', 'X..X', 'XX.X', '.XX.'],
  ['...X', '..XX', '.XXX', '.XX.', 'XXX.', 'XX..', 'X...', 'XX..'],
  ['X.X', '.XX', '..X', 'XXX', '.X.', 'XX.', 'X.X'],
  ['X...X', 'XX.XX', '.XXX.', 'X.X.X', 'X...X', 'XX.XX', '.XXX.', 'X.X.X'],
  ['X...X', '.X.X.', '..X..', '.XXX.', 'X.X.X', '.X.X.', 'X...X', '.X.X.'],
  ['.XX.', 'X.XX', 'XX.X', 'X.XX', '.XX.', 'X..X', '.X.X'],
  ['.X.', 'XXX', 'X.X', 'XXX', '.X.', '.X.', 'X.X', 'X.X'],
  ['X...X', 'XXXXX', 'X.X.X', '.X.X.', 'XXXXX', 'X...X', 'XX.XX'],
  ['X.X.', 'XXXX', '.XX.', '..X.', '.XXX', 'X.X.', 'XXX.', 'X...'],
  ['X.X', 'X.X', 'X.X', '.X.', 'X.X', 'X.X', 'X.X'],
  ['XX..', '.XX.', '..XX', '...X', '..XX', '.XX.', 'XX..', 'X...'],
  ['XXXX', 'X..X', 'X..X', 'XX.X', 'X..X', 'X..X', 'XXXX', '.X.X'],
  ['.X.', 'XXX', 'X.X', '.X.', 'XXX', '.X.', 'X.X', '.X.'],
  ['X...X', 'XX.XX', '.X.X.', 'X.X.X', '.X.X.', 'XX.XX', 'X...X'],
  ['.XXX.', 'XX.XX', 'X...X', 'X.X.X', 'X...X', 'XX.XX', '.XXX.'],
  ['X...X', 'XX.XX', '.XXX.', '..X.X', '.XXXX', 'XX.X.', 'X..X.'],
  ['.X.', 'XXX', 'X.X', 'X.X', 'X.X', 'XXX', '.X.', 'X.X'],
  ['X...X', 'XX.XX', '.X.X.', '..X..', '.XXX.', 'X.X.X', 'X...X', '.X.X.'],
  ['X.X', 'X.X', 'X.X', '.X.', 'X.X', 'X.X', 'X.X'],
  ['XX..', '.XX.', '..XX', '...X', '..XX', '.XX.', 'XX..', '.X..'],
  ['.X.', 'XXX', 'X.X', 'XXX', '.X.', 'X.X', '.X.', 'X.X'],
  ['X...X', 'XX.XX', '.XXX.', '..X..', '.XXX.', 'XX.XX', 'X...X', 'XX.XX'],
  ['X..X', 'XX.X', '.XX.', 'X.XX', '.X.X', 'XX.X', 'X..X', 'XXXX'],
  ['X...X', 'XX.XX', '.XXX.', 'X.X.X', 'XX.XX', '.XXX.', 'XX.XX', 'XXXXX'],
];

/// Bulky-portrait redesign masks. These retain readable negative space while
/// shifting the batch toward broader shoulders, thicker centre mass, fuller
/// bases, and visibly stacked Mahjong-like density.
const _masks = <List<String>>[
  ['.XX.', 'XXXX', 'X..X', 'XX.X', 'X..X', 'XXXX', 'X..X'],
  ['.XXX.', 'XXXXX', 'X...X', 'XX.XX', '.XXX.', 'X.X.X', 'XX.XX', 'XXXXX'],
  ['.XXX.', 'XXXXX', 'X.X.X', 'XXXXX', '.XXX.', 'XX.XX', '.XXX.', '..X..'],
  ['XX.XX', 'XXXXX', 'XX.XX', '.XXX.', 'XX.XX', 'XXXXX', 'X...X', 'XX.XX'],
  ['.XXX.', 'XXXXX', 'X.X.X', 'XX.XX', 'XXXXX', 'X.X.X', 'XX.XX', '.XXX.'],
  ['XXXX', 'X..X', 'XX.X', 'X..X', 'X.XX', 'X..X', 'XXXX'],
  ['XXX..', 'XXXXX', 'X...X', 'X...X', 'XXXXX', '.XXXX', 'XX...', 'XXXX.'],
  ['XX.XX', 'XXXXX', '.XXX.', 'X.X.X', 'XXXXX', 'XX.XX', 'X.X.X', 'XXXXX'],
  ['.XXX.', 'XXXXX', 'XX.XX', 'X...X', 'X.X.X', 'XX.XX', 'XXXXX', 'X.X.X'],
  ['.XXX.', 'XXXX.', 'X..X.', 'XX.X.', 'X.XX.', 'XXXX.', 'X..X.', 'XXXX.'],
  ['XX.XX', 'XXXXX', 'X.X.X', 'XXXXX', '.XXX.', 'XXXXX', 'X.X.X', 'XX.XX'],
  ['XX.X', 'XXXX', 'X.XX', 'XXXX', 'XX.X', 'XXXX', 'X.XX'],
  ['.XXX.', 'XXXXX', 'XX.XX', '.XXX.', 'XXXXX', 'X.X.X', '.XXX.', 'XX.XX'],
  ['..XXX', '.XXXX', 'X.X..', 'XXX..', '.X.XX', 'XXXX.', 'X..XX', 'XXXXX'],
  ['.XXX.', 'XXXXX', 'XX.XX', '.XXX.', 'XXXXX', 'X.X.X', 'XXXXX', '.XXX.'],
  ['XXXXX', 'X...X', 'X.X.X', 'X...X', 'XXXXX', '.XXX.', 'X.X.X', 'XX.XX'],
  ['.XX.', 'XXXX', 'X..X', 'XX.X', 'X..X', 'X.XX', 'XXXX'],
  ['...XX', '..XXX', '.XXXX', 'XXXXX', 'XXXX.', 'XXX..', 'XXXX.', 'XX...'],
  ['X.X.X', 'XXXXX', 'X...X', 'XX.XX', 'X...X', 'XXXXX', 'X.X.X', '.XXX.'],
  ['XX.XX', 'XXXXX', 'X.X.X', 'XXXXX', '.XXX.', 'XX.XX', 'XXXXX', 'XXXXX'],
  ['XX.XX', 'XXXXX', 'XX.XX', '.XXX.', 'X.X.X', 'XX.XX', 'X...X', 'XX.XX'],
  ['.XXX.', 'XXXXX', 'XX.XX', 'X.X.X', 'XXXXX', 'X.X.X', 'XX.XX', 'XXXXX'],
  ['.XX.', 'X..X', 'X..X', 'XXXX', 'X..X', 'XX.X', 'X..X'],
  ['XX.XX', 'XXXXX', 'XXXXX', 'X.X.X', 'XXXXX', 'XXXXX', 'XX.XX', 'X.X.X'],
  ['XXX..', 'XXXXX', '.X..X', 'XXX.X', 'X.X.X', 'XXXX.', 'X.XXX', '.XXX.'],
  ['XX.X', 'XXXX', 'X.XX', 'XXXX', 'XX.X', 'XXXX', 'X..X'],
  ['XXX..', 'XXXX.', '.X..X', 'XXX.X', '.X.XX', 'XXXX.', 'X.X..', 'XX.XX'],
  ['XXXXX', 'X...X', 'XX.XX', 'X.X.X', 'XXXXX', 'X.X.X', 'X...X', 'XXXXX'],
  ['.XX.', 'XXXX', 'XX.X', '.XXX', 'X.XX', 'XXXX', '.XX.'],
  ['XX.XX', 'XXXXX', 'X.X.X', 'XX.XX', 'XXXXX', 'X.X.X', 'XXXXX', 'XX.XX'],
  ['XXXXX', 'X...X', 'X...X', 'XX.XX', 'X...X', 'X...X', 'XXXXX', '.XXX.'],
  ['XXXX.', 'XXXXX', '.XXXX', 'XX.XX', 'XXXXX', 'X.XXX', 'XXXX.', '.XXX.'],
  ['.XXX.', 'XXXXX', 'X...X', 'XX.XX', 'X.X.X', 'XX.XX', 'XXXXX', '.XXX.'],
  ['XX.XX', 'XXXXX', 'X.X.X', '.XXX.', 'XXXXX', 'XX.XX', 'X.X.X', 'XXXXX'],
  ['XX.XX', 'XX.XX', '.X.X.', 'XX.XX', 'X.X.X', 'XX.XX', '.XXX.', 'X.X.X'],
  ['XXX..', 'XXXX.', '.X..X', 'XXX.X', 'X.X.X', 'XXXX.', '.X.XX', 'XXXXX'],
  ['..X..', '.XXX.', 'XXXXX', 'X.X.X', 'XX.XX', 'XXXXX', 'X.X.X', 'XXXXX'],
  ['XXXXX', 'X...X', 'XX.XX', 'X...X', 'XXXXX', '.XXX.', 'X...X', 'XXXXX'],
  ['XX...', 'XXXX.', '.XXXX', 'XXXXX', 'X.X.X', '.XXXX', 'XXXX.', 'XXXXX'],
  [
    '.XXX.',
    'XXXXX',
    'X.X.X',
    'XXXXX',
    'X...X',
    'X...X',
    'XXXXX',
    'XXXXX',
  ],
];

/// Human-review snapshot immediately before the final Level 240 refinement.
const _preFinalLevel240Mask = <String>[
  'XXXXX',
  'XX.XX',
  'X.X.X',
  'XXXXX',
  'XX.XX',
  'X.X.X',
  'XXXXX',
  'XXXXX',
];

NamedLayout _layoutFor(
  int index, {
  bool legacy = false,
  bool preFinal240 = false,
}) {
  final level = 201 + index;
  final mask = preFinal240
      ? _preFinalLevel240Mask
      : legacy
          ? _legacyMasks[index]
          : _masks[index];
  final width = mask.fold<int>(
      0, (value, row) => row.length > value ? row.length : value);
  final startCol = 16 - (width - 1);
  final base = <TilePosition>[];
  for (var row = 0; row < mask.length; row++) {
    for (var col = 0; col < mask[row].length; col++) {
      if (mask[row][col] == 'X') {
        base.add(TilePosition(row * 2, startCol + col * 2, 0));
      }
    }
  }
  final positions = <TilePosition>[
    ...base,
    for (final tile in base) TilePosition(tile.row + 1, tile.col, 1),
  ];
  final top = <TilePosition>[
    for (final tile in base)
      if (level == 240 && !legacy && !preFinal240
          ? base.indexOf(tile) < 20
          : (((tile.row ~/ 2) * 3 + ((tile.col - startCol) ~/ 2) * 5 + level) %
                  4) <
              2)
        TilePosition(tile.row, tile.col, 2),
  ];
  if (top.length.isOdd) top.removeLast();
  positions.addAll(top);
  return namedLayout(
    'expansion$level${_families[index].replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}'
        '${preFinal240 ? 'PreFinal' : legacy ? 'Legacy' : ''}',
    '${_families[index]} — '
        '${preFinal240 ? 'pre-finale-refinement snapshot' : legacy ? 'pre-bulk snapshot' : 'bulky portrait redesign'}',
    positions,
  );
}

ExpansionLayoutCandidate _candidateAt(int index, {bool legacy = false}) =>
    ExpansionLayoutCandidate(
      level: 201 + index,
      layout: _layoutFor(index, legacy: legacy),
      family: _families[index],
      silhouetteClass: _classes[index],
      proposedName: _names[index],
      features: [
        _classes[index],
        legacy
            ? 'pre-bulk visual baseline'
            : index.isEven
                ? 'layered centre mass and patterned negative space'
                : 'broad shoulders and a fuller lower base',
      ],
      symbolPlan: SymbolCopyPlan(
        symbolPoolSize: 48 + (index ~/ 4) * 2 + (index % 4),
        preferredCopies: 4,
      ),
      difficultyCategory: kLevels201To240Breathers.contains(201 + index)
          ? 'Legendary breather'
          : index < 20
              ? 'Legendary frontier'
              : 'Mythic frontier',
      isBreather: kLevels201To240Breathers.contains(201 + index),
    );

final ExpansionLayoutCandidate kLevel240PreFinalRefinementCandidate =
    ExpansionLayoutCandidate(
  level: 240,
  layout: _layoutFor(39, preFinal240: true),
  family: _families[39],
  silhouetteClass: _classes[39],
  proposedName: _names[39],
  features: const ['Monument', 'pre-finale-refinement snapshot'],
  symbolPlan: const SymbolCopyPlan(symbolPoolSize: 69, preferredCopies: 4),
  difficultyCategory: 'Mythic frontier',
  isBreather: false,
);

/// Frozen baseline retained only for visual and metric comparison.
final List<ExpansionLayoutCandidate> kLevels201To240LegacyCandidates =
    List.unmodifiable([
  for (var index = 0; index < 40; index++) _candidateAt(index, legacy: true),
]);

final List<ExpansionLayoutCandidate> kLevels201To240Candidates =
    List.unmodifiable([
  for (var index = 0; index < 40; index++) _candidateAt(index),
]);
