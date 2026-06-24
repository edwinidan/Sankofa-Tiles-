import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key, this.replay = false});

  final bool replay;

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  int _step = 0;
  final Set<int> _matchedPairs = {};
  bool _hintShown = false;

  static const _steps = [
    'Choose the glowing free tile.',
    'Now choose its matching symbol.',
    'This center tile is blocked. A tile must have one side open.',
    'Use Hint to reveal a safe pair.',
    'Clear the final pair.',
    'Tutorial complete.',
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logTutorialStarted(replay: widget.replay);
  }

  void _completeStep() {
    AnalyticsService.logTutorialStepCompleted(_step + 1);
    setState(() => _step = (_step + 1).clamp(0, _steps.length - 1));
  }

  Future<void> _finish() async {
    await ref.read(storageServiceProvider).setTutorialComplete();
    AnalyticsService.logTutorialCompleted();
    if (mounted) context.go('/');
  }

  Future<void> _skip() async {
    await ref.read(storageServiceProvider).setTutorialComplete();
    AnalyticsService.logTutorialSkipped();
    if (mounted) context.go('/');
  }

  void _tapTile(int index) {
    if (_step == 0 && index == 0) {
      _completeStep();
      return;
    }
    if (_step == 1 && index == 1) {
      setState(() => _matchedPairs.add(0));
      _completeStep();
      return;
    }
    if (_step == 2 && index == 2) {
      _completeStep();
      return;
    }
    if (_step == 4 && (index == 4 || index == 5)) {
      setState(() => _matchedPairs.add(2));
      _completeStep();
    }
  }

  void _useHint() {
    if (_step != 3) return;
    setState(() => _hintShown = true);
    _completeStep();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _step == _steps.length - 1;

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            color: SankofaGameTheme.parchmentLight,
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => context.go('/'),
                          ),
                          Expanded(
                            child: Text(
                              'Interactive Tutorial',
                              style: AppTextStyles.displaySmall.copyWith(
                                color: SankofaGameTheme.antiqueGold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: SankofaGameTheme.mutedLightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration:
                            SankofaGameTheme.appParchmentPanelDecoration,
                        child: Column(
                          children: [
                            Text(
                              _steps[_step],
                              style: AppTextStyles.archiveTitleLarge.copyWith(
                                color: SankofaGameTheme.darkText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            _TutorialBoard(
                              step: _step,
                              matchedPairs: _matchedPairs,
                              hintShown: _hintShown,
                              onTapTile: _tapTile,
                            ),
                            const SizedBox(height: 18),
                            if (_step == 3)
                              KenteButton(
                                label: 'HINT',
                                icon: Icons.lightbulb_outline,
                                width: double.infinity,
                                onTap: _useHint,
                              )
                            else if (isDone)
                              KenteButton(
                                label: 'CONTINUE',
                                icon: Icons.home_outlined,
                                width: double.infinity,
                                onTap: _finish,
                              )
                            else
                              Text(
                                'Follow the highlighted tile.',
                                style: AppTextStyles.archiveBodyMedium.copyWith(
                                  color: SankofaGameTheme.mutedGold,
                                ),
                              ),
                          ],
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

class _TutorialBoard extends StatelessWidget {
  const _TutorialBoard({
    required this.step,
    required this.matchedPairs,
    required this.hintShown,
    required this.onTapTile,
  });

  final int step;
  final Set<int> matchedPairs;
  final bool hintShown;
  final ValueChanged<int> onTapTile;

  static const _labels = ['Gye', 'Gye', 'Aya', 'Aya', 'Sanko', 'Sanko'];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: DecoratedBox(
        decoration: SankofaGameTheme.darkPanelDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth * 0.28).clamp(72.0, 92.0);
            final tileHeight = tileWidth * 0.82;
            const positions = [
              Offset(0.10, 0.08),
              Offset(0.62, 0.08),
              Offset(0.36, 0.34),
              Offset(0.37, 0.50),
              Offset(0.10, 0.73),
              Offset(0.62, 0.73),
            ];

            return Stack(
              children: List.generate(_labels.length, (index) {
                final pair = index ~/ 2;
                final matched = matchedPairs.contains(pair);
                final highlighted = (step == 0 && index == 0) ||
                    (step == 1 && index == 1) ||
                    (step == 2 && index == 2) ||
                    (hintShown && (index == 4 || index == 5)) ||
                    (step == 4 && (index == 4 || index == 5));

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  left: positions[index].dx * constraints.maxWidth,
                  top: positions[index].dy * constraints.maxHeight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: matched ? 0 : 1,
                    child: _TutorialTile(
                      label: _labels[index],
                      width: tileWidth,
                      height: tileHeight,
                      highlighted: highlighted,
                      blocked: step == 2 && index == 2,
                      onTap: () => onTapTile(index),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _TutorialTile extends StatelessWidget {
  const _TutorialTile({
    required this.label,
    required this.width,
    required this.height,
    required this.highlighted,
    required this.blocked,
    required this.onTap,
  });

  final String label;
  final double width;
  final double height;
  final bool highlighted;
  final bool blocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label tutorial tile',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blocked
                ? SankofaGameTheme.parchmentDark
                : SankofaGameTheme.parchmentLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: highlighted
                  ? SankofaGameTheme.antiqueGold
                  : SankofaGameTheme.parchmentDark,
              width: highlighted ? 3 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? SankofaGameTheme.antiqueGold.withValues(alpha: 0.36)
                    : Colors.black.withValues(alpha: 0.18),
                blurRadius: highlighted ? 18 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.archiveLabelSmall.copyWith(
              color: SankofaGameTheme.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
