import 'dart:math';

import '../../models/game_state.dart';
import '../constants/level_data.dart';

const int pairScore = 100;
const int completionScore = 500;
const int noHintScore = 250;
const int noShuffleScore = 250;
const int maximumTimeScore = 500;
const int hintScorePenalty = 50;
const int shuffleScorePenalty = 100;

int comboBonusForStreak(int streak) {
  if (streak >= 5) return 100;
  if (streak == 4) return 50;
  if (streak == 3) return 25;
  return 0;
}

int parTimeSecondsForLevel(LevelDefinition level) =>
    max(60, level.pairCount * 8 + level.layerCount * 15);

int completionBonusForState(GameState state, LevelDefinition level) {
  var bonus = completionScore;
  if (state.hintsUsed == 0) bonus += noHintScore;
  if (state.shufflesUsed == 0) bonus += noShuffleScore;

  if (state.difficulty == DifficultyMode.normal) {
    final par = parTimeSecondsForLevel(level);
    final remaining = (par - state.secondsElapsed).clamp(0, par);
    bonus += (maximumTimeScore * remaining / par).round();
  }
  return bonus;
}

/// A clear always earns one star. Additional stars reward clean play, while
/// Normal mode also asks the player to finish within the level's par time.
int starsForCompletedLevel(GameState state, LevelDefinition level) {
  if (state.status != GameStatus.won) return 0;

  final cleanClear = state.hintsUsed == 0 && state.shufflesUsed == 0;
  final mastered = cleanClear &&
      (state.difficulty != DifficultyMode.normal ||
          state.secondsElapsed <= parTimeSecondsForLevel(level));
  if (mastered) return 3;

  if (state.shufflesUsed == 0 && state.hintsUsed <= 1) return 2;
  return 1;
}

List<String> starRequirementsForLevel(
  LevelDefinition level,
  DifficultyMode difficulty,
) =>
    [
      '★ Clear the board',
      '★★ Use no manual shuffle and at most one hint',
      if (difficulty == DifficultyMode.normal)
        '★★★ No hints or shuffles · finish within ${formatClock(parTimeSecondsForLevel(level))}'
      else
        '★★★ No hints or shuffles · no time limit',
    ];

String formatClock(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
