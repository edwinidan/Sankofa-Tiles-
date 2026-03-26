import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/adinkra_divider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Logo area
            _LogoSection(),

            const SizedBox(height: 12),
            const AdinkraDivider(),
            const SizedBox(height: 32),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  KenteButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    width: double.infinity,
                    onTap: () => context.go('/level-select'),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    width: double.infinity,
                    onTap: () => context.go('/settings'),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'HOW TO PLAY',
                    icon: Icons.help_outline,
                    width: double.infinity,
                    onTap: () => context.go('/onboarding'),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'TILE PREVIEW',
                    icon: Icons.grid_view_outlined,
                    width: double.infinity,
                    onTap: () => context.go('/tile-preview'),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // Version
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'v1.0.0',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative Adinkra rings
        const Text(
          '◎',
          style: TextStyle(
            color: AppColors.kenteGold,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.displayLarge,
            children: const [
              TextSpan(text: 'SANKOFA'),
              TextSpan(
                text: '  ⟳  ',
                style: TextStyle(
                  color: AppColors.kenteGoldDim,
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
            color: AppColors.kenteGoldDim,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
