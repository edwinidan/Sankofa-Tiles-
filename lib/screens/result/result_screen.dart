import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/audio_service.dart';
import '../../models/game_state.dart';
import '../../models/game_launch_config.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/adinkra_divider.dart';
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
      _saveResult();
    }

    _controller.forward();
  }

  void _saveResult() {
    if (_resultHandled) return;

    final level = getLevelById(widget.gameState.levelId);
    if (level == null) return;
    _resultHandled = true;

    _stars = computeStars(widget.gameState.score, level.starThresholds);
    if (widget.launchConfig.isDeveloperTest) return;

    AnalyticsService.logLevelCompleted(
      widget.gameState.levelId,
      widget.gameState.difficulty.name,
      widget.gameState.score,
      _stars,
      widget.gameState.secondsElapsed,
    );

    ref.read(progressProvider).saveLevelResult(
          widget.gameState.levelId,
          widget.gameState.score,
          _stars,
        );
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
                                  scaleAnim: _scaleAnim,
                                  launchConfig: widget.launchConfig,
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

class _WinContent extends StatelessWidget {
  final GameState gameState;
  final int stars;
  final Animation<double> scaleAnim;
  final GameLaunchConfig launchConfig;

  const _WinContent({
    required this.gameState,
    required this.stars,
    required this.scaleAnim,
    required this.launchConfig,
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
          if (launchConfig.isDeveloperTest)
            _DeveloperResultActions(
              levelId: gameState.levelId,
              includeNext: gameState.levelId < kLevels.last.id,
            )
          else if (gameState.levelId < kLevels.last.id)
            KenteButton(
              label: 'NEXT GAME',
              icon: Icons.arrow_forward,
              width: double.infinity,
              onTap: () {
                final nextLevelId = gameState.levelId + 1;
                AnalyticsService.logNextGamePressed(nextLevelId);
                context.go(
                  '/game/$nextLevelId',
                  extra: GameLaunchConfig(
                    levelId: nextLevelId,
                    launchMode: GameLaunchMode.normalProgression,
                  ),
                );
              },
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
              onTap: () => context.go('/'),
            ),
          ],
        ],
      ),
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
          if (launchConfig.isDeveloperTest)
            _DeveloperResultActions(
              levelId: gameState.levelId,
              includeNext: false,
            )
          else
            Row(
              children: [
                Expanded(
                  child: KenteButton(
                    label: 'HOME',
                    icon: Icons.home_outlined,
                    onTap: () => context.go('/'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KenteButton(
                    label: 'RETRY',
                    icon: Icons.refresh,
                    onTap: () {
                      AnalyticsService.logLevelRetried(gameState.levelId);
                      context.go(
                        '/game/${gameState.levelId}',
                        extra: GameLaunchConfig(
                          levelId: gameState.levelId,
                          launchMode: GameLaunchMode.normalProgression,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
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
