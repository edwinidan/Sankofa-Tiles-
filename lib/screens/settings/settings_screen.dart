import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/developer_tools_config.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/haptic_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/sankofa_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final Uri _privacyPolicyUri = Uri.parse(
    'https://adinkra-tiles-privacy-policy.vercel.app/',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
            'Settings',
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              const _SectionHeader(title: 'Audio'),
              _ToggleTile(
                icon: Icons.volume_up_outlined,
                label: 'Sound Effects',
                value: settings.soundEnabled,
                onChanged: notifier.setSoundEnabled,
              ),
              _ToggleTile(
                icon: Icons.music_note_outlined,
                label: 'Background Music',
                value: settings.musicEnabled,
                onChanged: notifier.setMusicEnabled,
              ),
              _MusicVolumeTile(
                value: settings.musicVolume,
                enabled: settings.musicEnabled,
                onChanged: notifier.setMusicVolume,
              ),
              const SizedBox(height: 8),
              _HapticTile(
                selected: settings.hapticIntensity,
                onChanged: notifier.setHapticIntensity,
              ),
              const SizedBox(height: 16),
              const AdinkraDivider(),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Gameplay'),
              _ToggleTile(
                icon: Icons.text_fields,
                label: 'Show Tile Names',
                description: 'Display Adinkra symbol names on tiles',
                value: settings.showTileNames,
                onChanged: notifier.setShowTileNames,
              ),
              const SizedBox(height: 16),
              const AdinkraDivider(),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Legal'),
              _LinkTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                description: 'Learn how your data is collected and used',
                onTap: () => _openPrivacyPolicy(context),
              ),
              if (developerToolsEnabled) ...[
                const SizedBox(height: 16),
                const AdinkraDivider(),
                const SizedBox(height: 16),
                const _SectionHeader(title: 'Developer Tools'),
                _DeveloperTile(
                  icon: Icons.grid_view_outlined,
                  label: 'DEV: Level Tester',
                  description:
                      'Open any production level without saving progress',
                  onTap: () => context.push('/developer/levels'),
                ),
                const SizedBox(height: 8),
                _ResetTile(onReset: () => _confirmReset(context, ref)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    try {
      final opened = await launchUrl(
        _privacyPolicyUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open the privacy policy. Please try again.'),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SankofaGameTheme.appParchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        title: Text(
          'Reset Progress?',
          style: AppTextStyles.archiveHeadlineMedium,
        ),
        content: Text(
          'All level scores and stars will be deleted. This cannot be undone.',
          style: AppTextStyles.archiveBodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: SankofaGameTheme.mutedGold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsProvider.notifier).resetProgress();
              AnalyticsService.logResetProgress();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Progress reset.')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          letterSpacing: 2,
          color: SankofaGameTheme.antiqueGold,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: SwitchListTile(
        activeThumbColor: SankofaGameTheme.darkText,
        activeTrackColor: SankofaGameTheme.antiqueGold,
        inactiveThumbColor: SankofaGameTheme.mutedLightText,
        inactiveTrackColor:
            SankofaGameTheme.mutedLightText.withValues(alpha: 0.22),
        secondary: Icon(icon, color: SankofaGameTheme.antiqueGold),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: SankofaGameTheme.parchmentLight,
          ),
        ),
        subtitle: description != null
            ? Text(
                description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: SankofaGameTheme.mutedLightText,
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _MusicVolumeTile extends StatelessWidget {
  final double value;
  final bool enabled;
  final Future<void> Function(double) onChanged;

  const _MusicVolumeTile({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_down_outlined,
                color: enabled
                    ? SankofaGameTheme.antiqueGold
                    : SankofaGameTheme.mutedLightText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Music Volume',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: enabled
                        ? SankofaGameTheme.parchmentLight
                        : SankofaGameTheme.mutedLightText,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: enabled
                      ? SankofaGameTheme.antiqueGold
                      : SankofaGameTheme.mutedLightText,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: SankofaGameTheme.antiqueGold,
            inactiveColor:
                SankofaGameTheme.mutedLightText.withValues(alpha: 0.24),
            onChanged: enabled ? (val) => onChanged(val) : null,
          ),
        ],
      ),
    );
  }
}

class _HapticTile extends StatelessWidget {
  final HapticIntensity selected;
  final Future<void> Function(HapticIntensity) onChanged;

  const _HapticTile({required this.selected, required this.onChanged});

  static const _labels = {
    HapticIntensity.off: 'Off',
    HapticIntensity.low: 'Low',
    HapticIntensity.medium: 'Medium',
    HapticIntensity.high: 'High',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.vibration,
                color: SankofaGameTheme.antiqueGold,
              ),
              const SizedBox(width: 16),
              Text(
                'Haptic Feedback',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: HapticIntensity.values.map((level) {
              final isSelected = selected == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(level),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.16)
                          : SankofaGameTheme.boardEdge,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? SankofaGameTheme.antiqueGold
                            : SankofaGameTheme.mutedLightText
                                .withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _labels[level]!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? SankofaGameTheme.antiqueGold
                            : SankofaGameTheme.mutedLightText,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResetTile extends StatelessWidget {
  final VoidCallback onReset;
  const _ResetTile({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReset,
      child: Container(
        decoration: SankofaGameTheme.darkPanelDecoration(),
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
          title: Text(
            'Reset Real Player Progress',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.errorRed),
          ),
          subtitle: Text(
            'Clears all scores and unlocked levels',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.errorRed),
        ),
      ),
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: ListTile(
        leading: Icon(icon, color: SankofaGameTheme.antiqueGold),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: SankofaGameTheme.parchmentLight,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: SankofaGameTheme.mutedLightText,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: SankofaGameTheme.antiqueGold,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Future<void> Function() onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: ListTile(
        leading: Icon(icon, color: SankofaGameTheme.antiqueGold),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: SankofaGameTheme.parchmentLight,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: SankofaGameTheme.mutedLightText,
          ),
        ),
        trailing: const Icon(
          Icons.open_in_new,
          color: SankofaGameTheme.antiqueGold,
        ),
        onTap: onTap,
      ),
    );
  }
}
