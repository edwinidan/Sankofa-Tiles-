import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const audioGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const audioPlayerChannel = MethodChannel('xyz.luan/audioplayers');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioGlobalChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayerChannel, (_) async => null);
  });

  test('representative levels start quickly with solvable boards', () {
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);

    for (final levelId in [1, 3, 6, 14, 22]) {
      final stopwatch = Stopwatch()..start();
      notifier.startLevel(levelId, DifficultyMode.relaxed);
      stopwatch.stop();

      final state = container.read(gameProvider);
      final level = getLevelById(levelId)!;
      expect(state.status, GameStatus.playing);
      expect(state.levelId, levelId);
      expect(state.tiles, hasLength(level.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(seconds: 1)),
        reason: 'Level $levelId startup regressed',
      );
    }
  });

  test('reverse generation exhaustion fails safely without a board', () {
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
        gameProvider.overrideWith((ref) {
          return GameNotifier(
            ref.watch(audioServiceProvider),
            ref,
            reverseSolvedAttempts: 0,
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    container.read(gameProvider.notifier).startLevel(6, DifficultyMode.relaxed);

    final state = container.read(gameProvider);
    expect(state.status, GameStatus.loadFailed);
    expect(state.tiles, isEmpty);
    expect(state.loadError, isNotEmpty);
    expect(state.hasWon, isFalse);
  });

  test('main progression reaches the full 84 pair tile set', () {
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);

    for (final level in [kLevels.first, kLevels.last]) {
      notifier.startLevel(level.id, DifficultyMode.relaxed);

      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing);
      expect(state.levelId, level.id);
      expect(state.tiles, hasLength(level.tileCount));
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
    }

    expect(kLevels.last.tileCount, 168);
    expect(kLevels.last.tileIds, hasLength(84));
  });
}
