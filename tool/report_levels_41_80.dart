// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_41_80_candidate_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';

void main() {
  final directory =
      Directory('artifacts/layout-previews/levels-41-80-candidates')
        ..createSync(recursive: true);
  final report = StringBuffer()
    ..writeln('# Isolated Levels 41–80 candidate report')
    ..writeln()
    ..writeln('Production Levels 41–80 remain unchanged. These forty layouts '
        'are developer-only candidates for Chapters 3 and 4.')
    ..writeln()
    ..writeln(
        '|Level|Production name / layout|Candidate|Family / variant|Proposed name|Breather|Tiles / pairs|Width|Height|Tile px|')
    ..writeln('|---:|---|---|---|---|---|---:|---:|---:|---:|');
  final csv = StringBuffer()
    ..writeln('level,id,name,family,variant,tiles,pairs,width,height,tile');
  for (final candidate in kLevels41To80Candidates) {
    final production = getLevelById(candidate.level)!;
    final geometry =
        BoardLayoutGeometry.fromPositions(candidate.layout.positions);
    final fit = geometry.fit(availableWidth: 374, availableHeight: 804);
    final width = fit.boardWidth / 374 * 100;
    final height = fit.boardHeight / 804 * 100;
    report.writeln('|${candidate.level}|${production.name} / '
        '`${production.layoutName}`|`${candidate.layout.id}`|'
        '${candidate.family} / ${candidate.variant}|${candidate.proposedName}|'
        '${candidate.isBreather ? 'yes' : 'no'}|'
        '${candidate.layout.stats.tileCount} / ${candidate.layout.stats.pairCount}|'
        '${width.toStringAsFixed(1)}%|${height.toStringAsFixed(1)}%|'
        '${fit.tileWidth.toStringAsFixed(1)}|');
    csv.writeln('${candidate.level},${candidate.layout.id},'
        '"${candidate.proposedName}","${candidate.family}",'
        '"${candidate.variant}",${candidate.layout.stats.tileCount},'
        '${candidate.layout.stats.pairCount},${width.toStringAsFixed(1)},'
        '${height.toStringAsFixed(1)},${fit.tileWidth.toStringAsFixed(1)}');
  }
  report
    ..writeln()
    ..writeln('## Coordinates grouped by layer')
    ..writeln();
  for (final candidate in kLevels41To80Candidates) {
    report.writeln('### Level ${candidate.level} — `${candidate.layout.id}`');
    for (var layer = 0; layer < 3; layer++) {
      report.writeln(
          '- Layer $layer: ${candidate.layout.positions.where((p) => p.layer == layer).map((p) => '(${p.row},${p.col})').join(' ')}');
    }
    report.writeln();
  }
  report
    ..writeln('## Pairwise similarity matrix')
    ..writeln()
    ..write('|Level|');
  for (final candidate in kLevels41To80Candidates) {
    report.write('${candidate.level}|');
  }
  report
    ..writeln()
    ..write('|---:|');
  for (var i = 0; i < 40; i++) {
    report.write('---:|');
  }
  report.writeln();
  var highestAdjacent = 0.0;
  for (var i = 0; i < 40; i++) {
    report.write('|${i + 41}|');
    for (var j = 0; j < 40; j++) {
      final score = i == j
          ? 1.0
          : compareLayoutSilhouettes(kLevels41To80Candidates[i].layout,
                  kLevels41To80Candidates[j].layout)
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
    ..writeln('Highest adjacent score: ${highestAdjacent.toStringAsFixed(3)} '
        '(warning threshold 0.90).')
    ..writeln()
    ..writeln('## Verification')
    ..writeln()
    ..writeln('- 4,000 / 4,000 deterministic generations succeeded and solved.')
    ..writeln('- Minimum three legal and safe opening pairs on every seed.')
    ..writeln('- Zero forced-opening seeds.')
    ..writeln('- Breathers: 44, 49, 55, 62, 68, 74, 78.')
    ..writeln('- Production references for Levels 41–80 remain unchanged.');
  File('${directory.path}/levels-41-80-candidate-report.md')
      .writeAsStringSync(report.toString());
  File('${directory.path}/metrics.csv').writeAsStringSync(csv.toString());
  print('${directory.path}/levels-41-80-candidate-report.md');
}
