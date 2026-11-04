import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/router/app_router.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/game/game_screen.dart';
import 'package:sankofa_tiles/screens/game/widgets/tile_widget.dart';
import 'package:sankofa_tiles/screens/home/home_screen.dart';
import 'package:sankofa_tiles/screens/pre_level/pre_level_screen.dart';

class _SilentAudio extends AudioService {
  _SilentAudio() : super(sound: false, music: false);
  @override
  Future<void> startBackgroundMusic() async {}
  @override
  Future<void> stopBackgroundMusic() async {}
  @override
  Future<void> stopSfx() async {}
}

Future<StorageService> _storage({String style = 'classic'}) async {
  SharedPreferences.setMockInitialValues({
    'tutorial_complete': true,
    'first_session_completed': true,
    'campaign_progress_schema_version': 4,
    'preferred_play_style': style,
    'sound_enabled': false,
    'music_enabled': false,
    'haptic_intensity': 'off',
    'highest_completed_level': 8,
    for (var i = 1; i <= 8; i++) 'completed_$i': true,
    for (final id in kTileIds) 'collection_unlocked_$id': true,
  });
  final storage = StorageService();
  await storage.init();
  return storage;
}

typedef _Harness = ({GoRouter router, ProviderContainer container});
Future<_Harness> _mount(WidgetTester tester, StorageService storage,
    {String route = '/'}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = ProviderContainer(overrides: [
    storageServiceProvider.overrideWithValue(storage),
    audioServiceProvider.overrideWithValue(_SilentAudio()),
  ]);
  final router = createAppRouter(storage, initialLocation: route);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
  });
  return (router: router, container: container);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  kRunningTests = true;

  test('new launch configurations default to Relaxed', () {
    const config = GameLaunchConfig(
      levelId: 2,
      launchMode: GameLaunchMode.normalProgression,
    );
    expect(config.difficulty, DifficultyMode.relaxed);
  });

  for (final route in ['/game/2', '/level/2']) {
    testWidgets(
        '$route opens the requested board in Relaxed despite an old Classic preference',
        (tester) async {
      final app = await _mount(tester, await _storage(), route: route);
      expect(app.router.routeInformationProvider.value.uri.path, '/game/2');
      expect(find.byType(PreLevelScreen), findsNothing);
      expect(find.byType(GameScreen), findsOneWidget);
      final state = app.container.read(gameProvider);
      expect(state.levelId, 2,
          reason:
              'Must replay selected Level 2, rather than next unfinished Level 9');
      expect(state.difficulty, DifficultyMode.relaxed);
      expect(state.status, GameStatus.playing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Home starts its board immediately without a mode selector',
      (tester) async {
    final storage = await _storage();
    final app = await _mount(tester, storage);
    expect(find.text('Classic'), findsNothing);
    expect(find.text('Relaxed'), findsNothing);
    await _tap(tester, find.text('CONTINUE'));
    expect(tester.widget<GameScreen>(find.byType(GameScreen)).levelId, 9);
    expect(app.container.read(gameProvider).difficulty, DifficultyMode.relaxed);
    expect(find.byType(PreLevelScreen), findsNothing);
  });

  testWidgets(
      'Journey opens completed levels in Relaxed without a mode selector',
      (tester) async {
    final app = await _mount(tester, await _storage(style: 'relaxed'),
        route: '/journey');
    expect(find.text('Classic'), findsNothing);
    expect(find.text('Relaxed'), findsNothing);
    await _tap(tester, find.text('2'));
    expect(tester.widget<GameScreen>(find.byType(GameScreen)).levelId, 2);
    expect(app.container.read(gameProvider).difficulty, DifficultyMode.relaxed);
  });

  testWidgets('locked direct links do not open a game', (tester) async {
    await _mount(tester, await _storage(), route: '/game/10');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
  });

  testWidgets('Resume preserves a saved Classic board and its progress',
      (tester) async {
    final storage = await _storage(style: 'relaxed');
    await storage.saveActiveGame(GameState.initial().copyWith(
      levelId: 2,
      difficulty: DifficultyMode.normal,
      status: GameStatus.playing,
      score: 500,
      moves: 7,
      tiles: [TileModel(uid: 'saved', def: kAllTiles.first, row: 0, col: 0)],
    ));
    final app = await _mount(tester, storage);
    await _tap(tester, find.text('RESUME'));
    final state = app.container.read(gameProvider);
    expect(state.levelId, 2);
    expect(state.difficulty, DifficultyMode.normal);
    expect(state.moves, 7);
    expect(state.score, 500);
    expect(state.tiles.single.uid, 'saved');
  });

  for (final result in [
    (GameStatus.won, 'REPLAY'),
    (GameStatus.lost, 'RETRY')
  ]) {
    testWidgets('${result.$2} starts a fresh Relaxed board after Classic',
        (tester) async {
      final storage = await _storage();
      final app = await _mount(tester, storage);
      app.router.go('/result',
          extra: GameResultConfig(
            gameState: GameState.initial().copyWith(
              levelId: 2,
              status: result.$1,
              difficulty: DifficultyMode.normal,
              score: 1500,
            ),
            launchConfig: const GameLaunchConfig(
              levelId: 2,
              launchMode: GameLaunchMode.normalProgression,
              difficulty: DifficultyMode.normal,
            ),
          ));
      await tester.pumpAndSettle();
      await _tap(tester, find.text(result.$2));
      expect(find.byType(PreLevelScreen), findsNothing);
      final state = app.container.read(gameProvider);
      expect(state.levelId, 2);
      expect(state.difficulty, DifficultyMode.relaxed,
          reason: 'Replay/retry moves a finished Classic game to Relaxed');
      expect(state.status, GameStatus.playing);
    });
  }

  testWidgets('game settings pause and resume without a mode switch',
      (tester) async {
    final storage = await _storage();
    final app = await _mount(tester, storage, route: '/game/2');
    final notifier = app.container.read(gameProvider.notifier);
    notifier.replaceStateForTesting(
        app.container.read(gameProvider).copyWith(score: 500, moves: 3));
    await tester.pump();
    await _tap(tester, find.byTooltip('Settings'));
    expect(app.container.read(gameProvider).status, GameStatus.paused);
    expect(find.text('Classic'), findsNothing);
    expect(find.text('Relaxed'), findsNothing);
    expect(find.text('Restart in this mode'), findsNothing);
    expect(find.text('Sound Effects'), findsOneWidget);
    await _tap(tester, find.byTooltip('Close'));
    final state = app.container.read(gameProvider);
    expect(state.status, GameStatus.playing);
    expect(state.difficulty, DifficultyMode.relaxed);
    expect(state.moves, 3);
    expect(state.score, 500);
  });
}
