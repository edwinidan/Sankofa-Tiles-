import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/screens/game/widgets/board_widget.dart';

void main() {
  final definition = kAllTiles.first;

  TileModel tile({
    required String uid,
    bool isMatched = false,
  }) {
    return TileModel(
      uid: uid,
      def: definition,
      row: 0,
      col: 0,
      isMatched: isMatched,
    );
  }

  test('unmatched tiles remain visible', () {
    expect(
      shouldRenderBoardTile(tile(uid: 'active'), null),
      isTrue,
    );
  });

  test('matched tiles remain visible only during their smash animation', () {
    final matched = tile(uid: 'matched', isMatched: true);
    const animation = PendingMatchAnimation(
      id: 1,
      firstTileUid: 'matched',
      secondTileUid: 'partner',
      style: MatchAnimationStyle.directCollision,
    );

    expect(shouldRenderBoardTile(matched, animation), isTrue);
    expect(shouldRenderBoardTile(matched, null), isFalse);
  });

  test('older matched tiles stay hidden during a later smash animation', () {
    final oldMatch = tile(uid: 'old-match', isMatched: true);
    const laterAnimation = PendingMatchAnimation(
      id: 2,
      firstTileUid: 'new-first',
      secondTileUid: 'new-second',
      style: MatchAnimationStyle.directCollision,
    );

    expect(shouldRenderBoardTile(oldMatch, laterAnimation), isFalse);
  });
}
