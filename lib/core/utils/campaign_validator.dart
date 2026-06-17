import '../constants/level_data.dart';
import '../constants/tile_data.dart';
import 'board_solver.dart';
import '../../models/tile_model.dart';

class CampaignValidationIssue {
  final int? levelId;
  final String message;

  const CampaignValidationIssue(this.message, {this.levelId});

  @override
  String toString() {
    final prefix = levelId == null ? 'Campaign' : 'Level $levelId';
    return '$prefix: $message';
  }
}

List<CampaignValidationIssue> validateCampaignStructure() {
  final issues = <CampaignValidationIssue>[];
  final levelIds = <int>{};
  final knownTileIds = kTileIds.toSet();

  for (final level in kLevels) {
    if (!levelIds.add(level.id)) {
      issues.add(
          CampaignValidationIssue('Duplicate level ID', levelId: level.id));
    }

    final positions = level.layout;
    final coordinateKeys = <String>{};
    for (final position in positions) {
      final key = '${position.row}:${position.col}:${position.layer}';
      if (!coordinateKeys.add(key)) {
        issues.add(
          CampaignValidationIssue('Duplicate coordinate $key',
              levelId: level.id),
        );
      }
    }

    if (level.tileCount.isOdd) {
      issues.add(
        CampaignValidationIssue('Odd tile count ${level.tileCount}',
            levelId: level.id),
      );
    }

    if (level.symbolPoolSize * 2 > level.tileCount) {
      issues.add(
        CampaignValidationIssue(
          'Symbol pool ${level.symbolPoolSize} is too large for ${level.tileCount} tiles',
          levelId: level.id,
        ),
      );
    }

    final tileIds = level.tileIds;
    for (final tileId in tileIds) {
      if (!knownTileIds.contains(tileId)) {
        issues.add(
          CampaignValidationIssue('Unknown symbol $tileId', levelId: level.id),
        );
      }
    }

    final copyCounts = level.symbolCopyCounts;
    if (copyCounts.length != tileIds.length) {
      issues.add(
        CampaignValidationIssue('Copy count does not match symbol pool',
            levelId: level.id),
      );
    }
    if (copyCounts.fold<int>(0, (sum, count) => sum + count) !=
        level.tileCount) {
      issues.add(
        CampaignValidationIssue('Copy distribution does not equal tile count',
            levelId: level.id),
      );
    }
    if (copyCounts.any((count) => count.isOdd)) {
      issues.add(
        CampaignValidationIssue('Copy distribution contains odd counts',
            levelId: level.id),
      );
    }

    final openingTiles = [
      for (var i = 0; i < positions.length; i++)
        TileModel(
          def: kAllTiles.first,
          row: positions[i].row,
          col: positions[i].col,
          layer: positions[i].layer,
          uid: 'audit_$i',
        ),
    ];
    if (BoardSolver.getFreeTiles(openingTiles).length < 2) {
      issues.add(
        CampaignValidationIssue('Layout has no valid opening geometry',
            levelId: level.id),
      );
    }

    if (level.stats.boardWidth > 46 || level.stats.boardHeight > 28) {
      issues.add(
        CampaignValidationIssue(
          'Layout bounds are large: ${level.stats.boardWidth}x${level.stats.boardHeight}',
          levelId: level.id,
        ),
      );
    }
  }

  final flatLateLevels = kLevels
      .where((level) => level.id >= 31 && level.layerCount <= 2)
      .map((level) => level.id)
      .toList();
  if (flatLateLevels.length > 2) {
    issues.add(
      CampaignValidationIssue('Too many late flat levels: $flatLateLevels'),
    );
  }

  return issues;
}

String buildCampaignValidationReport() {
  final buffer = StringBuffer();
  for (final level in kLevels) {
    final stats = level.stats;
    buffer.writeln('Level ${level.id}:');
    buffer.writeln('Layout: ${level.layoutName}');
    buffer.writeln('Tiles: ${stats.tileCount}');
    buffer.writeln('Pairs: ${stats.pairCount}');
    buffer.writeln('Layers: ${stats.layerCount}');
    buffer.writeln('Unique symbols: ${level.symbolPoolSize}');
    buffer.writeln('Copies: ${level.symbolDistributionLabel}');
    buffer.writeln('Starting free tiles: ${stats.startingFreeTileCount}');
    buffer.writeln('Difficulty: ${level.difficultyCategory}');
    buffer.writeln();
  }
  return buffer.toString();
}
