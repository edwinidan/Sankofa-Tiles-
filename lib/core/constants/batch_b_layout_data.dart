import 'layout_data.dart';

class BatchBLayoutCandidate {
  const BatchBLayoutCandidate({
    required this.intendedLevel,
    required this.layout,
    required this.family,
    required this.variant,
    required this.proposedDisplayName,
    required this.isBreather,
  });

  final int intendedLevel;
  final NamedLayout layout;
  final String family;
  final String variant;
  final String proposedDisplayName;
  final bool isBreather;

  int get minimumLegalOpeningPairs => switch (intendedLevel) {
        6 => 5,
        7 => 7,
        8 => 12,
        9 => 9,
        10 => 5,
        11 => 6,
        12 => 7,
        13 => 9,
        14 => 5,
        15 => 6,
        16 => 10,
        17 => 5,
        18 => 10,
        19 => 8,
        20 => 12,
        _ => 0,
      };

  int get minimumSafeOpeningPairs => switch (intendedLevel) {
        6 => 4,
        7 => 6,
        8 => 12,
        9 => 8,
        10 => 5,
        11 => 5,
        12 => 7,
        13 => 8,
        14 => 4,
        15 => 5,
        16 => 9,
        17 => 4,
        18 => 10,
        19 => 7,
        20 => 10,
        _ => 0,
      };
}

NamedLayout _batchBLayout(
  String id,
  String name, {
  required List<List<int>> layer0Rows,
  required List<List<int>> layer1Rows,
  required List<List<int>> layer2Rows,
}) {
  final builder = TileLayoutBuilder();
  for (final row in layer0Rows) {
    builder.addRow(row: row[0], startCol: row[1], count: row[2]);
  }
  for (final row in layer1Rows) {
    builder.addRow(
      row: row[0],
      startCol: row[1],
      count: row[2],
      layer: 1,
      step: 2,
    );
  }
  for (final row in layer2Rows) {
    builder.addRow(
      row: row[0],
      startCol: row[1],
      count: row[2],
      layer: 2,
      step: 2,
    );
  }
  return namedLayout(id, name, builder.build());
}

final batchBOpenCourtyard01 = _batchBLayout(
  'batchBOpenCourtyard01',
  'Open Courtyard',
  layer0Rows: const [
    [0, 18, 4],
    [2, 18, 3],
    [4, 18, 1],
    [4, 24, 1],
    [6, 18, 1],
    [6, 24, 1],
    [8, 18, 1],
    [8, 24, 1],
    [10, 18, 1],
    [10, 24, 1],
    [12, 18, 4],
    [14, 17, 5],
  ],
  layer1Rows: const [
    [1, 19, 3],
    [3, 19, 2],
    [11, 19, 3],
  ],
  layer2Rows: const [
    [2, 20, 2],
    [12, 20, 2]
  ],
);

final batchBRiverPath01 = _batchBLayout(
  'batchBRiverPath01',
  'River Lesson',
  layer0Rows: const [
    [0, 20, 3],
    [2, 19, 3],
    [4, 18, 3],
    [6, 19, 3],
    [8, 20, 3],
    [10, 19, 3],
    [12, 18, 3],
    [14, 17, 3]
  ],
  layer1Rows: const [
    [1, 20, 2],
    [3, 19, 2],
    [7, 20, 2],
    [11, 19, 2],
    [13, 18, 2]
  ],
  layer2Rows: const [
    [2, 21, 2],
    [8, 21, 2],
    [12, 20, 2]
  ],
);

final batchBTempleGate01 = _batchBLayout(
  'batchBTempleGate01',
  'Wisdom Gate',
  layer0Rows: const [
    [0, 19, 4],
    [2, 18, 5],
    [4, 18, 2],
    [4, 24, 1],
    [6, 18, 2],
    [6, 24, 1],
    [8, 18, 1],
    [8, 24, 1],
    [10, 18, 1],
    [10, 24, 1],
    [12, 18, 5],
    [14, 18, 5],
  ],
  layer1Rows: const [
    [1, 19, 4],
    [3, 19, 4],
    [11, 19, 4],
  ],
  layer2Rows: const [
    [2, 21, 2],
    [10, 21, 2],
    [12, 22, 1]
  ],
);

