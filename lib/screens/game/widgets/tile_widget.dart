import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tile_model.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TileWidget extends ConsumerStatefulWidget {
  final TileModel tile;
  final double width;
  final double height;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = 56,
    this.height = 72,
  });

  @override
  ConsumerState<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends ConsumerState<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<double> _hintAnimation;
  late AnimationController _matchController;
  late Animation<double> _matchAnimation;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _hintAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    _matchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _matchAnimation = CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMatched && !oldWidget.tile.isMatched) {
      _matchController.forward();
    }
    if (!widget.tile.isHinted) {
      _hintController.reset();
      _hintController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showNames = ref.watch(settingsProvider).showTileNames;
    final tile = widget.tile;

    if (tile.isMatched) {
      return AnimatedBuilder(
        animation: _matchAnimation,
        builder: (_, __) {
          final scale = 1.0 - _matchAnimation.value;
          final opacity = 1.0 - _matchAnimation.value;
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: _buildTileFace(tile, showNames),
            ),
          );
        },
      );
    }

    if (tile.isHinted) {
      return AnimatedBuilder(
        animation: _hintAnimation,
        builder: (_, __) {
          final glow = _hintAnimation.value;
          return _buildTileFace(
            tile,
            showNames,
            extraBorder: Border.all(
              color: AppColors.matchGreen.withValues(alpha: glow),
              width: 2.5,
            ),
            extraShadow: [
              BoxShadow(
                color: AppColors.matchGreen.withValues(alpha: 0.6 * glow),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectTile(tile.uid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: tile.isSelected
            ? (Matrix4.identity()..translateByDouble(0, -8, 0, 1))
            : Matrix4.identity(),
        child: _buildTileFace(
          tile,
          showNames,
          extraBorder: tile.isSelected
              ? Border.all(color: AppColors.kenteGold, width: 2.5)
              : null,
          extraShadow: tile.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.kenteGold.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildTileFace(
    TileModel tile,
    bool showNames, {
    Border? extraBorder,
    List<BoxShadow>? extraShadow,
  }) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: tile.isSelected ? AppColors.tileSelected : AppColors.tileFace,
        borderRadius: BorderRadius.circular(8),
        border: extraBorder ??
            Border.all(color: AppColors.tileBorder, width: 1.5),
        boxShadow: extraShadow ??
            [
              BoxShadow(
                color: AppColors.tileEdge.withValues(alpha: 0.8),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
              const BoxShadow(
                color: Colors.black26,
                offset: Offset(1, 3),
                blurRadius: 3,
              ),
            ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.def.symbol,
            style: AppTextStyles.tileSymbol,
            textAlign: TextAlign.center,
          ),
          if (showNames) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                tile.def.name,
                style: AppTextStyles.tileName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
