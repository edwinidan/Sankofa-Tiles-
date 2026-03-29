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
  });

  int get remainingPairs =>
      tiles.where((t) => !t.isMatched).length ~/ 2;

  bool get hasWon =>
      tiles.isNotEmpty && tiles.every((t) => t.isMatched);

  Set<String> get availableTileUids {
    final occupied = <(int, int, int)>{};
    for (final t in tiles) {
      if (!t.isMatched) occupied.add((t.row, t.col, t.layer));
    }
    final result = <String>{};
    for (final t in tiles) {
      if (t.isMatched) continue;
      // Rule 1: not covered from above
      if (occupied.contains((t.row, t.col, t.layer + 1))) continue;
      // Rule 2: at least one lateral side is open
      final leftBlocked  = occupied.contains((t.row, t.col - 1, t.layer));
      final rightBlocked = occupied.contains((t.row, t.col + 1, t.layer));
      if (!leftBlocked || !rightBlocked) result.add(t.uid);
    }
    return result;
  }

  bool get isStuck {
    final avail = availableTileUids;
    if (avail.isEmpty) return false;
    final counts = <String, int>{};
    for (final t in tiles) {
      if (avail.contains(t.uid)) counts[t.def.id] = (counts[t.def.id] ?? 0) + 1;
    }
    return counts.values.every((c) => c < 2);
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
  }) => GameState(
    tiles: tiles ?? this.tiles,
    status: status ?? this.status,
    difficulty: difficulty ?? this.difficulty,
    score: score ?? this.score,
    moves: moves ?? this.moves,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    secondsElapsed: secondsElapsed ?? this.secondsElapsed,
    selectedTileUid: clearSelectedTile ? null : (selectedTileUid ?? this.selectedTileUid),
    levelId: levelId ?? this.levelId,
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
