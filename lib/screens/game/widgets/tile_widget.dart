import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tile_model.dart';
import '../../../core/constants/tile_data.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/sankofa_game_theme.dart';
import '../../../widgets/tile_back.dart';

const _kDefaultTileW = 64.0;
const _kDefaultTileH = 85.0;
const _kEdgeH = 5.0;
const _kEdgeW = 14.0;
const _kCornerRadius = 4.0;
const _kFullTileAssetScale = 1.0;
const _kTouchLiftDuration = Duration(milliseconds: 220);
const _kCoordinatedMatchDuration = Duration(milliseconds: 760);

class TileWidget extends ConsumerStatefulWidget {
  final TileModel tile;
  final double width;
  final double height;
  final bool showSuitCode;
  final bool forceHideName;
  final bool isAvailable;
  final bool isCoordinatedMatch;
  final ValueChanged<bool>? onPressChanged;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = _kDefaultTileW,
    this.height = _kDefaultTileH,
    this.showSuitCode = true,
    this.forceHideName = false,
    this.isAvailable = false,
    this.isCoordinatedMatch = false,
    this.onPressChanged,
  });

  @override
  ConsumerState<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends ConsumerState<TileWidget>
    with TickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<double> _glowOpacity;

  late AnimationController _shakeController;
  late Animation<double> _shakeX;

  bool _isPressed = false;
  bool _wasCoordinatedMatch = false;
  bool _coordinatedMatchFinished = false;

  @override
  void initState() {
    super.initState();
    _wasCoordinatedMatch = widget.isCoordinatedMatch;
    if (widget.isCoordinatedMatch) {
      _scheduleCoordinatedMatchFinish();
    }

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.55).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCoordinatedMatch && !oldWidget.isCoordinatedMatch) {
      _wasCoordinatedMatch = true;
      _coordinatedMatchFinished = false;
      _scheduleCoordinatedMatchFinish();
    }
    if (widget.tile.isMismatched && !oldWidget.tile.isMismatched) {
      _shakeController.forward(from: 0);
    }
    // Snap-click when tile lifts (selection confirmed)
    if (widget.tile.isSelected && !oldWidget.tile.isSelected) {
      HapticService.selectionClick(ref.read(settingsProvider).hapticIntensity);
    }
  }

  void _scheduleCoordinatedMatchFinish() {
    Future.delayed(_kCoordinatedMatchDuration, () {
      if (!mounted || !widget.tile.isMatched) return;
      setState(() => _coordinatedMatchFinished = true);
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String get _suitCode {
    final letter = switch (widget.tile.def.suit) {
      TileSuit.wisdom => 'W',
      TileSuit.earth => 'E',
      TileSuit.royalty => 'R',
      TileSuit.honor => 'H',
    };
    return '$letter${widget.tile.def.suitNumber}';
  }

  double _resolvedWidth(BuildContext context) {
    if (widget.width != _kDefaultTileW) return widget.width;
    final screenW = MediaQuery.of(context).size.width;
    final scale = (screenW / 400).clamp(1.0, 1.6);
    return _kDefaultTileW * scale;
  }

  double _resolvedHeight(BuildContext context) {
    if (widget.height != _kDefaultTileH) return widget.height;
    final screenW = MediaQuery.of(context).size.width;
    final scale = (screenW / 400).clamp(1.0, 1.6);
    return _kDefaultTileH * scale;
  }

  @override
  Widget build(BuildContext context) {
    final showNames = ref.watch(settingsProvider).showTileNames;
    final tile = widget.tile;
    final assetPath = tile.def.assetPath;
    const assetScale = _kFullTileAssetScale;
    final tileW = _resolvedWidth(context);
    final tileH = _resolvedHeight(context);

    Widget body;

    if (tile.isHidden) {
      return const SizedBox.shrink();
    }

    // Matched: smash animation — impact burst → shake → shatter out
    if (tile.isMatched) {
      if (_coordinatedMatchFinished) {
        return const SizedBox.shrink();
      }
      final matchedTile = _buildPhysicalTile(
        tile: tile,
        assetPath: assetPath,
        assetScale: assetScale,
        showNames: showNames,
        tileW: tileW,
        tileH: tileH,
        showSuitCode: widget.showSuitCode,
        forceHideName: widget.forceHideName,
      );
      body = (widget.isCoordinatedMatch || _wasCoordinatedMatch)
          ? _TileShatter(
              seed: tile.uid.hashCode,
              startDelay: const Duration(milliseconds: 285),
              tileBuilder: () => _buildPhysicalTile(
                tile: tile,
                assetPath: assetPath,
                assetScale: assetScale,
                showNames: showNames,
                tileW: tileW,
                tileH: tileH,
                showSuitCode: widget.showSuitCode,
                forceHideName: widget.forceHideName,
              ),
            )
          : matchedTile
              .animate()
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.25, 1.25),
                duration: 80.ms,
                curve: Curves.easeOut,
              )
              .then()
              .shake(hz: 10, duration: 160.ms)
              .then()
              .scale(
                end: Offset.zero,
                duration: 210.ms,
                curve: Curves.easeIn,
              )
              .fade(end: 0, duration: 210.ms);
    }

    // Covered or blocked: visible back artwork. Free covered tiles can be
    // tapped to peek/select, then return face-down unless matched.
    else if (tile.isCovered || (!widget.isAvailable && !tile.isMatched)) {
      body = _buildInteractiveTile(
        tile: tile,
        tileH: tileH,
        child: TileBackWidget(width: tileW, height: tileH),
      );
    }

    // Hinted: stronger antique-gold pulse without dimming the tile artwork.
    else if (tile.isHinted) {
      body = AnimatedBuilder(
        animation: _glowOpacity,
        builder: (_, __) => _buildPhysicalTile(
          tile: tile,
          assetPath: assetPath,
          assetScale: assetScale,
          showNames: showNames,
          tileW: tileW,
          tileH: tileH,
          showSuitCode: widget.showSuitCode,
          forceHideName: widget.forceHideName,
          borderColor: SankofaGameTheme.antiqueGold.withValues(
            alpha: 0.72 + (_glowOpacity.value * 0.28),
          ),
          borderWidth: 2.8,
          glowStrength: 0.34 + (_glowOpacity.value * 0.36),
        ),
      );
    }

    // Normal / selected (including mismatched — shake applied via outer AnimatedBuilder)
    else {
      Widget physicalTile = _buildPhysicalTile(
        tile: tile,
        assetPath: assetPath,
        assetScale: assetScale,
        showNames: showNames,
        tileW: tileW,
        tileH: tileH,
        showSuitCode: widget.showSuitCode,
        forceHideName: widget.forceHideName,
      );

      body = _buildInteractiveTile(
        tile: tile,
        tileH: tileH,
        child: physicalTile,
      );
    }

    // Shake transform — no-op (offset 0) unless _shakeController is running
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeX.value, 0),
        child: child,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(
            begin: pi / 2,
            end: 0,
          ).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, animatedChild) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotate.value),
                child: animatedChild,
              );
            },
          );
        },
        child: KeyedSubtree(
          key: ValueKey('${tile.uid}_${tile.visibility}_${tile.isMatched}'),
          child: body,
        ),
      ),
    );
  }

  Widget _buildInteractiveTile({
    required TileModel tile,
    required double tileH,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectTile(tile.uid),
      onTapDown: (_) {
        HapticService.tilePress(ref.read(settingsProvider).hapticIntensity);
        setState(() => _isPressed = true);
        widget.onPressChanged?.call(true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressChanged?.call(false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onPressChanged?.call(false);
      },
      child: AnimatedSlide(
        duration: _kTouchLiftDuration,
        curve: _isPressed ? Curves.easeOutCubic : Curves.easeOutBack,
        offset: Offset(
          0,
          _isPressed
              ? -min(10.0, tileH * 0.12) / tileH
              : tile.isSelected
                  ? -min(5.0, tileH * 0.06) / tileH
                  : 0,
        ),
        child: AnimatedScale(
          duration: _kTouchLiftDuration,
          curve: Curves.easeOutCubic,
          scale: _isPressed
              ? 1.24
              : tile.isSelected
                  ? 1.20
                  : 1.0,
          child: child,
        ),
      ),
    );
  }

  Widget _buildPhysicalTile({
    required TileModel tile,
    required String? assetPath,
    required double assetScale,
    required bool showNames,
    required double tileW,
    required double tileH,
    bool showSuitCode = true,
    bool forceHideName = false,
    Color bgColor = AppColors.tileFace,
    Color borderColor = Colors.transparent,
    double borderWidth = 0,
    double glowStrength = 0,
  }) {
    late final Widget tileBody;

    // Tiles with an image asset: scale up slightly so the PNG's built-in
    // padding is pushed outside the clip boundary, filling the slot fully.
    if (assetPath != null) {
      tileBody = SizedBox(
        width: tileW,
        height: tileH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SankofaGameTheme.tileRadius),
          child: Transform.scale(
            scale: assetScale,
            child: Image.asset(
              assetPath,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    } else {
      // The allocated height includes the 3D bottom edge.
      // The face occupies (tileH - _kEdgeH); the dark-gold slab shows at the bottom.
      tileBody = SizedBox(
        width: tileW,
        height: tileH,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.tileEdge,
                  borderRadius: BorderRadius.circular(_kCornerRadius),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: _kEdgeW,
              height: tileH - _kEdgeH,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(_kCornerRadius),
                ),
                child: _buildTileContent(
                  tile: tile,
                  assetPath: assetPath,
                  showNames: showNames,
                  faceH: tileH - _kEdgeH,
                  showSuitCode: showSuitCode,
                  forceHideName: forceHideName,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isBlocked = !widget.isAvailable && !tile.isMatched;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SankofaGameTheme.tileRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          ...SankofaGameTheme.tileShadowsForLayer(tile.layer),
          if (glowStrength > 0)
            BoxShadow(
              color: SankofaGameTheme.antiqueGold.withValues(
                alpha: glowStrength,
              ),
              blurRadius: 9,
              spreadRadius: 1.2,
            ),
        ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          tileBody,
          if (isBlocked)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SankofaGameTheme.backgroundTop.withValues(
                      alpha: 0.11,
                    ),
                    borderRadius:
                        BorderRadius.circular(SankofaGameTheme.tileRadius),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTileContent({
    required TileModel tile,
    required String? assetPath,
    required bool showNames,
    required double faceH,
    bool showSuitCode = true,
    bool forceHideName = false,
  }) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Suit code — top-left
        if (showSuitCode)
          Positioned(
            top: 4,
            left: 5,
            child: Text(
              _suitCode,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Times New Roman', 'serif'],
                fontSize: 9,
                color: AppColors.tileEdge,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        // Adinkra symbol — centered or full-fill for image assets
        if (assetPath != null)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kCornerRadius),
              child: Image.asset(
                assetPath,
                fit: BoxFit.fill,
              ),
            ),
          )
        else
          Center(
            child: Text(
              tile.def.symbol,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['Times New Roman', 'serif'],
                fontSize: 28,
                color: AppColors.tileEdge,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        // Tile name — bottom-center, only when showTileNames is on
        if (showNames && !forceHideName)
          Positioned(
            bottom: 4,
            left: 3,
            right: 3,
            child: Text(
              tile.def.name,
              style: const TextStyle(
                fontSize: 7.5,
                color: AppColors.tileEdge,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _TileShatter extends StatefulWidget {
  final int seed;
  final Duration startDelay;
  final Widget Function() tileBuilder;

  const _TileShatter({
    required this.seed,
    required this.startDelay,
    required this.tileBuilder,
  });

  @override
  State<_TileShatter> createState() => _TileShatterState();
}

class _TileShatterState extends State<_TileShatter>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 430);

  late final AnimationController _controller;
  late final List<_ShatterFragmentMotion> _motions;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _motions = _buildMotions(widget.seed);

    Future.delayed(widget.startDelay, () {
      if (!mounted) return;
      setState(() => _started = true);
      _controller.forward();
    });
  }

  List<_ShatterFragmentMotion> _buildMotions(int seed) {
    final rng = Random(seed);
    return List.generate(_kShatterPaths.length, (index) {
      final center = _kShatterCenters[index];
      final radial = Offset(center.dx - 0.5, center.dy - 0.5);
      final distance = radial.distance;
      final direction = distance == 0 ? const Offset(0, -1) : radial / distance;
      final speed = 32.0 + rng.nextDouble() * 34.0;
      return _ShatterFragmentMotion(
        velocity: direction * speed +
            Offset(
              (rng.nextDouble() - 0.5) * 18,
              -10 - rng.nextDouble() * 24,
            ),
        rotation: (rng.nextDouble() - 0.5) * 1.8,
        scale: 0.88 + rng.nextDouble() * 0.12,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return widget.tileBuilder();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final elapsedSeconds =
            _duration.inMilliseconds / 1000 * _controller.value;
        final opacity =
            (1 - ((_controller.value - 0.46) / 0.54).clamp(0.0, 1.0))
                .toDouble();

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < _kShatterPaths.length; i++)
              Transform.translate(
                offset: _motions[i].velocity * elapsedSeconds +
                    Offset(0, 80 * elapsedSeconds * elapsedSeconds),
                child: Transform.rotate(
                  angle: _motions[i].rotation * progress,
                  child: Transform.scale(
                    scale: 1 - (1 - _motions[i].scale) * progress,
                    child: Opacity(
                      opacity: opacity,
                      child: ClipPath(
                        clipper: _TileFragmentClipper(_kShatterPaths[i]),
                        child: widget.tileBuilder(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShatterFragmentMotion {
  final Offset velocity;
  final double rotation;
  final double scale;

  const _ShatterFragmentMotion({
    required this.velocity,
    required this.rotation,
    required this.scale,
  });
}

class _TileFragmentClipper extends CustomClipper<Path> {
  final List<Offset> points;

  const _TileFragmentClipper(this.points);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TileFragmentClipper oldClipper) => false;
}

const _kShatterCenters = [
  Offset(0.15, 0.16),
  Offset(0.48, 0.14),
  Offset(0.82, 0.18),
  Offset(0.22, 0.47),
  Offset(0.52, 0.45),
  Offset(0.82, 0.50),
  Offset(0.16, 0.82),
  Offset(0.48, 0.80),
  Offset(0.83, 0.82),
];

const _kShatterPaths = [
  [Offset(0, 0), Offset(0.34, 0), Offset(0.28, 0.31), Offset(0, 0.38)],
  [
    Offset(0.34, 0),
    Offset(0.68, 0),
    Offset(0.62, 0.30),
    Offset(0.28, 0.31),
  ],
  [Offset(0.68, 0), Offset(1, 0), Offset(1, 0.38), Offset(0.62, 0.30)],
  [
    Offset(0, 0.38),
    Offset(0.28, 0.31),
    Offset(0.36, 0.63),
    Offset(0, 0.66),
  ],
  [
    Offset(0.28, 0.31),
    Offset(0.62, 0.30),
    Offset(0.68, 0.64),
    Offset(0.36, 0.63),
  ],
  [
    Offset(0.62, 0.30),
    Offset(1, 0.38),
    Offset(1, 0.68),
    Offset(0.68, 0.64),
  ],
  [Offset(0, 0.66), Offset(0.36, 0.63), Offset(0.31, 1), Offset(0, 1)],
  [
    Offset(0.36, 0.63),
    Offset(0.68, 0.64),
    Offset(0.66, 1),
    Offset(0.31, 1),
  ],
  [Offset(0.68, 0.64), Offset(1, 0.68), Offset(1, 1), Offset(0.66, 1)],
];
