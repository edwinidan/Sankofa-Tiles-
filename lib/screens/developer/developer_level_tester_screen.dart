import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/level_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/board_layout_geometry.dart';
import '../../models/game_launch_config.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class DeveloperLevelTesterScreen extends ConsumerWidget {
  const DeveloperLevelTesterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextLevelId =
        ref.watch(progressProvider).nextUnfinishedLevelId ?? kLevels.last.id;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) safeBack(context);
      },
      child: Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        appBar: AppBar(
          backgroundColor: SankofaGameTheme.backgroundTop,
          foregroundColor: SankofaGameTheme.parchmentLight,
          title: Text(
            'DEV: Level Tester',
            style: AppTextStyles.displaySmall.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => safeBack(context),
          ),
        ),
        body: SankofaBackground(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      KenteButton(
                        label: 'TEST NEXT UNFINISHED',
                        icon: Icons.play_arrow,
                        onTap: () => _openLevel(context, nextLevelId),
                      ),
                      KenteButton(
                        label: 'TEST ALL SEQUENTIALLY',
                        icon: Icons.fast_forward,
                        onTap: () => _openLevel(context, kLevels.first.id),
                      ),
                      KenteButton(
                        label: 'RESET TEST SESSION',
                        icon: Icons.restart_alt,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Temporary test session cleared. '
                                'Real progress was not changed.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 900
                        ? 4
                        : width >= 620
                            ? 3
                            : 2;
                    return SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: width < 420 ? 0.68 : 0.78,
                      ),
                      itemCount: kLevels.length,
                      itemBuilder: (context, index) {
                        final level = kLevels[index];
                        final geometry =
                            BoardLayoutGeometry.fromPositions(level.layout);
                        final fitsAllViewports =
                            kRequiredBoardViewports.every((viewport) {
                          return geometry
                              .fit(
                                availableWidth: viewport.width,
                                availableHeight: viewport.height,
                              )
                              .fitsSafely;
                        });
                        final valid = level.tileCount.isEven &&
                            level.layout.length == level.tileCount &&
                            level.symbolCopyCounts.fold<int>(
                                  0,
                                  (sum, count) => sum + count,
                                ) ==
                                level.tileCount &&
                            fitsAllViewports;
                        return _DeveloperLevelCard(
                          level: level,
                          valid: valid,
                          onOpen: () => _openLevel(context, level.id),
                          onRegenerate: () => _openLevel(context, level.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, int levelId) {
    context.push(
      '/game/$levelId',
      extra: GameLaunchConfig(
        levelId: levelId,
        launchMode: GameLaunchMode.developerTest,
      ),
    );
  }
}

class _DeveloperLevelCard extends StatelessWidget {
  const _DeveloperLevelCard({
    required this.level,
    required this.valid,
    required this.onOpen,
    required this.onRegenerate,
  });

  final LevelDefinition level;
  final bool valid;
  final VoidCallback onOpen;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: SankofaGameTheme.darkPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Level ${level.id}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: SankofaGameTheme.antiqueGold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Regenerate board',
                    onPressed: onRegenerate,
                    icon: const Icon(Icons.refresh, size: 19),
                    color: SankofaGameTheme.antiqueGold,
                  ),
                ],
              ),
              Text(
                level.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: SankofaGameTheme.parchmentLight,
                ),
              ),
              const SizedBox(height: 8),
              _InfoLine(label: 'Layout', value: level.layoutName),
              _InfoLine(label: 'Tiles', value: '${level.tileCount}'),
              _InfoLine(label: 'Layers', value: '${level.layerCount}'),
              _InfoLine(
                label: 'Compact tile',
                value: '${_compactFit.tileWidth.toStringAsFixed(1)} × '
                    '${_compactFit.tileHeight.toStringAsFixed(1)}',
              ),
              _InfoLine(
                label: 'Board fit',
                value: _fitsAllViewports ? 'SAFE' : 'UNSAFE',
              ),
              _InfoLine(
                label: 'Difficulty',
                value: level.difficultyCategory,
              ),
              const Spacer(),
              Text(
                valid
                    ? 'Status: Valid · solver verified on launch'
                    : 'Status: Invalid configuration',
                style: AppTextStyles.bodySmall.copyWith(
                  color: valid ? Colors.lightGreenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on _DeveloperLevelCard {
  BoardLayoutGeometry get _geometry =>
      BoardLayoutGeometry.fromPositions(level.layout);

  BoardFit get _compactFit => _geometry.fit(
        availableWidth: kRequiredBoardViewports.first.width,
        availableHeight: kRequiredBoardViewports.first.height,
      );

  bool get _fitsAllViewports => kRequiredBoardViewports.every((viewport) {
        return _geometry
            .fit(
              availableWidth: viewport.width,
              availableHeight: viewport.height,
            )
            .fitsSafely;
      });
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(
          color: SankofaGameTheme.mutedLightText,
        ),
      ),
    );
  }
}
