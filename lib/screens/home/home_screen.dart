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
                    onTap: () => _showPlayModeSheet(context),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    width: double.infinity,
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'HOW TO PLAY',
                    icon: Icons.help_outline,
                    width: double.infinity,
                    onTap: () => context.push('/onboarding'),
                  ),
                  const SizedBox(height: 16),
                  KenteButton(
                    label: 'TILE PREVIEW',
                    icon: Icons.grid_view_outlined,
                    width: double.infinity,
                    onTap: () => context.push('/tile-preview'),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // Version
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('v1.0.0', style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.kenteGoldDim, width: 1),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Tile Set', style: AppTextStyles.displaySmall),
            const SizedBox(height: 16),
            KenteButton(
              label: 'CLASSIC TILES',
              icon: Icons.grid_view_outlined,
              width: double.infinity,
              onTap: () {
                Navigator.pop(context);
                context.push('/level-select');
              },
            ),
            const SizedBox(height: 12),
            KenteButton(
              label: 'TILE V2',
              icon: Icons.auto_awesome,
              width: double.infinity,
              onTap: () {
                Navigator.pop(context);
                context.push('/level-select?tileSet=v2');
              },
            ),
            const SizedBox(height: 8),
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
          style: TextStyle(color: AppColors.kenteGold, fontSize: 48),
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
                style: TextStyle(color: AppColors.kenteGoldDim, fontSize: 24),
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
