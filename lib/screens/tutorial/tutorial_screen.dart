import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/haptic_service.dart';
import '../../models/tile_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';
import '../game/widgets/tile_widget.dart';
import 'tutorial_controller.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key, this.replay = false});
  final bool replay;

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  late final TutorialController _controller;
  Timer? _feedbackTimer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TutorialController()..addListener(_refresh);
    AnalyticsService.logTutorialStarted(replay: widget.replay);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _finish({required bool skipped}) async {
    _feedbackTimer?.cancel();
    _advanceTimer?.cancel();
    await ref.read(storageServiceProvider).setTutorialComplete();
    if (skipped) {
      AnalyticsService.logTutorialSkipped();
    } else {
      AnalyticsService.logTutorialCompleted();
    }
    unawaited(ref.read(audioServiceProvider).stopGameAudio());
    if (mounted) context.go(skipped ? '/' : '/game/1');
  }

  void _tapTile(String uid) {
    final result = _controller.tap(uid);
    final settings = ref.read(settingsProvider);
    if (result == TutorialTapResult.matched) {
      ref.read(audioServiceProvider).playMatch();
      HapticService.sequence(settings.hapticIntensity, [0, 80]);
      AnalyticsService.logTutorialStepCompleted(_controller.lessonNumber);
      if (_controller.lessonComplete) {
        _advanceTimer?.cancel();
        _advanceTimer = Timer(const Duration(milliseconds: 650), () {
          if (mounted) _controller.advanceLesson();
        });
      }
    } else if (result == TutorialTapResult.blocked ||
        result == TutorialTapResult.covered ||
        result == TutorialTapResult.mismatch) {
      HapticService.tilePress(settings.hapticIntensity);
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) _controller.clearFeedback();
      });
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _advanceTimer?.cancel();
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final complete = _controller.lesson == TutorialLesson.completed;
    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: SafeArea(
          child: complete
              ? _TutorialCompletion(onPlay: () => _finish(skipped: false))
              : LayoutBuilder(builder: (context, constraints) {
                  final compact = constraints.maxHeight < 650;
                  return Column(
                    children: [
                      _TutorialHud(
                        lesson: _controller.lessonNumber,
                        matched: _controller.lessonPairsMatched,
                        target: _controller.lessonPairTarget,
                        onSkip: () => _finish(skipped: true),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(18, compact ? 5 : 10, 18, 0),
                        child:
                            _InstructionBanner(text: _controller.instruction),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(8, compact ? 4 : 10, 8, 8),
                          child: TutorialBoard(
                            controller: _controller,
                            reducedMotion: reducedMotion,
                            onTapTile: _tapTile,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
        ),
      ),
    );
  }
}

class _TutorialHud extends StatelessWidget {
  const _TutorialHud(
      {required this.lesson,
      required this.matched,
      required this.target,
      required this.onSkip});
  final int lesson, matched, target;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Tutorial lesson $lesson of 5. Pairs $matched of $target.',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 10, 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('TUTORIAL  •  LEVEL 0.5',
                        style: AppTextStyles.archiveLabelSmall.copyWith(
                            color: SankofaGameTheme.antiqueGold,
                            fontWeight: FontWeight.w900)),
                    Text('Lesson $lesson / 5',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: SankofaGameTheme.parchmentLight)),
                  ])),
              TextButton(
                  onPressed: onSkip,
                  child: Text('Skip',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: SankofaGameTheme.mutedGold))),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(
                          target,
                          (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.all(3),
                                width: 28,
                                height: 18,
                                decoration: BoxDecoration(
                                    color: index < matched
                                        ? SankofaGameTheme.antiqueGold
                                        : SankofaGameTheme.backgroundBottom
                                            .withValues(alpha: .65),
                                    border: Border.all(
                                        color: SankofaGameTheme.mutedGold),
                                    borderRadius: BorderRadius.circular(4)),
                              )))),
              const SizedBox(width: 8),
              Text('$matched / $target',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: SankofaGameTheme.parchmentLight,
                      fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      );
}

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        header: true,
        label: text,
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          child: Container(
            key: UniqueKey(),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  SankofaGameTheme.parchmentLight,
                  SankofaGameTheme.parchmentDark
                ]),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: SankofaGameTheme.antiqueGold, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 5))
                ]),
            child: Text(text,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.archiveTitleLarge
                    .copyWith(color: SankofaGameTheme.darkText, fontSize: 20)),
          ),
        ),
      );
}

