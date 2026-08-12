import '../constants/level_data.dart';
import '../constants/tile_data.dart';
import 'board_solver.dart';
import 'board_layout_geometry.dart';
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

    // Structural support: every tile on layer > 0 must overlap at least one
    // tile on the layer directly below it. Uses range-based overlap so
    // bridging across two lower tiles (via odd coordinates) is valid.
    for (final position in positions.where((p) => p.layer > 0)) {
      final hasSupport = positions.any((other) =>
          other.layer == position.layer - 1 &&
          _axisOverlaps(position.row, other.row) &&
          _axisOverlaps(position.col, other.col));
      if (!hasSupport) {
        issues.add(
          CampaignValidationIssue(
            'Floating tile at (${position.row}, ${position.col}, '
            '${position.layer}) has no support on layer '
            '${position.layer - 1}',
            levelId: level.id,
          ),
        );
      }
    }

    if (level.stats.boardWidth > 46 || level.stats.boardHeight > 28) {
      issues.add(
        CampaignValidationIssue(
          'Layout bounds are large: ${level.stats.boardWidth}x${level.stats.boardHeight}',
          levelId: level.id,
        ),
      );
    }

    final geometry = BoardLayoutGeometry.fromPositions(positions);
    for (final viewport in kRequiredBoardViewports) {
      final fit = geometry.fit(
        availableWidth: viewport.width,
        availableHeight: viewport.height,
      );
      if (!fit.fitsBounds) {
        issues.add(
          CampaignValidationIssue(
            'Board exceeds the ${viewport.name} gameplay area',
            levelId: level.id,
          ),
        );
      }
      // The 390 px compact gameplay area models a 360x640 device. Portrait
      // layouts intentionally trade a little scale there for usable height;
      // the standard and tall presets retain the 44 px campaign floor.
      final minimumTileWidth = viewport.name == 'compact phone'
          ? level.id >= 201
              ? 37.0
              : 40.0
          : kMinimumTileWidth;
      if (fit.tileWidth < minimumTileWidth - 0.01) {
        issues.add(
          CampaignValidationIssue(
            'Tile width ${fit.tileWidth.toStringAsFixed(1)} is below '
            '${minimumTileWidth.toStringAsFixed(0)} on ${viewport.name}',
            levelId: level.id,
          ),
        );
      }
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

bool _axisOverlaps(int startA, int startB) {
  const tileSpan = 2;
  return startA < startB + tileSpan && startB < startA + tileSpan;
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
