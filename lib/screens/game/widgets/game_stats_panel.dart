import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/sankofa_game_theme.dart';
import '../../../providers/game_provider.dart';

class GameStatsPanel extends ConsumerWidget {
  const GameStatsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = (constraints.maxWidth * 0.66).clamp(200.0, 280.0);
        final stats = [
          _StatData(
            icon: Icons.star_rounded,
            label: 'Score',
            value: gameState.score.toString(),
          ),
          _StatData(
            icon: Icons.layers_outlined,
            label: 'Pairs Left',
            value: gameState.remainingPairs.toString(),
          ),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 3),
          child: Center(
            child: SizedBox(
              width: panelWidth,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: SankofaGameTheme.panelGradient,
                  borderRadius:
                      BorderRadius.circular(SankofaGameTheme.panelRadius),
                  border: Border.all(
                    color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.48),
                  ),
                  boxShadow: SankofaGameTheme.panelShadow,
                ),
                child: Row(
                  children: [
                    Expanded(child: _StatChip(data: stats[0])),
                    const _GoldSeparator(),
                    Expanded(child: _StatChip(data: stats[1])),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatChip extends StatelessWidget {
  final _StatData data;

  const _StatChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(data.icon, color: SankofaGameTheme.antiqueGold, size: 16),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            data.value,
            style: AppTextStyles.archiveTitleMedium.copyWith(
              fontSize: 16,
              color: SankofaGameTheme.darkText,
            ),
          ),
        ),
        Text(
          data.label.toUpperCase(),
          style: AppTextStyles.archiveLabelSmall.copyWith(fontSize: 8),
        ),
      ],
    );
  }
}

class _GoldSeparator extends StatelessWidget {
  const _GoldSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.0),
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.58),
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
