import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/game/widgets/game_control_dock.dart';
import 'package:sankofa_tiles/screens/game/widgets/tile_widget.dart';
import 'package:sankofa_tiles/screens/preview/tile_preview_screen.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';
import 'package:sankofa_tiles/widgets/next_collection_unlock.dart';

Future<StorageService> storageWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Widget scope(StorageService storage, Widget app) => ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        audioServiceProvider
            .overrideWithValue(AudioService(sound: false, music: false)),
      ],
      child: app,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  kRunningTests = true;

  for (final levelId in [1, 20]) {
    testWidgets(
        'Next from level $levelId starts board directly in Relaxed mode',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final storage = await storageWith({
        for (final id in kTileIds) 'collection_unlocked_$id': true,
      });
      GameLaunchConfig? next;
      final router = GoRouter(initialLocation: '/result', routes: [
        GoRoute(
            path: '/result',
            builder: (_, __) => ResultScreen(
                  gameState: GameState.initial().copyWith(
                      levelId: levelId,
                      status: GameStatus.won,
                      difficulty: DifficultyMode.relaxed),
                  launchConfig: GameLaunchConfig(
                      levelId: levelId,
                      launchMode: GameLaunchMode.normalProgression),
                )),
        GoRoute(
            path: '/game/:levelId',
            builder: (_, state) {
              next = state.extra as GameLaunchConfig;
              return const Scaffold(body: Text('Next board'));
            }),
      ]);
      addTearDown(router.dispose);
      await tester
          .pumpWidget(scope(storage, MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(find.text('NEXT LEVEL')).dy, lessThan(640));
      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();
      expect(find.text('Next board'), findsOneWidget);
      expect(next?.levelId, levelId + 1);
      expect(next?.difficulty, DifficultyMode.relaxed);
      expect(storage.isLevelCompleted(levelId), isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  test('next collectible ignores owned rewards and unshipped milestones',
      () async {
    final playable = kTileUnlockMilestones
        .where((m) => m.completedLevel <= kImplementedFinalLevelId)
        .toList();
    final storage = await storageWith({
      for (final m in playable.skip(1)) 'collection_unlocked_${m.tileId}': true,
    });
    final container = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)]);
    addTearDown(container.dispose);
    expect(container.read(nextCollectionUnlockProvider)?.tileId,
        playable.first.tileId);
    await storage.unlockCollectionId(playable.first.tileId);
    // A fresh scope models a subsequent launch with all playable rewards owned.
    final reopened = ProviderContainer(
        overrides: [storageServiceProvider.overrideWithValue(storage)]);
    addTearDown(reopened.dispose);
    expect(reopened.read(nextCollectionUnlockProvider), isNull);
  });

  testWidgets(
      'next symbol preview explains earning it and keeps meaning locked',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final storage = await storageWith({});
    await tester.pumpWidget(
        scope(storage, const MaterialApp(home: TilePreviewScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Next symbol: Nea Onnim'), findsOneWidget);
    expect(find.text('Clear Level 4 to add it to your Collection.'),
        findsOneWidget);
    await tester.tap(find.text('Preview symbol'));
    await tester.pumpAndSettle();
    expect(find.text('Nea Onnim'), findsOneWidget);
    expect(find.textContaining('Unlock to read its meaning'), findsOneWidget);
    expect(find.text('He who does not know'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Undo is visibly labeled and explains why it is unavailable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final storage = await storageWith({});
    await tester.pumpWidget(scope(
        storage, const MaterialApp(home: Scaffold(body: GameControlDock()))));
    final context = tester.element(find.byType(GameControlDock));
    ProviderScope.containerOf(context)
        .read(gameProvider.notifier)
        .replaceStateForTesting(
          GameState.initial().copyWith(status: GameStatus.playing),
        );
    await tester.pump();
    expect(find.text('Undo (free)'), findsOneWidget);
    expect(find.textContaining('Hint '), findsOneWidget);
    expect(find.textContaining('Shuffle '), findsOneWidget);
    await tester.tap(find.byIcon(Icons.undo_rounded));
    await tester.pump();
    expect(find.textContaining('Make a match first'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
