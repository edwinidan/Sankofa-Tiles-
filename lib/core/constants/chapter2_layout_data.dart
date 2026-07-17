import 'layout_data.dart';

class Chapter2LayoutCandidate {
  const Chapter2LayoutCandidate(this.level, this.layout, this.family,
      this.variant, this.proposedName, this.isBreather);
  final int level;
  final NamedLayout layout;
  final String family;
  final String variant;
  final String proposedName;
  final bool isBreather;
}

typedef _Rows = List<List<int>>;

NamedLayout _layout(
  String id,
  String name,
  _Rows base,
  _Rows middle,
  _Rows top,
) {
  final positions = <TilePosition>[];
  int compactCol(int col) {
    if (col <= 16) return 16;
    if (col <= 18) return 18;
    if (col <= 20) return 20;
    if (col <= 22) return 22;
    return 24;
  }

  void addRows(_Rows rows, int layer, int rowOffset) {
    for (var index = 0; index < rows.length; index++) {
      final compact = rows[index].map(compactCol).toSet().toList()..sort();
      for (final col in compact) {
        positions.add(TilePosition(index * 2 + rowOffset, col, layer));
      }
    }
  }

  addRows(base, 0, 0);
  addRows(middle, 1, 1);
  addRows(top, 2, 2);
  for (var layer = 2; layer >= 1; layer--) {
    for (final position
        in positions.where((position) => position.layer == layer).toList()) {
      final supported = positions.any((lower) =>
          lower.layer == layer - 1 &&
          lower.row < position.row + 2 &&
          position.row < lower.row + 2 &&
          lower.col < position.col + 2 &&
          position.col < lower.col + 2);
      if (!supported) {
        positions.add(
          TilePosition(position.row - 1, position.col, position.layer - 1),
        );
      }
    }
  }
  if (positions.length.isOdd) {
    outer:
    for (var row = 0; row <= 14; row += 2) {
      for (var col = 16; col <= 24; col += 2) {
        final candidate = TilePosition(row, col, 0);
        final overlaps = positions.any((position) =>
            position.layer == 0 &&
            position.row < candidate.row + 2 &&
            candidate.row < position.row + 2 &&
            position.col < candidate.col + 2 &&
            candidate.col < position.col + 2);
        if (!overlaps) {
          positions.add(candidate);
          break outer;
        }
      }
    }
  }
  positions.sort((a, b) {
    final layer = a.layer.compareTo(b.layer);
    if (layer != 0) return layer;
    final row = a.row.compareTo(b.row);
    return row != 0 ? row : a.col.compareTo(b.col);
  });
  return namedLayout(id, name, List.unmodifiable(positions));
}

