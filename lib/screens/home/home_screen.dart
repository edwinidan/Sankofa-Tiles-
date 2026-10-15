import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/developer_tools_config.dart';
import '../../core/constants/chapter_data.dart';
import '../../core/constants/level_data.dart';
import '../../core/economy/economy_models.dart';
import '../../core/theme/game_menu_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../models/game_launch_config.dart';
import '../../providers/economy_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/game_menu_components.dart';
import '../../widgets/next_collection_unlock.dart';
import '../result/result_screen.dart';

abstract final class HomeArtwork {
  static const environment = 'assets/menu/misty_emerald_monument_courtyard.png';
  static const logo = 'assets/menu/adinkra_tiles_logo.png';
  static const medallion = 'assets/menu/wooden_medallion.png';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final economy = ref.watch(economyProvider);
    final savedGame = ref.read(storageServiceProvider).getActiveGameSummary();
    final nextLevel = progress.nextUnfinishedLevelId;
    final actionLevel = savedGame?.levelId ?? nextLevel;

    return Scaffold(
      backgroundColor: GameMenuTheme.forest,
      body: LayoutBuilder(
        builder: (context, viewport) {
          // Size artwork from available space, then allow content to scroll
          // when accessibility text or compact screens need more room.
          final height =
              (viewport.maxHeight - MediaQuery.paddingOf(context).vertical - 32)
                  .clamp(0.0, double.infinity);
          final compact = height < 650;
          final logoHeight = (height * .20).clamp(78.0, 180.0);
          final medallionSize =
              (height * (compact ? .24 : .27)).clamp(110.0, 230.0);
          final headerGap = (height * .012).clamp(6.0, 10.0);
          final artworkGap =
              (height * (compact ? .025 : .035)).clamp(10.0, 28.0);
          final actionGap = (height * .025).clamp(12.0, 20.0);
          final navigationGap = (height * .045).clamp(20.0, 36.0);
          return GameMenuLayout(
            background: ClipRect(
              child: Transform.scale(
                // Crop peripheral foliage to raise the distant arch above
                // the medallion while preserving the artwork's proportions.
                scale: 1.28,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  HomeArtwork.environment,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: GameCurrencyDisplay(
                            amount: economy.cowries,
                            showLabel: viewport.maxWidth >= 370)),
                    const SizedBox(width: 6),
                    GameIconButton(
                      label: 'Journey progress',
                      icon: Icons.insights_outlined,
                      onPressed: () => _showProgress(context),
                    ),
                    const SizedBox(width: 6),
                    GameIconButton(
                      label: 'Shop',
                      icon: Icons.storefront_outlined,
                      onPressed: () => context.push('/shop'),
                    ),
                    const SizedBox(width: 6),
                    GameIconButton(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      onPressed: () {
                        AnalyticsService.logSettingsOpened('home');
                        context.push('/settings');
                      },
                    ),
                  ],
                ),
                SizedBox(height: headerGap),
                Image.asset(
                  HomeArtwork.logo,
                  height: logoHeight,
                  fit: BoxFit.contain,
                  semanticLabel: 'Adinkra Tiles',
                ),
                SizedBox(height: artworkGap),
                Image.asset(
                  HomeArtwork.medallion,
                  height: medallionSize,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                SizedBox(height: actionGap),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.textScalerOf(context).scale(20) > 28
                              ? 0
                              : 20),
                  child: GamePrimaryButton(
                    key: const ValueKey('home-continue'),
                    label: savedGame != null
                        ? 'RESUME'
                        : actionLevel == null
                            ? 'JOURNEY COMPLETE'
                            : 'CONTINUE',
                    detail: actionLevel == null ? null : 'LEVEL $actionLevel',
                    onPressed: () {
                      if (savedGame != null) {
                        context.push(
                          '/game/${savedGame.levelId}',
                          extra: GameLaunchConfig(
                            levelId: savedGame.levelId,
                            launchMode: GameLaunchMode.normalProgression,
                            resumeSavedGame: true,
                          ),
                        );
                        return;
                      }
                      final levelId =
                          ref.read(progressProvider).nextUnfinishedLevelId;
                      AnalyticsService.logPlayPressed(levelId);
                      if (levelId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('All Current Levels Completed')),
                        );
                        return;
                      }
                      context.push('/level/$levelId');
                    },
                  ),
                ),
                if (savedGame != null) ...[
                  const SizedBox(height: 8),
                  _HomeCaption('${savedGame.remainingTiles} tiles remaining'),
                  if (nextLevel != null)
                    _HomeTextAction(
                      label: 'Start another level',
                      onPressed: () => context.push('/level/$nextLevel'),
                    ),
                ],
                SizedBox(height: navigationGap),
                GameNavigationGroup(buttons: [
                  GameNavigationButton(
                    label: 'Daily',
                    icon: Icons.calendar_today_outlined,
                    onPressed: () => context.push('/daily-reward'),
                  ),
                  GameNavigationButton(
                    label: 'Journey',
                    icon: Icons.map_outlined,
                    onPressed: () => context.push('/journey'),
                  ),
                  GameNavigationButton(
                    label: 'Collection',
                    icon: Icons.style_outlined,
                    onPressed: () {
                      AnalyticsService.logTilePreviewOpened();
                      context.push('/tile-preview');
                    },
                  ),
                ]),
                if (progress.shouldShowHowToPlayPrompt) ...[
                  const SizedBox(height: 10),
                  _HomeTextAction(
                    label: 'HOW TO PLAY',
                    onPressed: () => context.push('/tutorial?replay=1'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProgress(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GameMenuTheme.forest,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .8,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GameIconButton(
                    label: 'Close progress',
                    icon: Icons.close,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
                const SizedBox(height: 12),
                const _ProgressDetails(),
                const SizedBox(height: 16),
                const NextCollectionUnlock(),
                if (developerToolsEnabled) ...[
                  const SizedBox(height: 16),
                  GamePrimaryButton(
                    label: 'TEST SYMBOL REVEAL',
                    icon: Icons.auto_awesome_outlined,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      showDebugUnlockRevealPreview(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCaption extends StatelessWidget {
  const _HomeCaption(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GameMenuTheme.forest.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(text,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: GameMenuTheme.cream, fontSize: 12)),
          ),
        ),
      );
}

class _HomeTextAction extends StatelessWidget {
  const _HomeTextAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: GameMenuTheme.forest,
            foregroundColor: GameMenuTheme.cream,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      );
}

class _ProgressDetails extends ConsumerWidget {
  const _ProgressDetails();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final economy = ref.watch(economyProvider);
    final chapter = chapterForLevel(
        progress.nextUnfinishedLevelId ?? kImplementedFinalLevelId);
    return GamePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            progress.hasCompletedAllLevels
                ? 'Current Journey Complete'
                : 'Current Chapter: ${chapter.title}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value:
                progress.highestCompletedLevel / kImplementedCampaignLevelCount,
            color: GameMenuTheme.emerald,
            backgroundColor: GameMenuTheme.gold.withValues(alpha: .3),
            semanticsLabel: 'Campaign completion',
          ),
          const SizedBox(height: 12),
          Text(
              'Levels ${progress.highestCompletedLevel}/$kImplementedCampaignLevelCount · Stars ${progress.totalStars}/$kImplementedMaximumCampaignStars'),
          const SizedBox(height: 8),
          Text(
              'Hints ${economy.boosterCount(BoosterType.hint)} · Shuffles ${economy.boosterCount(BoosterType.shuffle)} · Open Path ${economy.boosterCount(BoosterType.openPath)}'),
        ],
      ),
    );
  }
}
