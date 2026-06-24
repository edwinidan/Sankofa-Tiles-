import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/chapter_data.dart';
import '../../core/constants/level_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../models/game_launch_config.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class PreLevelScreen extends ConsumerWidget {
  const PreLevelScreen({super.key, required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = getLevelById(levelId);
    final progress = ref.watch(progressProvider);
    final unlocked = level != null && progress.isLevelUnlocked(levelId);

    if (level == null || !unlocked) {
      return Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        body: SankofaBackground(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(22),
              decoration: SankofaGameTheme.appParchmentPanelDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    level == null ? 'Level Not Found' : 'Level Locked',
                    style: AppTextStyles.archiveDisplayMedium.copyWith(
                      color: SankofaGameTheme.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete the previous level to continue the journey.',
                    style: AppTextStyles.archiveBodyMedium.copyWith(
                      color: SankofaGameTheme.mutedGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  KenteButton(
                    label: 'BACK TO JOURNEY',
                    icon: Icons.map_outlined,
                    width: double.infinity,
                    onTap: () => context.go('/journey'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final chapter = chapterForLevel(levelId);
    final result = progress.getLevelResult(levelId);

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        foregroundColor: SankofaGameTheme.parchmentLight,
        title: Text(
          'Level $levelId',
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
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: SankofaGameTheme.appParchmentPanelDecoration,
                child: Column(
                  children: [
                    Text(
                      level.name,
                      style: AppTextStyles.archiveDisplayMedium.copyWith(
                        color: SankofaGameTheme.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chapter.title,
                      style: AppTextStyles.archiveBodyMedium.copyWith(
                        color: SankofaGameTheme.mutedGold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _LevelInfoGrid(levelId: levelId),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: SankofaGameTheme.darkPanelDecoration(),
                      child: Text(
                        'Boosters unlock in a later phase.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: SankofaGameTheme.mutedLightText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _BestResult(
                        score: result?.bestScore ?? 0,
                        stars: result?.stars ?? 0),
                    const SizedBox(height: 22),
                    KenteButton(
                      label: 'PLAY',
                      icon: Icons.play_arrow_rounded,
                      width: double.infinity,
                      onTap: () => context.go(
                        '/game/$levelId',
                        extra: GameLaunchConfig(
                          levelId: levelId,
                          launchMode: GameLaunchMode.normalProgression,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelInfoGrid extends StatelessWidget {
  const _LevelInfoGrid({required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context) {
    final level = getLevelById(levelId)!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _InfoPill(label: 'Tiles', value: '${level.tileCount}'),
        _InfoPill(label: 'Layers', value: '${level.layerCount}'),
        _InfoPill(label: 'Pairs', value: '${level.pairCount}'),
        _InfoPill(label: 'Difficulty', value: level.difficultyCategory),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BestResult extends StatelessWidget {
  const _BestResult({required this.score, required this.stars});

  final int score;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Best Score: $score · Best Stars: ${stars == 0 ? '-' : '★' * stars}',
      style: AppTextStyles.archiveBodyMedium.copyWith(
        color: SankofaGameTheme.mutedGold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
