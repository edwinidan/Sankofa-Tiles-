import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tile_model.dart';
import '../../../core/constants/tile_data.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';

const _kDefaultTileW = 64.0;
const _kDefaultTileH = 85.0;
const _kEdgeH = 5.0;
const _kCornerRadius = 9.0;

class TileWidget extends ConsumerStatefulWidget {
  final TileModel tile;
  final double width;
  final double height;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = _kDefaultTileW,
    this.height = _kDefaultTileH,
  });

  @override
  ConsumerState<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends ConsumerState<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<double> _hintOpacity;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _hintOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  String get _suitCode {
    final letter = switch (widget.tile.def.suit) {
      TileSuit.wisdom  => 'W',
      TileSuit.earth   => 'E',
      TileSuit.royalty => 'R',
      TileSuit.honor   => 'H',
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

    // Matched: smash animation — impact burst → shake → shatter out
    if (tile.isMatched) {
      return _buildPhysicalTile(
        tile: tile,
        showNames: showNames,
        tileW: tileW,
        tileH: tileH,
      )
          .animate()
          // Phase 1: impact burst (0–80ms)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.25, 1.25),
            duration: 80.ms,
            curve: Curves.easeOut,
          )
          // Phase 2: shake/tremor (80–240ms)
          .then()
          .shake(hz: 10, duration: 160.ms)
          // Phase 3: shatter — scale to zero + fade (240–450ms)
          .then()
          .scale(
            end: Offset.zero,
            duration: 210.ms,
            curve: Curves.easeIn,
          )
          .fade(end: 0, duration: 210.ms);
    }

    // Hinted: green border + pulsing whole-tile opacity
    if (tile.isHinted) {
      return AnimatedBuilder(
        animation: _hintOpacity,
        builder: (_, __) => Opacity(
          opacity: _hintOpacity.value,
          child: _buildPhysicalTile(
            tile: tile,
            showNames: showNames,
            tileW: tileW,
            tileH: tileH,
            borderColor: AppColors.matchGreen,
            borderWidth: 2.5,
          ),
        ),
      );
    }

    // Normal / selected
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectTile(tile.uid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: tile.isSelected
            ? (Matrix4.identity()..translate(0.0, -10.0))
            : Matrix4.identity(),
        child: _buildPhysicalTile(
          tile: tile,
          showNames: showNames,
          tileW: tileW,
          tileH: tileH,
          bgColor: tile.isSelected
              ? AppColors.tileSelected
              : AppColors.tileFace,
          borderColor: tile.isSelected
              ? AppColors.kenteGold
              : AppColors.tileBorder,
          borderWidth: tile.isSelected ? 2.5 : 1.5,
        ),
      ),
    );
  }

  Widget _buildPhysicalTile({
    required TileModel tile,
    required bool showNames,
    required double tileW,
    required double tileH,
    Color bgColor = AppColors.tileFace,
    Color borderColor = AppColors.tileBorder,
    double borderWidth = 1.5,
  }) {
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
          // Tile face — sits on top, leaving _kEdgeH of the slab visible below
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
  }) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Suit code — top-left
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
        if (showNames)
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
