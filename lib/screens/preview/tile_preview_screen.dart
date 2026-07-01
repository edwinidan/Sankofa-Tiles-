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
import '../../widgets/tile_back.dart';

class TilePreviewScreen extends ConsumerStatefulWidget {
  const TilePreviewScreen({super.key});

  @override
  ConsumerState<TilePreviewScreen> createState() => _TilePreviewScreenState();
}

class _TilePreviewScreenState extends ConsumerState<TilePreviewScreen> {
  static const _thumbnailWidth = 58.0;
  static const _thumbnailSpacing = 8.0;
  static const _thumbnailHorizontalPadding = 12.0;

  late final PageController _previewController;
  late final ScrollController _thumbnailController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final initialIndex = kAllTiles.indexWhere((t) => t.id == 'gye_nyame');
    _selectedIndex = initialIndex >= 0 ? initialIndex : 0;
    _previewController = PageController(initialPage: _selectedIndex);
    _thumbnailController = ScrollController();
    _scrollSelectedThumbnailIntoView();
  }

  @override
  void dispose() {
    _previewController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _selectTile(int index, {bool animatePreview = true}) {
    if (index == _selectedIndex) {
      _scrollSelectedThumbnailIntoView();
      return;
    }

    setState(() => _selectedIndex = index);
    _scrollSelectedThumbnailIntoView();

    if (animatePreview && _previewController.hasClients) {
      _previewController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollSelectedThumbnailIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_thumbnailController.hasClients) return;

      final viewportWidth = _thumbnailController.position.viewportDimension;
      final currentOffset = _thumbnailController.offset;
      final itemStart = _thumbnailHorizontalPadding +
          _selectedIndex * (_thumbnailWidth + _thumbnailSpacing);
      final itemEnd = itemStart + _thumbnailWidth;

      double? targetOffset;
      if (itemStart < currentOffset) {
        targetOffset = itemStart - _thumbnailHorizontalPadding;
      } else if (itemEnd > currentOffset + viewportWidth) {
        targetOffset = itemEnd - viewportWidth + _thumbnailHorizontalPadding;
      }

      if (targetOffset == null) return;

      final clampedOffset = targetOffset
          .clamp(
            _thumbnailController.position.minScrollExtent,
            _thumbnailController.position.maxScrollExtent,
          )
          .toDouble();
      _thumbnailController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final def = kAllTiles[_selectedIndex];
    final economy = ref.watch(economyProvider);
    final service = ref.read(economyServiceProvider);
    final unlocked = economy.unlockedCollectionIds.contains(def.id);

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
                child: PageView.builder(
                  key: const ValueKey('tile-preview-page-view'),
                  controller: _previewController,
                  itemCount: kAllTiles.length,
                  onPageChanged: (index) =>
                      _selectTile(index, animatePreview: false),
                  itemBuilder: (context, index) {
                    final previewDef = kAllTiles[index];
                    final previewUnlocked =
                        economy.unlockedCollectionIds.contains(previewDef.id);
                    final previewTile =
                        TileModel(def: previewDef, row: 0, col: 0);
                    final previewAssetPath = previewDef.assetPath;

                    return Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                        padding: const EdgeInsets.all(22),
                        decoration:
                            SankofaGameTheme.appParchmentPanelDecoration,
                        child: previewUnlocked && previewAssetPath != null
                            ? Image.asset(
                                previewAssetPath,
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              )
                            : previewUnlocked
                                ? IgnorePointer(
                                    child: TileWidget(
                                      tile: previewTile,
                                      width: 128,
                                      height: 170,
                                      showSuitCode: false,
                                      forceHideName: true,
                                    ),
                                  )
                                : const _LockedCollectionTile(
                                    width: 128,
                                    height: 170,
                                    lockSize: 38,
                                  ),
                      ),
                    );
                  },
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
                  controller: _thumbnailController,
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
                      key: ValueKey('tile-preview-thumbnail-${t.id}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectTile(index),
                      child: SizedBox(
                        width: _thumbnailWidth,
                        height: double.infinity,
                        child: Center(
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
                            child: IgnorePointer(
                              child: tileUnlocked
                                  ? TileWidget(
                                      tile: TileModel(def: t, row: 0, col: 0),
                                      width: isSelected ? 50 : 44,
                                      height: isSelected ? 66 : 58,
                                    )
                                  : SizedBox(
                                      width: isSelected ? 50 : 44,
                                      height: isSelected ? 66 : 58,
                                      child: _LockedCollectionTile(
                                        width: isSelected ? 50 : 44,
                                        height: isSelected ? 66 : 58,
                                        lockSize: isSelected ? 18 : 16,
                                      ),
                                    ),
                            ),
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

class _LockedCollectionTile extends StatelessWidget {
  const _LockedCollectionTile({
    required this.width,
    required this.height,
    required this.lockSize,
  });

  final double width;
  final double height;
  final double lockSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Locked Adinkra symbol',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.58,
            child: TileBackWidget(width: width, height: height),
          ),
          Container(
            width: lockSize * 1.55,
            height: lockSize * 1.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SankofaGameTheme.backgroundTop.withValues(alpha: 0.78),
              border: Border.all(
                color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              Icons.lock_outline,
              color: SankofaGameTheme.parchmentLight,
              size: lockSize,
            ),
          ),
        ],
      ),
    );
  }
}
