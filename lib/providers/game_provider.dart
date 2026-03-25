import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../core/constants/tile_data.dart';
import '../core/constants/level_data.dart';
import '../core/utils/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final audio = ref.watch(audioServiceProvider);
  return GameNotifier(audio);
});

class GameNotifier extends StateNotifier<GameState> {
  final AudioService _audio;
  Timer? _timer;

  GameNotifier(this._audio) : super(GameState.initial());

  void startLevel(int levelId, DifficultyMode difficulty) {
    _timer?.cancel();

    final levelDef = getLevelById(levelId);
    if (levelDef == null) return;

    // Build tile pairs
    final tileDefs = levelDef.tileIds
        .map((id) {
          try {
            return kAllTiles.firstWhere((t) => t.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<TileDefinition>()
        .toList();

    // Create pairs and shuffle
    final allDefs = [...tileDefs, ...tileDefs];
    allDefs.shuffle();

    // Trim to tileCount
    final count = levelDef.tileCount.clamp(0, allDefs.length);
    final trimmed = allDefs.take(count).toList();

    // Lay out on grid
    final tiles = <TileModel>[];
    for (int i = 0; i < trimmed.length; i++) {
      final row = i ~/ levelDef.boardCols;
      final col = i % levelDef.boardCols;
      tiles.add(TileModel(def: trimmed[i], row: row, col: col));
    }

    state = GameState(
      tiles: tiles,
      status: GameStatus.playing,
      difficulty: difficulty,
      score: 0,
      moves: 0,
      hintsUsed: 0,
      secondsElapsed: 0,
      levelId: levelId,
    );

    if (difficulty == DifficultyMode.normal) {
      _startTimer();
    }

    _audio.startBackgroundMusic();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void tick() {
    if (state.status != GameStatus.playing) return;
    state = state.copyWith(secondsElapsed: state.secondsElapsed + 1);
    // 5-minute limit in normal mode
    if (state.difficulty == DifficultyMode.normal &&
        state.secondsElapsed >= 300) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.lost);
      _audio.playLose();
    }
  }

  void selectTile(String uid) {
    if (state.status != GameStatus.playing) return;

    final tile = state.tiles.firstWhere(
      (t) => t.uid == uid,
      orElse: () => throw StateError('Tile not found'),
    );
    if (tile.isMatched) return;

    _audio.playTileTap();

    // No tile selected yet
    if (state.selectedTileUid == null) {
      state = state.copyWith(
        tiles: _updateTile(uid, isSelected: true),
        selectedTileUid: uid,
      );
      return;
    }

    // Same tile tapped — deselect
    if (state.selectedTileUid == uid) {
      state = state.copyWith(
        tiles: _updateTile(uid, isSelected: false),
        clearSelectedTile: true,
      );
      return;
    }

    // Two different tiles selected
    final firstUid = state.selectedTileUid!;
    final firstTile = state.tiles.firstWhere((t) => t.uid == firstUid);
    final secondTile = tile;

    final updatedTiles = _updateTile(uid, isSelected: true);

    if (firstTile.def.id == secondTile.def.id) {
      // Match!
      final matchedTiles = updatedTiles.map((t) {
        if (t.uid == firstUid || t.uid == uid) {
          return t.copyWith(isMatched: true, isSelected: false, isHinted: false);
        }
        return t;
      }).toList();

      state = state.copyWith(
        tiles: matchedTiles,
        score: state.score + 100,
        moves: state.moves + 1,
        clearSelectedTile: true,
      );

      _audio.playMatch();
      _checkWin();
    } else {
      // No match — show both selected briefly then deselect
      state = state.copyWith(
        tiles: updatedTiles,
        moves: state.moves + 1,
        clearSelectedTile: true,
      );

      _audio.playNoMatch();

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final deselected = state.tiles.map((t) {
          if (t.uid == firstUid || t.uid == uid) {
            return t.copyWith(isSelected: false);
          }
          return t;
        }).toList();
        state = state.copyWith(tiles: deselected);
        _checkStuck();
      });
    }
  }

  void useHint() {
    if (state.status != GameStatus.playing) return;

    // Find first available matching pair
    final unmatched = state.tiles.where((t) => !t.isMatched).toList();
    final counts = <String, List<TileModel>>{};
    for (final t in unmatched) {
      counts.putIfAbsent(t.def.id, () => []).add(t);
    }

    List<TileModel>? pair;
    for (final entry in counts.entries) {
      if (entry.value.length >= 2) {
        pair = entry.value.take(2).toList();
        break;
      }
    }

    if (pair == null) return;

    final hintedIds = {pair[0].uid, pair[1].uid};
    final hintedTiles = state.tiles.map((t) {
      if (hintedIds.contains(t.uid)) return t.copyWith(isHinted: true);
      return t;
    }).toList();

    state = state.copyWith(
      tiles: hintedTiles,
      hintsUsed: state.hintsUsed + 1,
    );

    // Clear hint after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final cleared = state.tiles.map((t) {
        if (hintedIds.contains(t.uid)) return t.copyWith(isHinted: false);
        return t;
      }).toList();
      state = state.copyWith(tiles: cleared);
    });
  }

  void shuffleRemaining() {
    if (state.status != GameStatus.playing) return;

    final unmatched = state.tiles.where((t) => !t.isMatched).toList();
    final matched = state.tiles.where((t) => t.isMatched).toList();

    // Get positions of unmatched tiles
    final positions = unmatched.map((t) => (t.row, t.col)).toList();
    positions.shuffle();

    final reshuffled = List.generate(unmatched.length, (i) {
      final (row, col) = positions[i];
      return TileModel(
        uid: unmatched[i].uid,
        def: unmatched[i].def,
        row: row,
        col: col,
        isSelected: false,
        isHinted: false,
      );
    });

    state = state.copyWith(
      tiles: [...matched, ...reshuffled],
      score: (state.score - 50).clamp(0, 999999),
      clearSelectedTile: true,
    );
  }

  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    _timer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
    if (state.difficulty == DifficultyMode.normal) {
      _startTimer();
    }
  }

  void _checkWin() {
    if (!state.hasWon) return;
    _timer?.cancel();

    int bonus = 0;
    if (state.difficulty == DifficultyMode.normal) {
      final remaining = (300 - state.secondsElapsed).clamp(0, 300);
      bonus = remaining * 2;
    }

    state = state.copyWith(
      status: GameStatus.won,
      score: state.score + bonus,
    );

    _audio.playWin();
    _audio.stopBackgroundMusic();
  }

  void _checkStuck() {
    if (state.status != GameStatus.playing) return;
    if (state.isStuck) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.lost);
      _audio.playLose();
      _audio.stopBackgroundMusic();
    }
  }

  List<TileModel> _updateTile(String uid, {
    bool? isSelected,
    bool? isMatched,
    bool? isHinted,
  }) {
    return state.tiles.map((t) {
      if (t.uid == uid) {
        return t.copyWith(
          isSelected: isSelected,
          isMatched: isMatched,
          isHinted: isHinted,
        );
      }
      return t;
    }).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
