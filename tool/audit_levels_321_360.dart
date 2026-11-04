// ignore_for_file: avoid_print
import 'dart:io';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_321_360_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';
import 'package:sankofa_tiles/core/utils/layout_similarity.dart';
import 'package:sankofa_tiles/core/utils/layout_validator.dart';
import 'levels_201_240_bulk_analysis.dart';

void main() {
  final failures = <String>[];
  final lines = <String>[
    'level,name,tiles,free,bulk,fullness,compactTileWidth,standardTileWidth,nearestLevel,similarity',
  ];
  for (final board in kLevels321To360Designs) {
    final validation = validateLayout(board.layout, minimumOpeningTiles: 10);
    failures.addAll(
        validation.issues.map((issue) => 'L${board.level}: ${issue.message}'));
    final bulk = analyzeBulk(board.layout);
    if (bulk.classification == BulkClass.thin) {
      failures.add('L${board.level}: thin');
    }
    final geometry = BoardLayoutGeometry.fromPositions(board.layout.positions);
    final fits = [
      for (final viewport in kRequiredBoardViewports)
        geometry.fit(
            availableWidth: viewport.width, availableHeight: viewport.height)
    ];
    for (final fit in fits) {
      if (!fit.fitsSafely) {
        failures.add('L${board.level}: ${fit.tileWidth} tile width');
      }
    }
    var maximum = 0.0;
    var nearest = 0;
    for (final other in kLevels.where((level) => level.id != board.level)) {
      final score =
          compareLayoutSilhouettes(board.layout, other.namedLayout).score;
      if (score > maximum) {
        maximum = score;
        nearest = other.id;
      }
    }
    if (maximum >= .90) {
      failures.add('L${board.level}/$nearest: near clone $maximum');
    }
    lines.add('${board.level},${board.name},${board.layout.stats.tileCount},'
        '${validation.startingFreeTileCount},${bulk.classification.name},'
        '${bulk.fullnessScore.toStringAsFixed(3)},${fits[0].tileWidth.toStringAsFixed(1)},'
        '${fits[1].tileWidth.toStringAsFixed(1)},$nearest,${maximum.toStringAsFixed(3)}');
  }
  final output =
      Directory('artifacts/layout-previews/levels-321-360-production')
        ..createSync(recursive: true);
  File('${output.path}/geometry.csv')
      .writeAsStringSync('${lines.join('\n')}\n');
  print(lines.join('\n'));
  print('Failures: ${failures.length}\n${failures.join('\n')}');
  if (failures.isNotEmpty) exitCode = 1;
}
