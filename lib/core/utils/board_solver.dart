import '../../models/tile_model.dart';

typedef TilePair = ({TileModel first, TileModel second});

class BoardSolver {
  static const int _tileSpan = 2;

  static List<TileModel> getFreeTiles(List<TileModel> tiles) {
    return tiles.where((tile) => isTileFree(tile, tiles)).toList();
  }

  static bool isTileFree(TileModel tile, List<TileModel> tiles) {
    if (tile.isMatched) return false;

    final unmatched = tiles.where((t) => !t.isMatched).toList();
    final isCovered = unmatched.any(
      (other) =>
          other.uid != tile.uid &&
          other.layer > tile.layer &&
          _overlaps(tile.row, tile.col, other.row, other.col),
    );
    if (isCovered) return false;

    final leftBlocked = unmatched.any(
      (other) =>
          other.uid != tile.uid &&
          other.layer == tile.layer &&
          other.col + _tileSpan == tile.col &&
          _axisOverlaps(tile.row, other.row),
    );
    final rightBlocked = unmatched.any(
      (other) =>
          other.uid != tile.uid &&
          other.layer == tile.layer &&
          other.col == tile.col + _tileSpan &&
          _axisOverlaps(tile.row, other.row),
    );

    return !leftBlocked || !rightBlocked;
  }

  static List<TilePair> findAvailableMatchingPairs(List<TileModel> tiles) {
    final freeTiles = getFreeTiles(tiles);
    final pairs = <TilePair>[];

    for (var i = 0; i < freeTiles.length; i++) {
      for (var j = i + 1; j < freeTiles.length; j++) {
        final first = freeTiles[i];
        final second = freeTiles[j];
        if (first.def.id == second.def.id) {
          pairs.add((first: first, second: second));
        }
      }
    }

    return pairs;
  }

  static bool hasAvailableMove(List<TileModel> tiles) {
    return findAvailableMatchingPairs(tiles).isNotEmpty;
  }

  static bool isSolvable(
    List<TileModel> tiles, {
    int maxSearchNodes = 250000,
  }) {
    final unmatched = tiles.where((t) => !t.isMatched).length;
    if (unmatched == 0) return true;
    if (unmatched.isOdd) return false;

    final memo = <String, bool>{};
    final budget = _SearchBudget(maxSearchNodes);
    return _isSolvable(tiles, memo, budget);
  }

  static bool isSafeMove(
    List<TileModel> tiles,
    TileModel a,
    TileModel b, {
    int maxSearchNodes = 250000,
  }) {
    if (a.uid == b.uid || a.def.id != b.def.id) return false;
    if (!isTileFree(a, tiles) || !isTileFree(b, tiles)) return false;

    return isSolvable(
      _removePair(tiles, a, b),
      maxSearchNodes: maxSearchNodes,
    );
  }

  static bool isFinalPairPlayable(List<TileModel> tiles) {
    final remaining = tiles.where((t) => !t.isMatched).toList();
    if (remaining.length != 2) return true;

    final first = remaining[0];
    final second = remaining[1];
    return first.def.id == second.def.id &&
        isTileFree(first, tiles) &&
        isTileFree(second, tiles);
  }

  static bool _isSolvable(
    List<TileModel> tiles,
    Map<String, bool> memo,
    _SearchBudget budget,
  ) {
    if (!budget.consume()) return false;

    final unmatched = tiles.where((t) => !t.isMatched).toList();
    if (unmatched.isEmpty) return true;
    if (unmatched.length.isOdd) return false;

    if (unmatched.length == 2) {
      final first = unmatched[0];
      final second = unmatched[1];
      return first.def.id == second.def.id &&
          isTileFree(first, tiles) &&
          isTileFree(second, tiles);
    }

    final key = _stateKey(unmatched);
    final cached = memo[key];
    if (cached != null) return cached;

    final pairs = findAvailableMatchingPairs(tiles);
    if (pairs.isEmpty) {
      memo[key] = false;
      return false;
    }

    for (final pair in pairs) {
      final next = _removePair(tiles, pair.first, pair.second);
      if (_isSolvable(next, memo, budget)) {
        memo[key] = true;
        return true;
      }
    }

    memo[key] = false;
    return false;
  }

  static List<TileModel> _removePair(
    List<TileModel> tiles,
    TileModel a,
    TileModel b,
  ) {
    return tiles.map((tile) {
      if (tile.uid == a.uid || tile.uid == b.uid) {
        return tile.copyWith(
            isMatched: true, isSelected: false, isHinted: false);
      }
      return tile;
    }).toList();
  }

  static String _stateKey(List<TileModel> unmatched) {
    final parts = unmatched
        .map((tile) => '${tile.def.id}@${tile.layer},${tile.row},${tile.col}')
        .toList()
      ..sort();
    return parts.join('|');
  }

  static bool _overlaps(int rowA, int colA, int rowB, int colB) {
    return _axisOverlaps(rowA, rowB) && _axisOverlaps(colA, colB);
  }

  static bool _axisOverlaps(int startA, int startB) {
    return startA < startB + _tileSpan && startB < startA + _tileSpan;
  }
}

class _SearchBudget {
  int remaining;

  _SearchBudget(this.remaining);

  bool consume() {
    if (remaining <= 0) return false;
    remaining--;
    return true;
  }
}
