import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../core/constants/layout_data.dart';
import '../core/constants/tile_data.dart';
import '../core/constants/level_data.dart';
import '../core/utils/audio_service.dart';
import '../core/utils/board_solver.dart';
import '../core/utils/haptic_service.dart';
import 'settings_provider.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final settings = ref.read(settingsProvider);
  final service = AudioService(
    sound: settings.soundEnabled,
    music: settings.musicEnabled,
  );

  // Keep AudioService in sync whenever the user changes settings.
  ref.listen<SettingsState>(settingsProvider, (prev, next) {
    if (prev?.soundEnabled != next.soundEnabled) {
      service.setSoundEnabled(next.soundEnabled);
    }
    if (prev?.musicEnabled != next.musicEnabled) {
      service.setMusicEnabled(next.musicEnabled);
    }
  });

  ref.onDispose(service.dispose);
  return service;
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final audio = ref.watch(audioServiceProvider);
  return GameNotifier(audio, ref);
});

class GameNotifier extends StateNotifier<GameState> {
  final AudioService _audio;
  final Ref _ref;
  Timer? _timer;

  GameNotifier(this._audio, this._ref) : super(GameState.initial());

  HapticIntensity get _hapticIntensity =>
      _ref.read(settingsProvider).hapticIntensity;

  static const _maxGenerationAttempts = 100;
  static const _maxShuffleAttempts = 80;
  static const _generationSearchNodes = 6000;
  static const _moveSearchNodes = 50000;

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
    if (tileDefs.isEmpty) return;

    // Ensure we have exactly enough pairs
    final int numPairs = levelDef.tileCount ~/ 2;
    final List<TileDefinition> selectedPairs = [];

    // Cycle through available tile definitions to gather the required number of pairs
    for (int i = 0; i < numPairs; i++) {
      selectedPairs.add(tileDefs[i % tileDefs.length]);
    }

    var attemptsUsed = 0;
    var usedFallback = false;
    List<TileModel>? tiles;

    for (var attempt = 1; attempt <= _maxGenerationAttempts; attempt++) {
      attemptsUsed = attempt;
      final candidate = _buildRandomBoard(selectedPairs, levelDef.layout);
      if (BoardSolver.isSolvable(
        candidate,
        maxSearchNodes: _generationSearchNodes,
      )) {
        tiles = candidate;
        break;
      }
    }

    if (tiles == null) {
      usedFallback = true;
      tiles = _buildReverseSolvedBoard(selectedPairs, levelDef.layout);
    }

    final solvable = BoardSolver.isSolvable(tiles);
    debugPrint(
      'Level $levelId solvable=$solvable generationAttempts=$attemptsUsed '
      'fallback=$usedFallback',
    );

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

  List<TileModel> _buildRandomBoard(
    List<TileDefinition> selectedPairs,
    List<TilePosition> layout,
  ) {
    final finalDefs = [...selectedPairs, ...selectedPairs]..shuffle();
    final safeLength = layout.length.clamp(0, finalDefs.length);

    return List.generate(
      safeLength,
      (i) => TileModel(
        def: finalDefs[i],
        row: layout[i].row,
        col: layout[i].col,
        layer: layout[i].layer,
      ),
    );
  }

