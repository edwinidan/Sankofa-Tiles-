import 'game_state.dart';

enum GameLaunchMode {
  normalProgression,
  developerTest,
}

class GameLaunchConfig {
  const GameLaunchConfig({
    required this.levelId,
    required this.launchMode,
    this.resumeSavedGame = false,
  });

  final int levelId;
  final GameLaunchMode launchMode;
  final bool resumeSavedGame;

  bool get isDeveloperTest => launchMode == GameLaunchMode.developerTest;
}

class GameResultConfig {
  const GameResultConfig({
    required this.gameState,
    required this.launchConfig,
  });

  final GameState gameState;
  final GameLaunchConfig launchConfig;
}
