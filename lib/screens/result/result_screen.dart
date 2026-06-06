import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameState gameState;

  const ResultScreen({super.key, required this.gameState});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
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
    final level = getLevelById(widget.gameState.levelId);
    if (level == null) return;

    _stars = computeStars(widget.gameState.score, level.starThresholds);

    ref.read(progressProvider).saveLevelResult(
          widget.gameState.levelId,
          widget.gameState.score,
          _stars,
        );
  }

  @override
  void dispose() {
    unawaited(ref.read(audioServiceProvider).stopSfx());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.gameState.status == GameStatus.won;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/level-select');
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
                                )
                              : _LoseContent(gameState: widget.gameState),
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

  const _WinContent({
    required this.gameState,
    required this.stars,
    required this.scaleAnim,
  });

  @override
  Widget build(BuildContext context) {
    final level = getLevelById(gameState.levelId);
    final matchScore = gameState.moves * 100;
    final timeBonus = gameState.difficulty == DifficultyMode.normal
        ? (300 - gameState.secondsElapsed).clamp(0, 300) * 2
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: SankofaGameTheme.parchmentPanelDecoration,
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
            label: 'Matches',
            value: '${gameState.moves} × 100',
            score: matchScore,
          ),
          if (gameState.difficulty == DifficultyMode.normal)
            _ScoreRow(
              label: 'Time Bonus',
              value: '${300 - gameState.secondsElapsed.clamp(0, 300)}s × 2',
              score: timeBonus,
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
          Row(
            children: [
              Expanded(
                child: KenteButton(
                  label: 'LEVELS',
                  icon: Icons.list,
                  onTap: () => context.go('/level-select'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KenteButton(
                  label: 'NEXT',
                  icon: Icons.arrow_forward,
                  onTap: gameState.levelId < kLevels.length
                      ? () => context.go('/level-select')
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoseContent extends StatelessWidget {
  final GameState gameState;

  const _LoseContent({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: SankofaGameTheme.parchmentPanelDecoration,
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
            score: gameState.moves,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: KenteButton(
                  label: 'LEVELS',
                  icon: Icons.list,
                  onTap: () => context.go('/level-select'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KenteButton(
                  label: 'RETRY',
                  icon: Icons.refresh,
                  onTap: () => context.go(
                    '/game/${gameState.levelId}',
                    extra: gameState.difficulty,
                  ),
                ),
              ),
            ],
          ),
        ],
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
