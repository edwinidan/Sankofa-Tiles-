import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/chapter_data.dart';
import '../../core/constants/level_data.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class ChapterCompleteScreen extends ConsumerWidget {
  const ChapterCompleteScreen({super.key, required this.completedLevelId});

  final int completedLevelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = chapterForLevel(completedLevelId);
    final progress = ref.watch(progressProvider);
    final stars = chapter.levels.fold(
      0,
      (sum, level) => sum + progress.getStars(level.id),
    );
    final campaignComplete = completedLevelId >= kFinalCampaignLevelId;
    final nextLevelId = campaignComplete ? null : completedLevelId + 1;

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                decoration: SankofaGameTheme.appParchmentPanelDecoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      campaignComplete
                          ? Icons.workspace_premium
                          : Icons.auto_awesome,
                      color: SankofaGameTheme.antiqueGold,
                      size: 58,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      campaignComplete
                          ? 'Campaign Complete'
                          : 'Chapter Complete',
                      style: AppTextStyles.archiveDisplayLarge.copyWith(
                        color: SankofaGameTheme.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chapter.title,
                      style: AppTextStyles.archiveTitleLarge.copyWith(
                        color: SankofaGameTheme.mutedGold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AdinkraDivider(),
                    const SizedBox(height: 18),
                    Text(
                      chapter.featuredSymbol,
                      style: AppTextStyles.archiveDisplayMedium.copyWith(
                        color: SankofaGameTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.meaning,
                      style: AppTextStyles.archiveBodyMedium.copyWith(
                        color: SankofaGameTheme.mutedGold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Chapter stars: $stars / 30',
                      style: AppTextStyles.archiveBodyMedium.copyWith(
                        color: SankofaGameTheme.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!campaignComplete) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Next: ${chapterForLevel(nextLevelId!).title}',
                        style: AppTextStyles.archiveBodyMedium.copyWith(
                          color: SankofaGameTheme.mutedGold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    KenteButton(
                      label: campaignComplete ? 'RETURN HOME' : 'CONTINUE',
                      icon: campaignComplete
                          ? Icons.home_outlined
                          : Icons.arrow_forward_rounded,
                      width: double.infinity,
                      onTap: () {
                        if (campaignComplete) {
                          context.go('/');
                        } else {
                          context.go('/level/$nextLevelId');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
