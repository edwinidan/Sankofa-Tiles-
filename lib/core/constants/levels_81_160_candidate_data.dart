import 'layout_data.dart';

/// Developer-only portrait-first proposals for Chapters 5–8.  This catalogue
/// deliberately has no dependency from [kLevels] or player navigation.
class FutureCampaignLayoutCandidate {
  const FutureCampaignLayoutCandidate({
    required this.level,
    required this.layout,
    required this.family,
    required this.variant,
    required this.proposedName,
    required this.isBreather,
  });

  final int level;
  final NamedLayout layout;
  final String family;
  final String variant;
  final String proposedName;
  final bool isBreather;
}

const _chapterFamilies = <String>[
  'Grand turtle',
  'Ancestral tree',
  'Forked river',
  'Winged emblem',
  'Guardian mask',
  'Sacred shield',
  'Layered grove',
  'Sankofa knot',
  'Split wings',
  'Serpent path',
  'Hollow tree',
  'Nature monument',
  'River fan',
  'Twin shell',
  'Open calabash',
  'Canopy shrine',
  'Spiral leaf',
  'Guardian grove',
  'Split delta',
  'Symbol monument',
  'Royal palace',
  'Ceremonial throne',
  'Triple crown',
  'Grand gate',
  'Open courtyard',
  'Royal stool',
  'Palace towers',
  'Tiered temple',
  'Royal canopy',
  'Guardian arch',
  'Crowned fortress',
  'Royal monument',
  'Twin pavilion',
  'Ceremonial fan',
  'Hollow citadel',
  'Crown bridge',
  'Sun court',
  'Royal drum',
  'Towered gate',
  'Finale palace',
  'Layered bridge',
  'Winding path',
  'Crossing river',
  'Split islands',
  'Grand staircase',
  'Journey portal',
  'Crossroads',
  'Twin sanctuary',
  'Suspended crossing',
  'Multi-arch route',
  'Stepped passage',
  'Journey monument',
  'Forked ascent',
  'River crossing',
  'Open causeway',
  'Pilgrim gate',
  'Spiral route',
  'Twin paths',
  'Split terrace',
  'Horizon bridge',
  'Ancestral pillar',
  'Memory shrine',
  'Ceremonial mask',
  'Memorial gate',
  'Sacred tree',
  'Ancestral key',
  'Adinkra monument',
  'Guardian house',
  'Memory tower',
  'Twin memorials',
  'Ancestral sanctuary',
  'Remembrance monument',
  'Hollow reliquary',
  'Pillar court',
  'Memory arch',
  'Guardian crown',
  'Sacred drum',
  'Ancestor wings',
  'Four-corner shrine',
  'Grand remembrance',
];

const Set<int> kLevels81To160VisualRedesignAnchors = {
  81,
  85,
  90,
  95,
  100,
  101,
  105,
  110,
  115,
  120,
  121,
  125,
  130,
  135,
  140,
  141,
  145,
  150,
  155,
  160,
};

const Set<int> kLevels81To160WideVisualAnchors = {
  81,
  100,
  120,
  121,
  135,
  140,
  145,
  160,
};

const Set<int> kLevels81To160AsymmetricVisualAnchors = {
  90,
  101,
  125,
  135,
  145,
};

const Set<int> kLevels81To160OpenVisualAnchors = {
  85,
  95,
  105,
  110,
  115,
  120,
  130,
  140,
  150,
  155,
  160,
};

const Map<int, String> kLevels81To160AnchorClasses = {
  81: 'Animal or emblem',
  85: 'Monument',
  90: 'Curved or winding',
  95: 'Hollow rectangle',
  100: 'Cross',
  101: 'Asymmetric formation',
  105: 'Ring',
  110: 'Arch',
  115: 'U-frame',
  120: 'Monument',
  121: 'Bridge',
  125: 'Staircase',
  130: 'H-frame',
  135: 'Split masses',
  140: 'Bridge',
  141: 'Pillar',
  145: 'Tree',
  150: 'Split masses',
  155: 'Arch',
  160: 'Monument',
};

