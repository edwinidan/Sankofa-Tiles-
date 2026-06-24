import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [_Page1(), _Page3(), _Page4()];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: SankofaGameTheme.mutedLightText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: _pages,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? SankofaGameTheme.antiqueGold
                                : SankofaGameTheme.mutedLightText
                                    .withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    _currentPage < _pages.length - 1
                        ? KenteButton(
                            label: 'NEXT',
                            icon: Icons.arrow_forward,
                            small: true,
                            onTap: _next,
                          )
                        : Flexible(
                            child: KenteButton(
                              label: 'START PLAYING',
                              icon: Icons.play_arrow_rounded,
                              onTap: _finish,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finish() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingComplete();
    AnalyticsService.logOnboardingCompleted();
    if (mounted) context.go('/tutorial');
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(
      icon: Icons.history_rounded,
      title: 'Welcome to\nAdinkra Tiles',
      body:
          'Sankofa is an Akan word meaning "go back and get it" — the wisdom of learning from the past.\n\n'
          'This game celebrates the rich visual language of Adinkra symbols from the Akan people of Ghana and Côte d\'Ivoire, '
          'woven into a meditative tile-matching experience inspired by Mahjong solitaire.',
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  static const _exampleTileIds = [
    'adinkrahene',
    'gye_nyame',
    'akoma',
    'aya',
    'nyansapo',
    'sankofa2',
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = _exampleTileIds
        .map((id) => kAllTiles.firstWhere((tile) => tile.id == id))
        .toList();

    return _OnboardingPage(
      icon: Icons.auto_awesome_outlined,
      title: 'The Symbols',
      body: 'Each tile carries an Adinkra symbol with deep meaning:',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 14.0;
          final tileSize =
              ((constraints.maxWidth - spacing * 2) / 3).clamp(62.0, 82.0);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: spacing,
              mainAxisSpacing: 16,
              mainAxisExtent: tileSize + 24,
            ),
            itemBuilder: (context, index) {
              return _TilePreview(def: tiles[index], tileSize: tileSize);
            },
          );
        },
      ),
    );
  }
}

class _Page4 extends StatelessWidget {
  const _Page4();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(
      icon: Icons.wb_sunny_outlined,
      title: 'Ready to Practice?',
      body:
          'The next screen is a short interactive tutorial. It will teach matching, blocked tiles, and hints before your first campaign level.',
    );
  }
}

// Shared layout
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? child;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        decoration: SankofaGameTheme.appParchmentPanelDecoration,
        child: Column(
          children: [
            Icon(
              icon,
              color: SankofaGameTheme.antiqueGold,
              size: 54,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.archiveDisplayMedium.copyWith(
                color: SankofaGameTheme.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (body.isNotEmpty) ...[
              Text(
                body,
                style: AppTextStyles.archiveBodyMedium.copyWith(
                  color: SankofaGameTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _TilePreview extends StatelessWidget {
  final TileDefinition def;
  final double tileSize;

  const _TilePreview({required this.def, required this.tileSize});

  @override
  Widget build(BuildContext context) {
    final assetPath = def.assetPath;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: tileSize,
          child: assetPath != null
              ? Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _SymbolFallback(def: def),
                )
              : _SymbolFallback(def: def),
        ),
        const SizedBox(height: 6),
        Text(
          def.name,
          style: AppTextStyles.tileName.copyWith(
            color: SankofaGameTheme.darkText,
            fontSize: 10.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SymbolFallback extends StatelessWidget {
  final TileDefinition def;

  const _SymbolFallback({required this.def});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        def.symbol,
        style: AppTextStyles.tileSymbol.copyWith(fontSize: 22),
      ),
    );
  }
}
