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

final List<FutureCampaignLayoutCandidate> kLevels81To160Candidates =
    List.unmodifiable([
  for (var index = 0; index < 80; index++)
    FutureCampaignLayoutCandidate(
      level: index + 81,
      family: _chapterFamilies[index],
      variant: index.isEven ? 'anchor profile' : 'complement profile',
      layout: _futureLayout(index + 81, _chapterFamilies[index]),
      proposedName: index == 79
          ? 'Grand Remembrance Monument'
          : '${_chapterFamilies[index]} ${index < 20 ? 'Formation' : index < 40 ? 'Ceremony' : index < 60 ? 'Passage' : 'Memorial'}',
      isBreather: const {
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
        155
      }.contains(index + 81),
    ),
]);
