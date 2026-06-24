import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/chapter_data.dart';
import '../../core/economy/economy_models.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../providers/economy_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/sankofa_background.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/adinkra_divider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const _LogoSection(),
                      const SizedBox(height: 14),
                      const AdinkraDivider(),
                      const SizedBox(height: 28),
                      const _WalletSummary(),
                      const SizedBox(height: 14),
                      const _ProgressSummary(),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration:
                              SankofaGameTheme.appParchmentPanelDecoration,
                          child: Column(
                            children: [
                              KenteButton(
                                label: 'CONTINUE',
                                icon: Icons.play_arrow_rounded,
                                width: double.infinity,
                                onTap: () {
                                  final levelId = ref
                                      .read(progressProvider)
                                      .nextUnfinishedLevelId;
                                  AnalyticsService.logPlayPressed(levelId);
                                  if (levelId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('All Levels Completed'),
                                      ),
                                    );
                                    return;
                                  }
                                  context.push('/level/$levelId');
                                },
                              ),
                              const SizedBox(height: 12),
                              KenteButton(
                                label: 'JOURNEY',
                                icon: Icons.map_outlined,
                                width: double.infinity,
                                onTap: () => context.push('/journey'),
                              ),
                              const SizedBox(height: 12),
                              KenteButton(
                                label: 'HOW TO PLAY',
                                icon: Icons.help_outline,
                                width: double.infinity,
                                onTap: () => context.push('/tutorial?replay=1'),
                              ),
                              const SizedBox(height: 12),
                              KenteButton(
                                label: 'SETTINGS',
                                icon: Icons.settings_outlined,
                                width: double.infinity,
                                onTap: () {
                                  AnalyticsService.logSettingsOpened('home');
                                  context.push('/settings');
                                },
                              ),
                              const SizedBox(height: 14),
                              const _RewardEntryRow(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'v1.0.0',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: SankofaGameTheme.mutedLightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressSummary extends ConsumerWidget {
  const _ProgressSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final nextLevelId = progress.nextUnfinishedLevelId;
    final chapter = chapterForLevel(nextLevelId ?? 50);
    final completed = progress.highestCompletedLevel;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
        child: Column(
          children: [
            Text(
              progress.hasCompletedAllLevels
                  ? 'Campaign Complete'
                  : 'Current Chapter: ${chapter.title}',
              style: AppTextStyles.titleMedium.copyWith(
                color: SankofaGameTheme.antiqueGold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completed / 50,
              backgroundColor: SankofaGameTheme.boardEdge,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SankofaGameTheme.antiqueGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Levels $completed/50 · Stars ${progress.totalStars}/150',
              style: AppTextStyles.bodySmall.copyWith(
                color: SankofaGameTheme.mutedLightText,
              ),
            ),
            if (nextLevelId != null)
              Text(
                'Next level: $nextLevelId',
                style: AppTextStyles.bodySmall.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WalletSummary extends ConsumerWidget {
  const _WalletSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final economy = ref.watch(economyProvider);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: SankofaGameTheme.darkPanelDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on_outlined,
              color: SankofaGameTheme.antiqueGold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${economy.cowries} Cowries',
                style: AppTextStyles.titleMedium.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
            ),
            Text(
              'Hints ${economy.boosterCount(BoosterType.hint)} · '
              'Shuffles ${economy.boosterCount(BoosterType.shuffle)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: SankofaGameTheme.mutedLightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardEntryRow extends StatelessWidget {
  const _RewardEntryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeRewardButton(
            icon: Icons.calendar_today_outlined,
            label: 'Daily',
            onTap: () => context.push('/daily-reward'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HomeRewardButton(
            icon: Icons.auto_awesome_outlined,
            label: 'Collection',
            onTap: () {
              AnalyticsService.logTilePreviewOpened();
              context.push('/tile-preview');
            },
          ),
        ),
      ],
    );
  }
}

class _HomeRewardButton extends StatelessWidget {
  const _HomeRewardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: SankofaGameTheme.darkPanelDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: SankofaGameTheme.antiqueGold, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: SankofaGameTheme.parchmentLight,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 462),
          child: Image.asset(
            'assets/adinkra_tiles_homescreen_show-removebg-preview.png',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A Ghanaian Mahjong Experience',
          style: AppTextStyles.bodyMedium.copyWith(
            color: SankofaGameTheme.mutedLightText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
