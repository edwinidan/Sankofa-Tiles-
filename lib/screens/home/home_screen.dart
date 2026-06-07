import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../widgets/sankofa_background.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/adinkra_divider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                                onTap: () => context.push('/level-select'),
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
        const Text(
          '◎',
          style: TextStyle(
            color: SankofaGameTheme.antiqueGold,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.displayLarge.copyWith(
              color: SankofaGameTheme.antiqueGold,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                Shadow(
                  color: SankofaGameTheme.mutedGold.withValues(alpha: 0.24),
                  blurRadius: 2,
                ),
              ],
            ),
            children: const [
              TextSpan(text: 'ADINKRA'),
              TextSpan(
                text: '  ⟳  ',
                style: TextStyle(
                  color: SankofaGameTheme.appParchmentLight,
                  fontSize: 24,
                ),
              ),
              TextSpan(text: 'TILES'),
            ],
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
