import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/scoring/level_scoring.dart';
import 'package:sankofa_tiles/models/game_state.dart';

GameState _clear({
  DifficultyMode difficulty = DifficultyMode.normal,
  int hints = 0,
  int shuffles = 0,
  int seconds = 0,
}) =>
    GameState(
      tiles: const [],
      status: GameStatus.won,
      difficulty: difficulty,
      score: 1000,
      moves: 10,
      hintsUsed: hints,
      secondsElapsed: seconds,
      levelId: 1,
      shufflesUsed: shuffles,
    );

void main() {
  final level = getLevelById(1)!;

  test('every completed board earns at least one star', () {
    expect(
      starsForCompletedLevel(_clear(hints: 5, shuffles: 2), level),
      1,
    );
  });

  test('two stars reward a clear with limited assistance', () {
    expect(starsForCompletedLevel(_clear(hints: 1), level), 2);
  });

  test('classic mastery requires a clean clear within par time', () {
    final par = parTimeSecondsForLevel(level);
    expect(starsForCompletedLevel(_clear(seconds: par), level), 3);
    expect(starsForCompletedLevel(_clear(seconds: par + 1), level), 2);
  });

  test('relaxed mastery has no time requirement', () {
    expect(
      starsForCompletedLevel(
        _clear(difficulty: DifficultyMode.relaxed, seconds: 99999),
        level,
      ),
      3,
    );
  });

  test('completion bonus rewards a clean, timely classic clear', () {
    final clean = completionBonusForState(_clear(), level);
    final assisted = completionBonusForState(
      _clear(hints: 1, shuffles: 1, seconds: parTimeSecondsForLevel(level)),
      level,
    );
    expect(clean, completionScore + noHintScore + noShuffleScore + 500);
    expect(assisted, completionScore);
  });
}
