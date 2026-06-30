import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../core/constants/layout_data.dart';
import '../core/constants/tile_data.dart';
import '../core/constants/level_data.dart';
import '../core/utils/analytics_service.dart';
import '../core/utils/audio_service.dart';
import '../core/utils/board_solver.dart';
import '../core/utils/crash_reporting_service.dart';
import '../core/utils/haptic_service.dart';
import 'settings_provider.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final settings = ref.read(settingsProvider);
  final service = AudioService(
    sound: settings.soundEnabled,
    music: settings.musicEnabled,
    musicVolume: settings.musicVolume,
  );

  // Keep AudioService in sync whenever the user changes settings.
  ref.listen<SettingsState>(settingsProvider, (prev, next) {
    if (prev?.soundEnabled != next.soundEnabled) {
      service.setSoundEnabled(next.soundEnabled);
    }
    if (prev?.musicEnabled != next.musicEnabled) {
      service.setMusicEnabled(next.musicEnabled);
    }
    if (prev?.musicVolume != next.musicVolume) {
      service.setMusicVolume(next.musicVolume);
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
  final int _reverseSolvedAttempts;
  bool _isDeveloperTest = false;
  int _matchAnimationSequence = 0;

  GameNotifier(
    this._audio,
    this._ref, {
    int reverseSolvedAttempts = _maxReverseSolvedAttempts,
  })  : _reverseSolvedAttempts = reverseSolvedAttempts,
        super(GameState.initial());

  @visibleForTesting
  void replaceStateForTesting(GameState testState) {
    state = testState;
  }

  HapticIntensity get _hapticIntensity =>
      _ref.read(settingsProvider).hapticIntensity;

  static const _maxGenerationAttempts = 12;
  static const _maxReverseSolvedAttempts = 100;
  static const _reverseSolvedTileThreshold = 40;
  static const _maxShuffleAttempts = 80;
  static const _generationSearchNodes = 6000;
  static const _moveSearchNodes = 50000;

  void startLevel(
    int levelId,
    DifficultyMode difficulty, {
    bool isDeveloperTest = false,
  }) {
    _isDeveloperTest = isDeveloperTest;
    final totalStopwatch = Stopwatch()..start();
    debugPrint('[LEVEL_LOAD] level=$levelId start');

    final levelDef = getLevelById(levelId);
    if (levelDef == null) return;

    // Build the configured symbol multiset for this level.
    final tileModelStopwatch = Stopwatch()..start();
    final symbolDeck = _buildSymbolDeck(levelDef);
    if (symbolDeck.isEmpty || symbolDeck.length != levelDef.tileCount) {
      _handleLevelLoadFailure(levelId, difficulty, totalStopwatch);
      return;
    }
    debugPrint(
      '[LEVEL_LOAD] level=$levelId prepareTileDefinitions took '
      '${tileModelStopwatch.elapsedMilliseconds} ms',
    );

    var attemptsUsed = 0;
    var usedFallback = false;
    var generationStrategy = 'random';
    var solverMilliseconds = 0;
    var solverNodes = 0;
    List<TileModel>? tiles;

    final generationStopwatch = Stopwatch()..start();
    try {
      if (levelDef.tileCount >= _reverseSolvedTileThreshold) {
        generationStrategy = 'reverseSolved';
        tiles = _buildReverseSolvedBoard(symbolDeck, levelDef.layout);
      } else {
        for (var attempt = 1; attempt <= _maxGenerationAttempts; attempt++) {
          attemptsUsed = attempt;
          final candidate = _buildRandomBoard(symbolDeck, levelDef.layout);
          final profile = BoardSolver.profileSolvability(
            candidate,
            maxSearchNodes: _generationSearchNodes,
          );
          solverMilliseconds += profile.elapsed.inMilliseconds;
          solverNodes += profile.nodesVisited;
          if (profile.isSolvable) {
            tiles = candidate;
            break;
          }
        }

        if (tiles == null) {
          usedFallback = true;
          generationStrategy = 'reverseSolved';
          tiles = _buildReverseSolvedBoard(symbolDeck, levelDef.layout);
        }
      }

      generationStopwatch.stop();
      debugPrint(
        '[LEVEL_LOAD] level=$levelId generateBoard took '
        '${generationStopwatch.elapsedMilliseconds} ms',
      );
      debugPrint(
        '[LEVEL_LOAD] level=$levelId solvability checks took '
        '$solverMilliseconds ms nodes=$solverNodes attempts=$attemptsUsed '
        'strategy=$generationStrategy fallback=$usedFallback',
      );

      if (tiles == null) {
        _handleLevelLoadFailure(levelId, difficulty, totalStopwatch);
        return;
      }

      final finalProfile = BoardSolver.profileSolvability(tiles);
      debugPrint(
        '[LEVEL_LOAD] level=$levelId final solvability check took '
        '${finalProfile.elapsed.inMilliseconds} ms '
        'nodes=${finalProfile.nodesVisited} solvable=${finalProfile.isSolvable}',
      );
      if (!finalProfile.isSolvable) {
        _handleLevelLoadFailure(levelId, difficulty, totalStopwatch);
        return;
      }

      final preparedTiles = _applyInitialPeekCoverage(tiles, levelDef);

      final stateStopwatch = Stopwatch()..start();
      state = GameState(
        tiles: preparedTiles,
        status: GameStatus.playing,
        difficulty: difficulty,
        score: 0,
        moves: 0,
        hintsUsed: 0,
        secondsElapsed: 0,
        levelId: levelId,
      );
      if (!_isDeveloperTest) {
        AnalyticsService.logLevelStarted(levelId, difficulty.name);
      }
      stateStopwatch.stop();
      debugPrint(
        '[LEVEL_LOAD] level=$levelId state update took '
        '${stateStopwatch.elapsedMilliseconds} ms',
      );

      _audio.startBackgroundMusic();
      totalStopwatch.stop();
      debugPrint(
        '[LEVEL_LOAD] level=$levelId total took '
        '${totalStopwatch.elapsedMilliseconds} ms',
      );
    } catch (error, stackTrace) {
      debugPrint('[LEVEL_LOAD] level=$levelId failed: $error\n$stackTrace');
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Unexpected level startup exception',
      );
      _handleLevelLoadFailure(levelId, difficulty, totalStopwatch);
    }
  }

  void _handleLevelLoadFailure(
    int levelId,
    DifficultyMode difficulty,
    Stopwatch totalStopwatch,
  ) {
    totalStopwatch.stop();
    debugPrint(
      '[LEVEL_LOAD] level=$levelId failed safely after '
      '${totalStopwatch.elapsedMilliseconds} ms',
    );
    if (!_isDeveloperTest) {
      AnalyticsService.logLevelFailed(
        levelId,
        difficulty.name,
        0,
        'board_load_failed',
      );
    }
    CrashReportingService.recordNonFatal(
      StateError('Board generation failed for level $levelId'),
      StackTrace.current,
      reason: 'Board generation load failure',
    );
    state = GameState(
      tiles: const [],
      status: GameStatus.loadFailed,
      difficulty: difficulty,
      score: 0,
      moves: 0,
      hintsUsed: 0,
      secondsElapsed: 0,
      levelId: levelId,
      loadError: 'We could not prepare this board. Please try again.',
    );
  }

  List<TileDefinition> _buildSymbolDeck(LevelDefinition levelDef) {
    final copyCounts = levelDef.symbolCopyCounts;
    final ids = levelDef.tileIds;
    final defsById = {for (final def in kAllTiles) def.id: def};
    final deck = <TileDefinition>[];
    for (var i = 0; i < ids.length; i++) {
      final def = defsById[ids[i]];
      if (def == null) continue;
      deck.addAll(List.filled(copyCounts[i], def));
    }
    deck.shuffle();
    return deck;
  }

  List<TileModel> _buildRandomBoard(
    List<TileDefinition> symbolDeck,
    List<TilePosition> layout,
  ) {
    final finalDefs = [...symbolDeck]..shuffle();
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

  List<TileModel>? _buildReverseSolvedBoard(
    List<TileDefinition> symbolDeck,
    List<TilePosition> layout,
  ) {
    final seedDef = symbolDeck.first;
    final rng = Random();
    final pairDefs = _pairDefinitionsFromDeck(symbolDeck);

    for (var attempt = 1; attempt <= _reverseSolvedAttempts; attempt++) {
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

      while (remaining.isNotEmpty) {
        final freeTiles = BoardSolver.getFreeTiles(remaining)..shuffle(rng);
        if (freeTiles.length < 2) break;

        final first = freeTiles[0];
        final second = freeTiles[1];
        removalOrder.add((row: first.row, col: first.col, layer: first.layer));
        removalOrder
            .add((row: second.row, col: second.col, layer: second.layer));

        remaining = remaining
            .where((tile) => tile.uid != first.uid && tile.uid != second.uid)
            .toList();
      }

      if (remaining.isNotEmpty) continue;

      final shuffledPairs = [...pairDefs]..shuffle(rng);
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

      debugPrint(
        'Used reverse-solved board generation in $attempt attempt(s).',
      );
      return tiles;
    }

    debugPrint(
      'Reverse-solved generation exhausted $_reverseSolvedAttempts attempt(s).',
    );
    return null;
  }

  List<TileDefinition> _pairDefinitionsFromDeck(List<TileDefinition> deck) {
    final counts = <String, ({TileDefinition def, int count})>{};
    for (final def in deck) {
      final current = counts[def.id];
      counts[def.id] = (
        def: def,
        count: (current?.count ?? 0) + 1,
      );
    }

    final pairs = <TileDefinition>[];
    for (final entry in counts.values) {
      if (entry.count.isOdd) {
        throw StateError('Symbol ${entry.def.id} has odd count ${entry.count}');
      }
      pairs.addAll(List.filled(entry.count ~/ 2, entry.def));
    }
    return pairs;
  }

  List<TileModel> _applyInitialPeekCoverage(
    List<TileModel> tiles,
    LevelDefinition levelDef,
  ) {
    final rng = Random(levelDef.id * 9973 + tiles.length);
    final freeUids =
        BoardSolver.getFreeTiles(tiles).map((tile) => tile.uid).toSet();
    final freeTiles = tiles
        .where((tile) => freeUids.contains(tile.uid))
        .toList()
      ..shuffle(rng);
    final blockedTiles = tiles
        .where((tile) => !freeUids.contains(tile.uid))
        .toList()
      ..shuffle(rng);

    final coverage = _peekCoverageForLevel(levelDef);
    final freeTarget = freeTiles.isEmpty
        ? 0
        : max(1, (freeTiles.length * coverage * 0.55).round());
    final blockedTarget = blockedTiles.isEmpty
        ? 0
        : (blockedTiles.length * coverage).round().clamp(
              1,
              max(1, blockedTiles.length - 1),
            ) as int;

    final coveredUids = <String>{
      ...freeTiles.take(freeTarget).map((tile) => tile.uid),
      ...blockedTiles.take(blockedTarget).map((tile) => tile.uid),
    };

    return tiles.map((tile) {
      return tile.copyWith(
        visibility: coveredUids.contains(tile.uid)
            ? TileVisibility.covered
            : TileVisibility.revealed,
        isPeeked: false,
      );
    }).toList();
  }

  double _peekCoverageForLevel(LevelDefinition levelDef) {
    final base = switch (levelDef.difficultyCategory) {
      'Novice' => 0.14,
      'Apprentice' => 0.18,
      'Strategic' => 0.22,
      'Advanced' => 0.26,
      'Master' => 0.30,
      'Expert' => 0.32,
      'Elder' => 0.34,
      'Legendary' => 0.35,
      _ => 0.18,
    };
    final progressionBonus =
        ((levelDef.id - 1) / kFinalCampaignLevelId).clamp(0.0, 0.07);
    return (base + progressionBonus).clamp(0.10, 0.35);
  }

  void selectTile(String uid) {
    if (state.status != GameStatus.playing) return;
    if (state.pendingMatchAnimation != null) return;

    final tile = state.tiles.firstWhere(
      (t) => t.uid == uid,
      orElse: () => throw StateError('Tile not found'),
    );
    if (tile.isMatched) return;

    // Mahjong rule: tile must be free (not covered, one side open)
    if (!state.freeTileUids.contains(uid)) return;

    _audio.playTileTap();

    if (tile.isCovered && state.selectedTileUid == null) {
      state = state.copyWith(
        tiles: _updateTile(
          uid,
          isSelected: true,
          isPeeked: true,
          visibility: TileVisibility.revealed,
        ),
        selectedTileUid: uid,
      );
      return;
    }

    if (!tile.isRevealed && !tile.isCovered) return;

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
        tiles: _hidePeekedTiles(
          _updateTile(uid, isSelected: false),
          onlyTileUids: {uid},
        ),
        clearSelectedTile: true,
      );
      return;
    }

    // Two different tiles selected
    final firstUid = state.selectedTileUid!;
    final firstTile = state.tiles.firstWhere((t) => t.uid == firstUid);
    final secondTile = tile;

    final updatedTiles = _updateTile(
      uid,
      isSelected: true,
      isPeeked: tile.isCovered ? true : null,
      visibility: tile.isCovered ? TileVisibility.revealed : null,
    );

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
            state = state.copyWith(
              tiles: _hidePeekedTiles(
                cleared,
                onlyTileUids: {firstUid, uid},
              ),
            );
          });
          return;
        }
      }

      final matchedTiles = updatedTiles.map((t) {
        if (t.uid == firstUid || t.uid == uid) {
          return t.copyWith(
            isMatched: true,
            isSelected: false,
            isHinted: false,
            isPeeked: false,
          );
        }
        return t;
      }).toList();

      final newStreak = state.currentStreak + 1;
      final matchAnimationId = _matchAnimationSequence++;
      final matchAnimationStyle = matchAnimationId % 4 == 3
          ? MatchAnimationStyle.secondHitsFirst
          : MatchAnimationStyle.directCollision;
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
        bestStreak: newStreak > state.bestStreak ? newStreak : state.bestStreak,
        pendingScorePops: [
          (row: firstTile.row, col: firstTile.col, layer: firstTile.layer),
          (row: secondTile.row, col: secondTile.col, layer: secondTile.layer),
        ],
        pendingMatchAnimation: PendingMatchAnimation(
          id: matchAnimationId,
          firstTileUid: firstUid,
          secondTileUid: uid,
          style: matchAnimationStyle,
        ),
      );

      Future.delayed(const Duration(milliseconds: 285), () {
        if (!mounted) return;
        HapticService.sequence(_hapticIntensity, [0, 80]);
        _audio.playMatch();
      });

      _debugFinalTileState();
      _checkWin();
      _checkStuck();

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        state = state.copyWith(
          pendingScorePops: const [],
          clearPendingMatchAnimation: true,
        );
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
        state = state.copyWith(
          tiles: _hidePeekedTiles(
            deselected,
            onlyTileUids: {firstUid, uid},
          ),
        );
        _checkStuck();
      });
    }
  }

  bool useHint() {
    if (state.status != GameStatus.playing) return false;

    final pairs = _findRevealedMatchingPairs(state.tiles);
    if (pairs.isEmpty) {
      return _hintPeekableTiles();
    }

    _audio.playHint();

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
    if (!_isDeveloperTest) {
      AnalyticsService.logHintUsed(state.levelId, state.difficulty.name);
    }

    // Clear hint after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final cleared = state.tiles.map((t) {
        if (hintedIds.contains(t.uid)) return t.copyWith(isHinted: false);
        return t;
      }).toList();
      state = state.copyWith(tiles: cleared);
    });
    return true;
  }

  bool shuffleRemaining() {
    return _shuffleRemaining();
  }

  bool useOpenPath() {
    if (state.status != GameStatus.playing) return false;
    final pairs = _findRevealedMatchingPairs(state.tiles);
    if (pairs.isEmpty) return false;

    TilePair? chosen;
    for (final pair in pairs) {
      if (BoardSolver.isSafeMove(
        state.tiles,
        pair.first,
        pair.second,
        maxSearchNodes: _moveSearchNodes,
      )) {
        chosen = pair;
        break;
      }
    }
    chosen ??= pairs.first;

    final removedIds = {chosen.first.uid, chosen.second.uid};
    final updatedTiles = state.tiles.map((tile) {
      if (removedIds.contains(tile.uid)) {
        return tile.copyWith(
          isMatched: true,
          isSelected: false,
          isHinted: false,
          isPeeked: false,
        );
      }
      return tile;
    }).toList();
    final newStreak = state.currentStreak + 1;

    _audio.playMatch();
    state = state.copyWith(
      tiles: updatedTiles,
      score: state.score + 100,
      moves: state.moves + 1,
      currentStreak: newStreak,
      bestStreak: newStreak > state.bestStreak ? newStreak : state.bestStreak,
      clearSelectedTile: true,
    );
    _checkWin();
    _checkStuck();
    return true;
  }

  bool _shuffleRemaining({
    bool penalizeScore = true,
    bool logUsage = true,
  }) {
    if (state.status != GameStatus.playing) return false;

    final unmatched = state.tiles.where((t) => !t.isMatched).toList();
    final matched = state.tiles.where((t) => t.isMatched).toList();
    if (unmatched.length < 2) return false;

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
          isPeeked: false,
          visibility: unmatched[i].isPeeked
              ? TileVisibility.covered
              : unmatched[i].visibility,
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
      return false;
    }

    _audio.playShuffle();

    state = state.copyWith(
      tiles: solvableShuffle,
      score: penalizeScore ? (state.score - 50).clamp(0, 999999) : state.score,
      clearSelectedTile: true,
      currentStreak: 0,
      shufflesUsed: logUsage ? state.shufflesUsed + 1 : state.shufflesUsed,
    );
    if (logUsage && !_isDeveloperTest) {
      AnalyticsService.logShuffleUsed(state.levelId, state.difficulty.name);
    }
    return true;
  }

  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    state = state.copyWith(status: GameStatus.paused);
    if (!_isDeveloperTest) {
      AnalyticsService.logPauseUsed(state.levelId, state.difficulty.name);
    }
  }

  void leaveGame() {
    _audio.stopGameAudio();
    state = GameState.initial();
    _isDeveloperTest = false;
  }

  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
  }

  void _checkWin() {
    if (!state.hasWon) return;
    state = state.copyWith(status: GameStatus.won);

    _audio.playWin();
    _audio.stopBackgroundMusic();
  }

  void _checkStuck() {
    if (state.status != GameStatus.playing) return;
    _debugFinalTileState();
    if (state.isStuck) {
      final recovered = _shuffleRemaining(
        penalizeScore: false,
        logUsage: false,
      );
      if (recovered) {
        debugPrint('No moves remained; board automatically reshuffled.');
        return;
      }

      state = state.copyWith(status: GameStatus.lost);
      if (!_isDeveloperTest) {
        AnalyticsService.logLevelFailed(
          state.levelId,
          state.difficulty.name,
          state.score,
          'no_moves',
        );
      }
      _audio.playLose();
      _audio.stopBackgroundMusic();
    }
  }

  bool _hasSafeMatchingMove(List<TileModel> tiles) {
    return _findRevealedMatchingPairs(tiles).any(
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
    bool? isPeeked,
    TileVisibility? visibility,
  }) {
    return state.tiles.map((t) {
      if (t.uid == uid) {
        return t.copyWith(
          isSelected: isSelected,
          isMatched: isMatched,
          isHinted: isHinted,
          isPeeked: isPeeked,
          visibility: visibility,
        );
      }
      return t;
    }).toList();
  }

  List<TilePair> _findRevealedMatchingPairs(List<TileModel> tiles) {
    return BoardSolver.findAvailableMatchingPairs(tiles)
        .where((pair) => pair.first.isRevealed && pair.second.isRevealed)
        .toList();
  }

  bool _hintPeekableTiles() {
    final peekable = BoardSolver.getFreeTiles(state.tiles)
        .where((tile) => tile.isCovered)
        .toList();
    if (peekable.isEmpty) return false;

    final pair = _findPeekableMatchingPair(peekable);
    final hintedIds = pair != null
        ? {pair.first.uid, pair.second.uid}
        : peekable.take(2).map((tile) => tile.uid).toSet();

    _audio.playHint();
    final hintedTiles = state.tiles.map((tile) {
      if (hintedIds.contains(tile.uid)) {
        return tile.copyWith(isHinted: true);
      }
      return tile;
    }).toList();

    state = state.copyWith(
      tiles: hintedTiles,
      hintsUsed: state.hintsUsed + 1,
    );
    if (!_isDeveloperTest) {
      AnalyticsService.logHintUsed(state.levelId, state.difficulty.name);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final cleared = state.tiles.map((tile) {
        if (hintedIds.contains(tile.uid)) {
          return tile.copyWith(isHinted: false);
        }
        return tile;
      }).toList();
      state = state.copyWith(tiles: cleared);
    });
    return true;
  }

  TilePair? _findPeekableMatchingPair(List<TileModel> peekable) {
    for (var i = 0; i < peekable.length; i++) {
      for (var j = i + 1; j < peekable.length; j++) {
        final first = peekable[i];
        final second = peekable[j];
        if (first.def.id == second.def.id) {
          return (first: first, second: second);
        }
      }
    }
    return null;
  }

  List<TileModel> _hidePeekedTiles(
    List<TileModel> tiles, {
    Set<String>? onlyTileUids,
  }) {
    return tiles.map((tile) {
      final shouldConsider =
          onlyTileUids == null || onlyTileUids.contains(tile.uid);
      if (shouldConsider && tile.isPeeked && !tile.isMatched) {
        return tile.copyWith(
          isSelected: false,
          isHinted: false,
          isPeeked: false,
          visibility: TileVisibility.covered,
        );
      }
      return tile;
    }).toList();
  }
}