final List<Chapter2LayoutCandidate> kChapter2LayoutCandidates = [
  Chapter2LayoutCandidate(
    21,
    _layout(
      'chapter2VerticalTurtle01',
      'Vertical Turtle',
      [
        [20],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
      ],
      [
        [19, 21],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
        [19, 21],
        [19, 21],
      ],
      [
        [20],
        [18, 22],
        [18, 22],
        [20],
      ],
    ),
    'Vertical turtle',
    'open shell',
    'Grand Turtle',
    false,
  ),
  Chapter2LayoutCandidate(
    22,
    _layout(
      'chapter2SplitSanctuary01',
      'Split Sanctuary',
      [
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 18, 22, 24, 26],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [16, 18, 22, 24],
      ],
      [
        [15, 17, 23, 25],
        [15, 17, 23, 25],
        [17, 23],
        [17, 23],
        [15, 17, 23, 25],
        [17, 23],
      ],
      [
        [16, 24],
        [16, 24],
        [18, 22],
        [18, 22],
      ],
    ),
    'Split sanctuary',
    'twin courts',
    'Split Islands',
    false,
  ),
  Chapter2LayoutCandidate(
    23,
    _layout(
      'chapter2LayeredCrown01',
      'Layered Crown',
      [
        [14, 20, 26],
        [14, 16, 20, 24, 26],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [18, 20, 22],
        [20],
      ],
      [
        [15, 19, 21, 25],
        [15, 17, 19, 21, 23, 25],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
        [19, 21],
        [19, 21],
      ],
      [
        [16, 20, 24],
        [18, 20, 22],
        [18, 20, 22],
        [18, 20, 22],
      ],
    ),
    'Layered crown',
    'three peak',
    'Royal Assembly',
    false,
  ),
  Chapter2LayoutCandidate(
    24,
    _layout(
      'chapter2WindingRiver01',
      'Winding River',
      [
        [14, 16, 18],
        [16, 18, 20],
        [18, 20, 22],
        [20, 22, 24],
        [22, 24, 26],
        [20, 22, 24],
        [18, 20, 22],
        [16, 18, 20],
      ],
      [
        [15, 17],
        [17, 19],
        [19, 21],
        [21, 23],
        [21, 23],
        [19, 21],
      ],
      [
        [16, 18],
        [18, 20],
        [20, 22],
        [22, 24],
      ],
    ),
    'Winding river',
    'switchback',
    'Winding Path',
    true,
  ),
  Chapter2LayoutCandidate(
    25,
    _layout(
      'chapter2CeremonialMask01',
      'Ceremonial Mask',
      [
        [16, 18, 20, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [14, 16, 20, 24, 26],
        [14, 16, 18, 22, 24, 26],
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [20],
      ],
      [
        [17, 19, 21, 23],
        [15, 17, 23, 25],
        [15, 19, 21, 25],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
        [19, 21],
      ],
      [
        [18, 22],
        [16, 24],
        [18, 22],
        [18, 20],
      ],
    ),
    'Ceremonial mask',
    'open eyes',
    'Ancestral Mask',
    false,
  ),
  Chapter2LayoutCandidate(
    26,
    _layout(
      'chapter2TwinTowers02',
      'Twin Towers',
      [
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 18, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [18, 20, 22],
      ],
      [
        [15, 25],
        [15, 25],
        [15, 17, 23, 25],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
        [19, 21],
      ],
      [
        [14, 26],
        [16, 24],
        [18, 22],
        [18, 20],
      ],
    ),
    'Twin towers',
    'open bridge',
    'Fortress Spirits',
    true,
  ),
  Chapter2LayoutCandidate(
    27,
    _layout(
      'chapter2HollowTemple01',
      'Hollow Pagoda',
      [
        [16, 18, 20, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
        [14, 16, 18, 22, 24, 26],
        [16, 18, 22, 24],
        [18, 22],
        [18, 20, 22],
      ],
      [
        [17, 19, 21, 23],
        [15, 17, 23, 25],
        [17, 23],
        [15, 17, 23, 25],
        [17, 23],
        [19, 21],
      ],
      [
        [18, 20, 22],
        [16, 24],
        [18, 22],
        [18, 20],
      ],
    ),
    'Hollow pagoda',
    'open court',
    'Hidden Center',
    false,
  ),
  Chapter2LayoutCandidate(
    28,
    _layout(
      'chapter2PortraitButterfly01',
      'Portrait Butterfly',
      [
        [20],
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [16, 20, 24],
        [16, 20, 24],
        [18, 20, 22],
        [18, 20, 22],
        [20],
      ],
      [
        [20],
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [16, 20, 24],
        [18, 20, 22],
        [18, 20, 22],
      ],
      [
        [20],
        [16, 20, 24],
        [18, 20, 22],
        [20],
        [18, 20, 22],
        [20],
      ],
    ),
    'Portrait butterfly',
    'folded wings',
    'Butterfly Path',
    false,
  ),
  Chapter2LayoutCandidate(
    29,
    _layout(
      'chapter2RoyalStool02',
      'Royal Stool',
      [
        [16, 18, 20, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
      ],
      [
        [17, 19, 21, 23],
        [15, 17, 19, 21, 23, 25],
        [17, 19, 21, 23],
        [17, 23],
        [17, 23],
        [17, 19, 21, 23],
      ],
      [
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [18, 22],
        [18, 22],
      ],
    ),
    'Royal stool',
    'open legs',
    'Golden Foundation',
    false,
  ),
  Chapter2LayoutCandidate(
    30,
    _layout(
      'chapter2StackedBridge01',
      'Stacked Bridge',
      [
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 24],
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 18, 20, 22, 24],
      ],
      [
        [16, 18, 20, 22, 24],
        [18, 22],
        [16, 18, 20, 22, 24],
        [18, 22],
        [16, 18, 20, 22, 24],
        [18, 22],
      ],
      [
        [16, 18, 20, 22, 24],
        [18, 22],
        [16, 18, 20, 22, 24],
        [18, 22],
      ],
    ),
    'Stacked bridge',
    'double arch',
    'Sacred Crossing',
    false,
  ),
  Chapter2LayoutCandidate(
    31,
    _layout(
      'chapter2SacredArch01',
      'Sacred Arch',
      [
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [16, 18, 20, 22, 24],
      ],
      [
        [19, 21],
        [17, 19, 21, 23],
        [15, 17, 23, 25],
        [15, 25],
        [15, 25],
        [17, 23],
      ],
      [
        [20],
        [18, 20, 22],
        [16, 24],
        [16, 24],
      ],
    ),
    'Sacred arch',
    'open lower court',
    'Path of Renewal',
    true,
  ),
  Chapter2LayoutCandidate(
    32,
    _layout(
      'chapter2Hourglass01',
      'Hourglass Shrine',
      [
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [20],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
      ],
      [
        [15, 17, 19, 21, 23, 25],
        [17, 19, 21, 23],
        [19, 21],
        [19, 21],
        [17, 19, 21, 23],
        [15, 17, 19, 21, 23, 25],
      ],
      [
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [20],
        [18, 20, 22],
      ],
    ),
    'Hourglass shrine',
    'narrow waist',
    'Hidden Wisdom',
    false,
  ),
  Chapter2LayoutCandidate(
    33,
    _layout(
      'chapter2WingedEmblem01',
      'Winged Emblem',
      [
        [20],
        [16, 18, 20, 22, 24],
        [12, 14, 16, 18, 20, 22, 24, 26, 28],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [18, 20, 22],
        [20],
      ],
      [
        [19, 21],
        [15, 17, 19, 21, 23, 25],
        [13, 15, 17, 19, 21, 23, 25, 27],
        [17, 19, 21, 23],
        [19, 21],
        [19, 21],
      ],
      [
        [20],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [20],
      ],
    ),
    'Winged emblem',
    'outstretched',
    'Gathered Emblem',
    false,
  ),
  Chapter2LayoutCandidate(
    34,
    _layout(
      'chapter2GrandStaircase01',
      'Grand Staircase',
      [
        [12, 14, 16],
        [12, 14, 16],
        [14, 16, 18],
        [16, 18, 20],
        [18, 20, 22],
        [20, 22, 24],
        [22, 24, 26],
        [24, 26, 28],
      ],
      [
        [13, 15],
        [15, 17],
        [17, 19],
        [19, 21],
        [21, 23],
        [23, 25],
      ],
      [
        [14, 16],
        [18, 20],
        [22, 24],
        [26, 28],
      ],
    ),
    'Grand staircase',
    'diagonal rise',
    'Elders Assembly',
    false,
  ),
  Chapter2LayoutCandidate(
    35,
    _layout(
      'chapter2OpenRing01',
      'Open Ring',
      [
        [18, 20, 22],
        [16, 18, 22, 24],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [16, 18, 22, 24],
        [18, 20, 22],
      ],
      [
        [19, 21],
        [17, 23],
        [15, 25],
        [15, 25],
        [17, 23],
        [19, 21],
      ],
      [
        [18, 22],
        [16, 24],
        [16, 24],
        [18, 22],
      ],
    ),
    'Open ring',
    'four gate',
    'Sacred Grove',
    false,
  ),
  Chapter2LayoutCandidate(
    36,
    _layout(
      'chapter2TallFortress01',
      'Tall Fortress',
      [
        [14, 16, 24, 26],
        [14, 16, 18, 20, 22, 24, 26],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [14, 16, 18, 20, 22, 24, 26],
      ],
      [
        [15, 19, 21, 25],
        [15, 17, 19, 21, 23, 25],
        [17, 19, 21, 23],
        [17, 23],
        [15, 17, 19, 21, 23, 25],
        [15, 17, 19, 21, 23, 25],
      ],
      [
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [18, 22],
        [18, 20, 22],
      ],
    ),
    'Tall fortress',
    'battlement gate',
    'Fortress Gate',
    true,
  ),
  Chapter2LayoutCandidate(
    37,
    _layout(
      'chapter2AdinkraFormation01',
      'Adinkra Formation',
      [
        [20],
        [16, 18, 20, 22, 24],
        [16, 20, 24],
        [14, 16, 18, 20, 22, 24, 26],
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [20],
        [18, 20, 22],
      ],
      [
        [19, 21],
        [17, 19, 21, 23],
        [15, 19, 21, 25],
        [17, 19, 21, 23],
        [19, 21],
        [19, 21],
      ],
      [
        [20],
        [18, 20, 22],
        [16, 20, 24],
        [20],
      ],
    ),
    'Adinkra formation',
    'crossed knot',
    'Steadfast Spirits',
    false,
  ),
  Chapter2LayoutCandidate(
    38,
    _layout(
      'chapter2SplitIslands01',
      'Split Islands',
      [
        [12, 14, 26, 28],
        [12, 14, 16, 24, 26, 28],
        [14, 16, 24, 26],
        [14, 16, 24, 26],
        [12, 14, 16, 24, 26, 28],
        [12, 14, 26, 28],
        [14, 16, 24, 26],
        [16, 18, 22, 24],
      ],
      [
        [13, 15, 25, 27],
        [13, 15, 25, 27],
        [15, 25],
        [13, 15, 25, 27],
        [13, 27],
        [17, 23],
      ],
      [
        [14, 26],
        [14, 26],
        [16, 24],
        [18, 22],
      ],
    ),
    'Split islands',
    'drifting',
    'Twin Shrines',
    true,
  ),
  Chapter2LayoutCandidate(
    39,
    _layout(
      'chapter2AncestralPillar01',
      'Ancestral Pillar',
      [
        [18, 20, 22],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
      ],
      [
        [19, 21],
        [19, 21],
        [17, 19, 21, 23],
        [19, 21],
        [17, 19, 21, 23],
        [17, 19, 21, 23],
      ],
      [
        [20],
        [18, 20, 22],
        [20],
        [18, 20, 22],
      ],
    ),
    'Ancestral pillar',
    'carved spine',
    'Ancestral Pillar',
    false,
  ),
  Chapter2LayoutCandidate(
    40,
    _layout(
      'chapter2GrandTemple01',
      'Grand Temple',
      [
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [16, 24],
        [16, 24],
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
      ],
      [
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
      ],
      [
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
      ],
    ),
    'Finale temple',
    'triple crown court',
    'Ancestral Trial',
    false,
  ),
];
