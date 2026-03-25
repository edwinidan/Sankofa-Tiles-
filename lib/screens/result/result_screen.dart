import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_state.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.gameState.status == GameStatus.won;

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(24),
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

    return Column(
      children: [
        const Spacer(),

        // Starburst animation
        ScaleTransition(
          scale: scaleAnim,
          child: const Text('✦', style: TextStyle(fontSize: 64, color: AppColors.kenteGold)),
        ),

        const SizedBox(height: 16),

        Text('Level Complete!', style: AppTextStyles.displayLarge),
        const SizedBox(height: 8),
        Text(
          level?.name ?? '',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.kenteGoldDim),
        ),

        const SizedBox(height: 24),
        const AdinkraDivider(),
        const SizedBox(height: 24),

        // Star rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return ScaleTransition(
              scale: scaleAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: i < stars ? AppColors.kenteGold : AppColors.textMuted,
                  size: 44,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Score breakdown
        _ScoreRow(label: 'Matches', value: '${gameState.moves} × 100', score: matchScore),
        if (gameState.difficulty == DifficultyMode.normal)
          _ScoreRow(label: 'Time Bonus', value: '${300 - gameState.secondsElapsed.clamp(0, 300)}s × 2', score: timeBonus),
        const Divider(color: AppColors.kenteGoldDim),
        _ScoreRow(
          label: 'TOTAL',
          value: '',
          score: gameState.score,
          bold: true,
        ),

        const Spacer(),

        Row(
          children: [
            Expanded(
              child: KenteButton(
                label: 'MENU',
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
                    ? () => context.go(
                          '/level-select',
                        )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LoseContent extends StatelessWidget {
  final GameState gameState;

  const _LoseContent({required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        const Text('◌', style: TextStyle(fontSize: 64, color: AppColors.textMuted)),

        const SizedBox(height: 16),
        Text('No More Moves', style: AppTextStyles.displayMedium),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '"Se wo were firi na wosan kofa a, yenkyiri"\n\nGo back and try again!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.kenteGoldDim,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),
        const AdinkraDivider(),
        const SizedBox(height: 24),

        _ScoreRow(label: 'Score reached', value: '', score: gameState.score),
        _ScoreRow(label: 'Pairs matched', value: '', score: gameState.moves),

        const Spacer(),

        Row(
          children: [
            Expanded(
              child: KenteButton(
                label: 'MENU',
                icon: Icons.list,
                onTap: () => context.go('/level-select'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KenteButton(
                label: 'TRY AGAIN',
                icon: Icons.refresh,
                onTap: () => context.go(
                  '/game/${gameState.levelId}',
                  extra: gameState.difficulty,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
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
        ? AppTextStyles.titleLarge.copyWith(color: AppColors.kenteGold)
        : AppTextStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          if (value.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.bodySmall),
          ],
          const Spacer(),
          Text(score.toString(), style: style),
        ],
      ),
    );
  }
}
