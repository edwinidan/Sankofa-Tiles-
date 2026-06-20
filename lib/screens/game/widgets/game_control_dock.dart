import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final buttonDiameter =
                (constraints.maxWidth * 0.18).clamp(56.0, 72.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ControlButton(
                  diameter: buttonDiameter,
                  icon: Icons.lightbulb_outline,
                  label: 'Hint',
                  onTap: isPlaying ? notifier.useHint : null,
                ),
                _ControlButton(
                  diameter: buttonDiameter,
                  icon: Icons.shuffle_rounded,
                  label: 'Shuffle',
                  onTap: isPlaying ? notifier.shuffleRemaining : null,
                ),
                _ControlButton(
                  diameter: buttonDiameter,
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final double diameter;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.diameter,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color =
        enabled ? SankofaGameTheme.antiqueGold : SankofaGameTheme.mutedText;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        excludeFromSemantics: true,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: enabled ? 0.22 : 0.12),
                  blurRadius: _isPressed ? 7 : 12,
                  offset: Offset(0, _isPressed ? 3 : 6),
                ),
              ],
            ),
            child: Material(
              shape: CircleBorder(
                side: BorderSide(
                  color: enabled
                      ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.68)
                      : SankofaGameTheme.mutedText.withValues(alpha: 0.34),
                  width: 1.25,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: Ink(
                width: widget.diameter,
                height: widget.diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: enabled
                        ? [
                            SankofaGameTheme.parchmentLight,
                            SankofaGameTheme.parchment,
                            SankofaGameTheme.parchmentDark,
                          ]
                        : [
                            SankofaGameTheme.parchmentLight
                                .withValues(alpha: 0.66),
                            SankofaGameTheme.parchment.withValues(alpha: 0.58),
                          ],
                  ),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: enabled ? _setPressed : null,
                  customBorder: const CircleBorder(),
                  splashColor:
                      SankofaGameTheme.antiqueGold.withValues(alpha: 0.16),
                  highlightColor:
                      SankofaGameTheme.antiqueGold.withValues(alpha: 0.08),
                  child: Icon(
                    widget.icon,
                    color: color,
                    size: widget.diameter * 0.38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
