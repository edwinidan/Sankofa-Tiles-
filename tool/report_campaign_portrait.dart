// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sankofa_tiles/core/constants/chapter2_layout_data.dart';
import 'package:sankofa_tiles/core/constants/layout_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';

void main() {
  final out = StringBuffer()
    ..writeln('# Portrait campaign content report')
    ..writeln()
    ..writeln(
        'Generated from production definitions and isolated candidate data.')
    ..writeln()
    ..writeln('## Frozen production Levels 1–20')
    ..writeln()
    ..writeln(
        '|Level|Name|Layout|Family|Tiles / pairs|Layers|Opening free|Collection unlock|Height|Width|Tile px|')
    ..writeln('|---:|---|---|---|---:|---:|---:|---|---:|---:|---:|');
  for (var id = 1; id <= 20; id++) {
    final level = getLevelById(id)!;
    final m = _metrics(level.layout);
    final unlocks = tileIdsUnlockedAtLevel(id);
    out.writeln(
        '|$id|${level.name}|`${level.layoutName}`|${_family(level.layoutName)}|'
        '${level.tileCount} / ${level.pairCount}|${level.layerCount}|${level.stats.startingFreeTileCount}|'
        '${unlocks.isEmpty ? '—' : unlocks.join(', ')}|${m.height}%|${m.width}%|${m.tile}px|');
  }
  out
    ..writeln()
    ..writeln('## Production audit and isolated proposals: Levels 21–40')
    ..writeln()
    ..writeln(
        '|Level|Existing name|Existing layout|Existing tiles / pairs|Symbols / copies|Difficulty|Layers / free|Collection|Candidate|Family / variant|Proposed name|Breather|Tiles / pairs|Height|Width|Tile px|Centre Δ px|')
    ..writeln(
        '|---:|---|---|---:|---|---|---:|---|---|---|---|---|---:|---:|---:|---:|---:|');
  for (final c in kChapter2LayoutCandidates) {
    final level = getLevelById(c.level)!;
    final m = _metrics(c.layout.positions);
    final unlocks = tileIdsUnlockedAtLevel(c.level);
    out.writeln(
        '|${c.level}|${level.name}|`${level.layoutName}`|${level.tileCount} / ${level.pairCount}|'
        '${level.symbolPoolSize} / ${level.symbolDistributionLabel}|${level.difficultyCategory}|'
        '${level.layerCount} / ${level.stats.startingFreeTileCount}|${unlocks.isEmpty ? '—' : unlocks.join(', ')}|'
        '`${c.layout.id}`|${c.family} / ${c.variant}|${c.proposedName}|${c.isBreather ? 'yes' : 'no'}|'
        '${c.layout.stats.tileCount} / ${c.layout.stats.pairCount}|${m.height}%|${m.width}%|${m.tile}px|${m.centreDelta}px|');
  }
  out
    ..writeln()
    ..writeln('## Chapter 2 coordinates by layer')
    ..writeln();
  for (final c in kChapter2LayoutCandidates) {
    out.writeln('### Level ${c.level} — `${c.layout.id}`');
    for (var layer = 0; layer < c.layout.stats.layerCount; layer++) {
      final positions = c.layout.positions.where((p) => p.layer == layer);
      out.writeln(
          '- Layer $layer: ${positions.map((p) => '(${p.row},${p.col})').join(' ')}');
    }
    out.writeln();
  }
  final file = File('artifacts/layout-previews/portrait-campaign-report.md');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(out.toString());
  print(file.path);
}

({String height, String width, String tile, String centreDelta}) _metrics(
    List<TilePosition> positions) {
  final geometry = BoardLayoutGeometry.fromPositions(positions);
  final fit = geometry.fit(availableWidth: 374, availableHeight: 780);
  final xs = positions
      .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer) + .5)
      .cast<double>();
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  final layerMeans = <double>[
    for (var layer = 0; layer < 3; layer++)
      () {
        final layerXs = positions
            .where((p) => p.layer == layer)
            .map((p) => BoardLayoutGeometry.projectX(p.col, p.layer) + .5)
            .cast<double>();
        return layerXs.reduce((a, b) => a + b) / layerXs.length;
      }(),
  ];
  final delta =
      layerMeans.map((x) => (x - mean).abs()).reduce((a, b) => a > b ? a : b) *
          fit.tileWidth;
  return (
    height: (fit.boardHeight / 780 * 100).toStringAsFixed(1),
    width: (fit.boardWidth / 374 * 100).toStringAsFixed(1),
    tile: fit.tileWidth.toStringAsFixed(1),
    centreDelta: delta.toStringAsFixed(1),
  );
}

String _family(String id) => id
    .replaceAll(RegExp(r'^(early|batchB)'), '')
    .replaceAll(RegExp(r'\d+$'), '')
    .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
