import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/storage_service.dart';
import 'animated_mahjong_tile.dart';

class EntryFlowDirector extends StatefulWidget {
  const EntryFlowDirector(
      {super.key, required this.storage, required this.child});
  final StorageService storage;
  final Widget child;

  @override
  State<EntryFlowDirector> createState() => _EntryFlowDirectorState();
}

class _EntryFlowDirectorState extends State<EntryFlowDirector> {
  late bool _showOverlay;

  @override
  void initState() {
    super.initState();
    final returningUser = widget.storage.hasCompletedEntryDiscovery();
    _showOverlay = returningUser && widget.storage.isAnimatedOpeningEnabled();
  }

  void _finish() => mounted ? setState(() => _showOverlay = false) : null;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          // The destination is deliberately built behind the entry overlay so
          // it is ready as soon as the opening finishes. Keep it inert while
          // covered: otherwise repeating route animations continue ticking and
          // hidden controls can receive accessibility or pointer interaction.
          TickerMode(
            key: const ValueKey('entry-flow-destination'),
            enabled: !_showOverlay,
            child: IgnorePointer(
              ignoring: _showOverlay,
              child: ExcludeSemantics(
                excluding: _showOverlay,
                child: widget.child,
              ),
            ),
          ),
          if (_showOverlay)
            KeyedSubtree(
              key: const ValueKey('entry-flow-overlay'),
              child: _ReturningSplash(
                  storage: widget.storage, onFinished: _finish),
            ),
        ],
      );
}

class _ReturningSplash extends StatefulWidget {
  const _ReturningSplash({required this.storage, required this.onFinished});
  final StorageService storage;
  final VoidCallback onFinished;

  @override
  State<_ReturningSplash> createState() => _ReturningSplashState();
}

class _ReturningSplashState extends State<_ReturningSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  final _started = DateTime.now();
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEntryFlowShown('returning');
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _timer = Timer(const Duration(milliseconds: 1200), () => _exit(false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      _controller.stop();
      _controller.value = .5;
    } else if (!_controller.isAnimating && !_exiting) {
      _controller.repeat(reverse: true);
    }
  }

  Future<void> _exit(bool tapped) async {
    if (_exiting) return;
    _exiting = true;
    _controller.stop();
    _timer?.cancel();
    final immediate =
        tapped && DateTime.now().difference(_started).inMilliseconds <= 300;
    await widget.storage.recordReturningSplashCompletion(immediate: immediate);
    AnalyticsService.logEntryReturningSplashCompleted(
        skipped: tapped, immediate: immediate);
    if (!mounted) return;
    setState(() {});
    await Future<void>.delayed(MediaQuery.of(context).disableAnimations
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 260));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    const ids = ['gye_nyame', 'sankofa2', 'dwennimmen', 'akoma'];
    return Semantics(
      button: true,
      label: 'Adinkra Tiles opening. Tap to continue.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _exit(true),
        child: AnimatedOpacity(
          opacity: _exiting ? 0 : 1,
          duration: reduced
              ? const Duration(milliseconds: 120)
              : const Duration(milliseconds: 260),
          child: DecoratedBox(
            decoration:
                const BoxDecoration(gradient: SankofaGameTheme.screenGradient),
            child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) => Transform.translate(
                        offset:
                            Offset(0, reduced ? 0 : -1 + _controller.value * 2),
                        child: SizedBox(
                          width: 230,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: .74,
                                    crossAxisSpacing: 8),
                            itemCount: ids.length,
                            itemBuilder: (_, i) => AnimatedMahjongTile(
                                definition: kAllTiles.firstWhere(
                                  (tile) => tile.id == ids[i],
                                ),
                                faceUp: true,
                                reducedMotion: reduced),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Adinkra Tiles',
                        style: AppTextStyles.archiveDisplayMedium
                            .copyWith(color: SankofaGameTheme.antiqueGold)),
                    const SizedBox(height: 10),
                    Text('Tap to continue',
                        style: AppTextStyles.archiveBodyMedium
                            .copyWith(color: SankofaGameTheme.mutedLightText)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
