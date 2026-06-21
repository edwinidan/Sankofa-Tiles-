import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../models/game_launch_config.dart';
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
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration:
                              SankofaGameTheme.appParchmentPanelDecoration,
                          child: Column(
                            children: [
                              KenteButton(
                                label: 'PLAY',
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
                                  context.push(
                                    '/game/$levelId',
                                    extra: GameLaunchConfig(
                                      levelId: levelId,
                                      launchMode:
                                          GameLaunchMode.normalProgression,
                                    ),
                                  );
                                },
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
                              const SizedBox(height: 12),
                              KenteButton(
                                label: 'HOW TO PLAY',
                                icon: Icons.help_outline,
                                width: double.infinity,
                                onTap: () => context.push('/onboarding'),
                              ),
                              const SizedBox(height: 12),
                              KenteButton(
                                label: 'TILE PREVIEW',
                                icon: Icons.grid_view_outlined,
                                width: double.infinity,
                                onTap: () {
                                  AnalyticsService.logTilePreviewOpened();
                                  context.push('/tile-preview');
                                },
                              ),
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
