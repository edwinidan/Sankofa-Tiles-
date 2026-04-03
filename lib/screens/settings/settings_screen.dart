import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptic_service.dart';
import '../../models/game_state.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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

          const SizedBox(height: 8),
          _DifficultyTile(
            selected: settings.defaultDifficulty,
            onChanged: notifier.setDefaultDifficulty,
          ),

          const SizedBox(height: 16),
          const AdinkraDivider(),
          const SizedBox(height: 16),

          const _SectionHeader(title: 'Data'),
          _ResetTile(
            onReset: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.navyMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        title: Text('Reset Progress?', style: AppTextStyles.headlineMedium),
        content: Text(
          'All level scores and stars will be deleted. This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(settingsProvider.notifier).resetProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset.')),
              );
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
          color: AppColors.kenteGold,
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
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navyLight, width: 1),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.kenteGold),
        title: Text(label, style: AppTextStyles.bodyLarge),
        subtitle: description != null
            ? Text(description!, style: AppTextStyles.bodySmall)
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final DifficultyMode selected;
  final Future<void> Function(DifficultyMode) onChanged;

  const _DifficultyTile({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navyLight, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.kenteGold),
              const SizedBox(width: 16),
              Text('Default Difficulty', style: AppTextStyles.bodyLarge),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: DifficultyMode.values.map((mode) {
              final label =
                  mode.name[0].toUpperCase() + mode.name.substring(1);
              final isSelected = selected == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(mode),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.kenteGold.withValues(alpha: 0.2)
                          : AppColors.navyDeep,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.kenteGold
                            : AppColors.navyLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.kenteGold
                            : AppColors.textMuted,
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
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navyLight, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vibration, color: AppColors.kenteGold),
              const SizedBox(width: 16),
              Text('Haptic Feedback', style: AppTextStyles.bodyLarge),
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
                          ? AppColors.kenteGold.withValues(alpha: 0.2)
                          : AppColors.navyDeep,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.kenteGold
                            : AppColors.navyLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _labels[level]!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.kenteGold
                            : AppColors.textMuted,
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
        decoration: BoxDecoration(
          color: AppColors.navyMid,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.5), width: 1),
        ),
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
          title: Text(
            'Reset All Progress',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.errorRed),
          ),
          subtitle: Text(
            'Clears all scores and unlocked levels',
            style: AppTextStyles.bodySmall,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.errorRed,
          ),
        ),
      ),
    );
  }
}
