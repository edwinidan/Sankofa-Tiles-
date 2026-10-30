import 'package:flutter/material.dart';

import '../core/theme/game_menu_theme.dart';
import 'cowrie_icon.dart';

TextStyle _navigationLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0,
          color: GameMenuTheme.cream,
        );

/// A safe, bounded, scrollable content area over a separately supplied scene.
/// Background artwork belongs outside the safe area; controls stay inside it.
class GameMenuLayout extends StatelessWidget {
  const GameMenuLayout({
    super.key,
    this.background,
    required this.child,
  });

  final Widget? background;
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: GameMenuTheme.forest,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              ExcludeSemantics(child: IgnorePointer(child: background)),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: GameMenuTheme.contentWidth,
                        minHeight: (constraints.maxHeight - 32)
                            .clamp(0.0, double.infinity),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class GameNavigationButton extends StatelessWidget {
  const GameNavigationButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: GameMenuTheme.buttonStyle().copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(48, 64)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: GameMenuTheme.gold, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: _navigationLabelStyle(context),
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center),
          ],
        ),
      );
}

/// Keeps navigation labels readable at large text sizes and narrow widths.
class GameNavigationGroup extends StatelessWidget {
  const GameNavigationGroup({super.key, required this.buttons});

  final List<GameNavigationButton> buttons;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          var widestLabel = 0.0;
          for (final button in buttons) {
            final painter = TextPainter(
              text: TextSpan(
                  text: button.label, style: _navigationLabelStyle(context)),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout();
            if (painter.width > widestLabel) widestLabel = painter.width;
            painter.dispose();
          }
          // Match the button's 4 px horizontal padding on either side.
          final requiredWidth = (widestLabel + 8) * buttons.length +
              GameMenuTheme.gap * (buttons.length - 1);
          final stacked = constraints.maxWidth < requiredWidth ||
              MediaQuery.textScalerOf(context).scale(14) > 20;
          final children = <Widget>[
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0)
                SizedBox(
                  width: stacked ? 0 : GameMenuTheme.gap,
                  height: stacked ? GameMenuTheme.gap : 0,
                ),
              if (stacked) buttons[i] else Expanded(child: buttons[i]),
            ],
          ];
          return stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children);
        },
      );
}

class GamePrimaryButton extends StatelessWidget {
  const GamePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
    this.detail,
    this.artwork,
  });

  final String label;
  final IconData icon;
  final String? detail;
  final String? artwork;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: artwork == null ? 16 : 20,
                height: 1.15,
                fontWeight: FontWeight.w700)),
        if (detail != null)
          Text(detail!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: artwork == null ? 20 : 14,
                  height: 1.15,
                  fontWeight: FontWeight.w700)),
      ],
    );
    if (artwork != null) {
      final largeText = MediaQuery.textScalerOf(context).scale(20) > 28;
      return _ArtworkPrimaryButton(
        artwork: artwork!,
        onPressed: onPressed,
        child: Flex(
          direction: largeText ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            SizedBox(width: largeText ? 0 : 8, height: largeText ? 4 : 0),
            if (largeText) text else Flexible(child: text),
          ],
        ),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: GameMenuTheme.buttonStyle(primary: true),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 10),
          Flexible(child: text),
        ],
      ),
    );
  }
}

class _ArtworkPrimaryButton extends StatefulWidget {
  const _ArtworkPrimaryButton({
    required this.artwork,
    required this.onPressed,
    required this.child,
  });

  final String artwork;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_ArtworkPrimaryButton> createState() => _ArtworkPrimaryButtonState();
}

class _ArtworkPrimaryButtonState extends State<_ArtworkPrimaryButton> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Set<WidgetState>>(
        valueListenable: _states,
        builder: (context, states, _) => AnimatedScale(
          scale: states.contains(WidgetState.pressed) ? .97 : 1,
          duration: const Duration(milliseconds: 100),
          child: LayoutBuilder(builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    widget.artwork,
                    scale: 2172 / constraints.maxWidth,
                    // Stretch only the plain middle; keep the gold end caps.
                    centerSlice: const Rect.fromLTWH(1000, 300, 100, 100),
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxWidth / 3,
                    minWidth: constraints.maxWidth,
                  ),
                  child: TextButton(
                    statesController: _states,
                    onPressed: widget.onPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: GameMenuTheme.ink,
                      disabledForegroundColor: GameMenuTheme.mutedInk,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: MediaQuery.textScalerOf(context).scale(24),
                      ),
                      shape: const StadiumBorder(),
                      textStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(letterSpacing: 1),
                    ),
                    child: widget.child,
                  ),
                ),
              ],
            );
          }),
        ),
      );
}

class GameIconButton extends StatelessWidget {
  const GameIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: label,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GameMenuTheme.gold,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: GameMenuTheme.cream,
          minimumSize: const Size(48, 48),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onPressed == null
                ? GameMenuTheme.disabled
                : GameMenuTheme.emerald,
            shape: BoxShape.circle,
            border: Border.all(
                color: GameMenuTheme.gold, width: GameMenuTheme.outlineWidth),
          ),
          child: Icon(icon, size: 22),
        ),
      );
}

/// Presentation only: the caller supplies the real economy balance.
/// No plus/purchase action is implied by displaying a wallet.
class GameCurrencyDisplay extends StatelessWidget {
  const GameCurrencyDisplay(
      {super.key, required this.amount, this.showLabel = true});

  final int amount;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$amount Cowries',
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GameMenuTheme.emerald,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: GameMenuTheme.gold,
                width: GameMenuTheme.outlineWidth,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CowrieIcon(size: 22),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    showLabel ? '$amount Cowries' : '$amount',
                    style: const TextStyle(
                      color: GameMenuTheme.cream,
                      fontSize: 15,
                      height: 1.2,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class GamePanel extends StatelessWidget {
  const GamePanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameMenuTheme.cream,
          border: Border.all(
            color: GameMenuTheme.gold,
            width: GameMenuTheme.outlineWidth,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: GameMenuTheme.ink),
          child: IconTheme.merge(
            data: const IconThemeData(color: GameMenuTheme.emerald),
            child: child,
          ),
        ),
      );
}

/// Controlled toggle: persistence remains the responsibility of the caller.
class GameToggle extends StatelessWidget {
  const GameToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(color: GameMenuTheme.ink)),
        value: value,
        onChanged: onChanged,
        activeTrackColor: GameMenuTheme.emerald,
        activeThumbColor: GameMenuTheme.gold,
        inactiveTrackColor: GameMenuTheme.mutedInk,
        inactiveThumbColor: GameMenuTheme.cream,
      );
}
