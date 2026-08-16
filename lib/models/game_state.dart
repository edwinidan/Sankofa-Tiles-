import '../core/utils/board_solver.dart';
import 'tile_model.dart';

enum GameStatus { idle, playing, paused, won, lost, loadFailed }

enum DifficultyMode { easy, normal, relaxed }

enum MatchAnimationStyle { directCollision, secondHitsFirst }

class PendingMatchAnimation {
  final int id;
  final String firstTileUid;
  final String secondTileUid;
  final MatchAnimationStyle style;

  const PendingMatchAnimation({
    required this.id,
    required this.firstTileUid,
    required this.secondTileUid,
    required this.style,
  });

  bool containsTile(String uid) => uid == firstTileUid || uid == secondTileUid;
}

class GameState {
  final List<TileModel> tiles;
  final GameStatus status;
  final DifficultyMode difficulty;
  final int score;
  final int moves;
  final int hintsUsed;
  final int secondsElapsed;
  final String? selectedTileUid;
  final String? loadError;
  final int levelId;

  final List<({int row, int col, int layer})> pendingScorePops;
  final List<PendingMatchAnimation> pendingMatchAnimations;
  final int currentStreak;
  final int bestStreak;
  final int shufflesUsed;
  final bool recoveryNeeded;
  final bool canUndo;
  final int freeUndosRemaining;
  final String? blockedTileUid;
  final Set<String> blockingTileUids;

  const GameState({
    required this.tiles,
    required this.status,
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.hintsUsed,
    required this.secondsElapsed,
    required this.levelId,
    this.selectedTileUid,
    this.loadError,
    this.pendingScorePops = const [],
    this.pendingMatchAnimations = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.shufflesUsed = 0,
    this.recoveryNeeded = false,
    this.canUndo = false,
    this.freeUndosRemaining = 1,
    this.blockedTileUid,
    this.blockingTileUids = const {},
  });

  int get remainingPairs => tiles.where((t) => !t.isMatched).length ~/ 2;

  bool get hasWon => tiles.isNotEmpty && tiles.every((t) => t.isMatched);

  Set<String> get animatingMatchedTileIds => {
        for (final animation in pendingMatchAnimations) ...[
          animation.firstTileUid,
          animation.secondTileUid,
        ],
      };

  Set<String> get availableTileUids {
    return BoardSolver.getFreeTiles(tiles)
        .where((tile) => tile.isRevealed)
        .map((tile) => tile.uid)
        .toSet();
  }

  Set<String> get freeTileUids {
    return BoardSolver.getFreeTiles(tiles).map((tile) => tile.uid).toSet();
  }

  Set<String> get peekableTileUids {
    return BoardSolver.getFreeTiles(tiles)
        .where((tile) => tile.isCovered)
        .map((tile) => tile.uid)
        .toSet();
  }

  bool get isStuck {
    final remaining = tiles.where((t) => !t.isMatched).length;
    if (peekableTileUids.isNotEmpty) return false;
    final hasRevealedMove = BoardSolver.findAvailableMatchingPairs(tiles).any(
      (pair) => pair.first.isRevealed && pair.second.isRevealed,
    );
    return remaining > 0 && !hasRevealedMove;
  }

  GameState copyWith({
    List<TileModel>? tiles,
    GameStatus? status,
    DifficultyMode? difficulty,
    int? score,
    int? moves,
    int? hintsUsed,
    int? secondsElapsed,
    String? selectedTileUid,
    bool clearSelectedTile = false,
    String? loadError,
    bool clearLoadError = false,
    int? levelId,
    List<({int row, int col, int layer})>? pendingScorePops,
    List<PendingMatchAnimation>? pendingMatchAnimations,
    int? currentStreak,
    int? bestStreak,
    int? shufflesUsed,
    bool? recoveryNeeded,
    bool? canUndo,
    int? freeUndosRemaining,
    String? blockedTileUid,
    bool clearBlockedTile = false,
    Set<String>? blockingTileUids,
  }) =>
      GameState(
        tiles: tiles ?? this.tiles,
        status: status ?? this.status,
        difficulty: difficulty ?? this.difficulty,
        score: score ?? this.score,
        moves: moves ?? this.moves,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        secondsElapsed: secondsElapsed ?? this.secondsElapsed,
        selectedTileUid: clearSelectedTile
            ? null
            : (selectedTileUid ?? this.selectedTileUid),
        loadError: clearLoadError ? null : (loadError ?? this.loadError),
        levelId: levelId ?? this.levelId,
        pendingScorePops: pendingScorePops ?? this.pendingScorePops,
        pendingMatchAnimations:
            pendingMatchAnimations ?? this.pendingMatchAnimations,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        shufflesUsed: shufflesUsed ?? this.shufflesUsed,
        recoveryNeeded: recoveryNeeded ?? this.recoveryNeeded,
        canUndo: canUndo ?? this.canUndo,
        freeUndosRemaining: freeUndosRemaining ?? this.freeUndosRemaining,
        blockedTileUid:
            clearBlockedTile ? null : (blockedTileUid ?? this.blockedTileUid),
        blockingTileUids: clearBlockedTile
            ? const {}
            : (blockingTileUids ?? this.blockingTileUids),
      );

  static GameState initial() => const GameState(
        tiles: [],
        status: GameStatus.idle,
        difficulty: DifficultyMode.normal,
        score: 0,
        moves: 0,
        hintsUsed: 0,
        secondsElapsed: 0,
        loadError: null,
        levelId: 1,
        bestStreak: 0,
        shufflesUsed: 0,
        recoveryNeeded: false,
        canUndo: false,
        freeUndosRemaining: 1,
      );
}
