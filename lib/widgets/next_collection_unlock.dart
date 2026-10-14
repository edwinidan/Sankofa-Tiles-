import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/level_data.dart';
import '../core/constants/tile_data.dart';
import '../core/constants/tile_unlock_data.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/sankofa_game_theme.dart';
import '../providers/economy_provider.dart';

/// Only advertise rewards that can be earned in the shipped campaign.
final nextCollectionUnlockProvider = Provider<TileUnlockMilestone?>((ref) {
  final unlocked = ref.watch(economyProvider).unlockedCollectionIds;
  for (final milestone in kTileUnlockMilestones) {
    if (milestone.completedLevel <= kImplementedFinalLevelId &&
        !unlocked.contains(milestone.tileId)) {
      return milestone;
    }
  }
  return null;
});

class NextCollectionUnlock extends ConsumerWidget {
  const NextCollectionUnlock({super.key, this.onPreview});

  final ValueChanged<String>? onPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestone = ref.watch(nextCollectionUnlockProvider);
    if (milestone == null) return const SizedBox.shrink();
    final tile = kAllTiles.firstWhere((tile) => tile.id == milestone.tileId);

    return Container(
      key: const ValueKey('next-collection-unlock'),
      padding: const EdgeInsets.all(14),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Row(
        children: [
          if (tile.assetPath != null) ...[
            Image.asset(tile.assetPath!,
                width: 48,
                height: 58,
                fit: BoxFit.contain,
                excludeFromSemantics: true),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next symbol: ${tile.name}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: SankofaGameTheme.antiqueGold)),
                const SizedBox(height: 4),
                Text(
                    'Clear Level ${milestone.completedLevel} to add it to your Collection.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: SankofaGameTheme.parchmentLight)),
                TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft),
                  onPressed: () {
                    if (onPreview != null) {
                      onPreview!(tile.id);
                    } else {
                      context.push('/tile-preview');
                    }
                  },
                  child: Text(
                      onPreview == null ? 'View Collection' : 'Preview symbol'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
