import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tile_model.dart';
import '../game/widgets/tile_widget.dart';

class TilePreviewScreen extends ConsumerStatefulWidget {
  const TilePreviewScreen({super.key});

  @override
  ConsumerState<TilePreviewScreen> createState() => _TilePreviewScreenState();
}

class _TilePreviewScreenState extends ConsumerState<TilePreviewScreen> {
  int _selectedIndex = kAllTiles.indexWhere((t) => t.id == 'gye_nyame');

  @override
  Widget build(BuildContext context) {
    final def = kAllTiles[_selectedIndex];
    final tile = TileModel(def: def, row: 0, col: 0);

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        backgroundColor: AppColors.navyMid,
        title: const Text(
          'Tile Preview',
          style: TextStyle(color: AppColors.kenteGold),
        ),
        iconTheme: const IconThemeData(color: AppColors.kenteGold),
      ),
      body: Column(
        children: [
          // Large tile preview
          Expanded(
            child: Center(
              child: TileWidget(
                tile: tile,
                width: 128,
                height: 170,
              ),
            ),
          ),
          // Tile info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Text(
                  def.name,
                  style: const TextStyle(
                    color: AppColors.kenteGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  def.meaning,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (def.assetPath != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'PNG asset',
                      style: TextStyle(
                        color: AppColors.matchGreen,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tile picker
          Container(
            height: 100,
            color: AppColors.navyMid,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: kAllTiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final t = kAllTiles[index];
                final isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: TileWidget(
                    tile: TileModel(def: t, row: 0, col: 0),
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 69 : 58,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
