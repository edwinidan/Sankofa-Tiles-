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
      'collection_unlocked_nea_onnim': true,
    };

const _wonUnlockLevel = GameState(
  tiles: [],
  status: GameStatus.won,
  difficulty: DifficultyMode.normal,
  score: 999999,
  moves: 12,
  hintsUsed: 0,
  secondsElapsed: 30,
  levelId: 4,
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
        gameState: _wonUnlockLevel,
        launchConfig: GameLaunchConfig(
          levelId: 4,
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

    expect(find.text('New Symbol Unlocked'), findsOneWidget);
    expect(find.text('Nea Onnim'), findsOneWidget);
    expect(find.text('He who does not know'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'New Adinkra symbol unlocked: Nea Onnim. He who does not know',
      ),
      findsOneWidget,
    );
    await _dismissUnlockReveals(tester);

    expect(
      find.textContaining('New symbol added to Collection'),
      findsOneWidget,
    );
    expect(find.textContaining('New symbol:'), findsNothing);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
  });

  testWidgets('already unlocked symbols do not repeat the reveal popup',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final storage = await _storage(_starterCollectionUnlocked());

    await tester.pumpWidget(_resultHarness(storage));
    await tester.pumpAndSettle();

    expect(find.textContaining('New Symbol Unlocked'), findsNothing);
    expect(
        find.textContaining('new symbols added to Collection'), findsNothing);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    final logicalScreenHeight =
        tester.getSize(find.byType(Scaffold).first).height;
    expect(
      tester.getBottomRight(find.text('NEXT LEVEL')).dy,
      lessThanOrEqualTo(logicalScreenHeight),
    );
  });
}
