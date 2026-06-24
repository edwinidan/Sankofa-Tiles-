import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tile_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../models/tile_model.dart';
import '../../providers/economy_provider.dart';
import '../game/widgets/tile_widget.dart';
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
    final economy = ref.watch(economyProvider);
    final service = ref.read(economyServiceProvider);
    final unlocked = economy.unlockedCollectionIds.contains(def.id);
    final tile = TileModel(def: def, row: 0, col: 0);
    final assetPath = def.assetPath;

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Adinkra Collection',
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
                    child: unlocked && assetPath != null
                        ? Image.asset(
                            assetPath,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          )
                        : unlocked
                            ? TileWidget(
                                tile: tile,
                                width: 128,
                                height: 170,
                                showSuitCode: false,
                                forceHideName: true,
                              )
                            : Icon(
                                Icons.lock_outline,
                                size: 96,
                                color: SankofaGameTheme.mutedGold
                                    .withValues(alpha: 0.72),
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
                      unlocked ? def.name : 'Undiscovered Symbol',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: SankofaGameTheme.antiqueGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked
                          ? def.meaning
                          : service.collectionUnlockSource(def.id),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: SankofaGameTheme.parchmentLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (unlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          service.collectionUnlockSource(def.id),
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
                    final tileUnlocked =
                        economy.unlockedCollectionIds.contains(t.id);
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
                        child: tileUnlocked
                            ? TileWidget(
                                tile: TileModel(def: t, row: 0, col: 0),
                                width: isSelected ? 50 : 44,
                                height: isSelected ? 66 : 58,
                              )
                            : SizedBox(
                                width: isSelected ? 50 : 44,
                                height: isSelected ? 66 : 58,
                                child: const Icon(
                                  Icons.lock_outline,
                                  color: SankofaGameTheme.mutedLightText,
                                  size: 20,
                                ),
                              ),
                      ),
                    );
                  },
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
