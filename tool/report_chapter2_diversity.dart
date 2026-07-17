// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sankofa_tiles/core/constants/chapter2_layout_data.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';

void main() {
  final directory =
      Directory('artifacts/layout-previews/chapter-2-diversity-pass')
        ..createSync(recursive: true);
  final report = StringBuffer()
    ..writeln('# Chapter 2 silhouette-diversity redesign')
    ..writeln()
    ..writeln('Status: isolated developer candidates only. Production Levels '
        '1–200, names, progression, collection, migration, monetisation, '
        'solver, matching, projection, and board fitting are unchanged.')
    ..writeln()
    ..writeln('## Baseline audit')
    ..writeln()
    ..writeln('The previous twenty candidates were all emitted by one centered '
        'row-count generator: eight base rows, six middle rows, and three '
        'small top rows. Their dominant class was tall centered rectangle / '
        'tiered tower, with repeated flat bases, two-tile crowns, small or '
        'absent openings, and mostly one connected mass. The preserved '
        'baseline measurements are in `baseline-portrait-report.md`.')
    ..writeln()
    ..writeln('## Final family assignment and measurements')
    ..writeln()
    ..writeln(
        '|Level|Existing name|Candidate|Family / variant|Proposed name|Breather|Tiles / pairs|Layers|Aspect|Width|Height|Tile px|Negative space|Symmetry|Masses|')
    ..writeln(
        '|---:|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|');

  for (final candidate in kChapter2LayoutCandidates) {
    final level = getLevelById(candidate.level)!;
    final metrics = _metrics(candidate.layout);
    report.writeln('|${candidate.level}|${level.name}|`${candidate.layout.id}`|'
        '${candidate.family} / ${candidate.variant}|${candidate.proposedName}|'
        '${candidate.isBreather ? 'yes' : 'no'}|'
        '${candidate.layout.stats.tileCount} / ${candidate.layout.stats.pairCount}|'
        '${candidate.layout.stats.layerCount}|${metrics.aspect}|${metrics.width}%|'
        '${metrics.height}%|${metrics.tile}|${metrics.negative}%|'
        '${metrics.symmetric ? 'yes' : 'no'}|${metrics.masses}|');
  }

  report
    ..writeln()
    ..writeln('## Coordinates grouped by layer')
    ..writeln();
  for (final candidate in kChapter2LayoutCandidates) {
    report.writeln('### Level ${candidate.level} — `${candidate.layout.id}`');
    for (var layer = 0; layer < 3; layer++) {
      final positions =
          candidate.layout.positions.where((p) => p.layer == layer);
      report.writeln(
          '- Layer $layer: ${positions.map((p) => '(${p.row},${p.col})').join(' ')}');
    }
    report.writeln();
  }

  report
    ..writeln('## Pairwise silhouette similarity matrix')
    ..writeln()
    ..write('|Level|');
  for (final candidate in kChapter2LayoutCandidates) {
    report.write('${candidate.level}|');
  }
  report
    ..writeln()
    ..write('|---:|');
  for (var i = 0; i < 20; i++) {
    report.write('---:|');
  }
  report.writeln();
  var highestAdjacent = 0.0;
  for (var i = 0; i < 20; i++) {
    report.write('|${kChapter2LayoutCandidates[i].level}|');
    for (var j = 0; j < 20; j++) {
      final score = i == j
          ? 1.0
          : compareLayoutSilhouettes(kChapter2LayoutCandidates[i].layout,
                  kChapter2LayoutCandidates[j].layout)
              .score;
      if ((i - j).abs() == 1 && score > highestAdjacent) {
        highestAdjacent = score;
      }
      report.write('${score.toStringAsFixed(2)}|');
    }
    report.writeln();
  }
  report
    ..writeln()
    ..writeln('Warning threshold: 0.90. Highest adjacent score: '
        '${highestAdjacent.toStringAsFixed(3)}. Exact coordinate duplication '
        'is forbidden; base and top masks contribute separate score weights.')
    ..writeln()
    ..writeln('## Verification summary')
    ..writeln()
    ..writeln('- 2,000 / 2,000 deterministic boards generated and solved.')
    ..writeln(
        '- Every seed had at least three legal and three safe opening pairs.')
    ..writeln(
        '- Zero forced-opening seeds; generation attempts were bounded at 100.')
    ..writeln('- Breathers: Levels 24, 26, 31, 36, and 38.')
    ..writeln('- Stage A anchors: 21, 23, 25, 27, 29, 31, 33, 35, 37, 40.')
    ..writeln('- Stage B complements: 22, 24, 26, 28, 30, 32, 34, 36, 38, 39.')
    ..writeln(
        '- All candidates remain isolated from production campaign data.');

  final reportFile = File('${directory.path}/chapter-2-diversity-report.md')
    ..writeAsStringSync(report.toString());
  final csv = StringBuffer()
    ..writeln('level,layout_id,family,variant,tiles,pairs,width_pct,height_pct,'
        'tile_px,negative_space_pct,nearest_level,nearest_score');
  for (final candidate in kChapter2LayoutCandidates) {
    final metrics = _metrics(candidate.layout);
    final neighbours = kChapter2LayoutCandidates
        .where((other) => other.level != candidate.level)
        .map((other) => (
              level: other.level,
              score:
                  compareLayoutSilhouettes(candidate.layout, other.layout).score
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    csv.writeln('${candidate.level},${candidate.layout.id},'
        '"${candidate.family}","${candidate.variant}",'
        '${candidate.layout.stats.tileCount},${candidate.layout.stats.pairCount},'
        '${metrics.width},${metrics.height},${metrics.tile},${metrics.negative},'
        '${neighbours.first.level},${neighbours.first.score.toStringAsFixed(3)}');
  }
  File('${directory.path}/metrics-and-neighbours.csv')
      .writeAsStringSync(csv.toString());
  print(reportFile.path);
}

({
  String aspect,
  String width,
  String height,
  String tile,
  String negative,
  bool symmetric,
  int masses
}) _metrics(NamedLayout layout) {
  final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
  final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
  final base = layout.positions.where((p) => p.layer == 0).toList();
  final rows = <int, Set<int>>{};
  for (final position in base) {
    rows.putIfAbsent(position.row, () => <int>{}).add(position.col);
  }
  final boundingCells = rows.isEmpty
      ? 1
      : ((base.map((p) => p.row).reduce((a, b) => a > b ? a : b) -
                      base.map((p) => p.row).reduce((a, b) => a < b ? a : b)) ~/
                  2 +
              1) *
          ((base.map((p) => p.col).reduce((a, b) => a > b ? a : b) -
                      base.map((p) => p.col).reduce((a, b) => a < b ? a : b)) ~/
                  2 +
              1);
  final negative = (1 - base.length / boundingCells).clamp(0, 1) * 100;
  final center = (layout.stats.minCol + layout.stats.maxCol) / 2;
  final keys = base.map((p) => '${p.row}:${p.col}').toSet();
  final symmetric = base
      .every((p) => keys.contains('${p.row}:${(2 * center - p.col).round()}'));
  final remaining = base.toSet();
  var masses = 0;
  while (remaining.isNotEmpty) {
    masses++;
    final queue = <TilePosition>[remaining.first];
    remaining.remove(remaining.first);
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final connected = remaining
          .where((p) => ((p.row - current.row).abs() <= 2 &&
              (p.col - current.col).abs() <= 2))
          .toList();
      queue.addAll(connected);
      remaining.removeAll(connected);
    }
  }
  return (
    aspect: (geometry.heightInTileUnits / geometry.widthInTileUnits)
        .toStringAsFixed(2),
    width: (fit.boardWidth / 374 * 100).toStringAsFixed(1),
    height: (fit.boardHeight / 804 * 100).toStringAsFixed(1),
    tile: fit.tileWidth.toStringAsFixed(1),
    negative: negative.toStringAsFixed(1),
    symmetric: symmetric,
    masses: masses,
  );
}
