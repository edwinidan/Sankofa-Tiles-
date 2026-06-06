import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../models/game_state.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) safeBack(context);
      },
      child: Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        appBar: AppBar(
          backgroundColor: SankofaGameTheme.backgroundTop,
          surfaceTintColor: Colors.transparent,
          foregroundColor: SankofaGameTheme.parchmentLight,
          title: Text(
            'Choose Your Level',
            style: AppTextStyles.displaySmall.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => safeBack(context),
          ),
        ),
        body: SankofaBackground(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemCount: kLevels.length,
            itemBuilder: (context, i) {
              final level = kLevels[i];
              final unlocked = progress.isLevelUnlocked(level.id);
              final stars = progress.getStars(level.id);

              return _LevelCard(
                level: level,
                badgeLabel: '${i + 1}',
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
      backgroundColor: SankofaGameTheme.boardSurface,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.52),
        ),
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
  final String badgeLabel;
  final bool unlocked;
  final int stars;
  final DifficultyMode defaultDifficulty;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.badgeLabel,
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
        decoration: SankofaGameTheme.darkPanelDecoration(
          emphasized: unlocked,
          disabled: !unlocked,
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
                        ? SankofaGameTheme.antiqueGold
                        : SankofaGameTheme.mutedText.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: unlocked
                          ? SankofaGameTheme.darkText
                          : SankofaGameTheme.mutedLightText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (!unlocked)
                  const Icon(
                    Icons.lock_outline,
                    color: SankofaGameTheme.mutedLightText,
                    size: 18,
                  )
                else
                  _StarRow(stars: stars),
              ],
            ),
            const Spacer(),
            Text(
              level.name,
              style: AppTextStyles.titleMedium.copyWith(
                color: unlocked
                    ? SankofaGameTheme.parchmentLight
                    : SankofaGameTheme.mutedLightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${level.tileCount ~/ 2} pairs · ${level.boardRows}×${level.boardCols}',
              style: AppTextStyles.bodySmall.copyWith(
                color: unlocked
                    ? SankofaGameTheme.mutedLightText
                    : SankofaGameTheme.mutedLightText.withValues(alpha: 0.58),
              ),
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
          color: i < stars
              ? SankofaGameTheme.antiqueGold
              : SankofaGameTheme.mutedLightText.withValues(alpha: 0.48),
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Difficulty',
              style: AppTextStyles.displaySmall.copyWith(
                color: SankofaGameTheme.antiqueGold,
              ),
            ),
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
                        ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.12)
                        : SankofaGameTheme.boardEdge,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? SankofaGameTheme.antiqueGold
                          : SankofaGameTheme.mutedLightText
                              .withValues(alpha: 0.18),
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
                            ? SankofaGameTheme.antiqueGold
                            : SankofaGameTheme.mutedLightText,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: SankofaGameTheme.parchmentLight,
                              ),
                            ),
                            Text(
                              desc,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: SankofaGameTheme.mutedLightText,
                              ),
                            ),
                          ],
                        ),
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
                context.push('/game/${widget.levelId}', extra: _selected);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
