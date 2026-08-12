// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sankofa_tiles/core/constants/chapter_data.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/levels_201_240_candidate_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/board_layout_geometry.dart';

import 'levels_201_240_bulk_analysis.dart';
import 'levels_81_160_visual_analysis.dart';

void main() {
  final directory =
      Directory('artifacts/layout-previews/levels-201-240-production')
        ..createSync(recursive: true);
  final matrix = StringBuffer()
    ..writeln('level,layoutId,name,tiles,pairs,layers,symbolPool,'
        'symbolPlanTotal,chapterIndex,chapterTitle,width,height,tileWidth');
  final report = StringBuffer()
    ..writeln('# Levels 201–240 production assignment report')
    ..writeln()
    ..writeln('- Implemented production levels: '
        '$kImplementedCampaignLevelCount.')
    ..writeln('- Implemented boundary: Level $kImplementedFinalLevelId.')
    ..writeln('- Planned campaign horizon: $kPlannedCampaignLevelCount.')
    ..writeln('- Collection horizon: $kCollectionScheduleFinalLevel.')
    ..writeln('- Level 241 production definition: '
        '${getLevelById(241) == null ? 'unavailable' : 'ERROR'}.')
    ..writeln()
    ..writeln('## Exact production assignment matrix')
    ..writeln()
    ..writeln('|Level|Layout ID|Display name|Tiles|Symbol plan|Chapter|')
    ..writeln('|---:|---|---|---:|---:|---|');

  for (final candidate in kLevels201To240Candidates) {
    final level = getLevelById(candidate.level)!;
    final chapter = chapterForLevel(level.id);
    final fit = BoardLayoutGeometry.fromPositions(level.layout).fit(
      availableWidth: 374,
      availableHeight: 804,
    );
    final planTotal =
        level.symbolCopyCounts.fold<int>(0, (sum, value) => sum + value);
    matrix.writeln('${level.id},${level.layoutName},"${level.name}",'
        '${level.tileCount},${level.pairCount},${level.layerCount},'
        '${level.symbolPlan.symbolPoolSize},$planTotal,${chapter.index},'
        '"${chapter.title}",'
        '${(fit.boardWidth / 374 * 100).toStringAsFixed(1)},'
        '${(fit.boardHeight / 804 * 100).toStringAsFixed(1)},'
        '${fit.tileWidth.toStringAsFixed(1)}');
    report.writeln('|${level.id}|${level.layoutName}|${level.name}|'
        '${level.tileCount}|$planTotal|${chapter.index} · ${chapter.title}|');
  }

  final level220 = analyzeCoarseSilhouette(getLevelById(220)!.namedLayout);
  final level240 = analyzeCoarseSilhouette(getLevelById(240)!.namedLayout);
  final old240 = analyzeBulk(kLevel240PreFinalRefinementCandidate.layout);
  final new240 = analyzeBulk(getLevelById(240)!.namedLayout);
  final finaleSimilarity = compareCoarseSilhouettes(
    level220,
    level240,
    familyA: 'Horizon palace',
    familyB: 'Living archive',
  );
  report
    ..writeln()
    ..writeln('## Level 240 final refinement')
    ..writeln()
    ..writeln('|Measure|Before final refinement|Production final|')
    ..writeln('|---|---:|---:|')
    ..writeln(
        '|Tiles|${kLevel240PreFinalRefinementCandidate.layout.stats.tileCount}|'
        '${getLevelById(240)!.tileCount}|')
    ..writeln('|Width occupancy|'
        '${(old240.coarse.widthOccupancy * 100).toStringAsFixed(1)}%|'
        '${(new240.coarse.widthOccupancy * 100).toStringAsFixed(1)}%|')
    ..writeln('|Height occupancy|'
        '${(old240.coarse.heightOccupancy * 100).toStringAsFixed(1)}%|'
        '${(new240.coarse.heightOccupancy * 100).toStringAsFixed(1)}%|')
    ..writeln('|Opening free tiles|'
        '${kLevel240PreFinalRefinementCandidate.layout.stats.startingFreeTileCount}|'
        '${getLevelById(240)!.stats.startingFreeTileCount}|')
    ..writeln('|Detected holes|${old240.coarse.holeCount}|'
        '${new240.coarse.holeCount}|')
    ..writeln()
    ..writeln('- Level 220 versus Level 240 coarse similarity: '
        '${finaleSimilarity.score.toStringAsFixed(3)}.')
    ..writeln('- Production Level 240: twin archive wings, one major central '
        'ceremonial opening, paired secondary openings, a tiered crown, and '
        'a broad lower foundation.')
    ..writeln()
    ..writeln('### Final Level 240 geometry')
    ..writeln();
  for (var layer = 0; layer < 3; layer++) {
    final positions = getLevelById(240)!
        .layout
        .where((position) => position.layer == layer)
        .toList()
      ..sort((a, b) {
        final row = a.row.compareTo(b.row);
        return row != 0 ? row : a.col.compareTo(b.col);
      });
    report.writeln('- Layer $layer (${positions.length}): '
        '${positions.map((position) => '(${position.row},${position.col})').join(' ')}');
  }
  report
    ..writeln()
    ..writeln('## Chapters and collection')
    ..writeln()
    ..writeln('- Chapter 11: ${kChapters[10].title}, '
        '${kChapters[10].levelStart}–${kChapters[10].levelEnd}.')
    ..writeln('- Chapter 12: ${kChapters[11].title}, '
        '${kChapters[11].levelStart}–${kChapters[11].levelEnd}.')
    ..writeln('- Active collection milestones in Levels 201–240:');
  for (final milestone in kTileUnlockMilestones.where(
    (milestone) =>
        milestone.completedLevel >= 201 && milestone.completedLevel <= 240,
  )) {
    final tile = kAllTiles.firstWhere((tile) => tile.id == milestone.tileId);
    report.writeln('  - Level ${milestone.completedLevel}: ${tile.name} '
        '(`${milestone.tileId}`).');
  }
  report
    ..writeln('- Collection remains 97 faces; no definitions were added.')
    ..writeln('- Schema-v4 collection migration remains the frozen additive '
        'union; owned faces are never cleared.');

  File('${directory.path}/production-assignment-matrix.csv')
      .writeAsStringSync(matrix.toString());
  File('${directory.path}/levels-201-240-production-report.md')
      .writeAsStringSync(report.toString());
  print('${directory.path}/levels-201-240-production-report.md');
}
