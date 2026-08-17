import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../core/utils/storage_service.dart';
import '../../widgets/sankofa_background.dart';

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
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _pulseController;
  Timer? _timer;
  final _started = DateTime.now();
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEntryFlowShown('returning');
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _timer = Timer(const Duration(milliseconds: 2400), () => _exit(false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      _revealController.value = 1;
      _pulseController.value = .5;
    } else if (_revealController.value == 0 && !_exiting) {
      _revealController.forward().then((_) {
        if (mounted && !_exiting) _pulseController.repeat(reverse: true);
      });
    }
  }

  Future<void> _exit(bool tapped) async {
    if (_exiting) return;
    _exiting = true;
    _revealController.stop();
    _pulseController.stop();
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
    _revealController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    const ids = ['gye_nyame', 'sankofa2', 'dwennimmen', 'akoma'];
    final tiles = [
      for (final id in ids) kAllTiles.firstWhere((tile) => tile.id == id),
    ];
    return Semantics(
      button: true,
      label: 'Adinkra Tiles opening. Tap to begin.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _exit(true),
        child: AnimatedOpacity(
          opacity: _exiting ? 0 : 1,
          duration: reduced
              ? const Duration(milliseconds: 120)
              : const Duration(milliseconds: 260),
          child: SankofaBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => _CeremonialOpening(
                  tiles: tiles,
                  reveal: _revealController,
                  pulse: _pulseController,
                  availableSize: constraints.biggest,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CeremonialOpening extends StatelessWidget {
  const _CeremonialOpening({
    required this.tiles,
    required this.reveal,
    required this.pulse,
    required this.availableSize,
  });

  final List<TileDefinition> tiles;
  final Animation<double> reveal;
  final Animation<double> pulse;
  final Size availableSize;

  @override
  Widget build(BuildContext context) {
    final contentWidth = availableSize.width.clamp(280.0, 430.0);
    final compact = availableSize.height < 650;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: availableSize.height * 0.08,
          left: (availableSize.width - 330) / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.045,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  SankofaGameTheme.antiqueGold,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  tiles.first.assetPath!,
                  width: 330,
                  height: 330,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22,
                vertical: compact ? 12 : 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OpeningTileComposition(
                    tiles: tiles,
                    reveal: reveal,
                    width: contentWidth - 44,
                  ),
                  SizedBox(height: compact ? 12 : 20),
                  _OpeningWordmark(reveal: reveal),
                  SizedBox(height: compact ? 18 : 28),
                  _OpeningCta(reveal: reveal, pulse: pulse),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpeningTileComposition extends StatelessWidget {
  const _OpeningTileComposition({
    required this.tiles,
    required this.reveal,
    required this.width,
  });

  final List<TileDefinition> tiles;
  final Animation<double> reveal;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tileWidth = (width * 0.255).clamp(66.0, 88.0);
    final height = tileWidth * 1.45;
    final usableWidth = width - tileWidth;
    const rotations = [-0.12, -0.045, 0.045, 0.12];
    const verticalOffsets = [16.0, 0.0, 0.0, 16.0];

    return SizedBox(
      key: const ValueKey('entry-opening-tiles'),
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: width * 0.7,
                height: tileWidth * 0.72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color:
                          SankofaGameTheme.antiqueGold.withValues(alpha: 0.16),
                      blurRadius: 46,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (var index = 0; index < tiles.length; index++)
            Positioned(
              left: usableWidth * index / (tiles.length - 1),
              top: verticalOffsets[index],
              child: _OpeningTile(
                definition: tiles[index],
                reveal: reveal,
                index: index,
                width: tileWidth,
                rotation: rotations[index],
              ),
            ),
        ],
      ),
    );
  }
}

class _OpeningTile extends StatelessWidget {
  const _OpeningTile({
    required this.definition,
    required this.reveal,
    required this.index,
    required this.width,
    required this.rotation,
  });

  final TileDefinition definition;
  final Animation<double> reveal;
  final int index;
  final double width;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        final start = 0.08 + index * 0.07;
        final progress = Curves.easeOutBack.transform(
          ((reveal.value - start) / 0.42).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - progress)),
            child: Transform.rotate(
              angle: rotation,
              child:
                  Transform.scale(scale: 0.82 + progress * 0.18, child: child),
            ),
          ),
        );
      },
      child: Container(
        width: width,
        height: width * 1.18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 14,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.18),
              blurRadius: 18,
            ),
          ],
        ),
        child: Image.asset(
          definition.assetPath!,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _OpeningWordmark extends StatelessWidget {
  const _OpeningWordmark({required this.reveal});

  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          ((reveal.value - 0.46) / 0.34).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'ADINKRA TILES',
              key: const ValueKey('entry-opening-wordmark'),
              style: AppTextStyles.displayLarge.copyWith(
                color: const Color(0xFFD4A343),
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.1,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _OpeningOrnament(),
          const SizedBox(height: 10),
          Text(
            'MATCH SYMBOLS  •  PRESERVE WISDOM',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.25,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningOrnament extends StatelessWidget {
  const _OpeningOrnament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Row(
        children: [
          const Expanded(child: _GoldHairline()),
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            transform: Matrix4.rotationZ(0.785398),
            decoration: const BoxDecoration(color: Color(0xFFD4A343)),
          ),
          const Expanded(child: _GoldHairline()),
        ],
      ),
    );
  }
}

class _GoldHairline extends StatelessWidget {
  const _GoldHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFFB88A3A), Colors.transparent],
        ),
      ),
    );
  }
}

class _OpeningCta extends StatelessWidget {
  const _OpeningCta({required this.reveal, required this.pulse});

  final Animation<double> reveal;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([reveal, pulse]),
      builder: (context, child) {
        final visibility = Curves.easeOut.transform(
          ((reveal.value - 0.72) / 0.28).clamp(0.0, 1.0),
        );
        final pulseScale = 0.992 + pulse.value * 0.016;
        return Opacity(
          opacity: visibility,
          child: Transform.scale(scale: pulseScale, child: child),
        );
      },
      child: Container(
        key: const ValueKey('entry-opening-cta'),
        width: 224,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFD4A343),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFF5D98E).withValues(alpha: 0.86),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A343).withValues(alpha: 0.23),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              color: SankofaGameTheme.backgroundTop,
              size: 21,
            ),
            const SizedBox(width: 7),
            Text(
              'TAP TO BEGIN',
              style: AppTextStyles.buttonText.copyWith(
                color: SankofaGameTheme.backgroundTop,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.45,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