/// Silhouette-first base masks for visual-redesign pass 1.
///
/// Each character is one full half-grid tile position. Upper layers are
/// derived only from occupied cells, so openings remain open through the
/// complete stack instead of becoming shallow grooves in a dense slab.
const Map<int, List<String>> _anchorMasks = {
  81: [
    '.XXX.',
    'XXXXX',
    'XXXXX',
    'X.X.X',
    '.XXX.',
    'X...X',
  ],
  85: [
    'XXXXX',
    'X.X.X',
    'X.X.X',
    'XXXXX',
    '.XXX.',
    '.XXX.',
    '..X..',
  ],
  90: [
    'XXX.',
    '..X.',
    '..XX',
    '...X',
    '.XXX',
    '.X..',
    'XX..',
  ],
  95: [
    '.XXX.',
    'XXXXX',
    '..X..',
    '.X.X.',
    'X...X',
    'X...X',
    '.XXX.',
  ],
  100: [
    '..X..',
    '.XXX.',
    'X.X.X',
    'XXXXX',
    '.X.X.',
    'XX.XX',
    '.XXX.',
    'XXXXX',
  ],
  101: [
    'X.X.X',
    'XXXXX',
    'X...X',
    'X.X.X',
    'XXXXX',
    '..X.X',
    '.XXXX',
  ],
  105: [
    'XX.X',
    'X..X',
    'X..X',
    'X..X',
    'X..X',
    'X..X',
    'XX.X',
  ],
  110: [
    '.X.',
    'XXX',
    'X.X',
    'X.X',
    'X.X',
    'X.X',
    'X.X',
  ],
  115: [
    'X.XX',
    'XXXX',
    'X..X',
    'X..X',
    'X..X',
    'X..X',
    'X..X',
    'XX.X',
  ],
  120: [
    'X.X.X',
    'XXXXX',
    '.XXX.',
    'X.X.X',
    'X...X',
    'XX.XX',
    'X...X',
    'XXXXX',
  ],
  121: [
    'X...X',
    'XXXXX',
    'X.X.X',
    'X.X.X',
    'XXXXX',
    'X.X.X',
  ],
  125: [
    '...X',
    '..XX',
    '.XXX',
    '.XXX',
    'XXX.',
    'XXX.',
    'XX..',
    'X...',
  ],
  130: [
    'XXXX',
    'X..X',
    'XX.X',
    'X..X',
    'X.XX',
    'X..X',
    'XXXX',
  ],
  135: [
    'XX...',
    'XX...',
    '.XXX.',
    '...XX',
    '...XX',
    '...XX',
  ],
  140: [
    'X...X',
    'XXXXX',
    'X...X',
    'X...X',
    'X...X',
    'XXXXX',
    'XX.XX',
  ],
  141: [
    '.X.',
    'XXX',
    '.X.',
    '.X.',
    '.X.',
    '.X.',
    'XXX',
    'XXX',
  ],
  145: [
    '..X..',
    '.XXX.',
    'XXXXX',
    'X.X.X',
    '.XXX.',
    '..X..',
    '.X.X.',
    'XX.XX',
  ],
  150: [
    'X..X',
    'XX.X',
    'X..X',
    'X..X',
    'X..X',
    'X..X',
    'X.XX',
    'XXXX',
  ],
  155: [
    'X.X',
    '.X.',
    'X.X',
    'X.X',
    'X.X',
    'X.X',
    'X.X',
    'XXX',
  ],
  160: [
    '..X..',
    '.XXX.',
    'X.X.X',
    '.X.X.',
    'X...X',
    'X.X.X',
    '.XXX.',
    'XXXXX',
  ],
};

NamedLayout _visualAnchorLayout(int level, String family) {
  final mask = _anchorMasks[level]!;
  final base = <TilePosition>[];
  for (var row = 0; row < mask.length; row++) {
    for (var col = 0; col < mask[row].length; col++) {
      if (mask[row][col] == 'X') {
        base.add(TilePosition(row * 2, 16 + col * 2, 0));
      }
    }
  }

  final positions = <TilePosition>[...base];
  for (final tile in base) {
    positions.add(TilePosition(tile.row + 1, tile.col, 1));
  }

  final top = <TilePosition>[
    for (final tile in base)
      if (level == 160 || ((tile.row ~/ 2) + ((tile.col - 16) ~/ 2)).isEven)
        TilePosition(tile.row, tile.col, 2),
  ];
  if (top.length.isOdd) top.removeLast();
  positions.addAll(top);

  return namedLayout(
    'future${family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}$level',
    '$family — visual redesign anchor',
    positions,
  );
}

