import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/chapter/chapter_complete_screen.dart';
import 'package:sankofa_tiles/screens/home/home_screen.dart';
import 'package:sankofa_tiles/screens/pre_level/pre_level_screen.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';
import 'package:sankofa_tiles/screens/tutorial/tutorial_screen.dart';

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget _scopedApp({
  required StorageService storage,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      audioServiceProvider.overrideWithValue(
        AudioService(sound: false, music: false),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _routerApp({
  required StorageService storage,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      audioServiceProvider.overrideWithValue(
        AudioService(sound: false, music: false),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tutorial completion persists', () async {
    final storage = await _storage({});

    expect(storage.isTutorialComplete(), isFalse);
    await storage.setTutorialComplete();
    expect(storage.isTutorialComplete(), isTrue);
  });

  testWidgets('tutorial skip marks completion', (tester) async {
    final storage = await _storage({});
    final router = GoRouter(
      initialLocation: '/tutorial',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/tutorial',
          builder: (_, __) => const TutorialScreen(),
        ),
      ],
    );

    await tester.pumpWidget(_routerApp(storage: storage, router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(storage.isTutorialComplete(), isTrue);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('home presents the next unfinished level', (tester) async {
    final storage = await _storage({'completed_1': true});

    await tester.pumpWidget(
      _scopedApp(storage: storage, child: const HomeScreen()),
    );

    expect(find.textContaining('Next level: 2'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('locked pre-level cannot be started', (tester) async {
    final storage = await _storage({});

    await tester.pumpWidget(
      _scopedApp(storage: storage, child: const PreLevelScreen(levelId: 2)),
    );

    expect(find.text('Level Locked'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
  });

  testWidgets('completed level can be replayed from pre-level', (tester) async {
    final storage = await _storage({'completed_1': true});

    await tester.pumpWidget(
      _scopedApp(storage: storage, child: const PreLevelScreen(levelId: 1)),
    );

    expect(find.text('First Symbols'), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('chapter-complete result routes to milestone screen',
      (tester) async {
    final storage = await _storage({
      'completed_9': true,
      for (final tileId in tileIdsUnlockedThroughLevel(10))
        'collection_unlocked_$tileId': true,
    });
    final router = GoRouter(
      initialLocation: '/result',
      routes: [
        GoRoute(
          path: '/result',
          builder: (_, __) => const ResultScreen(
            gameState: GameState(
              tiles: [],
              status: GameStatus.won,
              difficulty: DifficultyMode.normal,
              score: 4000,
              moves: 12,
              hintsUsed: 0,
              secondsElapsed: 30,
              levelId: 10,
            ),
            launchConfig: GameLaunchConfig(
              levelId: 10,
              launchMode: GameLaunchMode.normalProgression,
            ),
          ),
        ),
        GoRoute(
          path: '/chapter-complete/:levelId',
          builder: (_, state) => ChapterCompleteScreen(
            completedLevelId:
                int.parse(state.pathParameters['levelId'] ?? '10'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(_routerApp(storage: storage, router: router));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Chapter Complete'), findsOneWidget);
    expect(find.text('First Symbols'), findsOneWidget);
  });
}
