import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/tile_data.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../widgets/tile_back.dart';

class AnimatedMahjongTile extends StatelessWidget {
  const AnimatedMahjongTile({
    super.key,
    required this.definition,
    required this.faceUp,
    this.matched = false,
    this.mismatched = false,
    this.glowing = false,
    this.disabled = false,
    this.reducedMotion = false,
    this.layer = 1,
    this.onTap,
  });

  final TileDefinition definition;
  final bool faceUp;
  final bool matched;
  final bool mismatched;
  final bool glowing;
  final bool disabled;
  final bool reducedMotion;
  final int layer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final duration =
        reducedMotion ? Duration.zero : const Duration(milliseconds: 400);
    return Semantics(
      button: !disabled && !matched,
      label:
          '${definition.name} tile, ${matched ? 'matched' : faceUp ? 'face up' : 'face down'}${!faceUp && !disabled ? '. Tap to reveal.' : '.'}',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: faceUp ? 1 : 0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, turn, _) {
          final angle = turn * math.pi;
          final showFront = turn >= .5;
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, .0018)
            ..rotateY(angle);
          return AnimatedContainer(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(
                mismatched ? 4 : 0, matched ? -3 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SankofaGameTheme.tileRadius),
              boxShadow: [
                ...SankofaGameTheme.tileShadowsForLayer(
                    layer + (faceUp ? 1 : 0)),
                if (glowing || matched)
                  BoxShadow(
                      color:
                          SankofaGameTheme.antiqueGold.withValues(alpha: .75),
                      blurRadius: 16,
                      spreadRadius: 2),
              ],
            ),
            child: GestureDetector(
              onTap: disabled || matched ? null : onTap,
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: showFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _TileFace(definition: definition),
                      )
                    : const TileBackWidget(
                        width: double.infinity, height: double.infinity),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TileFace extends StatelessWidget {
  const _TileFace({required this.definition});
  final TileDefinition definition;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: SankofaGameTheme.panelGradient,
          borderRadius: BorderRadius.circular(SankofaGameTheme.tileRadius),
          border: Border.all(color: SankofaGameTheme.antiqueGold, width: 1.5),
        ),
        padding: const EdgeInsets.all(7),
        child: definition.assetPath == null
            ? Center(
                child: Text(definition.symbol,
                    style: const TextStyle(
                        fontSize: 28, color: SankofaGameTheme.darkText)))
            : Image.asset(definition.assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Center(child: Text(definition.symbol))),
      );
}
