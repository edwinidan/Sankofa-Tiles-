import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/economy_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/preview/tile_preview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StorageService> _storage(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('collection updates immediately when a new symbol unlocks',
      (tester) async {
    final storage = await _storage({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: const MaterialApp(
          home: TilePreviewScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Undiscovered Symbol'), findsOneWidget);
    expect(find.text('Gye Nyame'), findsNothing);
    expect(find.bySemanticsLabel('Locked Adinkra symbol'), findsWidgets);

    final context = tester.element(find.byType(TilePreviewScreen));
    final container = ProviderScope.containerOf(context);
    final summary =
        await container.read(economyProvider.notifier).grantLevelRewards(
              gameState: _wonLevelOne,
              previousStars: 0,
              wasCompleted: false,
            );
    await tester.pump();

    expect(summary.unlockedSymbols, contains('gye_nyame'));
    expect(find.text('Gye Nyame'), findsOneWidget);
    expect(find.text('Undiscovered Symbol'), findsNothing);
    expect(find.text('Except God'), findsOneWidget);
    expect(find.text('Unlocked at Level 1'), findsOneWidget);
  });
}
