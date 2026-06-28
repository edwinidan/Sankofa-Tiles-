import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';

void main() {
  final definition = kAllTiles.first;

  TileModel tile({
    required String uid,
    required int col,
    TileVisibility visibility = TileVisibility.revealed,
  }) {
    return TileModel(
      uid: uid,
      def: definition,
      row: 0,
      col: col,
      visibility: visibility,
    );
  }

  test('new tiles default to revealed and available', () {
    final model = tile(uid: 'tile-1', col: 0);

    expect(model.visibility, TileVisibility.revealed);
    expect(model.isRevealed, isTrue);
    expect(model.isAvailable, isTrue);
  });

  test('covered tiles are visible but not available for matching', () {
    final model = tile(
      uid: 'tile-1',
      col: 0,
      visibility: TileVisibility.covered,
    );

    expect(model.isCovered, isTrue);
    expect(model.isAvailable, isFalse);
  });

  test('game state exposes only revealed free tiles as available', () {
    final state = GameState.initial().copyWith(
      tiles: [
        tile(uid: 'revealed-a', col: 0),
        tile(uid: 'covered-a', col: 3, visibility: TileVisibility.covered),
      ],
    );

    expect(state.availableTileUids, contains('revealed-a'));
    expect(state.availableTileUids, isNot(contains('covered-a')));
    expect(state.freeTileUids, containsAll(['revealed-a', 'covered-a']));
    expect(state.peekableTileUids, contains('covered-a'));
  });

  test('covered matching pair is peekable instead of stuck', () {
    final coveredState = GameState.initial().copyWith(
      tiles: [
        tile(uid: 'covered-a', col: 0, visibility: TileVisibility.covered),
        tile(uid: 'covered-b', col: 3, visibility: TileVisibility.covered),
      ],
    );
    final revealedState = GameState.initial().copyWith(
      tiles: [
        tile(uid: 'revealed-a', col: 0),
        tile(uid: 'revealed-b', col: 3),
      ],
    );

    expect(
        coveredState.peekableTileUids, containsAll(['covered-a', 'covered-b']));
    expect(coveredState.isStuck, isFalse);
    expect(revealedState.isStuck, isFalse);
  });
}
