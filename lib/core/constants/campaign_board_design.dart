import 'layout_data.dart';
import 'level_data.dart';

/// Explicit layered board designs shared by late-campaign chapter batches.
/// Themes inform broad Mahjong masses, never thin literal outlines.
class CampaignBoardDesign {
  const CampaignBoardDesign({
    required this.level,
    required this.name,
    required this.family,
    required this.baseMask,
    required this.layout,
    required this.isBreather,
    required this.isShowcase,
  });

  final int level;
  final String name;
  final String family;
  final List<String> baseMask;
  final NamedLayout layout;
  final bool isBreather;
  final bool isShowcase;

  int get chapter => (level - 1) ~/ 20 + 1;
  String get chapterTitle => switch (chapter) {
        15 => 'Royal Roads',
        16 => 'Voices of the Drum',
        17 => 'Northern Weaves',
        18 => 'Festival of Light',
        19 => 'Still Waters',
        _ => throw StateError('Missing chapter title for L$level'),
      };
  String get difficulty => isBreather
      ? 'Expert breather'
      : chapter >= 18
          ? 'Master'
          : 'Expert';
  SymbolCopyPlan get symbolPlan => SymbolCopyPlan(
        symbolPoolSize: isBreather
            ? 28
            : level <= 320
                ? 36 + (level - 281) ~/ 5
                : 34 + (level - 321) ~/ 10,
        preferredCopies: 4,
      );
}

CampaignBoardDesign campaignBoard(
  int level,
  String name,
  String family,
  List<String> baseMask,
  List<String> topMask, {
  bool breather = false,
  bool showcase = false,
}) {
  final positions = <TilePosition>[];
  final width = baseMask.first.length;
  for (var row = 0; row < baseMask.length; row++) {
    if (baseMask[row].length != width || topMask[row].length != width) {
      throw StateError('L$level has inconsistent mask widths');
    }
    for (var col = 0; col < width; col++) {
      final x = 16 - (width - 1) + col * 2;
      if (baseMask[row][col] == 'X') {
        positions.add(TilePosition(row * 2, x, 0));
        positions.add(TilePosition(row * 2, x, 1));
      }
      if (topMask[row][col] == 'X') {
        if (baseMask[row][col] != 'X') {
          throw StateError('L$level has an unsupported crown');
        }
        positions.add(TilePosition(row * 2, x, 2));
      }
    }
  }
  // Keep render and removal order consistent with the existing catalogue.
  positions.sort((a, b) {
    final layer = a.layer.compareTo(b.layer);
    if (layer != 0) return layer;
    final row = a.row.compareTo(b.row);
    return row != 0 ? row : a.col.compareTo(b.col);
  });
  return CampaignBoardDesign(
    level: level,
    name: name,
    family: family,
    baseMask: List.unmodifiable(baseMask),
    layout: namedLayout('journey${level}Board', '$name: $family', positions),
    isBreather: breather,
    isShowcase: showcase,
  );
}
