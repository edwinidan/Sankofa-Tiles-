import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/sankofa_game_theme.dart';
import '../../../models/game_state.dart';
import '../../../providers/game_provider.dart';

class GameControlDock extends ConsumerWidget {
  const GameControlDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final isPlaying = gameState.status == GameStatus.playing;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 3, 0, 10),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.86,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                gradient: SankofaGameTheme.panelGradient,
                borderRadius:
                    BorderRadius.circular(SankofaGameTheme.panelRadius + 2),
                border: Border.all(
                  color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.52),
                ),
                boxShadow: SankofaGameTheme.panelShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DockButton(
                      icon: Icons.lightbulb_outline,
                      label: 'Hint',
                      onTap: isPlaying ? notifier.useHint : null,
                    ),
                  ),
                  Expanded(
                    child: _DockButton(
                      icon: Icons.shuffle_rounded,
                      label: 'Shuffle',
                      onTap: isPlaying ? notifier.shuffleRemaining : null,
                    ),
                  ),
                  Expanded(
                    child: _DockButton(
                      icon: gameState.status == GameStatus.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      label: gameState.status == GameStatus.paused
                          ? 'Resume'
                          : 'Pause',
                      onTap: gameState.status == GameStatus.paused
                          ? notifier.resumeGame
                          : (isPlaying ? notifier.pauseGame : null),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DockButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color =
        enabled ? SankofaGameTheme.antiqueGold : SankofaGameTheme.mutedText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: SankofaGameTheme.antiqueGold.withValues(alpha: 0.14),
        highlightColor: SankofaGameTheme.antiqueGold.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconWell(icon: icon, color: color, enabled: enabled),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyles.archiveLabelSmall.copyWith(
                    color: enabled
                        ? SankofaGameTheme.darkText
                        : SankofaGameTheme.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconWell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool enabled;

  const _IconWell({
    required this.icon,
    required this.color,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: enabled
              ? [
                  SankofaGameTheme.parchmentDark.withValues(alpha: 0.48),
                  SankofaGameTheme.parchmentLight.withValues(alpha: 0.74),
                ]
              : [
                  SankofaGameTheme.parchmentDark.withValues(alpha: 0.28),
                  SankofaGameTheme.parchment.withValues(alpha: 0.46),
                ],
        ),
        border: Border.all(
          color: enabled
              ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.62)
              : SankofaGameTheme.mutedText.withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: enabled ? 0.12 : 0.0),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}
