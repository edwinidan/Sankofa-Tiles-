import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/chapter_data.dart';
import '../../core/constants/level_data.dart';
import '../../core/constants/tile_data.dart';
import '../../core/economy/economy_models.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/haptic_service.dart';
import '../../models/game_state.dart';
import '../../models/game_launch_config.dart';
import '../../providers/game_provider.dart';
import '../../providers/economy_provider.dart';
import '../../providers/monetization_provider.dart';
import '../../core/monetization/monetization_models.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/cowrie_icon.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameState gameState;
  final GameLaunchConfig launchConfig;

  const ResultScreen({
    super.key,
    required this.gameState,
    required this.launchConfig,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

/// Opens the production symbol-unlock ceremony without changing progression.
/// Intended only for the developer-tools test button.
Future<void> showDebugUnlockRevealPreview(
  BuildContext context, {
  String tileId = 'nea_onnim',
}) async {
  final tile = _tileById(tileId);
  if (tile == null) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: SankofaGameTheme.backgroundTop.withValues(alpha: 0.88),
    builder: (_) => _UnlockRevealDialog(
      tile: tile,
      currentIndex: 1,
      totalCount: 1,
    ),
  );
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late final AudioService _audioService;
  int _stars = 0;
  bool _resultHandled = false;
  bool _unlockRevealInProgress = false;
  RewardGrantSummary? _rewardSummary;
  final Set<String> _shownUnlockRevealIds = {};
  Future<void>? _saveResultFuture;
  bool _isFirstSessionCompletion = false;
  bool _tutorialActiveAtCompletion = false;
  bool _primaryActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    if (widget.gameState.status == GameStatus.won) {
      _saveResultFuture = _saveResult();
      unawaited(_saveResultFuture);
    }

    _controller.forward();
  }

  Future<void> _saveResult() async {
    if (_resultHandled) return;

    final level = getLevelById(widget.gameState.levelId);
    if (level == null) return;
    _resultHandled = true;

    _stars = computeStars(widget.gameState.score, level.starThresholds);
    if (widget.launchConfig.isDeveloperTest) return;
    final progress = ref.read(progressProvider);
    final previousStars = progress.getStars(widget.gameState.levelId);
    final wasCompleted = progress.isLevelCompleted(widget.gameState.levelId);

    AnalyticsService.logLevelCompleted(
      widget.gameState.levelId,
      widget.gameState.difficulty.name,
      widget.gameState.score,
      _stars,
      widget.gameState.secondsElapsed,
    );

    final rewardSummary =
        await ref.read(economyProvider.notifier).grantLevelRewards(
              gameState: widget.gameState,
              previousStars: previousStars,
              wasCompleted: wasCompleted,
            );

    await ref.read(progressProvider).saveLevelResult(
          widget.gameState.levelId,
          widget.gameState.score,
          _stars,
        );

    final storage = ref.read(storageServiceProvider);
    _isFirstSessionCompletion = !storage.isFirstSessionCompleted();
    _tutorialActiveAtCompletion = !storage.isTutorialComplete();

    await ref
        .read(monetizationProvider.notifier)
        .recordCompletedLevelForInterstitial();

    // Mark first session as completed after recording this result, while
    // retaining the original first-session value for the continue action.
    if (!storage.isFirstSessionCompleted()) {
      await storage.setFirstSessionCompleted();
    }

    if (mounted) {
      setState(() => _rewardSummary = rewardSummary);
      _scheduleUnlockReveal(rewardSummary.unlockedSymbols);
    }
  }

  Future<void> _continueAfterInterstitial(
    FutureOr<void> Function() navigate,
  ) async {
    if (_primaryActionInProgress) return;
    _primaryActionInProgress = true;

    try {
      await _saveResultFuture;
      if (widget.gameState.status == GameStatus.won &&
          !widget.launchConfig.isDeveloperTest) {
        await ref
            .read(monetizationProvider.notifier)
            .maybeShowCompletedLevelInterstitial(
              tutorialActive: _tutorialActiveAtCompletion,
              isFirstSession: _isFirstSessionCompletion,
            );
      }

      if (!mounted) return;
      await navigate();
    } finally {
      _primaryActionInProgress = false;
    }
  }

  void _scheduleUnlockReveal(List<String> unlockedSymbols) {
    if (unlockedSymbols.isEmpty || _unlockRevealInProgress) return;
    final revealIds = [
      for (final id in unlockedSymbols)
        if (_shownUnlockRevealIds.add(id)) id,
    ];
    if (revealIds.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_showUnlockRevealQueue(revealIds));
    });
  }

  Future<void> _showUnlockRevealQueue(List<String> tileIds) async {
    if (_unlockRevealInProgress) return;
    _unlockRevealInProgress = true;
    try {
      for (var index = 0; index < tileIds.length; index++) {
        if (!mounted) return;
        final tile = _tileById(tileIds[index]);
        if (tile == null) continue;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: SankofaGameTheme.backgroundTop.withValues(alpha: 0.88),
          builder: (dialogContext) {
            return _UnlockRevealDialog(
              tile: tile,
              currentIndex: index + 1,
              totalCount: tileIds.length,
            );
          },
        );
      }
    } finally {
      _unlockRevealInProgress = false;
    }
  }

  @override
  void dispose() {
    unawaited(_audioService.stopSfx());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.gameState.status == GameStatus.won;
    final backLocation =
        widget.launchConfig.isDeveloperTest ? '/developer/levels' : '/';
    final bestScore = widget.launchConfig.isDeveloperTest
        ? widget.gameState.score
        : ref
                .watch(progressProvider)
                .getLevelResult(widget.gameState.levelId)
                ?.bestScore ??
            widget.gameState.score;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(backLocation);
      },
      child: Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        bottomNavigationBar: isWin ? _buildPersistentWinActions(context) : null,
        body: SankofaBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight > 40
                            ? constraints.maxHeight - 40
                            : 0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: isWin
                              ? _WinContent(
                                  gameState: widget.gameState,
                                  stars: _stars,
                                  bestScore: bestScore,
                                  rewardSummary: _rewardSummary,
                                  scaleAnim: _scaleAnim,
                                )
                              : _LoseContent(
                                  gameState: widget.gameState,
                                  launchConfig: widget.launchConfig,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersistentWinActions(BuildContext context) {
    final gameState = widget.gameState;
    late final Widget actions;

    if (widget.launchConfig.isDeveloperTest) {
      actions = _DeveloperResultActions(
        levelId: gameState.levelId,
        includeNext: gameState.levelId < kLevels.last.id,
      );
    } else if (isChapterFinalLevel(gameState.levelId)) {
      actions = _ResultActions(
        primaryLabel:
            gameState.levelId == kLevels.last.id ? 'FINISH' : 'CONTINUE',
        primaryIcon: Icons.auto_awesome,
        onPrimary: () => _continueAfterInterstitial(
          () => context.go('/chapter-complete/${gameState.levelId}'),
        ),
        levelId: gameState.levelId,
      );
    } else if (gameState.levelId < kLevels.last.id) {
      actions = _ResultActions(
        primaryLabel: 'NEXT LEVEL',
        primaryIcon: Icons.arrow_forward,
        onPrimary: () => _continueAfterInterstitial(() {
          final nextLevelId = gameState.levelId + 1;
          AnalyticsService.logNextGamePressed(nextLevelId);
          context.go(
            '/game/$nextLevelId',
            extra: GameLaunchConfig(
              levelId: nextLevelId,
              launchMode: GameLaunchMode.normalProgression,
            ),
          );
        }),
        levelId: gameState.levelId,
      );
    } else {
      actions = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'All Current Levels Completed',
            style: AppTextStyles.archiveTitleLarge.copyWith(
              color: SankofaGameTheme.parchmentLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          KenteButton(
            label: 'RETURN HOME',
            icon: Icons.home_outlined,
            width: double.infinity,
            onTap: () => _continueAfterInterstitial(() => context.go('/')),
          ),
        ],
      );
    }

    return _PersistentActionBar(child: actions);
  }
}

