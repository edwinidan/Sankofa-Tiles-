import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/game_state.dart';
import '../../../providers/game_provider.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GameHud extends ConsumerWidget {
  const GameHud({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final levelDef = getLevelById(gameState.levelId);
    final levelName = levelDef?.name ?? 'Level ${gameState.levelId}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.navyMid,
        border: Border(
          bottom: BorderSide(color: AppColors.kenteGoldDim, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Level name
          Expanded(
            child: Text(
              levelName.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                color: AppColors.kenteGold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Score
          _HudChip(
            label: 'SCORE',
            value: gameState.score.toString(),
          ),

          const SizedBox(width: 12),

          // Timer — only in normal mode
          if (gameState.difficulty == DifficultyMode.normal) ...[
            _HudChip(
              label: 'TIME',
              value: _formatTime(gameState.secondsElapsed),
              valueColor: gameState.secondsElapsed >= 240
                  ? AppColors.errorRed
                  : null,
            ),
            const SizedBox(width: 12),
          ],

          // Moves
          _HudChip(
            label: 'MOVES',
            value: gameState.moves.toString(),
          ),

          const SizedBox(width: 12),

          // Pairs remaining
          _HudChip(
            label: 'LEFT',
            value: gameState.remainingPairs.toString(),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HudChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 15,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