final batchBGatheringWings01 = _batchBLayout(
  'batchBGatheringWings01',
  'Gathering Wings',
  layer0Rows: const [
    [0, 20, 3],
    [2, 18, 2],
    [2, 22, 2],
    [4, 17, 2],
    [4, 23, 2],
    [6, 18, 5],
    [8, 18, 5],
    [10, 19, 3],
    [12, 19, 4],
    [14, 20, 2]
  ],
  layer1Rows: const [
    [1, 20, 2],
    [3, 18, 2],
    [3, 24, 2],
    [7, 20, 2],
    [11, 20, 2],
    [13, 20, 2]
  ],
  layer2Rows: const [
    [2, 21, 2],
    [8, 21, 2],
    [12, 21, 2]
  ],
);

final batchBTwinBridge01 = _batchBLayout(
  'batchBTwinBridge01',
  'Elder Twin Bridge',
  layer0Rows: const [
    [0, 19, 4],
    [2, 18, 5],
    [4, 18, 2],
    [4, 24, 2],
    [6, 18, 4],
    [8, 18, 4],
    [10, 18, 2],
    [10, 24, 2],
    [12, 18, 5],
    [14, 19, 4]
  ],
  layer1Rows: const [
    [1, 20, 3],
    [3, 19, 3],
    [5, 20, 2],
    [9, 20, 2],
    [11, 19, 1],
    [13, 20, 2]
  ],
  layer2Rows: const [
    [2, 21, 2],
    [6, 21, 2],
    [12, 21, 1]
  ],
);

final batchBSmallTurtle01 = _batchBLayout(
  'batchBSmallTurtle01',
  'Heritage Turtle',
  layer0Rows: const [
    [0, 20, 3],
    [2, 19, 4],
    [4, 18, 5],
    [6, 18, 5],
    [8, 18, 5],
    [10, 18, 5],
    [12, 19, 2],
    [14, 20, 1]
  ],
  layer1Rows: const [
    [1, 20, 2],
    [3, 19, 3],
    [5, 19, 3],
    [7, 18, 4],
    [9, 19, 2],
    [11, 20, 2],
    [13, 20, 2]
  ],
  layer2Rows: const [
    [4, 20, 2],
    [8, 20, 2],
    [10, 20, 2]
  ],
);

final batchBButterfly01 = _batchBLayout(
  'batchBButterfly01',
  'Butterfly Path',
  layer0Rows: const [
    [0, 20, 2],
    [2, 17, 2],
    [2, 23, 2],
    [4, 17, 3],
    [4, 23, 2],
    [6, 18, 5],
    [8, 18, 5],
    [10, 17, 2],
    [10, 23, 2],
    [12, 18, 2],
    [12, 23, 2],
    [14, 20, 2]
  ],
  layer1Rows: const [
    [1, 20, 2],
    [3, 18, 2],
    [3, 24, 2],
    [7, 20, 2],
    [9, 20, 2],
    [11, 19, 2],
    [11, 23, 2],
    [13, 20, 2]
  ],
  layer2Rows: const [
    [2, 21, 2],
    [8, 21, 2],
    [12, 21, 2],
    [14, 21, 1]
  ],
);

final batchBShrineSteps01 = _batchBLayout(
  'batchBShrineSteps01',
  'Temple Steps',
  layer0Rows: const [
    [0, 20, 2],
    [2, 19, 3],
    [4, 18, 4],
    [6, 17, 5],
    [8, 17, 5],
    [10, 17, 5],
    [12, 17, 5],
    [14, 17, 5],
  ],
  layer1Rows: const [
    [1, 20, 2],
    [3, 19, 3],
    [5, 19, 3],
    [9, 19, 3],
    [11, 19, 3],
  ],
  layer2Rows: const [
    [2, 20, 2],
    [6, 20, 2],
    [10, 20, 2]
  ],
);

