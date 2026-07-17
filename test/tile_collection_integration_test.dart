import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
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

    expect(find.text('Gye Nyame'), findsOneWidget);
    expect(find.bySemanticsLabel('Locked Adinkra symbol'), findsWidgets);

    final context = tester.element(find.byType(TilePreviewScreen));
    final container = ProviderScope.containerOf(context);
    final summary =
        await container.read(economyProvider.notifier).grantLevelRewards(
              gameState: _wonUnlockLevel,
              previousStars: 0,
              wasCompleted: false,
            );
    await tester.pump();

    expect(summary.unlockedSymbols, contains('nea_onnim'));
    await tester
        .tap(find.byKey(const ValueKey('tile-preview-thumbnail-nea_onnim')));
    await tester.pumpAndSettle();
    expect(find.text('Nea Onnim'), findsOneWidget);
    expect(find.text('Undiscovered Symbol'), findsNothing);
    expect(find.text('He who does not know'), findsOneWidget);
    expect(find.text('Unlocked at Level 4'), findsOneWidget);
  });

  testWidgets('preview swipes and thumbnail taps share selected tile',
      (tester) async {
    final initialIndex = kAllTiles.indexWhere((tile) => tile.id == 'gye_nyame');
    final nextTile = kAllTiles[initialIndex + 1];
    final storage = await _storage({
      'collection_unlocked_gye_nyame': true,
      'collection_unlocked_${nextTile.id}': true,
    });

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
    await tester.pumpAndSettle();

    expect(find.text('Gye Nyame'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('tile-preview-page-view')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text(nextTile.name), findsOneWidget);
    expect(find.text('Gye Nyame'), findsNothing);

    final gyeNyameThumbnail =
        find.byKey(const ValueKey('tile-preview-thumbnail-gye_nyame'));
    await tester.ensureVisible(gyeNyameThumbnail);
    await tester.pumpAndSettle();
    await tester.tap(gyeNyameThumbnail);
    await tester.pumpAndSettle();

    expect(find.text('Gye Nyame'), findsOneWidget);
    expect(find.text(nextTile.name), findsNothing);
  });
}
