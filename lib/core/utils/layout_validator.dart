import '../constants/layout_data.dart';
import '../constants/tile_data.dart';
import '../../models/tile_model.dart';
import 'board_layout_geometry.dart';
import 'board_solver.dart';

enum LayoutIssueKind {
  invalidId,
  duplicateCoordinate,
  oddTileCount,
  invalidLayer,
  missingLayer,
  floatingTile,
  sameLayerOverlap,
  insufficientOpeningTiles,
  invalidBounds,
  viewportOverflow,
}

class LayoutValidationIssue {
  final LayoutIssueKind kind;
  final String message;

  const LayoutValidationIssue(this.kind, this.message);
}

class LayoutValidationResult {
  final List<LayoutValidationIssue> issues;
  final int startingFreeTileCount;
  final int unsupportedTileCount;

  const LayoutValidationResult({
    required this.issues,
    required this.startingFreeTileCount,
    required this.unsupportedTileCount,
  });

  bool get isValid => issues.isEmpty;
}

LayoutValidationResult validateLayout(
  NamedLayout layout, {
  List<BoardViewportPreset> viewports = kRequiredBoardViewports,
  int minimumOpeningTiles = 2,
}) {
  final issues = <LayoutValidationIssue>[];
  final positions = layout.positions;
  if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(layout.id)) {
    issues.add(const LayoutValidationIssue(
      LayoutIssueKind.invalidId,
      'Layout ID must be lower camel case.',
    ));
  }
  if (positions.length.isOdd) {
    issues.add(LayoutValidationIssue(
      LayoutIssueKind.oddTileCount,
      'Tile count ${positions.length} is odd.',
    ));
  }

  final keys = <String>{};
  for (final position in positions) {
    final key = '${position.row}:${position.col}:${position.layer}';
    if (!keys.add(key)) {
      issues.add(LayoutValidationIssue(
        LayoutIssueKind.duplicateCoordinate,
        'Duplicate coordinate $key.',
      ));
    }
    if (position.layer < 0) {
      issues.add(LayoutValidationIssue(
        LayoutIssueKind.invalidLayer,
        'Negative layer at $key.',
      ));
    }
  }

  final layers = positions.map((position) => position.layer).toSet();
  if (layers.isNotEmpty) {
    final maxLayer = layers.reduce((a, b) => a > b ? a : b);
    for (var layer = 0; layer <= maxLayer; layer++) {
      if (!layers.contains(layer)) {
        issues.add(LayoutValidationIssue(
          LayoutIssueKind.missingLayer,
          'Layer $layer is missing.',
        ));
      }
    }
  }

  var unsupported = 0;
  for (final position in positions.where((p) => p.layer > 0)) {
    final supported = positions.any(
      (lower) => lower.layer == position.layer - 1 && overlaps(position, lower),
    );
    if (!supported) {
      unsupported++;
      issues.add(LayoutValidationIssue(
        LayoutIssueKind.floatingTile,
        'Tile ${_label(position)} has no support on layer ${position.layer - 1}.',
      ));
    }
  }

  for (var i = 0; i < positions.length; i++) {
    for (var j = i + 1; j < positions.length; j++) {
      final a = positions[i];
      final b = positions[j];
      if (a.layer == b.layer && overlaps(a, b)) {
        issues.add(LayoutValidationIssue(
          LayoutIssueKind.sameLayerOverlap,
          'Same-layer tiles ${_label(a)} and ${_label(b)} overlap.',
        ));
      }
    }
  }

  final tiles = <TileModel>[
    for (var i = 0; i < positions.length; i++)
      TileModel(
        uid: 'layout_validation_$i',
        def: kAllTiles.first,
        row: positions[i].row,
        col: positions[i].col,
        layer: positions[i].layer,
      ),
  ];
  final freeCount = BoardSolver.getFreeTiles(tiles).length;
  if (freeCount < minimumOpeningTiles) {
    issues.add(LayoutValidationIssue(
      LayoutIssueKind.insufficientOpeningTiles,
      'Only $freeCount starting tiles are free.',
    ));
  }

  final geometry = BoardLayoutGeometry.fromPositions(positions);
  if (!geometry.widthInTileUnits.isFinite ||
      !geometry.heightInTileUnits.isFinite ||
      geometry.widthInTileUnits <= 0 ||
      geometry.heightInTileUnits <= 0) {
    issues.add(const LayoutValidationIssue(
      LayoutIssueKind.invalidBounds,
      'Projected board bounds are invalid.',
    ));
  }
  for (final viewport in viewports) {
    if (!geometry
        .fit(availableWidth: viewport.width, availableHeight: viewport.height)
        .fitsBounds) {
      issues.add(LayoutValidationIssue(
        LayoutIssueKind.viewportOverflow,
        'Board overflows ${viewport.name}.',
      ));
    }
  }

  return LayoutValidationResult(
    issues: List.unmodifiable(issues),
    startingFreeTileCount: freeCount,
    unsupportedTileCount: unsupported,
  );
}

bool overlaps(TilePosition a, TilePosition b) =>
    axisOverlaps(a.row, b.row) && axisOverlaps(a.col, b.col);

bool axisOverlaps(int a, int b) => a < b + 2 && b < a + 2;

String _label(TilePosition position) =>
    '(${position.row}, ${position.col}, ${position.layer})';
