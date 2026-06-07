import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/tile_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../models/game_state.dart';
import '../../models/tile_model.dart';
import '../game/widgets/tile_widget.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class TilePreviewScreen extends ConsumerStatefulWidget {
  const TilePreviewScreen({super.key});

  @override
  ConsumerState<TilePreviewScreen> createState() => _TilePreviewScreenState();
}

class _TilePreviewScreenState extends ConsumerState<TilePreviewScreen> {
  int _selectedIndex = kAllTiles.indexWhere((t) => t.id == 'gye_nyame');

  @override
  Widget build(BuildContext context) {
    final def = kAllTiles[_selectedIndex];
    final tile = TileModel(def: def, row: 0, col: 0);
    final assetPath = def.assetPath;

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Tile Preview',
          style: AppTextStyles.displaySmall.copyWith(
            color: SankofaGameTheme.antiqueGold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: SankofaGameTheme.parchmentLight,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => safeBack(context),
        ),
      ),
      body: SankofaBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    padding: const EdgeInsets.all(22),
                    decoration: SankofaGameTheme.appParchmentPanelDecoration,
                    child: assetPath != null
                        ? Image.asset(
                            assetPath,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          )
                        : TileWidget(
                            tile: tile,
                            width: 128,
                            height: 170,
                            showSuitCode: false,
                            forceHideName: true,
                          ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: SankofaGameTheme.darkPanelDecoration(),
                child: Column(
                  children: [
                    Text(
                      def.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: SankofaGameTheme.antiqueGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      def.meaning,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: SankofaGameTheme.parchmentLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (def.assetPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'PNG asset',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: SankofaGameTheme.mutedLightText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: SankofaGameTheme.boardSurface,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color:
                          SankofaGameTheme.antiqueGold.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: kAllTiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final t = kAllTiles[index];
                    final isSelected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: SankofaGameTheme.antiqueGold,
                                  width: 2.5,
                                )
                              : Border.all(
                                  color: Colors.transparent,
                                  width: 2.5,
                                ),
                        ),
                        child: TileWidget(
                          tile: TileModel(def: t, row: 0, col: 0),
                          width: isSelected ? 50 : 44,
                          height: isSelected ? 66 : 58,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: KenteButton(
                  label: 'OPEN FULL TILE SET LEVEL',
                  icon: Icons.science_outlined,
                  width: double.infinity,
                  onTap: () =>
                      context.push('/game/22', extra: DifficultyMode.relaxed),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