@visibleForTesting
class TutorialBoard extends StatelessWidget {
  const TutorialBoard(
      {super.key,
      required this.controller,
      required this.reducedMotion,
      required this.onTapTile});
  final TutorialController controller;
  final bool reducedMotion;
  final ValueChanged<String> onTapTile;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final paintTiles = [...controller.tiles]..sort((a, b) {
            final layerOrder = a.layer.compareTo(b.layer);
            if (layerOrder != 0) return layerOrder;
            if (a.isSelected == b.isSelected) return 0;
            return a.isSelected ? 1 : -1;
          });
        final minCol = controller.tiles.map((tile) => tile.col).reduce(min);
        final maxCol = controller.tiles.map((tile) => tile.col).reduce(max);
        final minRow = controller.tiles.map((tile) => tile.row).reduce(min);
        final maxRow = controller.tiles.map((tile) => tile.row).reduce(max);
        final logicalColumns = (maxCol - minCol) / 2 + 1;
        final logicalRows = (maxRow - minRow) / 2 + 1;
        final tileW = min(c.maxWidth / (logicalColumns + .12),
            c.maxHeight / (logicalRows * 1.34 + .25));
        final width = tileW.clamp(64.0, 112.0);
        final height = width * 1.31;
        final boardW = c.maxWidth;
        final colStep = width * .5125;
        final rowStep = height * .53;
        final contentW = (maxCol - minCol) * colStep + width;
        final contentH = (maxRow - minRow) * rowStep + height;
        final boardH = min(c.maxHeight, contentH + 24);
        return Center(
            child: RepaintBoundary(
                child: SizedBox(
          width: boardW,
          height: boardH,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(
                child: CustomPaint(painter: _BoardAtmospherePainter())),
            for (final tile in paintTiles)
              _positionedTile(context, tile, minCol, minRow, width, height,
                  colStep, rowStep, contentW, contentH, boardW, boardH),
          ]),
        )));
      });

  Widget _positionedTile(
      BuildContext context,
      TileModel tile,
      int minCol,
      int minRow,
      double width,
      double height,
      double colStep,
      double rowStep,
      double contentW,
      double contentH,
      double boardW,
      double boardH) {
    var left = (boardW - contentW) / 2 + (tile.col - minCol) * colStep;
    var top = (boardH - contentH) / 2 + (tile.row - minRow) * rowStep;
    if (tile.layer > 0) {
      top -= height * .10 * tile.layer;
      left += width * .055 * tile.layer;
    }
    final free = controller.isFree(tile);
    final covered = controller.isCovered(tile);
    final target = tile.uid == controller.targetUid;
    final semantics = tile.isCovered
        ? 'Face-down tile. ${free ? 'Free. Tap to reveal.' : covered ? 'Covered by another tile.' : 'Blocked on both sides.'}'
        : '${tile.def.name} tile. ${tile.isMatched ? 'Matched.' : tile.isSelected ? 'Selected. Find its matching tile.' : covered ? 'Covered by another tile.' : free ? 'Free. Tap to select.' : 'Blocked on both sides.'}';
    return AnimatedPositioned(
      key: ValueKey(tile.uid),
      duration:
          reducedMotion ? Duration.zero : const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
          button: !tile.isMatched,
          label: semantics,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapTile(tile.uid),
            child: Stack(clipBehavior: Clip.none, children: [
              AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  opacity: tile.isMatched ? 0 : 1,
                  child: IgnorePointer(
                      child: TileWidget(
                          tile: tile,
                          width: width,
                          height: height,
                          isAvailable: free,
                          isHinted: false,
                          isCoordinatedMatch: tile.isMatched,
                          showSuitCode: true,
                          forceHideName: width < 78))),
              if (target && !tile.isMatched)
                Positioned.fill(
                    child: IgnorePointer(
                        child: Container(
                  key: ValueKey('tutorial-target-glow-${tile.uid}'),
                  margin: EdgeInsets.all(width * .035),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .12),
                    border: Border.all(
                      color: SankofaGameTheme.antiqueGold.withValues(alpha: .8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            SankofaGameTheme.antiqueGold.withValues(alpha: .28),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ))),
              if (target && !tile.isMatched)
                Positioned.fill(
                    child: IgnorePointer(
                        child: TutorialPointer(reducedMotion: reducedMotion))),
            ]),
          )),
    );
  }
}

class TutorialPointer extends StatefulWidget {
  const TutorialPointer({super.key, required this.reducedMotion});
  final bool reducedMotion;
  @override
  State<TutorialPointer> createState() => _TutorialPointerState();
}

class _TutorialPointerState extends State<TutorialPointer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    if (!widget.reducedMotion && !kRunningTests) _animation.repeat();
  }

  @override
  void didUpdateWidget(covariant TutorialPointer old) {
    super.didUpdateWidget(old);
    if (widget.reducedMotion) {
      _animation.stop();
    } else if (!_animation.isAnimating && !kRunningTests) {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: AnimatedBuilder(
          animation: _animation,
          builder: (_, __) {
            final value = widget.reducedMotion ? .35 : _animation.value;
            final pulse = sin(value * pi);
            return Align(
                alignment: const Alignment(.62, .72),
                child: Transform.scale(
                  scale: 1 - pulse * .12,
                  child: Container(
                      width: 30 + value * 16,
                      height: 30 + value * 16,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SankofaGameTheme.antiqueGold
                              .withValues(alpha: .14 * (1 - value)),
                          border: Border.all(
                              color: SankofaGameTheme.antiqueGold,
                              width: 2.5 - value))),
                ));
          }));
}

class _TutorialCompletion extends StatelessWidget {
  const _TutorialCompletion({required this.onPlay});
  final VoidCallback onPlay;
  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
            liveRegion: true,
            label: 'Tutorial completed.',
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.all(28),
              decoration: SankofaGameTheme.appParchmentPanelDecoration,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome,
                    size: 54, color: SankofaGameTheme.antiqueGold),
                const SizedBox(height: 14),
                Text('Tutorial Complete',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall
                        .copyWith(color: SankofaGameTheme.darkText)),
                const SizedBox(height: 10),
                Text('You are ready to begin your journey.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.archiveBodyMedium
                        .copyWith(color: SankofaGameTheme.darkText)),
                const SizedBox(height: 24),
                KenteButton(
                    label: 'PLAY LEVEL 1',
                    icon: Icons.play_arrow_rounded,
                    width: double.infinity,
                    onTap: onPlay),
              ]),
            )),
      ));
}

class _BoardAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: .055);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.shortestSide * .43, paint);
    final ring = Paint()
      ..color = SankofaGameTheme.antiqueGold.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.shortestSide * .34, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
