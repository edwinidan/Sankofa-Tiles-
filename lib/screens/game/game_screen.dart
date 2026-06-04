import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_state.dart';
import '../../core/utils/haptic_service.dart';
import '../../core/utils/audio_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/tile_theme_type.dart';
import '../../core/constants/level_data.dart';
import 'widgets/board_widget.dart';
import 'widgets/game_hud.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  final DifficultyMode difficulty;
  final TileThemeType? tileThemeOverride;

  const GameScreen({
    super.key,
    required this.levelId,
    required this.difficulty,
    this.tileThemeOverride,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showCombo = false;
  int _displayedStreak = 0;
  DateTime? _lastMatchTime;
  late final Stopwatch _levelLoadStopwatch;
  late final AudioService _audioService;
  bool _reportedReadyFrame = false;

  void _returnToLevelSelect() {
    ref.read(gameProvider.notifier).leaveGame();
    context.go('/level-select');
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
          _returnToLevelSelect();
        },
      ),
    );
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
      ref
          .read(gameProvider.notifier)
          .startLevel(widget.levelId, widget.difficulty);
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
          context.go('/result', extra: capturedNext);
        });
      }

      // Time-based Combo Trigger
      // Only show banner if matches are fast: (2 in 2s, 3 in 5s, 4+ in 4s)
      if (next.currentStreak > (prev?.currentStreak ?? 0)) {
        final now = DateTime.now();
        bool showBanner = false;

        if (_lastMatchTime != null) {
          final diff = now.difference(_lastMatchTime!).inMilliseconds / 1000.0;
          final streak = next.currentStreak;

          if (streak == 2 && diff <= 2.0) {
            showBanner = true;
          } else if (streak == 3 && diff <= 5.0) {
            showBanner = true;
          } else if (streak >= 4 && diff <= 4.0) {
            showBanner = true;
          }
        }

        _lastMatchTime = now;

        if (showBanner) {
          _fireComboHaptic(next.currentStreak);
          setState(() {
            _showCombo = true;
            _displayedStreak = next.currentStreak;
          });
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted) setState(() => _showCombo = false);
          });
        }
      } else if (next.currentStreak == 0) {
        _lastMatchTime = null;
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_confirmQuit());
      },
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                levelId: widget.levelId,
                title: widget.levelId == kTileV2TestLevelId
                    ? 'Tile V2 Test'
                    : null,
                onBack: _confirmQuit,
              ),

              const GameHud(),

              // Board + combo overlay
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      gameState.status == GameStatus.paused
                          ? _PausedOverlay(
                              onResume: () =>
                                  ref.read(gameProvider.notifier).resumeGame(),
                              onQuit: _returnToLevelSelect,
                            )
                          : gameState.status == GameStatus.loadFailed
                              ? _LoadFailedOverlay(
                                  message: gameState.loadError ??
                                      'We could not prepare this board.',
                                  onRetry: () => ref
                                      .read(gameProvider.notifier)
                                      .startLevel(
                                        widget.levelId,
                                        widget.difficulty,
                                      ),
                                  onBack: _returnToLevelSelect,
                                )
                              : BoardWidget(
                                  tileThemeOverride: widget.tileThemeOverride,
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

              _BottomBar(gameState: gameState),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final int levelId;
  final String? title;
  final VoidCallback onBack;
  const _TopBar({
    required this.levelId,
    required this.onBack,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.kenteGold),
            onPressed: onBack,
          ),
          const Spacer(),
          Text(title ?? 'Level $levelId', style: AppTextStyles.displaySmall),
          const Spacer(),
          IconButton(
            tooltip: 'Settings',
            icon:
                const Icon(Icons.settings_outlined, color: AppColors.kenteGold),
            onPressed: () => _openGameSettings(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _openGameSettings(BuildContext context, WidgetRef ref) async {
    final wasPlaying = ref.read(gameProvider).status == GameStatus.playing;
    if (wasPlaying) {
      ref.read(gameProvider.notifier).pauseGame();
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.navyMid,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _GameSettingsSheet(),
    );

    if (!context.mounted) return;
    if (wasPlaying && ref.read(gameProvider).status == GameStatus.paused) {
      ref.read(gameProvider.notifier).resumeGame();
    }
  }
}

class _BottomBar extends ConsumerWidget {
  final GameState gameState;
  const _BottomBar({required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final isPlaying = gameState.status == GameStatus.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.navyMid,
        border: Border(
          top: BorderSide(color: AppColors.kenteGoldDim, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            onTap: isPlaying ? notifier.useHint : null,
          ),
          _ActionButton(
            icon: Icons.shuffle,
            label: 'Shuffle (-50)',
            onTap: isPlaying ? notifier.shuffleRemaining : null,
          ),
          _ActionButton(
            icon: gameState.status == GameStatus.paused
                ? Icons.play_arrow
                : Icons.pause,
            label: gameState.status == GameStatus.paused ? 'Resume' : 'Pause',
            onTap: gameState.status == GameStatus.paused
                ? notifier.resumeGame
                : (isPlaying ? notifier.pauseGame : null),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: enabled ? AppColors.kenteGold : AppColors.textMuted,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: enabled ? AppColors.kenteGold : AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
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

    return SafeArea(
      child: Padding(
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
                  color: AppColors.navyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text('Settings', style: AppTextStyles.displaySmall),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, color: AppColors.kenteGold),
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
      secondary: Icon(icon, color: AppColors.kenteGold),
      title: Text(label, style: AppTextStyles.bodyLarge),
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
                color: enabled ? AppColors.kenteGold : AppColors.textMuted,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Music Volume',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color:
                        enabled ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: enabled ? AppColors.kenteGold : AppColors.textMuted,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: AppColors.kenteGold,
            inactiveColor: AppColors.navyLight,
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

class _PausedOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const _PausedOverlay({required this.onResume, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.navyMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.kenteGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PAUSED', style: AppTextStyles.displayMedium),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onResume, child: const Text('Resume')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onQuit,
              child: Text(
                'Quit to Menu',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
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
          color: AppColors.navyMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.kenteGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BOARD UNAVAILABLE', style: AppTextStyles.displaySmall),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBack,
              child: Text(
                'Back to Levels',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
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
          color: AppColors.navyMid.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.kenteGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.kenteGold.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label,
              style: AppTextStyles.displayMedium.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 3),
            Text(
              '+$_bonus bonus',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.tileSelected,
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
      backgroundColor: AppColors.navyMid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.kenteGold, width: 1.5),
      ),
      title: Text('Leave Game?', style: AppTextStyles.headlineMedium),
      content: Text(
        'Your progress will be lost.',
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(onPressed: onResume, child: const Text('Stay')),
        ElevatedButton(onPressed: onQuit, child: const Text('Leave')),
      ],
    );
  }
}
