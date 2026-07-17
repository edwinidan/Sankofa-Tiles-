import 'package:flutter/foundation.dart';

import '../../core/constants/tile_data.dart';
import '../../core/utils/board_solver.dart';
import '../../models/tile_model.dart';

enum TutorialLesson {
  matchingPair,
  freeSides,
  coveredTiles,
  backTiles,
  practice,
  completed
}

enum TutorialTapResult {
  selected,
  matched,
  blocked,
  covered,
  mismatch,
  ignored
}

class TutorialController extends ChangeNotifier {
  TutorialController() {
    _loadLesson();
  }

  TutorialLesson lesson = TutorialLesson.matchingPair;
  List<TileModel> tiles = const [];
  String? selectedUid;
  String? feedback;
  int pairsMatched = 0;
  int lessonPairsMatched = 0;

  String get instruction {
    if (feedback != null) return feedback!;
    if (lesson == TutorialLesson.matchingPair && selectedUid != null) {
      return 'Now tap its matching symbol.';
    }
    if (lesson == TutorialLesson.freeSides && lessonPairsMatched == 1) {
      return 'The centre tiles are free now.';
    }
    if (lesson == TutorialLesson.coveredTiles && lessonPairsMatched == 1) {
      return 'The tiles below are now free.';
    }
    if (lesson == TutorialLesson.backTiles && selectedUid != null) {
      return 'Now reveal its matching back tile.';
    }
    return switch (lesson) {
      TutorialLesson.matchingPair => 'Match two identical free tiles.',
      TutorialLesson.freeSides =>
        'A tile is free when its left or right side is open.',
      TutorialLesson.coveredTiles =>
        'Remove the top tiles to unlock the tiles below.',
      TutorialLesson.backTiles => 'Tap a free back tile to reveal its symbol.',
      TutorialLesson.practice => 'Clear the board using free matching tiles.',
      TutorialLesson.completed => 'Tutorial Complete',
    };
  }

  int get lessonNumber => switch (lesson) {
        TutorialLesson.matchingPair => 1,
        TutorialLesson.freeSides => 2,
        TutorialLesson.coveredTiles => 3,
        TutorialLesson.backTiles => 4,
        TutorialLesson.practice => 5,
        TutorialLesson.completed => 5,
      };

  int get lessonPairTarget => switch (lesson) {
        TutorialLesson.matchingPair => 1,
        TutorialLesson.freeSides => 2,
        TutorialLesson.coveredTiles => 2,
        TutorialLesson.backTiles => 3,
        TutorialLesson.practice => 6,
        TutorialLesson.completed => 6,
      };

  String? get targetUid {
    if (lesson == TutorialLesson.completed) return null;
    if (selectedUid != null) {
      final selected = tiles.firstWhere((tile) => tile.uid == selectedUid);
      for (final tile in tiles) {
        if (!tile.isMatched &&
            tile.uid != selected.uid &&
            tile.def.id == selected.def.id &&
            BoardSolver.isTileFree(tile, tiles)) {
          return tile.uid;
        }
      }
    }
    final pairs = BoardSolver.findAvailableMatchingPairs(tiles);
    return pairs.isEmpty ? null : pairs.first.first.uid;
  }

  bool isFree(TileModel tile) => BoardSolver.isTileFree(tile, tiles);

  bool isCovered(TileModel tile) => tiles.any((other) =>
      !other.isMatched &&
      other.uid != tile.uid &&
      other.layer > tile.layer &&
      (other.row - tile.row).abs() < 2 &&
      (other.col - tile.col).abs() < 2);

  TutorialTapResult tap(String uid) {
    if (lesson == TutorialLesson.completed) return TutorialTapResult.ignored;
    var tile = tiles.firstWhere((item) => item.uid == uid);
    if (tile.isMatched) return TutorialTapResult.ignored;
    if (!isFree(tile)) {
      feedback = isCovered(tile)
          ? 'This tile is covered.'
          : 'This tile is blocked on both sides.';
      _markMismatch(uid);
      notifyListeners();
      return isCovered(tile)
          ? TutorialTapResult.covered
          : TutorialTapResult.blocked;
    }

    feedback = null;
    if (selectedUid == null) {
      selectedUid = uid;
      tiles = [
        for (final item in tiles)
          item.uid == uid
              ? item.copyWith(
                  isSelected: true,
                  isPeeked: item.isCovered,
                  visibility: item.isCovered
                      ? TileVisibility.revealed
                      : item.visibility,
                )
              : item,
      ];
      _syncVisualState();
      notifyListeners();
      return TutorialTapResult.selected;
    }
    if (selectedUid == uid) {
      selectedUid = null;
      tiles = [
        for (final item in tiles)
          item.uid == uid
              ? item.copyWith(
                  isSelected: false,
                  isPeeked: false,
                  visibility:
                      item.isPeeked ? TileVisibility.covered : item.visibility,
                )
              : item,
      ];
      _syncVisualState();
      notifyListeners();
      return TutorialTapResult.ignored;
    }
    final selected = tiles.firstWhere((item) => item.uid == selectedUid);
    if (tile.isCovered) {
      tiles = [
        for (final item in tiles)
          item.uid == uid
              ? item.copyWith(
                  isPeeked: true,
                  visibility: TileVisibility.revealed,
                )
              : item,
      ];
      tile = tiles.firstWhere((item) => item.uid == uid);
    }
    if (selected.def.id != tile.def.id) {
      final oldUid = selectedUid!;
      selectedUid = null;
      feedback = 'These symbols do not match.';
      _markMismatch(oldUid, secondUid: uid);
      notifyListeners();
      return TutorialTapResult.mismatch;
    }

    final matched = {selected.uid, tile.uid};
    selectedUid = null;
    tiles = [
      for (final item in tiles)
        item.copyWith(
          isMatched: item.isMatched || matched.contains(item.uid),
          isSelected: false,
          isHinted: false,
          isMismatched: false,
          isPeeked: matched.contains(item.uid) ? false : item.isPeeked,
        ),
    ];
    pairsMatched++;
    lessonPairsMatched++;
    notifyListeners();
    return TutorialTapResult.matched;
  }