  List<TileModel> _buildReverseSolvedBoard(
    List<TileDefinition> selectedPairs,
    List<TilePosition> layout,
  ) {
    final seedDef = selectedPairs.first;
    var remaining = [
      for (final position in layout)
        TileModel(
          def: seedDef,
          row: position.row,
          col: position.col,
          layer: position.layer,
        ),
    ];
    final removalOrder = <({int row, int col, int layer})>[];
    final rng = Random();

    while (remaining.isNotEmpty) {
      final freeTiles = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
      if (freeTiles.length < 2) {
        debugPrint('Reverse-solved generation hit a blocked layout.');
        return _buildRandomBoard(selectedPairs, layout);
      }

      final first = freeTiles[0];
      final second = freeTiles[1];
      removalOrder.add((row: first.row, col: first.col, layer: first.layer));
      removalOrder.add((row: second.row, col: second.col, layer: second.layer));

      remaining = remaining
          .map((tile) {
            if (tile.uid == first.uid || tile.uid == second.uid) {
              return tile.copyWith(isMatched: true);
            }
            return tile;
          })
          .where((tile) => !tile.isMatched)
          .toList();
    }

    final shuffledPairs = [...selectedPairs]..shuffle(rng);
    final tiles = <TileModel>[];
    for (var i = 0; i < shuffledPairs.length; i++) {
      final def = shuffledPairs[i];
      final first = removalOrder[i * 2];
      final second = removalOrder[i * 2 + 1];
      tiles
        ..add(
          TileModel(
            def: def,
            row: first.row,
            col: first.col,
            layer: first.layer,
          ),
        )
        ..add(
          TileModel(
            def: def,
            row: second.row,
            col: second.col,
            layer: second.layer,
          ),
        );
    }

    debugPrint('Used reverse-solved board generation.');
    return tiles;
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

    // Mahjong rule: tile must be free (not covered, one side open)
    if (!state.availableTileUids.contains(uid)) return;

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
      final isSafeMove = BoardSolver.isSafeMove(
        state.tiles,
        firstTile,
        secondTile,
        maxSearchNodes: _moveSearchNodes,
      );
      if (!isSafeMove) {
        debugPrint(
          'Blocked unsafe move: ${firstTile.def.id} at '
          '(${firstTile.row}, ${firstTile.col}, ${firstTile.layer}) and '
          '(${secondTile.row}, ${secondTile.col}, ${secondTile.layer})',
        );

        if (_hasSafeMatchingMove(state.tiles)) {
          HapticService.heavyImpact(_hapticIntensity);
          _audio.playNoMatch();

          final deniedTiles = updatedTiles.map((t) {
            if (t.uid == firstUid || t.uid == uid) {
              return t.copyWith(
                isSelected: false,
                isMismatched: true,
              );
            }
            return t;
          }).toList();

          state = state.copyWith(
            tiles: deniedTiles,
            clearSelectedTile: true,
            currentStreak: 0,
          );

          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            final cleared = state.tiles.map((t) {
              if (t.uid == firstUid || t.uid == uid) {
                return t.copyWith(isMismatched: false);
              }
              return t;
            }).toList();
            state = state.copyWith(tiles: cleared);
          });
          return;
        }
      }

      // Match! — double-thud slam-lock
      HapticService.sequence(_hapticIntensity, [0, 80]);
      _audio.playMatch();

      final matchedTiles = updatedTiles.map((t) {
        if (t.uid == firstUid || t.uid == uid) {
          return t.copyWith(
              isMatched: true, isSelected: false, isHinted: false);
        }
        return t;
      }).toList();

      final newStreak = state.currentStreak + 1;
      final streakBonus = newStreak >= 5
          ? 200
          : newStreak == 4
              ? 100
              : newStreak == 3
                  ? 50
                  : 0;

      state = state.copyWith(
        tiles: matchedTiles,
        score: state.score + 100 + streakBonus,
        moves: state.moves + 1,
        clearSelectedTile: true,
        currentStreak: newStreak,
        pendingScorePops: [
          (row: firstTile.row, col: firstTile.col, layer: firstTile.layer),
          (row: secondTile.row, col: secondTile.col, layer: secondTile.layer),
        ],
      );

      _debugFinalTileState();
      _checkWin();
      _checkStuck();

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        state = state.copyWith(pendingScorePops: const []);
      });
    } else {
      // No match — sharp "denied" slam
      HapticService.heavyImpact(_hapticIntensity);
      _audio.playNoMatch();

      final mismatchedTiles = updatedTiles.map((t) {
        if (t.uid == firstUid || t.uid == uid) {
          return t.copyWith(isMismatched: true);
        }
        return t;
      }).toList();

      state = state.copyWith(
        tiles: mismatchedTiles,
        moves: state.moves + 1,
        clearSelectedTile: true,
        currentStreak: 0,
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        final deselected = state.tiles.map((t) {
          if (t.uid == firstUid || t.uid == uid) {
            return t.copyWith(isSelected: false, isMismatched: false);
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

    final pairs = BoardSolver.findAvailableMatchingPairs(state.tiles);
    if (pairs.isEmpty) return;

    TilePair pair = pairs.first;
    for (final candidate in pairs) {
      if (BoardSolver.isSafeMove(
        state.tiles,
        candidate.first,
        candidate.second,
        maxSearchNodes: _moveSearchNodes,
      )) {
        pair = candidate;
        break;
      }
    }

    final isSafe = BoardSolver.isSafeMove(
      state.tiles,
      pair.first,
      pair.second,
      maxSearchNodes: _moveSearchNodes,
    );
    if (!isSafe) {
      debugPrint('Hint fallback selected an available but unsafe move.');
    }

    final hintedIds = {pair.first.uid, pair.second.uid};
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
    if (unmatched.length < 2) return;

    List<TileModel>? solvableShuffle;
    for (var attempt = 1; attempt <= _maxShuffleAttempts; attempt++) {
      // Shuffle (row, col, layer) triples to preserve pyramid structure.
      final positions = unmatched.map((t) => (t.row, t.col, t.layer)).toList()
        ..shuffle();

      final reshuffled = List.generate(unmatched.length, (i) {
        final (row, col, layer) = positions[i];
        return TileModel(
          uid: unmatched[i].uid,
          def: unmatched[i].def,
          row: row,
          col: col,
          layer: layer,
          isSelected: false,
          isHinted: false,
        );
      });

      final candidate = [...matched, ...reshuffled];
      if (BoardSolver.isSolvable(
        candidate,
        maxSearchNodes: _moveSearchNodes,
      )) {
        solvableShuffle = candidate;
        debugPrint('Shuffle produced solvable board in $attempt attempt(s).');
        break;
      }
    }

    if (solvableShuffle == null) {
      debugPrint('Shuffle refused: no solvable board found.');
      return;
    }

    state = state.copyWith(
      tiles: solvableShuffle,
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
    _debugFinalTileState();
    if (state.isStuck) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.lost);
      _audio.playLose();
      _audio.stopBackgroundMusic();
    }
  }

  bool _hasSafeMatchingMove(List<TileModel> tiles) {
    return BoardSolver.findAvailableMatchingPairs(tiles).any(
      (pair) => BoardSolver.isSafeMove(
        tiles,
        pair.first,
        pair.second,
        maxSearchNodes: _moveSearchNodes,
      ),
    );
  }

  void _debugFinalTileState() {
    final remaining = state.tiles.where((t) => !t.isMatched).toList();
    if (remaining.length != 2) return;

    if (!BoardSolver.isFinalPairPlayable(state.tiles)) {
      debugPrint(
        'Invalid final pair: ${remaining[0].def.id} free='
        '${BoardSolver.isTileFree(remaining[0], state.tiles)} and '
        '${remaining[1].def.id} free='
        '${BoardSolver.isTileFree(remaining[1], state.tiles)}',
      );
    }
  }

  List<TileModel> _updateTile(
    String uid, {
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
