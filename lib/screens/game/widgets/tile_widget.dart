import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tile_model.dart';
import '../../../core/constants/tile_data.dart';
import '../../../core/utils/haptic_service.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';

const _kDefaultTileW = 64.0;
const _kDefaultTileH = 85.0;
const _kEdgeH = 5.0;
const _kEdgeW = 14.0;
const _kCornerRadius = 4.0;

class TileWidget extends ConsumerStatefulWidget {
  final TileModel tile;
  final double width;
  final double height;
  final bool showSuitCode;
  final bool forceHideName;
  final bool isAvailable;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = _kDefaultTileW,
    this.height = _kDefaultTileH,
    this.showSuitCode = true,
    this.forceHideName = false,
    this.isAvailable = false,
  });

  @override
  ConsumerState<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends ConsumerState<TileWidget>
    with TickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<double> _hintOpacity;
  late Animation<double> _glowOpacity;

  late AnimationController _shakeController;
  late Animation<double> _shakeX;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _hintOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
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
    if (widget.tile.isMismatched && !oldWidget.tile.isMismatched) {
      _shakeController.forward(from: 0);
    }
    // Snap-click when tile lifts (selection confirmed)
    if (widget.tile.isSelected && !oldWidget.tile.isSelected) {
      HapticService.selectionClick(ref.read(settingsProvider).hapticIntensity);
    }
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
    final tileW = _resolvedWidth(context);
    final tileH = _resolvedHeight(context);

    Widget body;

    // Matched: smash animation — impact burst → shake → shatter out
    if (tile.isMatched) {
      body = _buildPhysicalTile(
        tile: tile,
        showNames: showNames,
        tileW: tileW,
        tileH: tileH,
        showSuitCode: widget.showSuitCode,
        forceHideName: widget.forceHideName,
      )
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

    // Hinted: green border + pulsing whole-tile opacity
    else if (tile.isHinted) {
      body = AnimatedBuilder(
        animation: _hintOpacity,
        builder: (_, __) => Opacity(
          opacity: _hintOpacity.value,
          child: _buildPhysicalTile(
            tile: tile,
            showNames: showNames,
            tileW: tileW,
            tileH: tileH,
            showSuitCode: widget.showSuitCode,
            forceHideName: widget.forceHideName,
            borderColor: AppColors.matchGreen,
            borderWidth: 2.5,
          ),
        ),
      );
    }

    // Normal / selected (including mismatched — shake applied via outer AnimatedBuilder)
    else {
      Widget physicalTile = _buildPhysicalTile(
        tile: tile,
        showNames: showNames,
        tileW: tileW,
        tileH: tileH,
        showSuitCode: widget.showSuitCode,
        forceHideName: widget.forceHideName,
        bgColor: tile.isSelected ? AppColors.tileSelected : AppColors.tileFace,
        borderColor: tile.isSelected ? AppColors.kenteGold : AppColors.tileBorder,
        borderWidth: tile.isSelected ? 2.5 : 1.5,
      );

      // Available glow — gold border pulse on unselected, non-mismatched playable tiles
      if (widget.isAvailable && !tile.isSelected && !tile.isMismatched) {
        physicalTile = AnimatedBuilder(
          animation: _glowOpacity,
          builder: (_, child) => Stack(
            children: [
              child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_kCornerRadius),
                      border: Border.all(
                        color: AppColors.kenteGold
                            .withValues(alpha: _glowOpacity.value),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          child: physicalTile,
        );
      }

      body = GestureDetector(
        onTap: () => ref.read(gameProvider.notifier).selectTile(tile.uid),
        onTapDown: (_) {
          HapticService.tilePress(ref.read(settingsProvider).hapticIntensity);
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: tile.isSelected
              ? Matrix4.translationValues(0.0, -10.0, 0.0)
              : _isPressed
                  ? Matrix4.diagonal3Values(0.93, 0.93, 1.0)
                  : Matrix4.identity(),
          child: physicalTile,
        ),
      );
    }

    // Shake transform — no-op (offset 0) unless _shakeController is running
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeX.value, 0),
        child: child,
      ),
      child: body,
    );
  }

  Widget _buildPhysicalTile({
    required TileModel tile,
    required bool showNames,
    required double tileW,
    required double tileH,
    bool showSuitCode = true,
    bool forceHideName = false,
    Color bgColor = AppColors.tileFace,
    Color borderColor = AppColors.tileBorder,
    double borderWidth = 1.5,
  }) {
    // Tiles with an image asset: scale up slightly so the PNG's built-in
    // padding is pushed outside the clip boundary, filling the slot fully.
    if (tile.def.assetPath != null) {
      return SizedBox(
        width: tileW,
        height: tileH,
        child: ClipRect(
          child: Transform.scale(
            scale: 1.634,
            child: Image.asset(
              tile.def.assetPath!,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }

    // The allocated height includes the 3D bottom edge.
    // The face occupies (tileH - _kEdgeH); the dark-gold slab shows at the bottom.
    return SizedBox(
      width: tileW,
      height: tileH,
      child: Stack(
        children: [
          // Bottom edge — full-height dark-gold slab gives a 3D raised look
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tileEdge,
                borderRadius: BorderRadius.circular(_kCornerRadius),
              ),
            ),
          ),
          // Tile face — sits on top, leaving _kEdgeH visible below and _kEdgeW visible on right
          Positioned(
            top: 0,
            left: 0,
            right: _kEdgeW,
            height: tileH - _kEdgeH,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(_kCornerRadius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: _buildTileContent(
                tile: tile,
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

  Widget _buildTileContent({
    required TileModel tile,
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
        if (tile.def.assetPath != null)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kCornerRadius),
              child: Image.asset(
                tile.def.assetPath!,
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
