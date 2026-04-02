import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/board_widget.dart';
import 'widgets/game_hud.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  final DifficultyMode difficulty;

  const GameScreen({
    super.key,
    required this.levelId,
    required this.difficulty,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showCombo = false;
  int _displayedStreak = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startLevel(
        widget.levelId,
        widget.difficulty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    ref.listen<GameState>(gameProvider, (prev, next) {
      // Navigate to result when game ends
      if (prev?.status != next.status &&
          (next.status == GameStatus.won || next.status == GameStatus.lost)) {
        final capturedNext = next;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          context.go('/result', extra: capturedNext);
        });
      }

      // Show combo banner when streak reaches or extends past 3
      if (next.currentStreak >= 3 &&
          next.currentStreak != (prev?.currentStreak ?? 0)) {
        setState(() {
          _showCombo = true;
          _displayedStreak = next.currentStreak;
        });
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) setState(() => _showCombo = false);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(levelId: widget.levelId),

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
                            onQuit: () => context.go('/level-select'),
                          )
                        : const BoardWidget(),
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
                            .fade(
                              begin: 1.0,
                              end: 0.0,
                              duration: 480.ms,
                            ),
                      ),
                  ],
                ),
              ),
            ),

            _BottomBar(gameState: gameState),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final int levelId;
  const _TopBar({required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.kenteGold),
            onPressed: () {
              ref.read(gameProvider.notifier).pauseGame();
              showDialog(
                context: context,
                builder: (_) => _QuitDialog(
                  onResume: () {
                    Navigator.pop(context);
                    ref.read(gameProvider.notifier).resumeGame();
                  },
                  onQuit: () {
                    Navigator.pop(context);
                    context.go('/level-select');
                  },
                ),
              );
            },
          ),
          const Spacer(),
          Text('Level $levelId', style: AppTextStyles.displaySmall),
          const Spacer(),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
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

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

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
            ElevatedButton(
              onPressed: onResume,
              child: const Text('Resume'),
            ),
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

class _ComboOverlay extends StatelessWidget {
  final int streak;
  const _ComboOverlay({super.key, required this.streak});

  String get _label => '${streak}x Combo!';

  int get _bonus => streak >= 5 ? 200 : streak == 4 ? 100 : 50;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.navyMid.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.kenteGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.kenteGold.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_label, style: AppTextStyles.displayMedium),
            const SizedBox(height: 4),
            Text(
              '+$_bonus bonus',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.tileSelected,
                fontSize: 15,
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
        TextButton(
          onPressed: onResume,
          child: const Text('Stay'),
        ),
        ElevatedButton(
          onPressed: onQuit,
          child: const Text('Leave'),
        ),
      ],
    );
  }
}
