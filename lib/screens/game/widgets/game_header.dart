import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/sankofa_game_theme.dart';

class GameHeader extends StatelessWidget {
  final int levelId;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const GameHeader({
    super.key,
    required this.levelId,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SankofaGameTheme.backgroundTop.withValues(alpha: 0.88),
            SankofaGameTheme.backgroundMiddle.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeaderIconButton(
            tooltip: 'Back',
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(
                      child: _TitleOrnament(alignment: Alignment.centerRight),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      child: Text(
                        'LEVEL $levelId',
                        style: AppTextStyles.archiveDisplaySmall.copyWith(
                          fontSize: 17,
                          color: SankofaGameTheme.parchment,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Expanded(
                      child: _TitleOrnament(alignment: Alignment.centerLeft),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _HeaderIconButton(
            tooltip: 'Settings',
            icon: Icons.settings_outlined,
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class _TitleOrnament extends StatelessWidget {
  final Alignment alignment;

  const _TitleOrnament({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 62),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alignment == Alignment.centerRight) ...[
              const Expanded(child: _OrnamentLine()),
              const _OrnamentDot(),
            ] else ...[
              const _OrnamentDot(),
              const Expanded(child: _OrnamentLine()),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrnamentLine extends StatelessWidget {
  const _OrnamentLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.0),
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.58),
            SankofaGameTheme.antiqueGold.withValues(alpha: 0.18),
          ],
        ),
      ),
    );
  }
}

class _OrnamentDot extends StatelessWidget {
  const _OrnamentDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        border: Border.all(
          color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.65),
          width: 1,
        ),
        color: SankofaGameTheme.backgroundMiddle.withValues(alpha: 0.72),
        shape: BoxShape.circle,
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
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: SankofaGameTheme.antiqueGold),
        onPressed: onPressed,
        splashRadius: 22,
      ),
    );
  }
}
