import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/tile_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/adinkra_divider.dart';
import '../../widgets/kente_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _Page1(),
    _Page2(),
    _Page3(),
    _Page4(),
  ];

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
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),

            // Dots + navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.kenteGold
                              : AppColors.navyLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Next / Finish
                  _currentPage < _pages.length - 1
                      ? KenteButton(
                          label: 'NEXT',
                          icon: Icons.arrow_forward,
                          small: true,
                          onTap: _next,
                        )
                      : KenteButton(
                          label: 'START PLAYING',
                          icon: Icons.play_arrow_rounded,
                          onTap: _finish,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setOnboardingComplete();
    if (mounted) context.go('/level-select');
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(
      symbol: '⟳',
      title: 'Welcome to\nSankofa Tiles',
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
      symbol: '◈',
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
          const _StepRow(number: '3', text: 'Matching pairs are removed from the board'),
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.kenteGoldDim,
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
    'nyansapo', 'sankofa', 'gye_nyame', 'akoma', 'adinkrahene', 'aya',
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = kAllTiles.where((t) => _exampleTiles.contains(t.id)).toList();

    return _OnboardingPage(
      symbol: '✦',
      title: 'The Symbols',
      body: 'Each tile carries an Adinkra symbol with deep meaning:',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
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
      symbol: '☀',
      title: 'Ready?',
      body:
          'Gye Nyame — "Except God" — the most important Adinkra symbol, representing the supremacy of the Almighty.\n\n'
          'May your journey through Sankofa Tiles be filled with wisdom and joy.',
    );
  }
}

// Shared layout
class _OnboardingPage extends StatelessWidget {
  final String symbol;
  final String title;
  final String body;
  final Widget? child;

  const _OnboardingPage({
    required this.symbol,
    required this.title,
    required this.body,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: AppColors.kenteGold,
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (body.isNotEmpty) ...[
            Text(
              body,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          if (child != null) child!,
        ],
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
            color: AppColors.kenteGold,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.navyDeep,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTextStyles.bodyMedium),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tileFace,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tileBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.tileEdge,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            def.symbol,
            style: AppTextStyles.tileSymbol.copyWith(fontSize: 22),
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
