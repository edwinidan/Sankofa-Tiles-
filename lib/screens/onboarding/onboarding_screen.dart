import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/analytics_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
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

  final _pages = const [_Page1(), _Page2(), _Page3(), _Page4()];

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
    if (mounted) context.go('/');
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

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      icon: Icons.touch_app_outlined,
      title: 'How to Play',
      body: '',
      child: Column(
        children: [
          const _StepRow(number: '1', text: 'Tap any tile to select it'),
          const SizedBox(height: 12),
          const _StepRow(
            number: '2',
            text: 'Tap another tile with the same Adinkra symbol',
          ),
          const SizedBox(height: 12),
          const _StepRow(
            number: '3',
            text: 'Matching pairs are removed from the board',
          ),
          const SizedBox(height: 12),
          const _StepRow(
            number: '4',
            text: 'Clear all tiles to complete the level',
          ),
          const SizedBox(height: 20),
          const AdinkraDivider(),
          const SizedBox(height: 12),
          Text(
            'Use hints to highlight a matching pair.\nShuffle to rearrange remaining tiles.',
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: SankofaGameTheme.mutedGold,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  static const _exampleTiles = [
    'nyansapo',
    'sankofa',
    'gye_nyame',
    'akoma',
    'adinkrahene',
    'aya',
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = kAllTiles.where((t) => _exampleTiles.contains(t.id)).toList();

    return _OnboardingPage(
      icon: Icons.auto_awesome_outlined,
      title: 'The Symbols',
      body: 'Each tile carries an Adinkra symbol with deep meaning:',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
        children: tiles.map((def) => _TilePreview(def: def)).toList(),
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
      title: 'Ready?',
      body:
          'Gye Nyame — "Except God" — the most important Adinkra symbol, representing the supremacy of the Almighty.\n\n'
          'May your journey through Adinkra Tiles be filled with wisdom and joy.',
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

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: SankofaGameTheme.antiqueGold,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.archiveLabelSmall.copyWith(
              color: SankofaGameTheme.darkText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: SankofaGameTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class _TilePreview extends StatelessWidget {
  final TileDefinition def;

  const _TilePreview({required this.def});

  @override
  Widget build(BuildContext context) {
    final assetPath = def.assetPath;

    return Container(
      decoration: BoxDecoration(
        gradient: SankofaGameTheme.appPanelGradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: assetPath != null
                ? Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _SymbolFallback(def: def),
                  )
                : _SymbolFallback(def: def),
          ),
          const SizedBox(height: 4),
          Text(
            def.name,
            style: AppTextStyles.tileName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            def.meaning,
            style: AppTextStyles.tileName.copyWith(fontSize: 7),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