final batchBWisdomStaircase01 = _batchBLayout(
  'batchBWisdomStaircase01',
  'Wisdom Staircase',
  layer0Rows: const [
    [0, 20, 2],
    [2, 20, 2],
    [4, 19, 3],
    [6, 19, 3],
    [8, 18, 5],
    [10, 18, 5],
    [12, 17, 5],
    [14, 17, 5],
  ],
  layer1Rows: const [
    [1, 21, 2],
    [3, 21, 2],
    [5, 20, 2],
    [7, 20, 2],
    [9, 19, 2],
    [11, 19, 2],
  ],
  layer2Rows: const [
    [2, 22, 2],
    [6, 21, 2],
    [10, 20, 2]
  ],
);

final batchBCrown01 = _batchBLayout(
  'batchBCrown01',
  'Ancestral Crown',
  layer0Rows: const [
    [0, 17, 1],
    [0, 21, 1],
    [0, 25, 1],
    [2, 17, 5],
    [4, 18, 4],
    [6, 18, 4],
    [8, 18, 5],
    [10, 18, 5],
    [12, 19, 4],
    [14, 19, 3]
  ],
  layer1Rows: const [
    [1, 18, 2],
    [1, 22, 2],
    [3, 19, 3],
    [5, 20, 2],
    [7, 19, 3],
    [9, 19, 3],
    [11, 20, 2]
  ],
  layer2Rows: const [
    [2, 21, 2],
    [6, 21, 2],
    [10, 21, 2]
  ],
);

final batchBOpenRing01 = _batchBLayout(
  'batchBOpenRing01',
  'Sacred Grove',
  layer0Rows: const [
    [0, 18, 5],
    [2, 18, 5],
    [4, 18, 2],
    [4, 24, 2],
    [6, 18, 1],
    [6, 26, 1],
    [8, 18, 1],
    [8, 26, 1],
    [10, 18, 2],
    [10, 24, 2],
    [12, 18, 5],
    [14, 18, 5],
  ],
  layer1Rows: const [
    [1, 19, 4],
    [3, 19, 3],
    [9, 19, 3],
    [11, 19, 4],
  ],
  layer2Rows: const [
    [2, 21, 2],
    [10, 21, 2],
    [12, 21, 2]
  ],
);

final batchBRoyalStool01 = _batchBLayout(
  'batchBRoyalStool01',
  'Golden Stool',
  layer0Rows: const [
    [0, 17, 5],
    [2, 17, 5],
    [4, 18, 2],
    [4, 24, 2],
    [6, 19, 4],
    [8, 19, 4],
    [10, 18, 5],
    [12, 18, 5],
    [14, 18, 4]
  ],
  layer1Rows: const [
    [1, 18, 4],
    [3, 19, 3],
    [5, 20, 2],
    [7, 20, 2],
    [9, 19, 3],
    [11, 19, 4]
  ],
  layer2Rows: const [
    [2, 20, 2],
    [8, 21, 2],
    [12, 21, 2]
  ],
);

final batchBAncestralGate01 = _batchBLayout(
  'batchBAncestralGate01',
  'Ancestral Gate',
  layer0Rows: const [
    [0, 19, 4],
    [2, 18, 5],
    [4, 18, 5],
    [6, 18, 2],
    [6, 24, 2],
    [8, 18, 2],
    [8, 24, 2],
    [10, 18, 2],
    [10, 24, 2],
    [12, 18, 5],
    [14, 18, 5],
  ],
  layer1Rows: const [
    [1, 19, 4],
    [3, 19, 4],
    [5, 19, 3],
    [9, 19, 3],
    [11, 19, 4],
  ],
  layer2Rows: const [
    [2, 21, 2],
    [6, 21, 2],
    [10, 21, 2]
  ],
);

final batchBTwinTowers01 = _batchBLayout(
  'batchBTwinTowers01',
  'Twin Houses',
  layer0Rows: const [
    [0, 18, 2],
    [0, 23, 2],
    [2, 18, 2],
    [2, 24, 2],
    [4, 18, 2],
    [4, 24, 2],
    [6, 18, 2],
    [6, 24, 2],
    [8, 18, 2],
    [8, 24, 2],
    [10, 18, 5],
    [12, 18, 5],
    [14, 17, 5]
  ],
  layer1Rows: const [
    [1, 18, 2],
    [1, 24, 2],
    [3, 18, 2],
    [3, 24, 2],
    [5, 19, 2],
    [5, 23, 2],
    [7, 20, 1],
    [7, 24, 2],
    [9, 20, 3],
    [11, 19, 4]
  ],
  layer2Rows: const [
    [2, 19, 2],
    [2, 25, 2],
    [10, 21, 2],
    [12, 21, 1]
  ],
);

