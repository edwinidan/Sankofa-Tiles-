import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/audio_service.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/game_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const audioGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const audioPlayerChannel = MethodChannel('xyz.luan/audioplayers');

  late StorageService storage;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioGlobalChannel, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioPlayerChannel, (_) async => null);
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
  });

  test('unfinished game survives a storage round trip', () async {
    final state = _state([
      _tile('matched-a', kAllTiles[0], 0, isMatched: true),
      _tile('matched-b', kAllTiles[0], 4, isMatched: true),
      _tile('left-a', kAllTiles[1], 8),
      _tile('left-b', kAllTiles[1], 12),
    ]).copyWith(
      score: 450,
      moves: 3,
      shufflesUsed: 1,
      freeUndosRemaining: 0,
    );

    await storage.saveActiveGame(state);

    final summary = storage.getActiveGameSummary();
    final restored = storage.getActiveGame()!.toGameState();
    expect(summary?.levelId, 1);
    expect(summary?.remainingTiles, 2);
    expect(restored.score, 450);
    expect(restored.moves, 3);
    expect(restored.shufflesUsed, 1);
    expect(restored.freeUndosRemaining, 0);
    expect(restored.tiles.where((tile) => tile.isMatched), hasLength(2));
  });

  test('one free undo restores the previous match and score', () {
    final harness = _Harness(storage);
    addTearDown(harness.dispose);
    harness.load([
      _tile('a1', kAllTiles[0], 0),
      _tile('a2', kAllTiles[0], 4),
      _tile('b1', kAllTiles[1], 8),
      _tile('b2', kAllTiles[1], 12),
    ]);

    harness.notifier.selectTile('a1');
    harness.notifier.selectTile('a2');
    expect(harness.state.canUndo, isTrue);
    expect(harness.state.score, 100);

    expect(harness.notifier.undoLastMatch(), isTrue);
    expect(harness.state.score, 0);
    expect(harness.state.moves, 0);
    expect(harness.state.freeUndosRemaining, 0);
    expect(harness.state.tiles.where((tile) => tile.isMatched), isEmpty);
    expect(harness.notifier.undoLastMatch(), isFalse);
  });

  test('any two free copies of the same symbol can match', () {
    final harness = _Harness(storage);
    addTearDown(harness.dispose);
    harness.load([
      _tile('covered-a', kAllTiles[0], 0),
      _tile('covering-a', kAllTiles[0], 0, layer: 1),
      _tile('free-a-1', kAllTiles[0], 4),
      _tile('free-a-2', kAllTiles[0], 8),
      _tile('b1', kAllTiles[1], 12),
      _tile('b2', kAllTiles[1], 16),
    ]);

    // This choice does not preserve the solver's preferred solution because
    // it leaves the other A covered. It is still a valid player match: both
    // selected tiles are free and display the same symbol.
    harness.notifier.selectTile('free-a-1');
    harness.notifier.selectTile('free-a-2');

    expect(harness.tile('free-a-1').isMatched, isTrue);
    expect(harness.tile('free-a-2').isMatched, isTrue);
    expect(harness.state.moves, 1);
    expect(harness.state.score, 100);
  });

  test('blocked tap shakes the covering tile without enlarging it', () {
    final harness = _Harness(storage);
    addTearDown(harness.dispose);
    harness.load([
      _tile('blocked', kAllTiles[0], 0),
      _tile('covering', kAllTiles[1], 0, layer: 1),
      _tile('pair', kAllTiles[0], 6),
    ]);

    harness.notifier.selectTile('blocked');

    expect(harness.state.blockedTileUid, 'blocked');
    expect(harness.state.blockingTileUids, contains('covering'));
    expect(harness.tile('blocked').isMismatched, isTrue);
    expect(harness.tile('covering').isMismatched, isTrue);
    expect(harness.tile('covering').isHinted, isFalse);
  });

  test('blocked tap shakes both immediate side blockers', () {
    final harness = _Harness(storage);
    addTearDown(harness.dispose);
    harness.load([
      _tile('left-blocker', kAllTiles[1], 0),
      _tile('blocked', kAllTiles[0], 2),
      _tile('right-blocker', kAllTiles[2], 4),
    ]);

    harness.notifier.selectTile('blocked');

    expect(
      harness.state.blockingTileUids,
      containsAll(<String>{'left-blocker', 'right-blocker'}),
    );
    expect(harness.tile('blocked').isMismatched, isTrue);
    expect(harness.tile('left-blocker').isMismatched, isTrue);
    expect(harness.tile('right-blocker').isMismatched, isTrue);
    expect(harness.tile('left-blocker').isHinted, isFalse);
    expect(harness.tile('right-blocker').isHinted, isFalse);
  });

  test('dead end requests recovery instead of ending the level', () {
    final harness = _Harness(storage);
    addTearDown(harness.dispose);
    harness.load([
      _tile('a1', kAllTiles[0], 0),
      _tile('a2', kAllTiles[0], 4),
      _tile('b', kAllTiles[1], 8),
      _tile('c', kAllTiles[2], 12),
    ]);

    harness.notifier.selectTile('a1');
    harness.notifier.selectTile('a2');

    expect(harness.state.status, GameStatus.playing);
    expect(harness.state.recoveryNeeded, isTrue);
    expect(harness.state.canUndo, isTrue);
  });
}

class _Harness {
  _Harness(StorageService storage)
      : container = ProviderContainer(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            audioServiceProvider.overrideWithValue(
              AudioService(sound: false, music: false),
            ),
          ],
        );

  final ProviderContainer container;

  GameNotifier get notifier => container.read(gameProvider.notifier);
  GameState get state => container.read(gameProvider);

  void load(List<TileModel> tiles) {
    notifier.replaceStateForTesting(_state(tiles));
  }

  TileModel tile(String uid) =>
      state.tiles.firstWhere((tile) => tile.uid == uid);

  void dispose() => container.dispose();
}

GameState _state(List<TileModel> tiles) {
  return GameState(
    tiles: tiles,
    status: GameStatus.playing,
    difficulty: DifficultyMode.relaxed,
    score: 0,
    moves: 0,
    hintsUsed: 0,
    secondsElapsed: 0,
    levelId: 1,
  );
}

TileModel _tile(
  String uid,
  TileDefinition definition,
  int col, {
  int layer = 0,
  bool isMatched = false,
}) {
  return TileModel(
    uid: uid,
    def: definition,
    row: 0,
    col: col,
    layer: layer,
    isMatched: isMatched,
  );
}
