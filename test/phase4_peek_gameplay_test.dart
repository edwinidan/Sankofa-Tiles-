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

  test('covered free tile peeks and hides again when deselected', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0, visibility: TileVisibility.covered),
      _tile('a2', kAllTiles[0], 4),
    ]);

    harness.notifier.selectTile('a1');
    var tile = harness.tile('a1');
    expect(tile.isSelected, isTrue);
    expect(tile.isPeeked, isTrue);
    expect(tile.visibility, TileVisibility.revealed);

    harness.notifier.selectTile('a1');
    tile = harness.tile('a1');
    expect(tile.isSelected, isFalse);
    expect(tile.isPeeked, isFalse);
    expect(tile.visibility, TileVisibility.covered);
    expect(harness.state.selectedTileUid, isNull);
  });

  test('covered tile can be peeked and matched with a revealed pair', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0),
      _tile('a2', kAllTiles[0], 4, visibility: TileVisibility.covered),
    ]);

    harness.notifier.selectTile('a1');
    harness.notifier.selectTile('a2');

    expect(harness.tile('a1').isMatched, isTrue);
    expect(harness.tile('a2').isMatched, isTrue);
    expect(harness.tile('a2').isPeeked, isFalse);
    expect(harness.state.status, GameStatus.won);
  });

  testWidgets('wrong peeked pair returns covered after mismatch feedback',
      (tester) async {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0, visibility: TileVisibility.covered),
      _tile('b1', kAllTiles[1], 4),
      _tile('a2', kAllTiles[0], 8),
      _tile('b2', kAllTiles[1], 12),
    ]);

    harness.notifier.selectTile('a1');
    harness.notifier.selectTile('b1');

    expect(harness.tile('a1').isMismatched, isTrue);
    expect(harness.tile('a1').visibility, TileVisibility.revealed);

    await tester.pump(const Duration(milliseconds: 650));

    expect(harness.tile('a1').isMismatched, isFalse);
    expect(harness.tile('a1').isPeeked, isFalse);
    expect(harness.tile('a1').visibility, TileVisibility.covered);
    expect(harness.tile('b1').isSelected, isFalse);
    expect(harness.state.moves, 1);
  });

  test('blocked covered tile cannot be peeked until it is free', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('blocked', kAllTiles[0], 0, visibility: TileVisibility.covered),
      _tile('covering', kAllTiles[1], 0, layer: 1),
      _tile('pair', kAllTiles[0], 4),
    ]);

    harness.notifier.selectTile('blocked');

    expect(harness.tile('blocked').isPeeked, isFalse);
    expect(harness.tile('blocked').visibility, TileVisibility.covered);
    expect(harness.state.selectedTileUid, isNull);
  });

  test('hint prefers revealed available pairs before covered clues', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0),
      _tile('a2', kAllTiles[0], 4),
      _tile('b1', kAllTiles[1], 8, visibility: TileVisibility.covered),
      _tile('b2', kAllTiles[1], 12, visibility: TileVisibility.covered),
    ]);

    expect(harness.notifier.useHint(), isTrue);

    expect(harness.tile('a1').isHinted, isTrue);
    expect(harness.tile('a2').isHinted, isTrue);
    expect(harness.tile('b1').isHinted, isFalse);
    expect(harness.tile('b1').visibility, TileVisibility.covered);
    expect(harness.state.hintsUsed, 1);
  });

  test('hint can clue peekable covered tiles without revealing them', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0, visibility: TileVisibility.covered),
      _tile('a2', kAllTiles[0], 4, visibility: TileVisibility.covered),
    ]);

    expect(harness.notifier.useHint(), isTrue);

    expect(harness.tile('a1').isHinted, isTrue);
    expect(harness.tile('a2').isHinted, isTrue);
    expect(harness.tile('a1').isPeeked, isFalse);
    expect(harness.tile('a1').visibility, TileVisibility.covered);
    expect(harness.state.hintsUsed, 1);
  });

  test('shuffle preserves covered identity and resets temporary peeks', () {
    final harness = _GameHarness(storage);
    addTearDown(harness.dispose);

    harness.load([
      _tile('a1', kAllTiles[0], 0),
      _tile('a2', kAllTiles[0], 4),
      _tile('b1', kAllTiles[1], 8, visibility: TileVisibility.covered),
      _tile('b2', kAllTiles[1], 12, visibility: TileVisibility.covered),
    ]);
    harness.notifier.selectTile('b1');

    expect(harness.notifier.shuffleRemaining(), isTrue);

    expect(harness.tile('a1').visibility, TileVisibility.revealed);
    expect(harness.tile('a2').visibility, TileVisibility.revealed);
    expect(harness.tile('b1').visibility, TileVisibility.covered);
    expect(harness.tile('b2').visibility, TileVisibility.covered);
    expect(harness.tile('b1').isPeeked, isFalse);
    expect(harness.state.selectedTileUid, isNull);
  });

  test('covered peekable tiles prevent no-move stuck state', () {
    final state = _state([
      _tile('a1', kAllTiles[0], 0, visibility: TileVisibility.covered),
      _tile('a2', kAllTiles[0], 4, visibility: TileVisibility.covered),
    ]);

    expect(state.availableTileUids, isEmpty);
    expect(state.peekableTileUids, containsAll(['a1', 'a2']));
    expect(state.isStuck, isFalse);
  });
}

class _GameHarness {
  _GameHarness(StorageService storage)
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

  TileModel tile(String uid) {
    return state.tiles.firstWhere((tile) => tile.uid == uid);
  }

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
  TileDefinition def,
  int col, {
  int layer = 0,
  TileVisibility visibility = TileVisibility.revealed,
}) {
  return TileModel(
    uid: uid,
    def: def,
    row: 0,
    col: col,
    layer: layer,
    visibility: visibility,
  );
}