final batchBRaisedCourtyard01 = _batchBLayout(
  'batchBRaisedCourtyard01',
  'Raised Courtyard',
  layer0Rows: const [
    [0, 18, 5],
    [2, 18, 5],
    [4, 18, 2],
    [4, 24, 2],
    [6, 18, 2],
    [6, 24, 2],
    [8, 18, 2],
    [8, 24, 2],
    [10, 18, 2],
    [10, 24, 2],
    [12, 18, 5],
    [14, 18, 5]
  ],
  layer1Rows: const [
    [1, 18, 5],
    [3, 18, 5],
    [5, 21, 2],
    [9, 21, 2],
    [11, 18, 5],
    [13, 18, 5]
  ],
  layer2Rows: const [[2, 21, 2], [12, 21, 2]],
);

final List<BatchBLayoutCandidate> kBatchBLayoutCandidates = [
  BatchBLayoutCandidate(
      intendedLevel: 6,
      layout: batchBOpenCourtyard01,
      family: 'Open courtyard',
      variant: 'open stepped',
      proposedDisplayName: 'Open Courtyard',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 7,
      layout: batchBRiverPath01,
      family: 'River path',
      variant: 'single bend',
      proposedDisplayName: 'River Lesson',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 8,
      layout: batchBTempleGate01,
      family: 'Temple gate',
      variant: 'open gate',
      proposedDisplayName: 'Wisdom Gate',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 9,
      layout: batchBGatheringWings01,
      family: 'Wings',
      variant: 'gathered',
      proposedDisplayName: 'Gathering Wings',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 10,
      layout: batchBTwinBridge01,
      family: 'Twin bridge',
      variant: 'elder crossing',
      proposedDisplayName: 'Elder Twin Bridge',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 11,
      layout: batchBSmallTurtle01,
      family: 'Small turtle',
      variant: 'open shell',
      proposedDisplayName: 'Heritage Turtle',
      isBreather: true),
  BatchBLayoutCandidate(
      intendedLevel: 12,
      layout: batchBButterfly01,
      family: 'Butterfly',
      variant: 'open wings',
      proposedDisplayName: 'Butterfly Path',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 13,
      layout: batchBShrineSteps01,
      family: 'Shrine steps',
      variant: 'broad steps',
      proposedDisplayName: 'Temple Steps',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 14,
      layout: batchBWisdomStaircase01,
      family: 'Shrine steps',
      variant: 'rising diagonal',
      proposedDisplayName: 'Wisdom Staircase',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 15,
      layout: batchBCrown01,
      family: 'Crown',
      variant: 'three point',
      proposedDisplayName: 'Ancestral Crown',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 16,
      layout: batchBOpenRing01,
      family: 'Open ring',
      variant: 'four gate',
      proposedDisplayName: 'Sacred Grove',
      isBreather: true),
  BatchBLayoutCandidate(
      intendedLevel: 17,
      layout: batchBRoyalStool01,
      family: 'Royal stool',
      variant: 'wide base',
      proposedDisplayName: 'Golden Stool',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 18,
      layout: batchBAncestralGate01,
      family: 'Temple gate',
      variant: 'ancestral arch',
      proposedDisplayName: 'Ancestral Gate',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 19,
      layout: batchBTwinTowers01,
      family: 'Twin towers',
      variant: 'paired houses',
      proposedDisplayName: 'Twin Houses',
      isBreather: false),
  BatchBLayoutCandidate(
      intendedLevel: 20,
      layout: batchBRaisedCourtyard01,
      family: 'Open courtyard',
      variant: 'chapter showcase',
      proposedDisplayName: 'Raised Courtyard',
      isBreather: false),
];