TileDefinition? _tileById(String id) {
  for (final tile in kAllTiles) {
    if (tile.id == id) return tile;
  }
  return null;
}

String _doubleCowriesClaimKey(GameState state, int stars, int cowries) {
  return 'double_cowries:${state.levelId}:${state.score}:$stars:$cowries';
}

String _retryAssistanceClaimKey(GameState state) {
  final tileKey = state.tiles.map((tile) => tile.uid).toList()..sort();
  return 'retry_assistance:${state.levelId}:${state.score}:${state.moves}:'
      '${state.shufflesUsed}:${state.hintsUsed}:${tileKey.join(',')}';
}

class _WinContent extends StatelessWidget {
  final GameState gameState;
  final int stars;
  final int bestScore;
  final RewardGrantSummary? rewardSummary;
  final Animation<double> scaleAnim;

  const _WinContent({
    required this.gameState,
    required this.stars,
    required this.bestScore,
    required this.rewardSummary,
    required this.scaleAnim,
  });

  @override
  Widget build(BuildContext context) {
    final level = getLevelById(gameState.levelId);
    final pairsCleared =
        gameState.tiles.where((tile) => tile.isMatched).length ~/ 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: SankofaGameTheme.appParchmentPanelDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: const Text(
              '✦',
              style: TextStyle(
                fontSize: 38,
                color: SankofaGameTheme.antiqueGold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level Complete!',
            style: AppTextStyles.archiveDisplayMedium.copyWith(
              color: SankofaGameTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            level?.name ?? '',
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: SankofaGameTheme.mutedGold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return ScaleTransition(
                scale: scaleAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: i < stars
                        ? SankofaGameTheme.antiqueGold
                        : SankofaGameTheme.mutedText.withValues(alpha: 0.55),
                    size: 34,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          _CompactResultStats(
            score: gameState.score,
            moves: gameState.moves,
            streak: gameState.bestStreak,
          ),
          const SizedBox(height: 10),
          _ResultDetails(
            pairsCleared: pairsCleared,
            shufflesUsed: gameState.shufflesUsed,
            bestScore: bestScore,
          ),
          const SizedBox(height: 12),
          _RewardReveal(summary: rewardSummary),
          if (rewardSummary != null && rewardSummary!.cowries > 0) ...[
            const SizedBox(height: 10),
            _DoubleCowriesReward(
              gameState: gameState,
              stars: stars,
              cowries: rewardSummary!.cowries,
            ),
          ],
          const SizedBox(height: 12),
          _ChapterProgressCard(levelId: gameState.levelId),
        ],
      ),
    );
  }
}

class _CompactResultStats extends StatelessWidget {
  const _CompactResultStats({
    required this.score,
    required this.moves,
    required this.streak,
  });

