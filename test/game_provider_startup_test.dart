import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/campaign_validator.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('campaign structure is internally consistent', () {
    final issues = validateCampaignStructure();
    expect(
      issues,
      isEmpty,
      reason: issues.map((issue) => issue.toString()).join('\n'),
    );
    expect(kLevels, hasLength(50));
    expect(kLevels.map((level) => level.id),
        orderedEquals(List.generate(50, (i) => i + 1)));
    expect(kLevels.where((level) => level.layerCount <= 1),
        hasLength(lessThanOrEqualTo(2)));
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

    for (final levelId in [1, 5, 10, 18, 25, 35, 42, 50]) {
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

  test('all campaign levels generate without exceptions', () {
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    final stopwatch = Stopwatch()..start();

    for (final level in kLevels) {
      notifier.startLevel(level.id, DifficultyMode.relaxed);
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing, reason: 'Level ${level.id}');
      expect(
        state.tiles,
        hasLength(level.tileCount),
        reason: 'Level ${level.id}',
      );
      expect(
        BoardSolver.isSolvable(state.tiles),
        isTrue,
        reason: 'Level ${level.id}',
      );
    }

    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
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

    container
        .read(gameProvider.notifier)
        .startLevel(10, DifficultyMode.relaxed);

    final state = container.read(gameProvider);
    expect(state.status, GameStatus.loadFailed);
    expect(state.tiles, isEmpty);
    expect(state.loadError, isNotEmpty);
    expect(state.hasWon, isFalse);
  });

  test('main progression reaches advanced symbols without oversized flat grids',
      () {
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

    expect(kLevels.last.tileCount, lessThanOrEqualTo(130));
    expect(kLevels.last.layerCount, greaterThanOrEqualTo(5));
    expect(kLevels.last.tileIds, contains('woforo_dua_pa_a'));
    expect(kLevels.where((level) => level.id >= 31 && level.layerCount == 1),
        isEmpty);
  });

  test('campaign progress migration preserves existing level results',
      () async {
    SharedPreferences.setMockInitialValues({
      'best_score_1': 1500,
      'stars_1': 3,
      'best_score_25': 9000,
      'stars_25': 2,
    });

    final storage = StorageService();
    await storage.init();

    expect(storage.getBestScore(1), 1500);
    expect(storage.getStars(1), 3);
    expect(storage.getBestScore(25), 9000);
    expect(storage.getStars(25), 2);
    expect(storage.isLevelUnlocked(26), isTrue);
    expect(storage.isLevelUnlocked(50), isFalse);
  });
}
