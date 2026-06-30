import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Map<String, Object> _starterCollectionUnlocked() => {
      for (final tileId in kTileIds.take(10))
        'collection_unlocked_$tileId': true,
    };

const _wonLevelOne = GameState(
  tiles: [],
  status: GameStatus.won,
  difficulty: DifficultyMode.normal,
  score: 999999,
  moves: 12,
  hintsUsed: 0,
  secondsElapsed: 30,
  levelId: 1,
  bestStreak: 5,
  shufflesUsed: 0,
);

Widget _resultHarness(StorageService storage) {
  return ProviderScope(
    overrides: [
      audioServiceProvider.overrideWithValue(
        AudioService(sound: false, music: false),
      ),
      storageServiceProvider.overrideWithValue(storage),
    ],
    child: const MaterialApp(
      home: ResultScreen(
        gameState: _wonLevelOne,
        launchConfig: GameLaunchConfig(
          levelId: 1,
          launchMode: GameLaunchMode.normalProgression,
        ),
      ),
    ),
  );
}

Future<void> _dismissUnlockReveals(WidgetTester tester) async {
  while (find.text('NEXT SYMBOL').evaluate().isNotEmpty ||
      find.text('CONTINUE').evaluate().isNotEmpty) {
    final next = find.text('NEXT SYMBOL');
    final continueButton = find.text('CONTINUE');
    await tester.tap(next.evaluate().isNotEmpty ? next : continueButton);
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('new collection unlocks show reveal cards before result actions',
      (tester) async {
    final storage = await _storage({});

    await tester.pumpWidget(_resultHarness(storage));
    await tester.pumpAndSettle();

    expect(find.text('New Symbol Unlocked 1 of 10'), findsOneWidget);
    expect(find.text('Aban'), findsOneWidget);
    expect(find.text('The castle - authority'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'New Adinkra symbol unlocked: Aban. The castle - authority',
      ),
      findsOneWidget,
    );
    await _dismissUnlockReveals(tester);

    expect(
      find.textContaining('10 new symbols added to Collection'),
      findsOneWidget,
    );
    expect(find.textContaining('New symbol:'), findsNothing);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
  });

  testWidgets('already unlocked symbols do not repeat the reveal popup',
      (tester) async {
    final storage = await _storage(_starterCollectionUnlocked());

    await tester.pumpWidget(_resultHarness(storage));
    await tester.pumpAndSettle();

    expect(find.textContaining('New Symbol Unlocked'), findsNothing);
    expect(
        find.textContaining('new symbols added to Collection'), findsNothing);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
  });
}
