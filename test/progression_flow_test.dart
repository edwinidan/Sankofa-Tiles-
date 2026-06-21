import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/progress_provider.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingProgressStorage {
  int saveCalls = 0;

  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    saveCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new and returning players resolve the next unfinished level', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    final progress = ProgressService(storage);

    expect(progress.nextUnfinishedLevelId, 1);

    await progress.saveLevelResult(1, 0, 0);
    expect(progress.highestCompletedLevel, 1);
    expect(progress.nextUnfinishedLevelId, 2);

    await progress.saveLevelResult(1, 500, 1);
    expect(progress.highestCompletedLevel, 1);
    expect(progress.nextUnfinishedLevelId, 2);
  });

  test('legacy unlocked progress migrates without resetting the player',
      () async {
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 2,
      'highest_unlocked_level': 8,
      'default_difficulty': 'relaxed',
    });
    final storage = StorageService();
    await storage.init();
    final progress = ProgressService(storage);

    expect(progress.highestCompletedLevel, 7);
    expect(progress.nextUnfinishedLevelId, 8);
    expect(storage.isLevelCompleted(7), isTrue);
  });

  test('final level completion is clamped safely', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    final progress = ProgressService(storage);

    await progress.saveLevelResult(50, 10000, 3);

    expect(progress.highestCompletedLevel, 50);
    expect(progress.hasCompletedAllLevels, isTrue);
    expect(progress.nextUnfinishedLevelId, isNull);
  });

  testWidgets('developer result never saves real progression', (tester) async {
    final audio = AudioService(sound: false, music: false);
    final storage = _RecordingProgressStorage();
    const gameState = GameState(
      tiles: [],
      status: GameStatus.won,
      difficulty: DifficultyMode.normal,
      score: 1500,
      moves: 14,
      hintsUsed: 0,
      secondsElapsed: 42,
      levelId: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(audio),
          progressProvider.overrideWithValue(ProgressService(storage)),
        ],
        child: const MaterialApp(
          home: ResultScreen(
            gameState: gameState,
            launchConfig: GameLaunchConfig(
              levelId: 1,
              launchMode: GameLaunchMode.developerTest,
            ),
          ),
        ),
      ),
    );

    expect(storage.saveCalls, 0);
    expect(find.text('BACK TO LEVEL TESTER'), findsOneWidget);
  });
}
