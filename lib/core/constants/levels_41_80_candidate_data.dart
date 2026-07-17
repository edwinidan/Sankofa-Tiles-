import 'chapter2_layout_data.dart';
import 'layout_data.dart';

class AdvancedLayoutCandidate {
  const AdvancedLayoutCandidate({
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

NamedLayout _advancedVariant(
  NamedLayout source,
  int level,
  String family,
  String variant,
) {
  final seed = level - 40;
  final mirror = seed.isEven;
  final positions = <TilePosition>[];
  for (final position in source.positions) {
    final col = mirror ? 40 - position.col : position.col;
    positions.add(TilePosition(position.row, col, position.layer));
  }

  final maxRow = positions.map((p) => p.row).reduce((a, b) => a > b ? a : b);
  var additions = 0;
  TilePosition? lastAddition;
  for (var offset = 0; offset < 8 && additions < 2; offset++) {
    final row = ((seed + offset) % (maxRow ~/ 2 + 1)) * 2;
    final col = 16 + ((seed * 3 + offset) % 5) * 2;
    final candidate = TilePosition(row, col, 0);
    final overlaps = positions.any((position) =>
        position.layer == 0 &&
        position.row < candidate.row + 2 &&
        candidate.row < position.row + 2 &&
        position.col < candidate.col + 2 &&
        candidate.col < position.col + 2);
    if (!overlaps) {
      positions.add(candidate);
      lastAddition = candidate;
      additions++;
    }
  }
  if (additions.isOdd && lastAddition != null) {
    positions.remove(lastAddition);
  }

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

  final unique = positions.toSet().toList();
  if (unique.length.isOdd) {
    final minRow = unique.map((p) => p.row).reduce((a, b) => a < b ? a : b);
    final minCol = unique.map((p) => p.col).reduce((a, b) => a < b ? a : b);
    for (final candidate in [
      TilePosition(minRow, minCol - 2, 0),
      TilePosition(minRow + 2, minCol - 2, 0),
      TilePosition(minRow, minCol + 2, 0),
    ]) {
      final overlaps = unique.any((position) =>
          position.layer == 0 &&
          position.row < candidate.row + 2 &&
          candidate.row < position.row + 2 &&
          position.col < candidate.col + 2 &&
          candidate.col < position.col + 2);
      if (!overlaps) {
        unique.add(candidate);
        break;
      }
    }
  }
  unique.sort((a, b) {
    final layer = a.layer.compareTo(b.layer);
    if (layer != 0) return layer;
    final row = a.row.compareTo(b.row);
    return row != 0 ? row : a.col.compareTo(b.col);
  });
  return namedLayout(
    'advanced${family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}${level.toString().padLeft(2, '0')}',
    '$family — $variant',
    List.unmodifiable(unique),
  );
}

List<List<int>> _profile(
  List<int> counts, {
  List<int>? shifts,
  Set<int> holes = const {},
}) {
  return [
    for (var row = 0; row < counts.length; row++)
      [
        for (var index = 0; index < counts[row]; index++)
          20 - (counts[row] - 1) + index * 2 + (shifts?[row] ?? 0),
      ].where((col) => !(holes.contains(row) && col == 20)).toList(),
  ];
}

List<List<int>> _reviewedBase(int level) {
  switch (level) {
    case 45:
      return const [
        [18, 20, 22],
        [16, 18, 24],
        [16, 24],
        [16, 20, 24],
        [16, 20, 22, 24],
        [16, 24],
        [16, 18, 24],
        [18, 20, 22],
      ];
    case 46:
      return const [
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 18, 20, 22, 24],
        [18, 22],
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
      ];
    case 48:
      return const [
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
        [16, 24],
        [16, 24],
        [16, 18, 22, 24],
        [16, 24],
        [16, 18, 22, 24],
        [18, 20, 22],
      ];
    case 54:
      return const [
        [16, 18, 24],
        [16, 18, 24],
        [16, 18, 24],
        [16, 18, 22, 24],
        [16, 22, 24],
        [16, 22, 24],
        [16, 22, 24],
        [18, 22],
      ];
    case 57:
      return const [
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
      ];
    case 58:
      return _profile([3, 5, 3, 1, 1, 3, 5, 3]);
    case 59:
      return _profile([1, 1, 3, 5, 5, 3, 1, 1]);
    case 60:
      return const [
        [16, 18, 20, 22, 24],
        [16, 18, 20, 22, 24],
        [16, 18, 22, 24],
        [16, 24],
        [16, 24],
        [16, 18, 22, 24],
        [16, 18, 20, 22, 24],
        [18, 20, 22],
      ];
    case 61:
      return _profile([1, 3, 5, 3, 3, 5, 3, 1],
          shifts: [0, 0, -2, -2, 2, 2, 0, 0]);
    case 62:
      return _profile([3, 5, 4, 3, 2, 3, 4, 5],
          shifts: [2, 0, -2, -2, 0, 2, 2, 0], holes: {1, 2, 5});
    case 63:
      return _profile([5, 4, 3, 2, 2, 3, 4, 5], holes: {0, 1, 6, 7});
    case 64:
      return _profile([2, 3, 4, 5, 4, 3, 2, 1],
          shifts: [-2, -2, 0, 0, 0, 2, 2, 2]);
    case 65:
      return _profile([1, 2, 3, 4, 3, 2, 3, 4],
          shifts: [-2, -2, -2, 0, 2, 2, 2, 0]);
    case 66:
      return _profile([5, 3, 1, 3, 5, 3, 1, 3],
          shifts: [0, -2, -2, -2, 0, 2, 2, 2]);
    case 67:
      return const [
        [16, 20, 24],
        [16, 20, 24],
        [16, 18, 22, 24],
        [18, 22],
        [16, 18, 22, 24],
        [16, 20, 24],
        [16, 20, 24],
        [18, 20, 22]
      ];
    case 68:
      return _profile([1, 3, 5, 4, 3, 2, 3, 4],
          shifts: [-2, -2, -2, 0, 0, 2, 2, 2]);
    case 69:
      return _profile([4, 3, 2, 3, 4, 5, 3, 1],
          shifts: [-2, -2, 0, 2, 2, 0, 0, 0], holes: {0, 4, 5});
    case 70:
      return _profile([1, 2, 3, 4, 5, 4, 3, 2],
          shifts: [-2, -2, -2, 0, 0, 2, 2, 2]);
    case 71:
      return const [
        [16, 18, 22, 24],
        [16, 24],
        [16, 20, 24],
        [16, 24],
        [16, 18, 22, 24],
        [16, 24],
        [16, 20, 24],
        [18, 22]
      ];
    case 72:
      return _profile([5, 3, 3, 1, 3, 3, 5, 1], holes: {0, 6});
    case 73:
      return _profile([1, 3, 5, 3, 1, 3, 5, 3],
          shifts: [0, -2, -2, -2, 0, 2, 2, 2]);
    case 74:
      return const [
        [16, 24],
        [16, 18, 22, 24],
        [16, 20, 24],
        [18, 22],
        [16, 20, 24],
        [16, 18, 22, 24],
        [16, 24],
        [18, 22]
      ];
    case 75:
      return _profile([3, 5, 3, 5, 1, 3, 5, 3], holes: {1, 3, 6});
    case 76:
      return _profile([2, 4, 3, 5, 3, 4, 2, 3],
          shifts: [-2, -2, 0, 0, 2, 2, 0, 0], holes: {3});
    case 77:
      return _profile([5, 3, 2, 4, 2, 3, 5, 2],
          shifts: [0, -2, -2, 0, 2, 2, 0, 0], holes: {0, 3, 6});
    case 78:
      return const [
        [16, 18, 22, 24],
        [16, 24],
        [16, 20, 24],
        [18, 22],
        [16, 18, 22, 24],
        [16, 24],
        [18, 20, 22],
        [20]
      ];
    case 79:
      return _profile([1, 3, 1, 5, 1, 3, 1, 5], holes: {3, 7});
    case 80:
      return const [
        [16, 18, 22, 24],
        [16, 20, 24],
        [16, 18, 20, 22, 24],
        [18, 22],
        [16, 20, 24],
        [16, 18, 22, 24],
        [18, 20, 22],
        [16, 18, 20, 22, 24],
      ];
  }
  throw ArgumentError.value(level);
}

NamedLayout _reviewedLayout(int level, String family, String variant) {
  final base = [
    for (final row in _reviewedBase(level))
      (row.map((col) => ((col / 2).round() * 2).clamp(16, 24)).toSet().toList()
        ..sort()),
  ];
  final positions = <TilePosition>[];
  for (var row = 0; row < base.length; row++) {
    for (final col in base[row]) {
      positions.add(TilePosition(row * 2, col, 0));
    }
  }
  final middle = <List<int>>[];
  for (var row = 0; row < 7; row++) {
    final intersection =
        base[row].where((col) => base[row + 1].contains(col)).toList();
    final selected = intersection.length >= 2
        ? intersection
        : (<int>{...base[row], ...base[row + 1]}.toList()..sort())
            .where((col) => col == 16 || col == 20 || col == 24)
            .toList();
    middle.add(selected);
    for (final col in selected) {
      positions.add(TilePosition(row * 2 + 1, col, 1));
    }
  }
  for (var row = 0; row < 5; row++) {
    final candidates = <int>{...middle[row], ...middle[row + 1]}.toList()
      ..sort();
    final selected = const {60, 80}.contains(level)
        ? candidates.where((col) => col % 4 == 0).toList()
        : candidates.where((col) => (col + row + level).isEven).toList();
    for (final col in selected) {
      positions.add(TilePosition(row * 2 + 2, col, 2));
    }
  }
  if (positions.where((p) => p.layer == 2).isEmpty) {
    positions.add(const TilePosition(2, 20, 2));
  }
  final targetCount = level == 60
      ? 72
      : level == 80
          ? 78
          : 0;
  if (targetCount > 0) {
    for (final col in const [16, 24, 20, 18, 22]) {
      for (var row = 2; row <= 12 && positions.length < targetCount; row += 2) {
        final candidate = TilePosition(row, col, 2);
        final supported = positions.any((lower) =>
            lower.layer == 1 &&
            lower.row < candidate.row + 2 &&
            candidate.row < lower.row + 2 &&
            lower.col < candidate.col + 2 &&
            candidate.col < lower.col + 2);
        final overlaps = positions.any((position) =>
            position.layer == 2 &&
            position.row == candidate.row &&
            (position.col - candidate.col).abs() < 2);
        if (supported && !overlaps) positions.add(candidate);
      }
    }
  }
  if (positions.length.isOdd) {
    final top = positions.lastWhere((p) => p.layer == 2);
    positions.remove(top);
  }
  positions.sort((a, b) {
    final layer = a.layer.compareTo(b.layer);
    if (layer != 0) return layer;
    final row = a.row.compareTo(b.row);
    return row != 0 ? row : a.col.compareTo(b.col);
  });
  return namedLayout(
    'reviewed${family.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}$level',
    '$family — $variant',
    List.unmodifiable(positions),
  );
}

const _families = <String>[
  'Grand turtle',
  'Twin sanctuary',
  'Tall butterfly',
  'Royal mask',
  'Spiral courtyard',
  'Layered bridges',
  'Hollow fortress',
  'Vertical fort',
  'Ceremonial crown',
  'Multi-arch gate',
  'Sacred ring',
  'Stepped temple',
  'Winged emblem',
  'Split islands',
  'Ancestral hourglass',
  'Royal stool',
  'Twin towers',
  'Ceremonial pillar',
  'Ancestral cross',
  'Grand shrine',
  'Lantern gate',
  'River delta',
  'Shield shrine',
  'Forked monument',
  'Crescent court',
  'Drum tower',
  'Triple arch',
  'Guardian wings',
  'Open chalice',
  'Serpent path',
  'Four corners',
  'Crowned well',
  'Split crown',
  'Stepped mask',
  'Twin spirals',
  'Portal stair',
  'Sunburst',
  'Hollow sceptre',
  'River crown',
  'Memory monument',
];

const _variants = <String>[
  'ascending',
  'open court',
  'split wing',
  'guardian',
  'clockwise',
  'triple span',
  'inner keep',
  'switchback',
  'five peak',
  'upper passage',
  'broken gate',
  'offset tiers',
  'raised wings',
  'drifting',
  'narrow waist',
  'high seat',
  'ceremonial link',
  'carved',
  'crossed knot',
  'open sanctuary',
];

final List<AdvancedLayoutCandidate> kLevels41To80Candidates =
    List.unmodifiable([
  for (var index = 0; index < 40; index++)
    AdvancedLayoutCandidate(
      level: index + 41,
      layout: const {45, 46, 48, 54, 57, 58, 59, 60}.contains(index + 41) ||
              index + 41 >= 61
          ? _reviewedLayout(
              index + 41, _families[index], _variants[index % _variants.length])
          : _advancedVariant(
              kChapter2LayoutCandidates[(index * 7) % 20].layout,
              index + 41,
              _families[index],
              _variants[index % _variants.length],
            ),
      family: _families[index],
      variant: _variants[index % _variants.length],
      proposedName: index == 39
          ? 'Monument of Memory'
          : '${_families[index]} ${index < 20 ? 'Path' : 'Trial'}',
      isBreather: const {44, 49, 55, 62, 68, 74, 78}.contains(index + 41),
    ),
]);
