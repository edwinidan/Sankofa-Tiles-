import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_state.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Choose Your Level', style: AppTextStyles.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: kLevels.length,
          itemBuilder: (context, i) {
            final level = kLevels[i];
            final unlocked = progress.isLevelUnlocked(level.id);
            final stars = progress.getStars(level.id);

            return _LevelCard(
              level: level,
              unlocked: unlocked,
              stars: stars,
              defaultDifficulty: settings.defaultDifficulty,
              onTap: unlocked
                  ? () => _showDifficultySheet(
                        context,
                        level.id,
                        settings.defaultDifficulty,
                      )
                  : null,
            );
          },
        ),
      ),
    );
  }

  void _showDifficultySheet(
    BuildContext context,
    int levelId,
    DifficultyMode defaultDifficulty,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.kenteGoldDim, width: 1),
      ),
      builder: (_) => _DifficultySheet(
        levelId: levelId,
        defaultDifficulty: defaultDifficulty,
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelDefinition level;
  final bool unlocked;
  final int stars;
  final DifficultyMode defaultDifficulty;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.defaultDifficulty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.navyMid : AppColors.navyDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? AppColors.kenteGold : AppColors.navyLight,
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.kenteGold.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.kenteGold
                        : AppColors.navyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${level.id}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: unlocked ? AppColors.navyDeep : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (!unlocked)
                  const Icon(Icons.lock, color: AppColors.textMuted, size: 18)
                else
                  _StarRow(stars: stars),
              ],
            ),
            const Spacer(),
            Text(
              level.name,
              style: AppTextStyles.titleMedium.copyWith(
                color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${level.tileCount ~/ 2} pairs · ${level.boardRows}×${level.boardCols}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < stars ? Icons.star : Icons.star_border,
          color: i < stars ? AppColors.kenteGold : AppColors.textMuted,
          size: 16,
        );
      }),
    );
  }
}

class _DifficultySheet extends StatefulWidget {
  final int levelId;
  final DifficultyMode defaultDifficulty;

  const _DifficultySheet({
    required this.levelId,
    required this.defaultDifficulty,
  });

  @override
  State<_DifficultySheet> createState() => _DifficultySheetState();
}

class _DifficultySheetState extends State<_DifficultySheet> {
  late DifficultyMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.defaultDifficulty;
  }

  static const _descriptions = {
    DifficultyMode.easy: 'Unlimited hints, no timer',
    DifficultyMode.normal: '3 hints, 5-minute timer',
    DifficultyMode.relaxed: 'No timer, unlimited hints',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Difficulty', style: AppTextStyles.displaySmall),
          const SizedBox(height: 4),
          const AdinkraDivider(),
          const SizedBox(height: 16),

          ...DifficultyMode.values.map((mode) {
            final label = mode.name[0].toUpperCase() + mode.name.substring(1);
            final desc = _descriptions[mode] ?? '';
            final isSelected = _selected == mode;

            return GestureDetector(
              onTap: () => setState(() => _selected = mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.kenteGold.withValues(alpha: 0.15)
                      : AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.kenteGold
                        : AppColors.navyLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColors.kenteGold
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.titleMedium),
                        Text(desc, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),
          KenteButton(
            label: 'BEGIN',
            icon: Icons.play_arrow_rounded,
            width: double.infinity,
            onTap: () {
              Navigator.pop(context);
              context.go(
                '/game/${widget.levelId}',
                extra: _selected,
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
