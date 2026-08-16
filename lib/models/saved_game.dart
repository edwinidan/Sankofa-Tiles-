import '../core/constants/tile_data.dart';
import 'game_state.dart';
import 'tile_model.dart';

class SavedGameSummary {
  const SavedGameSummary({
    required this.levelId,
    required this.remainingTiles,
  });

  final int levelId;
  final int remainingTiles;
}

class SavedGameSnapshot {
  const SavedGameSnapshot({
    required this.levelId,
    required this.difficulty,
    required this.score,
    required this.moves,
    required this.hintsUsed,
    required this.secondsElapsed,
    required this.currentStreak,
    required this.bestStreak,
    required this.shufflesUsed,
    required this.freeUndosRemaining,
    required this.tiles,
  });

  final int levelId;
  final DifficultyMode difficulty;
  final int score;
  final int moves;
  final int hintsUsed;
  final int secondsElapsed;
  final int currentStreak;
  final int bestStreak;
  final int shufflesUsed;
  final int freeUndosRemaining;
  final List<TileModel> tiles;

  factory SavedGameSnapshot.fromState(GameState state) {
    return SavedGameSnapshot(
      levelId: state.levelId,
      difficulty: state.difficulty,
      score: state.score,
      moves: state.moves,
      hintsUsed: state.hintsUsed,
      secondsElapsed: state.secondsElapsed,
      currentStreak: state.currentStreak,
      bestStreak: state.bestStreak,
      shufflesUsed: state.shufflesUsed,
      freeUndosRemaining: state.freeUndosRemaining,
      tiles: state.tiles,
    );
  }

  GameState toGameState() {
    return GameState(
      tiles: tiles,
      status: GameStatus.playing,
      difficulty: difficulty,
      score: score,
      moves: moves,
      hintsUsed: hintsUsed,
      secondsElapsed: secondsElapsed,
      levelId: levelId,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      shufflesUsed: shufflesUsed,
      freeUndosRemaining: freeUndosRemaining,
    );
  }

  Map<String, Object?> toJson() => {
        'version': 1,
        'levelId': levelId,
        'difficulty': difficulty.name,
        'score': score,
        'moves': moves,
        'hintsUsed': hintsUsed,
        'secondsElapsed': secondsElapsed,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'shufflesUsed': shufflesUsed,
        'freeUndosRemaining': freeUndosRemaining,
        'tiles': [
          for (final tile in tiles)
            {
              'uid': tile.uid,
              'definitionId': tile.def.id,
              'row': tile.row,
              'col': tile.col,
              'layer': tile.layer,
              'isMatched': tile.isMatched,
              'visibility': tile.visibility.name,
            },
        ],
      };

  static SavedGameSnapshot? fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 || json['tiles'] is! List) return null;
    final definitions = {for (final tile in kAllTiles) tile.id: tile};
    final tiles = <TileModel>[];

    for (final rawTile in json['tiles'] as List) {
      if (rawTile is! Map) return null;
      final data = Map<String, dynamic>.from(rawTile);
      final definition = definitions[data['definitionId']];
      if (definition == null) return null;
      tiles.add(
        TileModel(
          uid: data['uid'] as String?,
          def: definition,
          row: data['row'] as int,
          col: data['col'] as int,
          layer: data['layer'] as int? ?? 0,
          isMatched: data['isMatched'] as bool? ?? false,
          visibility: TileVisibility.values.firstWhere(
            (value) => value.name == data['visibility'],
            orElse: () => TileVisibility.revealed,
          ),
        ),
      );
    }

    final difficultyName = json['difficulty'] as String?;
    return SavedGameSnapshot(
      levelId: json['levelId'] as int,
      difficulty: DifficultyMode.values.firstWhere(
        (value) => value.name == difficultyName,
        orElse: () => DifficultyMode.normal,
      ),
      score: json['score'] as int? ?? 0,
      moves: json['moves'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      secondsElapsed: json['secondsElapsed'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      shufflesUsed: json['shufflesUsed'] as int? ?? 0,
      freeUndosRemaining: json['freeUndosRemaining'] as int? ?? 0,
      tiles: tiles,
    );
  }
}
