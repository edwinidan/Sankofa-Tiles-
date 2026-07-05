import 'dart:async';

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
        body: SankofaBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
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
                                  launchConfig: widget.launchConfig,
                                  onBeforePrimaryNavigation:
                                      _continueAfterInterstitial,
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
  final GameLaunchConfig launchConfig;
  final Future<void> Function(FutureOr<void> Function() navigate)
      onBeforePrimaryNavigation;

  const _WinContent({
    required this.gameState,
    required this.stars,
    required this.bestScore,
    required this.rewardSummary,
    required this.scaleAnim,
    required this.launchConfig,
    required this.onBeforePrimaryNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final level = getLevelById(gameState.levelId);
    final pairsCleared =
        gameState.tiles.where((tile) => tile.isMatched).length ~/ 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: SankofaGameTheme.appParchmentPanelDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: const Text(
              '✦',
              style: TextStyle(
                fontSize: 58,
                color: SankofaGameTheme.antiqueGold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Level Complete!',
            style: AppTextStyles.archiveDisplayLarge.copyWith(
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
          const SizedBox(height: 20),
          const AdinkraDivider(),
          const SizedBox(height: 18),
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
                    size: 42,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          _ScoreRow(
            label: 'Pairs cleared',
            value: '',
            score: pairsCleared,
          ),
          _ScoreRow(
            label: 'Moves used',
            value: '',
            score: gameState.moves,
          ),
          _ScoreRow(
            label: 'Best streak',
            value: '',
            score: gameState.bestStreak,
          ),
          _ScoreRow(
            label: 'Shuffles used',
            value: '',
            score: gameState.shufflesUsed,
          ),
          _ScoreRow(
            label: 'Best score',
            value: '',
            score: bestScore,
          ),
          Divider(
            color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.42),
          ),
          _ScoreRow(
            label: 'TOTAL',
            value: '',
            score: gameState.score,
            bold: true,
          ),
          const SizedBox(height: 22),
          _RewardReveal(summary: rewardSummary),
          if (rewardSummary != null && rewardSummary!.cowries > 0) ...[
            const SizedBox(height: 10),
            _DoubleCowriesReward(
              gameState: gameState,
              stars: stars,
              cowries: rewardSummary!.cowries,
            ),
          ],
          const SizedBox(height: 14),
          if (launchConfig.isDeveloperTest)
            _DeveloperResultActions(
              levelId: gameState.levelId,
              includeNext: gameState.levelId < kLevels.last.id,
            )
          else if (isChapterFinalLevel(gameState.levelId))
            _ResultActions(
              primaryLabel:
                  gameState.levelId == kLevels.last.id ? 'FINISH' : 'CONTINUE',
              primaryIcon: Icons.auto_awesome,
              onPrimary: () => onBeforePrimaryNavigation(
                () => context.go('/chapter-complete/${gameState.levelId}'),
              ),
              levelId: gameState.levelId,
            )
          else if (gameState.levelId < kLevels.last.id)
            _ResultActions(
              primaryLabel: 'NEXT LEVEL',
              primaryIcon: Icons.arrow_forward,
              onPrimary: () => onBeforePrimaryNavigation(() {
                final nextLevelId = gameState.levelId + 1;
                AnalyticsService.logNextGamePressed(nextLevelId);
                context.go('/level/$nextLevelId');
              }),
              levelId: gameState.levelId,
            )
          else ...[
            Text(
              'All Levels Completed',
              style: AppTextStyles.archiveTitleLarge.copyWith(
                color: SankofaGameTheme.mutedGold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            KenteButton(
              label: 'RETURN HOME',
              icon: Icons.home_outlined,
              width: double.infinity,
              onTap: () => onBeforePrimaryNavigation(() => context.go('/')),
            ),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (summary!.cowries > 0)
            CowrieAmount(
              amount: summary!.cowries,
              prefix: '+',
              iconSize: 22,
              mainAxisAlignment: MainAxisAlignment.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: SankofaGameTheme.parchmentLight,
              ),
            ),
          if (summary!.cowries > 0 && lines.isNotEmpty)
            const SizedBox(height: 6),
          if (lines.isNotEmpty)
            Text(
              lines.join('\n'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: SankofaGameTheme.parchmentLight,
              ),
              textAlign: TextAlign.center,
            ),
          if (lines.isNotEmpty) const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
              CowrieAmount(
                amount: summary!.updatedBalance,
                iconSize: 22,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnlockRevealDialog extends StatelessWidget {
  const _UnlockRevealDialog({
    required this.tile,
    required this.currentIndex,
    required this.totalCount,
  });

  final TileDefinition tile;
  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final countLabel = totalCount > 1 ? ' $currentIndex of $totalCount' : '';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Semantics(
        label: 'New Adinkra symbol unlocked: ${tile.name}. ${tile.meaning}',
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: SankofaGameTheme.appParchmentPanelDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New Symbol Unlocked$countLabel',
                style: AppTextStyles.archiveTitleLarge.copyWith(
                  color: SankofaGameTheme.mutedGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _UnlockRevealImage(tile: tile),
              const SizedBox(height: 16),
              Text(
                tile.name,
                style: AppTextStyles.archiveDisplayMedium.copyWith(
                  color: SankofaGameTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tile.meaning,
                style: AppTextStyles.archiveBodyMedium.copyWith(
                  color: SankofaGameTheme.mutedGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              KenteButton(
                label: currentIndex == totalCount ? 'CONTINUE' : 'NEXT SYMBOL',
                icon: currentIndex == totalCount
                    ? Icons.check
                    : Icons.arrow_forward,
                width: double.infinity,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
                onTap: () => context.go('/level/$levelId'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KenteButton(
                label: 'HOME',
                icon: Icons.home_outlined,
                onTap: () => context.go('/'),
              ),
            ),
          ],
        ),
      ],
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
  final bool bold;

  const _ScoreRow({
    required this.label,
    required this.value,
    required this.score,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.archiveTitleLarge.copyWith(
            color: SankofaGameTheme.mutedGold,
          )
        : AppTextStyles.archiveBodyMedium.copyWith(
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
