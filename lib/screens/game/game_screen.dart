import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_state.dart';
import '../../models/game_launch_config.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/analytics_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import 'widgets/board_widget.dart';
import 'widgets/game_control_dock.dart';
import 'widgets/game_header.dart';
import 'widgets/parchment_background.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameLaunchConfig launchConfig;

  const GameScreen({
    super.key,
    required this.launchConfig,
  });

  int get levelId => launchConfig.levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showCombo = false;
  int _displayedStreak = 0;
  late final Stopwatch _levelLoadStopwatch;
  late final AudioService _audioService;
  bool _reportedReadyFrame = false;

  void _leaveGame() {
    ref.read(gameProvider.notifier).leaveGame();
    context.go(
      widget.launchConfig.isDeveloperTest ? '/developer/levels' : '/',
    );
  }

  void _restartLevel() {
    ref.read(gameProvider.notifier).startLevel(
          widget.levelId,
          DifficultyMode.normal,
          isDeveloperTest: widget.launchConfig.isDeveloperTest,
        );
  }

  Future<void> _confirmQuit() async {
    ref.read(gameProvider.notifier).pauseGame();
    await showDialog<void>(
      context: context,
      builder: (_) => _QuitDialog(
        onResume: () {
          Navigator.pop(context);
          ref.read(gameProvider.notifier).resumeGame();
        },
        onQuit: () {
          Navigator.pop(context);
          _leaveGame();
        },
      ),
    );
  }

  Future<void> _confirmRestart() async {
    ref.read(gameProvider.notifier).pauseGame();
    await showDialog<void>(
      context: context,
      builder: (_) => _ConfirmActionDialog(
        title: 'Restart Level?',
        message: 'This board will be rebuilt from the beginning.',
        confirmLabel: 'Restart',
        onCancel: () {
          Navigator.pop(context);
          ref.read(gameProvider.notifier).resumeGame();
        },
        onConfirm: () {
          Navigator.pop(context);
          _restartLevel();
        },
      ),
    );
  }

  Future<void> _openTutorial() async {
    ref.read(gameProvider.notifier).pauseGame();
    await context.push('/tutorial?replay=1');
    if (!context.mounted) return;
    if (ref.read(gameProvider).status == GameStatus.paused) {
      ref.read(gameProvider.notifier).resumeGame();
    }
  }

  Future<void> _openGameSettings() async {
    AnalyticsService.logSettingsOpened('game');
    final wasPlaying = ref.read(gameProvider).status == GameStatus.playing;
    if (wasPlaying) {
      ref.read(gameProvider.notifier).pauseGame();
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SankofaGameTheme.appParchment,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: SankofaGameTheme.antiqueGold),
      ),
      builder: (_) => const _GameSettingsSheet(),
    );

    if (!context.mounted) return;
    if (wasPlaying && ref.read(gameProvider).status == GameStatus.paused) {
      ref.read(gameProvider.notifier).resumeGame();
    }
  }

  void _fireComboHaptic(int streak) {
    final count = streak.clamp(2, 5);
    final delays = List.generate(count, (i) => 70 * i);
    HapticService.sequence(ref.read(settingsProvider).hapticIntensity, delays);
  }

  void _fireWinHaptic() {
    // Two quick doubles then a triple — triumphant celebration
    HapticService.sequence(ref.read(settingsProvider).hapticIntensity, [
      0,
      90,
      180,
      340,
      430,
      580,
    ]);
  }

  void _fireLostHaptic() {
    // Three slow heavy impacts — sombre, deliberate
    HapticService.sequence(ref.read(settingsProvider).hapticIntensity, [
      0,
      200,
      400,
    ]);
  }

  @override
  void dispose() {
    // Stop music whenever we leave the game screen — covers quit dialog,
    // back navigation, and the post-game result redirect.
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _levelLoadStopwatch = Stopwatch()..start();
    _audioService = ref.read(audioServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '[LEVEL_LOAD] level=${widget.levelId} first game screen frame took '
        '${_levelLoadStopwatch.elapsedMilliseconds} ms',
      );
      ref.read(gameProvider.notifier).startLevel(
            widget.levelId,
            DifficultyMode.normal,
            isDeveloperTest: widget.launchConfig.isDeveloperTest,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    if (!_reportedReadyFrame && gameState.status == GameStatus.playing) {
      _reportedReadyFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _levelLoadStopwatch.stop();
        debugPrint(
          '[LEVEL_LOAD] level=${widget.levelId} first ready frame took '
          '${_levelLoadStopwatch.elapsedMilliseconds} ms',
        );
      });
    }

    ref.listen<GameState>(gameProvider, (prev, next) {
      // Navigate to result when game ends
      if (prev?.status != next.status &&
          (next.status == GameStatus.won || next.status == GameStatus.lost)) {
        if (next.status == GameStatus.won) {
          _fireWinHaptic();
        } else {
          _fireLostHaptic();
        }
        final capturedNext = next;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          context.go(
            '/result',
            extra: GameResultConfig(
              gameState: capturedNext,
              launchConfig: widget.launchConfig,
            ),
          );
        });
      }

      // Reward consecutive correct matches without requiring fast play.
      if (next.currentStreak > (prev?.currentStreak ?? 0)) {
        if (next.currentStreak >= 2) {
          _fireComboHaptic(next.currentStreak);
          setState(() {
            _showCombo = true;
            _displayedStreak = next.currentStreak;
          });
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted) setState(() => _showCombo = false);
          });
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmQuit());
      },
      child: Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        body: SafeArea(
          child: ParchmentBackground(
            child: Column(
              children: [
                GameHeader(
                  levelId: widget.levelId,
                  isDeveloperTest: widget.launchConfig.isDeveloperTest,
                  onBack: _confirmQuit,
                  onSettings: _openGameSettings,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                    child: Stack(
                      children: [
                        if (gameState.status != GameStatus.loadFailed)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: gameState.status == GameStatus.paused,
                              child: Visibility(
                                visible: gameState.status != GameStatus.paused,
                                maintainState: true,
                                maintainAnimation: true,
                                maintainSize: true,
                                child: BoardWidget(
                                  key: ValueKey(widget.levelId),
                                ),
                              ),
                            ),
                          ),
                        if (gameState.status == GameStatus.paused)
                          _PausedOverlay(
                            onResume: () =>
                                ref.read(gameProvider.notifier).resumeGame(),
                            onRestart: _confirmRestart,
                            onHowToPlay: _openTutorial,
                            onQuit: _confirmQuit,
                          )
                        else if (gameState.status == GameStatus.loadFailed)
                          _LoadFailedOverlay(
                            message: gameState.loadError ??
                                'We could not prepare this board.',
                            onRetry: () =>
                                ref.read(gameProvider.notifier).startLevel(
                                      widget.levelId,
                                      DifficultyMode.normal,
                                      isDeveloperTest:
                                          widget.launchConfig.isDeveloperTest,
                                    ),
                            onBack: _leaveGame,
                          ),
                        if (_showCombo)
                          IgnorePointer(
                            child: _ComboOverlay(
                              key: ValueKey(_displayedStreak),
                              streak: _displayedStreak,
                            )
                                .animate()
                                .scale(
                                  begin: const Offset(0.2, 0.2),
                                  end: const Offset(1.0, 1.0),
                                  duration: 280.ms,
                                  curve: Curves.elasticOut,
                                )
                                .shake(hz: 4, duration: 220.ms)
                                .then(delay: 620.ms)
                                .fade(begin: 1.0, end: 0.0, duration: 480.ms),
                          ),
                      ],
                    ),
                  ),
                ),
                const GameControlDock(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameSettingsSheet extends ConsumerWidget {
  const _GameSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.82),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.archiveDisplaySmall.copyWith(
                      color: SankofaGameTheme.darkText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close,
                        color: SankofaGameTheme.mutedGold),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SheetSwitchTile(
                icon: Icons.volume_up_outlined,
                label: 'Sound Effects',
                value: settings.soundEnabled,
                onChanged: notifier.setSoundEnabled,
              ),
              _SheetSwitchTile(
                icon: Icons.music_note_outlined,
                label: 'Background Music',
                value: settings.musicEnabled,
                onChanged: notifier.setMusicEnabled,
              ),
              _SheetVolumeTile(
                value: settings.musicVolume,
                enabled: settings.musicEnabled,
                onChanged: notifier.setMusicVolume,
              ),
              _SheetSwitchTile(
                icon: Icons.text_fields,
                label: 'Show Tile Names',
                value: settings.showTileNames,
                onChanged: notifier.setShowTileNames,
              ),
              _SheetHapticTile(
                selected: settings.hapticIntensity,
                onChanged: notifier.setHapticIntensity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _SheetSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: SankofaGameTheme.darkText,
      activeTrackColor: SankofaGameTheme.antiqueGold,
      inactiveThumbColor: SankofaGameTheme.mutedText,
      inactiveTrackColor: SankofaGameTheme.parchmentDark,
      secondary: Icon(icon, color: SankofaGameTheme.mutedGold),
      title: Text(
        label,
        style: AppTextStyles.archiveBodyLarge.copyWith(
          color: SankofaGameTheme.darkText,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SheetVolumeTile extends StatelessWidget {
  final double value;
  final bool enabled;
  final Future<void> Function(double) onChanged;

  const _SheetVolumeTile({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_down_outlined,
                color: enabled
                    ? SankofaGameTheme.mutedGold
                    : SankofaGameTheme.mutedText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Music Volume',
                  style: AppTextStyles.archiveBodyLarge.copyWith(
                    color: enabled
                        ? SankofaGameTheme.darkText
                        : SankofaGameTheme.mutedText,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.archiveLabelSmall.copyWith(
                  color: enabled
                      ? SankofaGameTheme.mutedGold
                      : SankofaGameTheme.mutedText,
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
            inactiveColor: SankofaGameTheme.parchmentDark,
            onChanged: enabled ? (val) => onChanged(val) : null,
          ),
        ],
      ),
    );
  }
}

class _SheetHapticTile extends StatelessWidget {
  final HapticIntensity selected;
  final Future<void> Function(HapticIntensity) onChanged;

  const _SheetHapticTile({required this.selected, required this.onChanged});

  static const _labels = {
    HapticIntensity.off: 'Off',
    HapticIntensity.low: 'Low',
    HapticIntensity.medium: 'Medium',
    HapticIntensity.high: 'High',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vibration, color: SankofaGameTheme.mutedGold),
              const SizedBox(width: 16),
              Text(
                'Haptic Feedback',
                style: AppTextStyles.archiveBodyLarge.copyWith(
                  color: SankofaGameTheme.darkText,
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
                          ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.18)
                          : SankofaGameTheme.parchmentLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? SankofaGameTheme.antiqueGold
                            : SankofaGameTheme.parchmentDark,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _labels[level]!,
                      style: AppTextStyles.archiveLabelSmall.copyWith(
                        color: isSelected
                            ? SankofaGameTheme.mutedGold
                            : SankofaGameTheme.mutedText,
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

class _PausedOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHowToPlay;
  final VoidCallback onQuit;

  const _PausedOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onHowToPlay,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.panelFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.archiveGoldDeep, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowWarm.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PAUSED', style: AppTextStyles.archiveDisplayMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              style: _archiveElevatedButtonStyle(),
              onPressed: onResume,
              child: const Text('Resume'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: _archiveElevatedButtonStyle(),
              onPressed: onRestart,
              child: const Text('Restart Level'),
            ),
            const SizedBox(height: 12),
            const _PauseSettingsControls(),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onHowToPlay,
              child: Text(
                'How to Play',
                style: AppTextStyles.archiveBodyMedium,
              ),
            ),
            TextButton(
              onPressed: onQuit,
              child: Text(
                'Exit to Home',
                style: AppTextStyles.archiveBodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseSettingsControls extends ConsumerWidget {
  const _PauseSettingsControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        _CompactSwitch(
          label: 'Sound',
          value: settings.soundEnabled,
          onChanged: notifier.setSoundEnabled,
        ),
        _CompactSwitch(
          label: 'Music',
          value: settings.musicEnabled,
          onChanged: notifier.setMusicEnabled,
        ),
        _CompactSwitch(
          label: 'Haptics',
          value: settings.hapticIntensity != HapticIntensity.off,
          onChanged: (enabled) => notifier.setHapticIntensity(
            enabled ? HapticIntensity.high : HapticIntensity.off,
          ),
        ),
      ],
    );
  }
}

class _CompactSwitch extends StatelessWidget {
  const _CompactSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.archiveBodySmall),
      activeThumbColor: AppColors.archiveGoldDeep,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _LoadFailedOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _LoadFailedOverlay({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.panelFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.archiveGoldDeep, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowWarm.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BOARD UNAVAILABLE',
              style: AppTextStyles.archiveDisplaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.archiveBodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: _archiveElevatedButtonStyle(),
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBack,
              child: Text(
                'Back to Levels',
                style: AppTextStyles.archiveBodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboOverlay extends StatelessWidget {
  final int streak;
  const _ComboOverlay({super.key, required this.streak});

  String get _label => '${streak}x Combo!';

  int get _bonus => streak >= 5
      ? 200
      : streak == 4
          ? 100
          : 50;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.panelFill.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.archiveGoldDeep, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowWarm.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label,
              style: AppTextStyles.archiveDisplayMedium.copyWith(
                color: AppColors.archiveGoldDeep,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '+$_bonus bonus',
              style: AppTextStyles.archiveDisplaySmall.copyWith(
                color: AppColors.archiveInkLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuitDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const _QuitDialog({required this.onResume, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.panelFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.archiveGoldDeep, width: 1.5),
      ),
      title: Text('Leave Game?', style: AppTextStyles.archiveHeadlineMedium),
      content: Text(
        'Your progress will be lost.',
        style: AppTextStyles.archiveBodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: onResume,
          child: Text(
            'Stay',
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: AppColors.archiveGoldDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          style: _archiveElevatedButtonStyle(),
          onPressed: onQuit,
          child: const Text('Leave'),
        ),
      ],
    );
  }
}

class _ConfirmActionDialog extends StatelessWidget {
  const _ConfirmActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.panelFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.archiveGoldDeep, width: 1.5),
      ),
      title: Text(title, style: AppTextStyles.archiveHeadlineMedium),
      content: Text(message, style: AppTextStyles.archiveBodyMedium),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: AppColors.archiveGoldDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          style: _archiveElevatedButtonStyle(),
          onPressed: onConfirm,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

ButtonStyle _archiveElevatedButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: AppColors.archiveGoldDeep,
    foregroundColor: AppColors.panelFill,
    elevation: 2,
    shadowColor: AppColors.shadowWarm.withValues(alpha: 0.24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
