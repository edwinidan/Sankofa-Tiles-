import 'dart:math';

import '../../core/constants/tile_data.dart';

class EntryTile {
  const EntryTile(this.id, this.definition);
  final int id;
  final TileDefinition definition;
}

class EntryPairGame {
  EntryPairGame._(this.tiles);

  factory EntryPairGame.seeded({int seed = 1844}) {
    const ids = ['gye_nyame', 'sankofa2', 'dwennimmen'];
    final definitions =
        ids.map((id) => kAllTiles.firstWhere((tile) => tile.id == id)).toList();
    final tiles = <EntryTile>[];
    var instance = 0;
    for (final definition in definitions) {
      tiles.add(EntryTile(instance++, definition));
      tiles.add(EntryTile(instance++, definition));
    }
    tiles.shuffle(Random(seed));
    return EntryPairGame._(List.unmodifiable(tiles));
  }

  final List<EntryTile> tiles;

  bool isPair(EntryTile first, EntryTile second) =>
      first.id != second.id && first.definition.id == second.definition.id;
}