  void clearFeedback() {
    if (feedback == null && !tiles.any((tile) => tile.isMismatched)) return;
    feedback = null;
    tiles = [
      for (final tile in tiles)
        tile.copyWith(
          isMismatched: false,
          isSelected: false,
          isPeeked: false,
          visibility: tile.isPeeked ? TileVisibility.covered : tile.visibility,
        ),
    ];
    notifyListeners();
  }

  bool get lessonComplete => lessonPairsMatched >= lessonPairTarget;

  void advanceLesson() {
    if (!lessonComplete || lesson == TutorialLesson.completed) return;
    lesson = TutorialLesson.values[lesson.index + 1];
    _loadLesson();
    notifyListeners();
  }

  void _markMismatch(String uid, {String? secondUid}) {
    tiles = [
      for (final tile in tiles)
        tile.copyWith(
          isSelected: false,
          isMismatched: tile.uid == uid || tile.uid == secondUid,
        ),
    ];
  }

  void _syncVisualState() {
    final target = targetUid;
    tiles = [
      for (final tile in tiles)
        tile.copyWith(
          isSelected: tile.uid == selectedUid,
          isHinted: tile.uid == target,
          isMismatched: false,
        ),
    ];
  }

  void _loadLesson() {
    selectedUid = null;
    feedback = null;
    lessonPairsMatched = 0;
    tiles = switch (lesson) {
      TutorialLesson.matchingPair => [
          _tile('match-a', kAllTiles[9], 0, 0),
          _tile('match-b', kAllTiles[9], 0, 4),
        ],
      TutorialLesson.freeSides => [
          _tile('edge-a', kAllTiles[14], 0, 0),
          _tile('centre-a', kAllTiles[23], 0, 2),
          _tile('centre-b', kAllTiles[23], 0, 4),
          _tile('edge-b', kAllTiles[14], 0, 6),
        ],
      TutorialLesson.coveredTiles => [
          _tile('lower-a', kAllTiles[38], 1, 1),
          _tile('lower-b', kAllTiles[38], 1, 5),
          _tile('top-a', kAllTiles[9], 0, 1, layer: 1),
          _tile('top-b', kAllTiles[9], 0, 5, layer: 1),
        ],
      TutorialLesson.backTiles => [
          _tile('back-a1', kAllTiles[0], 0, 0,
              visibility: TileVisibility.covered),
          _tile('back-b1', kAllTiles[1], 0, 3),
          _tile('back-c1', kAllTiles[2], 0, 6,
              visibility: TileVisibility.covered),
          _tile('back-a2', kAllTiles[0], 2, 0),
          _tile('back-b2', kAllTiles[1], 2, 3,
              visibility: TileVisibility.covered),
          _tile('back-c2', kAllTiles[2], 2, 6),
        ],
      TutorialLesson.practice => [
          _tile('p-edge-a', kAllTiles[14], 0, 0,
              visibility: TileVisibility.covered),
          _tile('p-block-a', kAllTiles[23], 0, 2),
          _tile('p-block-b', kAllTiles[23], 0, 4),
          _tile('p-edge-b', kAllTiles[14], 0, 6,
              visibility: TileVisibility.covered),
          _tile('p-lower-a', kAllTiles[38], 3, 1),
          _tile('p-lower-b', kAllTiles[38], 3, 5),
          _tile('p-top-a', kAllTiles[9], 2, 1, layer: 1),
          _tile('p-top-b', kAllTiles[9], 2, 5, layer: 1),
          _tile('p-free-a', kAllTiles[0], 5, 0),
          _tile('p-inner-a', kAllTiles[1], 5, 2,
              visibility: TileVisibility.covered),
          _tile('p-inner-b', kAllTiles[1], 5, 4,
              visibility: TileVisibility.covered),
          _tile('p-free-b', kAllTiles[0], 5, 6),
        ],
      TutorialLesson.completed => const [],
    };
    _syncVisualState();
  }

  static TileModel _tile(String uid, TileDefinition def, int row, int col,
          {int layer = 0,
          TileVisibility visibility = TileVisibility.revealed}) =>
      TileModel(
        uid: uid,
        def: def,
        row: row,
        col: col,
        layer: layer,
        visibility: visibility,
      );
}
