import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/progress_provider.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';

class _RecordingAudioService extends AudioService {
  _RecordingAudioService() : super(sound: false, music: false);

  int stopSfxCalls = 0;

  @override
  Future<void> stopSfx() async {
    stopSfxCalls++;
  }
}

class _RecordingStorage {
  int saveCalls = 0;

  Future<void> saveLevelResult(int levelId, int score, int stars) async {
    saveCalls++;
  }
}

void main() {
  testWidgets('disposing ResultScreen does not access a disposed ref',
      (tester) async {
    final audio = _RecordingAudioService();
    final storage = _RecordingStorage();
    const gameState = GameState(
      tiles: [],
      status: GameStatus.won,
      difficulty: DifficultyMode.relaxed,
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
          home: ResultScreen(gameState: gameState),
        ),
      ),
    );

    expect(storage.saveCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(audio.stopSfxCalls, 1);
    expect(storage.saveCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
