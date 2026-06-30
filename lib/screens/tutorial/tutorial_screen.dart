import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../models/tile_model.dart';
import '../../providers/settings_provider.dart';
import '../../screens/game/widgets/tile_widget.dart';
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
    'Try the center tile. It is blocked for now.',
    'Clear this side pair to open the board.',
    'Match the side tile.',
    'Now the center tile is free.',
    'Match the center pair.',
    'Use Hint to reveal a safe pair.',
    'Choose the hinted tile.',
    'Match the final tile.',
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
    if (_step == 3 && index == 6) {
      _completeStep();
      return;
    }
    if (_step == 4 && index == 7) {
      setState(() => _matchedPairs.add(3));
      _completeStep();
      return;
    }
    if (_step == 5 && index == 2) {
      _completeStep();
      return;
    }
    if (_step == 6 && index == 3) {
      setState(() => _matchedPairs.add(1));
      _completeStep();
      return;
    }
    if (_step == 8 && index == 4) {
      _completeStep();
      return;
    }
    if (_step == 9 && index == 5) {
      setState(() => _matchedPairs.add(2));
      _completeStep();
    }
  }

  void _useHint() {
    if (_step != 7) return;
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
                            const SizedBox(height: 12),
                            _TutorialMiniHud(
                              step: _step,
                              matchedPairs: _matchedPairs.length,
                            ),
                            const SizedBox(height: 18),
                            _TutorialBoard(
                              step: _step,
                              matchedPairs: _matchedPairs,
                              hintShown: _hintShown,
                              onTapTile: _tapTile,
                            ),
                            const SizedBox(height: 18),
                            if (_step == 7)
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

class _TutorialMiniHud extends StatelessWidget {
  const _TutorialMiniHud({
    required this.step,
    required this.matchedPairs,
  });

  final int step;
  final int matchedPairs;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        const _TutorialHudChip(
          icon: Icons.flag_outlined,
          label: 'Level 0.5',
        ),
        _TutorialHudChip(
          icon: Icons.grid_view_outlined,
          label: '$matchedPairs / 4 pairs',
        ),
        _TutorialHudChip(
          icon: step >= 7 ? Icons.lightbulb_outline : Icons.lock_open_outlined,
          label: step >= 7 ? 'Hint ready' : 'Free sides',
        ),
      ],
    );
  }
}

class _TutorialHudChip extends StatelessWidget {
  const _TutorialHudChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SankofaGameTheme.parchmentDark.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SankofaGameTheme.mutedGold.withValues(alpha: 0.48),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SankofaGameTheme.mutedGold),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.archiveLabelSmall.copyWith(
              color: SankofaGameTheme.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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

  static final List<TileModel> _tiles = [
    _tile('tutorial-gye-1', kAllTiles[9], 0, 0),
    _tile('tutorial-gye-2', kAllTiles[9], 0, 4),
    _tile('tutorial-aya-covered', kAllTiles[23], 1, 2, layer: 1),
    _tile('tutorial-aya-base', kAllTiles[23], 2, 2),
    _tile('tutorial-sankofa-1', kAllTiles[38], 4, 0),
    _tile('tutorial-sankofa-2', kAllTiles[38], 4, 4),
    _tile('tutorial-akoma-1', kAllTiles[14], 2, 0),
    _tile('tutorial-akoma-2', kAllTiles[14], 2, 4),
  ];

  static TileModel _tile(
    String uid,
    TileDefinition def,
    int row,
    int col, {
    int layer = 0,
  }) {
    return TileModel(uid: uid, def: def, row: row, col: col, layer: layer);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: SankofaGameTheme.darkPanelDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth * 0.22).clamp(56.0, 86.0);
            final tileHeight = tileWidth * 1.32;
            const positions = [
              Offset(0.10, 0.05),
              Offset(0.68, 0.05),
              Offset(0.39, 0.23),
              Offset(0.39, 0.43),
              Offset(0.10, 0.70),
              Offset(0.68, 0.70),
              Offset(0.10, 0.38),
              Offset(0.68, 0.38),
            ];

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TutorialBoardGuidePainter(),
                  ),
                ),
                ...List.generate(_tiles.length, (index) {
                  final pair = index ~/ 2;
                  final matched = matchedPairs.contains(pair);
                  final selected = (step == 1 && index == 0) ||
                      (step == 4 && index == 6) ||
                      (step == 6 && index == 2) ||
                      (step == 9 && index == 4);
                  final highlighted = (step == 0 && index == 0) ||
                      (step == 1 && index == 1) ||
                      (step == 2 && index == 2) ||
                      (step == 3 && index == 6) ||
                      (step == 4 && index == 7) ||
                      (step == 5 && index == 2) ||
                      (step == 6 && index == 3) ||
                      (hintShown && (index == 4 || index == 5)) ||
                      (step == 8 && index == 4) ||
                      (step == 9 && index == 5);
                  final centerBlocked = step <= 4;
                  final covered = centerBlocked && (index == 2 || index == 3);
                  final available = !centerBlocked || index != 2 && index != 3;
                  final tile = _tiles[index].copyWith(
                    isSelected: selected,
                    isHinted: highlighted,
                    isMatched: matched,
                    visibility: covered
                        ? TileVisibility.covered
                        : TileVisibility.revealed,
                  );

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    left: positions[index].dx * constraints.maxWidth,
                    top: positions[index].dy * constraints.maxHeight,
                    width: tileWidth,
                    height: tileHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTapTile(index),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: matched ? 0 : 1,
                        child: IgnorePointer(
                          child: TileWidget(
                            tile: tile,
                            width: tileWidth,
                            height: tileHeight,
                            isAvailable: available,
                            showSuitCode: true,
                            forceHideName: tileWidth < 68,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                _TutorialCoachOverlay(step: step),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TutorialCoachOverlay extends StatelessWidget {
  const _TutorialCoachOverlay({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final text = switch (step) {
      0 => 'Free tile',
      1 => 'Match',
      2 => 'Blocked',
      3 || 4 => 'Open side',
      5 || 6 => 'Center open',
      7 => 'Hint',
      8 || 9 => 'Final pair',
      _ => 'Well done',
    };

    final alignment = switch (step) {
      0 => Alignment.topLeft,
      1 => Alignment.topRight,
      2 => Alignment.center,
      3 => Alignment.centerLeft,
      4 => Alignment.centerRight,
      5 || 6 => Alignment.center,
      7 || 8 || 9 => Alignment.bottomCenter,
      _ => Alignment.center,
    };

    return IgnorePointer(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: SankofaGameTheme.backgroundTop.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                step == 2 ? Icons.lock_outline : Icons.touch_app_outlined,
                size: 16,
                color: SankofaGameTheme.antiqueGold,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: AppTextStyles.archiveLabelSmall.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialBoardGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final centerPaint = Paint()
      ..color = SankofaGameTheme.parchmentLight.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.68,
        height: size.height * 0.52,
      ),
      centerPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.19),
      Offset(size.width * 0.74, size.height * 0.19),
      pathPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.83),
      Offset(size.width * 0.74, size.height * 0.83),
      pathPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