  final int score;
  final int moves;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ResultStat(label: 'SCORE', value: score),
        _ResultStat(label: 'MOVES', value: moves),
        _ResultStat(label: 'STREAK', value: streak),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: SankofaGameTheme.mutedGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$value',
            style: AppTextStyles.archiveTitleLarge.copyWith(
              color: SankofaGameTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDetails extends StatelessWidget {
  const _ResultDetails({
    required this.pairsCleared,
    required this.shufflesUsed,
    required this.bestScore,
  });

  final int pairsCleared;
  final int shufflesUsed;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 6),
        dense: true,
        visualDensity: VisualDensity.compact,
        iconColor: SankofaGameTheme.mutedGold,
        collapsedIconColor: SankofaGameTheme.mutedGold,
        title: Text(
          'View details',
          style: AppTextStyles.bodySmall.copyWith(
            color: SankofaGameTheme.mutedGold,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        children: [
          _ScoreRow(label: 'Pairs cleared', value: '', score: pairsCleared),
          _ScoreRow(label: 'Shuffles used', value: '', score: shufflesUsed),
          _ScoreRow(label: 'Best score', value: '', score: bestScore),
        ],
      ),
    );
  }
}

class _ChapterProgressCard extends ConsumerWidget {
  const _ChapterProgressCard({required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = chapterForLevel(levelId);
    final progress = ref.read(progressProvider);
    final completed = chapter.levels
        .where((level) => progress.isLevelCompleted(level.id))
        .length;
    final stars = chapter.levels
        .fold<int>(0, (sum, level) => sum + progress.getStars(level.id));
    final levelCount = chapter.levels.length;
    final maximumStars = levelCount * 3;
    final remainingLevels = (levelCount - completed).clamp(0, levelCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${chapter.title} progress',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: SankofaGameTheme.parchmentLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$completed/$levelCount',
                style: AppTextStyles.bodySmall.copyWith(
                  color: SankofaGameTheme.antiqueGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: levelCount == 0 ? 0 : completed / levelCount,
            backgroundColor: SankofaGameTheme.boardEdge,
            valueColor: const AlwaysStoppedAnimation<Color>(
              SankofaGameTheme.antiqueGold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            remainingLevels > 0
                ? '$stars/$maximumStars stars · $remainingLevels levels to the chapter reward'
                : '$stars/$maximumStars stars · Chapter reward earned',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RewardReveal extends StatelessWidget {
  const _RewardReveal({required this.summary});

  final RewardGrantSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: SankofaGameTheme.darkPanelDecoration(disabled: true),
        child: Text(
          'Revealing rewards...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: SankofaGameTheme.mutedLightText,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final lines = [
      for (final entry in summary!.boosters.entries)
        '+${entry.value} ${entry.key.label}',
      if (summary!.newBest) 'New best result',
      if (summary!.chapterCompleted) 'Chapter reward unlocked',
      if (summary!.unlockedSymbols.isNotEmpty)
        summary!.unlockedSymbols.length == 1
            ? 'New symbol added to Collection'
            : '${summary!.unlockedSymbols.length} new symbols added to Collection',
      for (final achievement in summary!.achievements)
        'Achievement: $achievement',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (summary!.cowries > 0)
                Expanded(
                  child: CowrieAmount(
                    amount: summary!.cowries,
                    prefix: '+',
                    iconSize: 20,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: SankofaGameTheme.parchmentLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(
                'Balance: ${summary!.updatedBalance}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
            ],
          ),
          if (lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                lines.join(' · '),
                style: AppTextStyles.bodySmall.copyWith(
                  color: SankofaGameTheme.mutedLightText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _UnlockRevealDialog extends ConsumerStatefulWidget {
  const _UnlockRevealDialog({
    required this.tile,
    required this.currentIndex,
    required this.totalCount,
  });

  final TileDefinition tile;
  final int currentIndex;
  final int totalCount;

  @override
  ConsumerState<_UnlockRevealDialog> createState() =>
      _UnlockRevealDialogState();
}

class _UnlockRevealDialogState extends ConsumerState<_UnlockRevealDialog>
    with SingleTickerProviderStateMixin {
  static const _revealDuration = Duration(milliseconds: 1800);

  late final AnimationController _revealController;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardOffset;
  late final Animation<double> _headingOpacity;
  late final Animation<double> _tileTurn;
  late final Animation<double> _tileScale;
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameOffset;
  late final Animation<double> _meaningOpacity;
  late final Animation<double> _buttonOpacity;
  Timer? _accentTimer;
  bool _started = false;
  bool _accentPlayed = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: _revealDuration,
    );
    _cardOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0, 0.22, curve: Curves.easeOut),
    );
    _cardOffset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0, 0.28, curve: Curves.easeOutCubic),
    ));
    _headingOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.08, 0.3, curve: Curves.easeOut),
    );
    _tileTurn = Tween<double>(begin: math.pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.2, 0.58, curve: Curves.easeOutBack),
      ),
    );
    _tileScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.72, end: 1.08), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 28),
    ]).animate(CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.2, 0.68, curve: Curves.easeOut),
    ));
    _nameOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.52, 0.74, curve: Curves.easeOut),
    );
    _nameOffset = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.52, 0.78, curve: Curves.easeOutCubic),
    ));
    _meaningOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.66, 0.86, curve: Curves.easeOut),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.82, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _revealController.value = 1;
      _playRevealAccent(useSequence: false);
      return;
    }

    _revealController.forward();
    _accentTimer = Timer(
      const Duration(milliseconds: 720),
      _playRevealAccent,
    );
  }

  void _playRevealAccent({bool useSequence = true}) {
    if (!mounted || _accentPlayed) return;
    _accentPlayed = true;
    unawaited(ref.read(audioServiceProvider).playMatch());
    final intensity = ref.read(settingsProvider).hapticIntensity;
    if (useSequence) {
      HapticService.sequence(intensity, const [0, 110]);
    } else {
      HapticService.heavyImpact(intensity);
    }
  }

  Future<void> _finishReveal() async {
    if (_revealController.value >= 1) return;
    _accentTimer?.cancel();
    await _revealController.animateTo(
      1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    _playRevealAccent();
  }

  void _continue() {
    if (_revealController.value < 1) {
      unawaited(_finishReveal());
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _accentTimer?.cancel();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finishReveal,
        child: FadeTransition(
          opacity: _cardOpacity,
          child: SlideTransition(
            position: _cardOffset,
            child: Semantics(
              liveRegion: true,
              label:
                  'New Adinkra symbol unlocked: ${tile.name}. ${tile.meaning}',
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: SankofaGameTheme.appParchmentPanelDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _headingOpacity,
                      child: Column(
                        children: [
                          Text(
                            'New Symbol Unlocked',
                            style: AppTextStyles.archiveTitleLarge.copyWith(
                              color: SankofaGameTheme.mutedGold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.totalCount > 1) ...[
                            const SizedBox(height: 7),
                            _UnlockProgressPill(
                              currentIndex: widget.currentIndex,
                              totalCount: widget.totalCount,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ArtifactTileReveal(
                      tile: tile,
                      controller: _revealController,
                      turn: _tileTurn,
                      scale: _tileScale,
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _nameOpacity,
                      child: SlideTransition(
                        position: _nameOffset,
                        child: Text(
                          tile.name,
                          key: const ValueKey('unlock-symbol-name'),
                          style: AppTextStyles.archiveDisplayMedium.copyWith(
                            color: SankofaGameTheme.darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _meaningOpacity,
                      child: Text(
                        tile.meaning,
                        key: const ValueKey('unlock-symbol-meaning'),
                        style: AppTextStyles.archiveBodyMedium.copyWith(
                          color: SankofaGameTheme.mutedGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: AnimatedBuilder(
                        animation: _revealController,
                        builder: (context, child) => IgnorePointer(
                          key: const ValueKey('unlock-reveal-action-gate'),
                          ignoring: _revealController.value < 0.88,
                          child: child,
                        ),
                        child: KenteButton(
                          label: widget.currentIndex == widget.totalCount
                              ? 'CONTINUE'
                              : 'NEXT SYMBOL',
                          icon: widget.currentIndex == widget.totalCount
                              ? Icons.check
                              : Icons.arrow_forward,
                          width: double.infinity,
                          onTap: _continue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockProgressPill extends StatelessWidget {
  const _UnlockProgressPill({
    required this.currentIndex,
    required this.totalCount,
  });

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        'Discovery $currentIndex of $totalCount',
        style: AppTextStyles.labelSmall.copyWith(
          color: SankofaGameTheme.mutedGold,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ArtifactTileReveal extends StatelessWidget {
  const _ArtifactTileReveal({
    required this.tile,
    required this.controller,
    required this.turn,
    required this.scale,
  });

  final TileDefinition tile;
  final AnimationController controller;
  final Animation<double> turn;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('artifact-tile-reveal'),
      width: 200,
      height: 180,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final revealProgress = Curves.easeOut.transform(
            ((controller.value - 0.18) / 0.5).clamp(0.0, 1.0),
          );
          final glowPulse = math.sin(revealProgress * math.pi);

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 180),
                painter: _ArtifactParticlePainter(progress: revealProgress),
              ),
              Container(
                width: 154 + (glowPulse * 18),
                height: 154 + (glowPulse * 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SankofaGameTheme.antiqueGold
                          .withValues(alpha: 0.34 * revealProgress),
                      SankofaGameTheme.antiqueGold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(turn.value),
                child: Transform.scale(
                  scale: scale.value,
                  child: _UnlockRevealImage(tile: tile),
                ),
              ),
              if (controller.value > 0.46 && controller.value < 0.82)
                IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 144,
                      height: 144,
                      child: Opacity(
                        opacity: math.sin(
                          ((controller.value - 0.46) / 0.36) * math.pi,
                        ),
                        child: Transform.translate(
                          offset: Offset(
                            -70 + (((controller.value - 0.46) / 0.36) * 140),
                            0,
                          ),
                          child: Container(
                            width: 18,
                            height: 136,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.58),
                                  SankofaGameTheme.antiqueGold
                                      .withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtifactParticlePainter extends CustomPainter {
  const _ArtifactParticlePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = size.center(Offset.zero);
    final paint = Paint()..color = SankofaGameTheme.antiqueGold;

    for (var index = 0; index < 14; index++) {
      final angle = ((math.pi * 2) / 14) * index - (math.pi / 2);
      final stagger = (index % 4) * 0.035;
      final local = ((progress - stagger) / (1 - stagger)).clamp(0.0, 1.0);
      final radius = 34 + (local * (42 + ((index % 3) * 7)));
      final opacity = math.sin(local * math.pi).clamp(0.0, 1.0) * 0.72;
      paint.color = SankofaGameTheme.antiqueGold.withValues(alpha: opacity);
      final position = Offset(
        center.dx + (math.cos(angle) * radius),
        center.dy + (math.sin(angle) * radius * 0.82),
      );
      canvas.drawCircle(position, 1.5 + ((index % 3) * 0.7), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArtifactParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _UnlockRevealImage extends StatelessWidget {
  const _UnlockRevealImage({required this.tile});

  final TileDefinition tile;

  @override
  Widget build(BuildContext context) {
    final assetPath = tile.assetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: 144,
        height: 144,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 132,
      height: 132,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SankofaGameTheme.parchmentLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Text(
        tile.symbol,
        style: AppTextStyles.archiveDisplayLarge.copyWith(
          color: SankofaGameTheme.darkText,
        ),
      ),
    );
  }
}

class _DoubleCowriesReward extends ConsumerStatefulWidget {
  const _DoubleCowriesReward({
    required this.gameState,
    required this.stars,
    required this.cowries,
  });

  final GameState gameState;
  final int stars;
  final int cowries;

  @override
  ConsumerState<_DoubleCowriesReward> createState() =>
      _DoubleCowriesRewardState();
}

class _DoubleCowriesRewardState extends ConsumerState<_DoubleCowriesReward> {
  bool _loading = false;
  bool _rewardGranted = false;
  bool _adUnavailable = false;

  @override
  Widget build(BuildContext context) {
    final claimKey = _doubleCowriesClaimKey(
      widget.gameState,
      widget.stars,
      widget.cowries,
    );
    final availability =
        ref.read(monetizationProvider.notifier).rewardedAdAvailability(
              RewardedPlacement.doubleCompletionCowries,
              claimKey: claimKey,
            );
    final canRequest = availability.canRequest && !_rewardGranted;
    final label = _loading
        ? 'LOADING…'
        : _adUnavailable
            ? 'AD UNAVAILABLE'
            : canRequest
                ? 'DOUBLE COWRIES'
                : 'ALREADY CLAIMED';

    return KenteButton(
      label: label,
      icon: canRequest && !_adUnavailable
          ? Icons.ondemand_video_outlined
          : Icons.check,
      width: double.infinity,
      onTap: canRequest && !_loading && !_adUnavailable
          ? () => _watchAd(claimKey)
          : null,
    );
  }

  Future<void> _watchAd(String claimKey) async {
    setState(() {
      _loading = true;
      _adUnavailable = false;
    });
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ref.read(monetizationProvider.notifier).completeRewardedAd(
              placement: RewardedPlacement.doubleCompletionCowries,
              claimKey: claimKey,
              baseCowries: widget.cowries,
            );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rewardGranted = result.completed;
      _adUnavailable = !result.completed &&
          result.status != PurchaseStatus.unavailable &&
          result.status != PurchaseStatus.loading;
    });
    messenger.showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}

class _LoseContent extends StatelessWidget {
  final GameState gameState;
  final GameLaunchConfig launchConfig;

  const _LoseContent({
    required this.gameState,
    required this.launchConfig,
  });

  @override
  Widget build(BuildContext context) {
    final pairsMatched =
        gameState.tiles.where((tile) => tile.isMatched).length ~/ 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: SankofaGameTheme.appParchmentPanelDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '◌',
            style: TextStyle(
              fontSize: 58,
              color: SankofaGameTheme.mutedGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No More Moves',
            style: AppTextStyles.archiveDisplayMedium.copyWith(
              color: SankofaGameTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '"Se wo were firi na wosan kofa a, yenkyiri"\n\n'
              'Go back and try again!',
              style: AppTextStyles.archiveBodyMedium.copyWith(
                color: SankofaGameTheme.mutedGold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          const AdinkraDivider(),
          const SizedBox(height: 18),
          _ScoreRow(
            label: 'Score reached',
            value: '',
            score: gameState.score,
          ),
          _ScoreRow(
            label: 'Pairs matched',
            value: '',
            score: pairsMatched,
          ),
          const SizedBox(height: 22),
          if (!launchConfig.isDeveloperTest) ...[
            _RetryAssistReward(gameState: gameState),
            const SizedBox(height: 10),
          ],
          if (launchConfig.isDeveloperTest)
            _DeveloperResultActions(
              levelId: gameState.levelId,
              includeNext: false,
            )
          else
            _ResultActions(
              primaryLabel: 'RETRY',
              primaryIcon: Icons.refresh,
              onPrimary: () {
                AnalyticsService.logLevelRetried(gameState.levelId);
                context.go(
                  '/game/${gameState.levelId}',
                  extra: GameLaunchConfig(
                    levelId: gameState.levelId,
                    launchMode: GameLaunchMode.normalProgression,
                  ),
                );
              },
              levelId: gameState.levelId,
            ),
        ],
      ),
    );
  }
}

class _RetryAssistReward extends ConsumerStatefulWidget {
  const _RetryAssistReward({required this.gameState});

  final GameState gameState;

  @override
  ConsumerState<_RetryAssistReward> createState() => _RetryAssistRewardState();
}

class _RetryAssistRewardState extends ConsumerState<_RetryAssistReward> {
  bool _isLoading = false;
  bool _rewardGranted = false;
  bool _adUnavailable = false;

  @override
  Widget build(BuildContext context) {
    final claimKey = _retryAssistanceClaimKey(widget.gameState);
    final availability =
        ref.read(monetizationProvider.notifier).rewardedAdAvailability(
              RewardedPlacement.retryAssistance,
              claimKey: claimKey,
            );
    final canRequest = availability.canRequest && !_rewardGranted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
      child: Column(
        children: [
          Text(
            'Retry with help',
            style: AppTextStyles.archiveTitleLarge.copyWith(
              color: SankofaGameTheme.parchmentLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Watch an ad to retry this level with one free Shuffle.',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          KenteButton(
            label: _isLoading
                ? 'LOADING…'
                : _adUnavailable
                    ? 'AD UNAVAILABLE'
                    : canRequest
                        ? 'WATCH AD & RETRY'
                        : 'ALREADY CLAIMED',
            icon: _isLoading
                ? Icons.hourglass_top
                : canRequest && !_adUnavailable
                    ? Icons.ondemand_video_outlined
                    : Icons.check,
            width: double.infinity,
            onTap: canRequest && !_isLoading && !_adUnavailable
                ? () => _onTap(claimKey)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _onTap(String claimKey) async {
    if (_isLoading || _rewardGranted) return;
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final result =
        await ref.read(monetizationProvider.notifier).completeRewardedAd(
              placement: RewardedPlacement.retryAssistance,
              claimKey: claimKey,
            );

    if (!mounted) return;

    if (result.completed) {
      setState(() => _rewardGranted = true);
      AnalyticsService.logLevelRetried(widget.gameState.levelId);
      router.go(
        '/game/${widget.gameState.levelId}',
        extra: GameLaunchConfig(
          levelId: widget.gameState.levelId,
          launchMode: GameLaunchMode.normalProgression,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _adUnavailable = result.status != PurchaseStatus.unavailable &&
            result.status != PurchaseStatus.loading;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.levelId,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final FutureOr<void> Function() onPrimary;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KenteButton(
          label: primaryLabel,
          icon: primaryIcon,
          width: double.infinity,
          onTap: onPrimary,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: KenteButton(
                label: 'REPLAY',
                icon: Icons.refresh,
                small: true,
                onTap: () => context.go('/level/$levelId'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KenteButton(
                label: 'HOME',
                icon: Icons.home_outlined,
                small: true,
                onTap: () => context.go('/'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersistentActionBar extends StatelessWidget {
  const _PersistentActionBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SankofaGameTheme.backgroundTop,
        border: Border(
          top: BorderSide(
            color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.28),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DeveloperResultActions extends StatelessWidget {
  const _DeveloperResultActions({
    required this.levelId,
    required this.includeNext,
  });

  final int levelId;
  final bool includeNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (includeNext) ...[
          KenteButton(
            label: 'NEXT TEST LEVEL',
            icon: Icons.arrow_forward,
            width: double.infinity,
            onTap: () => _openTestLevel(context, levelId + 1),
          ),
          const SizedBox(height: 10),
        ],
        KenteButton(
          label: 'RETRY TEST LEVEL',
          icon: Icons.refresh,
          width: double.infinity,
          onTap: () => _openTestLevel(context, levelId),
        ),
        const SizedBox(height: 10),
        KenteButton(
          label: 'BACK TO LEVEL TESTER',
          icon: Icons.grid_view_outlined,
          width: double.infinity,
          onTap: () => context.go('/developer/levels'),
        ),
      ],
    );
  }

  void _openTestLevel(BuildContext context, int levelId) {
    context.go(
      '/game/$levelId',
      extra: GameLaunchConfig(
        levelId: levelId,
        launchMode: GameLaunchMode.developerTest,
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final int score;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.archiveBodyMedium.copyWith(
      color: SankofaGameTheme.darkText,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          if (value.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.archiveBodySmall.copyWith(
                color: SankofaGameTheme.mutedText,
              ),
            ),
          ],
          const Spacer(),
          Text(score.toString(), style: style),
        ],
      ),
    );
  }
}