NamedLayout _futureLayout(int level, String family) {
  final positions = <TilePosition>[];
  final isFinale = const {100, 120, 140, 160}.contains(level);
  final isBreather = const {
    84,
    90,
    96,
    103,
    109,
    115,
    123,
    129,
    135,
    143,
    149,
    155,
  }.contains(level);
  // Nine deliberately varied vertical bands form the outer silhouette.  Odd
  // rows on upper layers exercise the integer half-grid projection.
  for (var band = 0; band < 8; band++) {
    final chapterSalt = ((level - 81) ~/ 20) * 104729;
    final mixed = _mix(level * 101 + band * 7919 + chapterSalt);
    var mask = mixed & 31;
    const minimumSlots = 4;
    for (var step = 0; _bitCount(mask) < minimumSlots; step++) {
      mask |= 1 << (_mix(mixed + step * 3571) % 5);
    }
    for (var slot = 0; slot < 5; slot++) {
      if (mask & (1 << slot) == 0) continue;
      positions.add(TilePosition(band * 2, 16 + slot * 2, 0));
    }
  }
  for (var band = 0; band < 8; band++) {
    // Reuse the lower band profile so every half-offset tile has immediate
    // support while retaining a different visible layer mask.
    final lower = positions
        .where((position) => position.layer == 0 && position.row == band * 2)
        .toList();
    for (var index = 0; index < lower.length; index++) {
      positions.add(TilePosition(band * 2 + 1, lower[index].col, 1));
    }
  }
  final breatherChapter = (level - 81) ~/ 20;
  final topRows = isFinale
      ? level == 100
          ? const [0, 2, 4, 8, 12]
          : level == 120
              ? const [0, 2, 4, 6, 10, 14]
              : level == 140
                  ? const [0, 2, 4, 6, 8, 12, 14]
                  : const [0, 2, 4, 6, 8, 10, 12, 14]
      : isBreather
          ? const [
              [2, 10],
              [0, 12],
              [4, 14],
              [6, 12],
            ][breatherChapter]
          : level <= 100
              ? const [0, 4, 8, 12]
              : level <= 120
                  ? const [0, 4, 6, 10, 14]
                  : level <= 140
                      ? const [0, 2, 6, 8, 12, 14]
                      : const [0, 2, 4, 6, 8, 10, 12, 14];
  for (final row in topRows) {
    final lower = positions
        .where((position) => position.layer == 1 && position.row == row + 1)
        .toList();
    final removedIndex = _mix(level * 313 + row) % lower.length;
    for (var index = 0; index < lower.length; index++) {
      if (index == removedIndex) continue;
      positions.add(TilePosition(row, lower[index].col, 2));
    }
  }
  if (positions.length.isOdd) positions.removeLast();
  return namedLayout(
    'future${family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}$level',
    '$family — portrait candidate',
    positions,
  );
}

int _mix(int value) {
  var mixed = value;
  mixed = ((mixed ^ (mixed >> 16)) * 0x45d9f3b) & 0x7fffffff;
  mixed = ((mixed ^ (mixed >> 16)) * 0x45d9f3b) & 0x7fffffff;
  return mixed ^ (mixed >> 16);
}

int _bitCount(int value) {
  var count = 0;
  var remaining = value;
  while (remaining != 0) {
    count += remaining & 1;
    remaining >>= 1;
  }
  return count;
}

FutureCampaignLayoutCandidate _candidateAt(
  int index, {
  required bool useVisualAnchors,
}) {
  final level = index + 81;
  final family = _chapterFamilies[index];
  return FutureCampaignLayoutCandidate(
    level: level,
    family: family,
    variant:
        useVisualAnchors && kLevels81To160VisualRedesignAnchors.contains(level)
            ? 'visual redesign pass 1'
            : index.isEven
                ? 'anchor profile'
                : 'complement profile',
    layout:
        useVisualAnchors && kLevels81To160VisualRedesignAnchors.contains(level)
            ? _visualAnchorLayout(level, family)
            : _futureLayout(level, family),
    proposedName: index == 79
        ? 'Grand Remembrance Monument'
        : '$family ${index < 20 ? 'Formation' : index < 40 ? 'Ceremony' : index < 60 ? 'Passage' : 'Memorial'}',
    isBreather: const {84, 90, 96, 103, 109, 115, 123, 129, 135, 143, 149, 155}
        .contains(level),
  );
}

/// Frozen reference catalogue from the technically valid but visually
/// repetitive first pass. It is retained only for development comparisons.
final List<FutureCampaignLayoutCandidate> kLevels81To160LegacyCandidates =
    List.unmodifiable([
  for (var index = 0; index < 80; index++)
    _candidateAt(index, useVisualAnchors: false),
]);

final List<FutureCampaignLayoutCandidate> kLevels81To160Candidates =
    List.unmodifiable([
  for (var index = 0; index < 80; index++)
    _candidateAt(index, useVisualAnchors: true),
]);
