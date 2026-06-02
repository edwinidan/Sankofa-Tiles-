import '../core/utils/board_solver.dart';
import 'tile_model.dart';

enum GameStatus { idle, playing, paused, won, lost }

enum DifficultyMode { easy, normal, relaxed }

class GameState {
  final List<TileModel> tiles;
  final GameStatus status;
  final DifficultyMode difficulty;
  final int score;
  final int moves;
  final int hintsUsed;
  final int secondsElapsed;
  final String? selectedTileUid;
  final int levelId;

  final List<({int row, int col, int layer})> pendingScorePops;
  final int currentStreak;

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
    this.pendingScorePops = const [],
    this.currentStreak = 0,
  });

  int get remainingPairs => tiles.where((t) => !t.isMatched).length ~/ 2;

  bool get hasWon => tiles.isNotEmpty && tiles.every((t) => t.isMatched);

  Set<String> get availableTileUids {
    return BoardSolver.getFreeTiles(tiles).map((tile) => tile.uid).toSet();
  }

  bool get isStuck {
    final remaining = tiles.where((t) => !t.isMatched).length;
    return remaining > 0 && !BoardSolver.hasAvailableMove(tiles);
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
    int? levelId,
    List<({int row, int col, int layer})>? pendingScorePops,
    int? currentStreak,
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
        levelId: levelId ?? this.levelId,
        pendingScorePops: pendingScorePops ?? this.pendingScorePops,
        currentStreak: currentStreak ?? this.currentStreak,
      );

  static GameState initial() => const GameState(
        tiles: [],
        status: GameStatus.idle,
        difficulty: DifficultyMode.normal,
        score: 0,
        moves: 0,
        hintsUsed: 0,
        secondsElapsed: 0,
        levelId: 1,
      );
}
