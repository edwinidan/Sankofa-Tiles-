import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/chapter_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final nextLevelId = progress.nextUnfinishedLevelId;

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        foregroundColor: SankofaGameTheme.parchmentLight,
        title: Text(
          'Grand Archive',
          style: AppTextStyles.displaySmall.copyWith(
            color: SankofaGameTheme.antiqueGold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => safeBack(context),
        ),
      ),
      body: SankofaBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            if (nextLevelId != null)
              KenteButton(
                label: 'CONTINUE LEVEL $nextLevelId',
                icon: Icons.play_arrow_rounded,
                width: double.infinity,
                onTap: () => context.push('/level/$nextLevelId'),
              ),
            const SizedBox(height: 16),
            for (final chapter in kChapters) ...[
              _ChapterCard(chapter: chapter),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends ConsumerWidget {
  const _ChapterCard({required this.chapter});

  final ChapterDefinition chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final completed = chapter.levels
        .where((level) => progress.isLevelCompleted(level.id))
        .length;
    final chapterStars = chapter.levels
        .fold(0, (sum, level) => sum + progress.getStars(level.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Levels ${chapter.levelStart}-${chapter.levelEnd} · '
            '$completed/10 complete · $chapterStars stars',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chapter.levels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final level = chapter.levels[index];
              final unlocked = progress.isLevelUnlocked(level.id);
              final completed = progress.isLevelCompleted(level.id);
              final stars = progress.getStars(level.id);
              return _LevelChip(
                levelId: level.id,
                unlocked: unlocked,
                completed: completed,
                stars: stars,
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Locked levels open when the previous level is completed.',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.levelId,
    required this.unlocked,
    required this.completed,
    required this.stars,
  });

  final int levelId;
  final bool unlocked;
  final bool completed;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: unlocked && completed,
      label: unlocked
          ? 'Level $levelId, ${completed ? '$stars stars' : 'current'}'
          : 'Level $levelId locked',
      child: InkWell(
        onTap: unlocked && completed
            ? () => context.push('/level/$levelId')
            : null,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: unlocked
                ? SankofaGameTheme.parchmentLight
                : SankofaGameTheme.boardEdge,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: completed
                  ? SankofaGameTheme.antiqueGold
                  : SankofaGameTheme.mutedLightText.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unlocked ? Icons.grid_view_rounded : Icons.lock_outline,
                color: unlocked
                    ? SankofaGameTheme.mutedGold
                    : SankofaGameTheme.mutedLightText,
                size: 18,
              ),
              Text(
                '$levelId',
                style: AppTextStyles.labelSmall.copyWith(
                  color: unlocked
                      ? SankofaGameTheme.darkText
                      : SankofaGameTheme.mutedLightText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                completed ? '★' * stars : (unlocked ? 'Now' : ''),
                style: AppTextStyles.labelSmall.copyWith(
                  color: SankofaGameTheme.antiqueGold,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
