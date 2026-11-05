import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/providers/economy_provider.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/preview/tile_preview_screen.dart';
import 'package:sankofa_tiles/screens/result/result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'heritage preview becomes a named collection portrait on unlock',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'campaign_progress_schema_version': 4,
        'highest_completed_level': 20,
      });
      final storage = StorageService();
      await storage.init();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storageServiceProvider.overrideWithValue(storage)],
          child: const MaterialApp(home: TilePreviewScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Next heritage tile: Kwame Nkrumah'), findsOneWidget);
      await tester.tap(find.text('Preview portrait'));
      await tester.pumpAndSettle();
      expect(find.text('Ghana Heritage'), findsOneWidget);
      expect(find.text('Kwame Nkrumah'), findsOneWidget);
      expect(find.textContaining('Unlock to read their story'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TilePreviewScreen)),
      );
      final summary = await container
          .read(economyProvider.notifier)
          .grantLevelRewards(
            gameState: const GameState(
              tiles: [],
              status: GameStatus.won,
              difficulty: DifficultyMode.relaxed,
              score: 999999,
              moves: 12,
              hintsUsed: 0,
              secondsElapsed: 30,
              levelId: 21,
            ),
            previousStars: 0,
            wasCompleted: false,
          );
      await tester.pumpAndSettle();
      expect(summary.unlockedSymbols, contains('kwame_nkrumah'));
      expect(
        find.text('One of Ghana’s Big Six independence leaders.'),
        findsOneWidget,
      );
      expect(find.text('Unlocked at Level 21'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('each heritage portrait renders in its unlock card', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          audioServiceProvider.overrideWithValue(
            AudioService(sound: false, music: false),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(onPressed: () {}, child: const Text('Preview')),
            ),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(TextButton));
    for (final tile in kHeritageTiles) {
      final dismissed = showDebugUnlockRevealPreview(context, tileId: tile.id);
      await tester.pumpAndSettle();
      expect(find.text('Heritage Tile Unlocked'), findsOneWidget);
      expect(find.text(tile.name), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'New Ghana Heritage portrait unlocked: ${tile.name}. ${tile.meaning}',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await dismissed;
    }
  });
}
