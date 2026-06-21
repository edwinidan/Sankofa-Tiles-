import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/level_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/sankofa_game_theme.dart';
import '../../../providers/game_provider.dart';

const double kCompactGameplayHeaderHeight = 72;

class GameHeader extends ConsumerWidget {
  final int levelId;
  final bool isDeveloperTest;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const GameHeader({
    super.key,
    required this.levelId,
    required this.isDeveloperTest,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final levelPairs = getLevelById(levelId)?.pairCount ?? 0;
    final hasCurrentBoard =
        gameState.levelId == levelId && gameState.tiles.isNotEmpty;
    final totalPairs =
        hasCurrentBoard ? gameState.tiles.length ~/ 2 : levelPairs;
    final completedMatches = hasCurrentBoard
        ? (totalPairs - gameState.remainingPairs).clamp(0, totalPairs)
        : 0;
    final progress = totalPairs == 0 ? 0.0 : completedMatches / totalPairs;

    return SizedBox(
      key: const Key('compact-gameplay-header'),
      height: kCompactGameplayHeaderHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SankofaGameTheme.backgroundTop.withValues(alpha: 0.96),
              SankofaGameTheme.backgroundMiddle.withValues(alpha: 0.88),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.42),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 6),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _HeaderIconButton(
                      tooltip: 'Back',
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: onBack,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _HeaderStat(
                              label: 'Level',
                              value: levelId.toString(),
                              badge: isDeveloperTest ? 'TEST' : null,
                            ),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _HeaderStat(
                              label: 'Score',
                              value: gameState.score.toString(),
                            ),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _HeaderStat(
                              label: 'Matches',
                              value: completedMatches.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      tooltip: 'Settings',
                      icon: Icons.settings_outlined,
                      onPressed: onSettings,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: _MatchProgressBar(value: progress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;

  const _HeaderStat({
    required this.label,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value${badge == null ? '' : ', test mode'}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: SankofaGameTheme.mutedLightText,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 3),
                  Container(
                    key: const Key('developer-test-mode-label'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color:
                            SankofaGameTheme.parchment.withValues(alpha: 0.32),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 0.45,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTextStyles.archiveTitleMedium.copyWith(
                  color: SankofaGameTheme.parchment,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.25),
    );
  }
}

class _MatchProgressBar extends StatelessWidget {
  final double value;

  const _MatchProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Level progress',
      value: '${(value * 100).round()} percent',
      child: SizedBox(
        key: const Key('gameplay-progress-bar'),
        height: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: SankofaGameTheme.boardEdge.withValues(alpha: 0.92),
            valueColor: const AlwaysStoppedAnimation<Color>(
              SankofaGameTheme.antiqueGold,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: SankofaGameTheme.antiqueGold, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        splashRadius: 21,
      ),
    );
  }
}
