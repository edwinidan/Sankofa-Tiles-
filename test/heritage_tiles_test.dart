import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/level_data.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/constants/tile_unlock_data.dart';
import 'package:sankofa_tiles/core/economy/economy_service.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/board_solver.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/saved_game.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('heritage debuts follow the agreed chapter schedule', () {
    const expected = {
      'kwame_nkrumah': 21,
      'yaa_asantewaa': 41,
      'naa_dedei': 61,
      'j_b_danquah': 81,
      'edward_akufo_addo': 101,
      'ebenezer_ako_adjei': 121,
      'emmanuel_obetsebi_lamptey': 141,
      'william_ofori_atta': 161,
    };
    expect(kHeritageIntroductions, expected);
    for (final entry in expected.entries) {
      expect(heritageTileIdForLevel(entry.value), entry.key);
      expect(unlockLevelForTileId(entry.key), entry.value);
      expect(tileIdsUnlockedAtLevel(entry.value), contains(entry.key));
      expect(
        tileIdsUnlockedThroughLevel(entry.value - 1),
        isNot(contains(entry.key)),
      );
    }
  });

  test(
    'all campaign decks keep their size with one eligible heritage pair',
    () {
      final appearances = <String, int>{};
      for (final level in kLevels) {
        final ids = level.tileIds;
        final counts = level.symbolCopyCounts;
        expect(ids, hasLength(level.symbolPoolSize));
        expect(ids.toSet(), hasLength(ids.length));
        expect(counts, hasLength(ids.length));
        expect(counts.reduce((a, b) => a + b), level.tileCount);
        expect(counts.every((count) => count >= 2 && count.isEven), isTrue);
        final heritage = ids.where(kHeritageIntroductions.containsKey).toList();
        final isHeritageBoard = level.id >= 21 && (level.id - 21) % 5 == 0;
        expect(
          heritage,
          hasLength(isHeritageBoard ? 1 : 0),
          reason: 'Level ${level.id}',
        );
        if (heritage.isEmpty) {
          expect(
            counts,
            level.symbolPlan.copyCountsForTileCount(level.tileCount),
          );
        } else {
          final id = heritage.single;
          expect(kHeritageIntroductions[id], lessThanOrEqualTo(level.id));
          expect(counts[ids.indexOf(id)], 2, reason: 'Level ${level.id}');
          appearances[id] = (appearances[id] ?? 0) + 1;
        }
      }
      expect(appearances.keys.toSet(), kHeritageIntroductions.keys.toSet());
      expect(appearances.values.every((count) => count > 1), isTrue);
    },
  );

  test(
    'all heritage images decode from the bundle at game tile size',
    () async {
      for (final tile in kHeritageTiles) {
        expect(tile.isHeritage, isTrue);
        final bytes = await rootBundle.load(tile.assetPath!);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
          targetWidth: 64,
          targetHeight: 85,
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 64);
        expect(frame.image.height, 85);
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test('heritage boards start solvable and their portraits survive saving', () {
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (_) async => null);
    }
    final container = ProviderContainer(
      overrides: [
        audioServiceProvider.overrideWithValue(
          AudioService(sound: false, music: false),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    for (final levelId in [
      ...kHeritageIntroductions.values,
      166,
      201,
      281,
      361,
      376,
    ]) {
      notifier.startLevel(
        levelId,
        DifficultyMode.relaxed,
        isDeveloperTest: true,
      );
      final state = container.read(gameProvider);
      expect(state.status, GameStatus.playing, reason: 'Level $levelId');
      expect(BoardSolver.isSolvable(state.tiles), isTrue);
      final portraits = state.tiles.where((tile) => tile.def.isHeritage);
      expect(portraits, hasLength(2));
      expect(portraits.map((tile) => tile.def.id).toSet(), hasLength(1));
      final restored = SavedGameSnapshot.fromJson(
        SavedGameSnapshot.fromState(state).toJson(),
      );
      expect(restored, isNotNull);
      expect(
        restored!.tiles.map((tile) => tile.def.id),
        state.tiles.map((tile) => tile.def.id),
      );
    }
  });

  test('shared debut level grants both rewards once', () async {
    SharedPreferences.setMockInitialValues({
      'campaign_progress_schema_version': 4,
      'highest_completed_level': 40,
    });
    final storage = StorageService();
    await storage.init();
    final economy = EconomyService(storage);
    economy.loadState();
    const won = GameState(
      tiles: [],
      status: GameStatus.won,
      difficulty: DifficultyMode.relaxed,
      score: 999999,
      moves: 10,
      hintsUsed: 0,
      secondsElapsed: 30,
      levelId: 41,
    );
    expect(tileIdsUnlockedAtLevel(41), hasLength(2));
    final first = await economy.grantLevelRewards(
      gameState: won,
      previousStars: 0,
      wasCompleted: false,
    );
    expect(first.unlockedSymbols, unorderedEquals(tileIdsUnlockedAtLevel(41)));
    expect(first.unlockedSymbols, contains('yaa_asantewaa'));
    final replay = await economy.grantLevelRewards(
      gameState: won,
      previousStars: 3,
      wasCompleted: true,
    );
    expect(replay.unlockedSymbols, isEmpty);
  });

  test(
    'existing progress gains eligible portraits without changing earnings',
    () async {
      SharedPreferences.setMockInitialValues({
        'campaign_progress_schema_version': 4,
        'highest_completed_level': 80,
        'economy_cowries': 777,
        'collection_unlocked_woforo_dua_pa_a': true,
      });
      final storage = StorageService();
      await storage.init();
      final economy = EconomyService(storage);
      final unlocked = economy.loadState().unlockedCollectionIds;
      expect(
        unlocked,
        containsAll(['kwame_nkrumah', 'yaa_asantewaa', 'naa_dedei']),
      );
      expect(unlocked, isNot(contains('j_b_danquah')));
      expect(unlocked, contains('woforo_dua_pa_a'));
      expect(economy.loadState().unlockedCollectionIds, unlocked);
      expect(storage.getCowries(), 777);
      expect(storage.getHighestCompletedLevel(), 80);
    },
  );
}
