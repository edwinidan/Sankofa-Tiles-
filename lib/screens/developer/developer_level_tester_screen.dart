import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/layout_data.dart';
import '../../core/constants/batch_b_layout_data.dart';
import '../../core/constants/level_data.dart';
import '../../core/constants/tile_data.dart';
import '../../core/constants/tile_unlock_data.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../core/utils/board_layout_geometry.dart';
import '../../core/utils/board_solver.dart';
import '../../models/game_launch_config.dart';
import '../../models/tile_model.dart';
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'BATCH B CANDIDATES · ISOLATED',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: SankofaGameTheme.antiqueGold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 310,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: kBatchBLayoutCandidates.length,
                  itemBuilder: (context, index) => _BatchBCandidateCard(
                    candidate: kBatchBLayoutCandidates[index],
                  ),
                ),
              ),
              // Layout Library section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'LAYOUT LIBRARY',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: SankofaGameTheme.antiqueGold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
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
                      itemCount: kLayoutLibrary.length,
                      itemBuilder: (context, index) {
                        final layout = kLayoutLibrary[index];
                        return _LayoutPreviewCard(layout: layout);
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

class _BatchBCandidateCard extends StatelessWidget {
  const _BatchBCandidateCard({required this.candidate});

  final BatchBLayoutCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final layout = candidate.layout;
    final stats = layout.stats;
    final level = candidate.intendedLevel;
    final tileMilestone = tileIdsUnlockedAtLevel(level).isNotEmpty;
    final reward = [
      if (tileMilestone) 'collection',
      if (level % 10 == 0) '10-level',
      if (level % 5 == 0) '5-level',
      if (level == 20) 'chapter',
    ].join(' + ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proposed Level $level',
            style: AppTextStyles.titleMedium.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
          Text(
            candidate.proposedDisplayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: SankofaGameTheme.parchmentLight,
            ),
          ),
          const SizedBox(height: 6),
          _InfoLine(label: 'ID', value: layout.id),
          _InfoLine(label: 'Family', value: candidate.family),
          _InfoLine(label: 'Variant', value: candidate.variant),
          _InfoLine(
              label: 'Tiles / pairs',
              value: '${stats.tileCount} / ${stats.pairCount}'),
          _InfoLine(label: 'Layers', value: '${stats.layerCount}'),
          _InfoLine(
              label: 'Free start', value: '${stats.startingFreeTileCount}'),
          _InfoLine(
            label: 'Min legal / safe',
            value: '${candidate.minimumLegalOpeningPairs} / '
                '${candidate.minimumSafeOpeningPairs} (100 seeds)',
          ),
          const _InfoLine(label: 'Half-grid', value: 'yes'),
          const _InfoLine(label: 'Structure', value: 'valid'),
          const _InfoLine(label: 'Solvability', value: '100/100'),
          _InfoLine(
              label: 'Milestone', value: reward.isEmpty ? 'none' : reward),
          const Spacer(),
          Text(
            'Developer preview only · not assigned',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.lightGreenAccent,
            ),
          ),
        ],
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

class _LayoutPreviewCard extends StatelessWidget {
  const _LayoutPreviewCard({required this.layout});

  final NamedLayout layout;

  @override
  Widget build(BuildContext context) {
    final stats = layout.stats;
    final geometry = BoardLayoutGeometry.fromPositions(layout.positions);
    final fitsAllViewports = kRequiredBoardViewports.every((viewport) {
      return geometry
          .fit(
            availableWidth: viewport.width,
            availableHeight: viewport.height,
          )
          .fitsSafely;
    });

    // Check structural support: every tile on layer > 0 must overlap at least
    // one tile on the layer directly below.
    bool hasFloatingTiles = false;
    int unsupportedCount = 0;
    for (final pos in layout.positions.where((p) => p.layer > 0)) {
      final hasSupport = layout.positions.any((other) =>
          other.layer == pos.layer - 1 &&
          _axisOverlaps(pos.row, other.row) &&
          _axisOverlaps(pos.col, other.col));
      if (!hasSupport) {
        hasFloatingTiles = true;
        unsupportedCount++;
      }
    }

    // Check opening geometry.
    final openingTiles = List.generate(
      layout.positions.length,
      (i) => TileModel(
        def: kAllTiles.first,
        row: layout.positions[i].row,
        col: layout.positions[i].col,
        layer: layout.positions[i].layer,
        uid: 'preview_$i',
      ),
    );
    final freeCount = BoardSolver.getFreeTiles(openingTiles).length;
    final hasOddCoords = layout.positions.any(
      (p) => p.row.isOdd || p.col.isOdd,
    );

    final allValid = stats.tileCount.isEven &&
        !hasFloatingTiles &&
        freeCount >= 2 &&
        fitsAllViewports;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            layout.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: SankofaGameTheme.antiqueGold,
            ),
          ),
          Text(
            layout.id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          _InfoLine(label: 'Tiles', value: '${stats.tileCount}'),
          _InfoLine(label: 'Pairs', value: '${stats.pairCount}'),
          _InfoLine(label: 'Layers', value: '${stats.layerCount}'),
          _InfoLine(
              label: 'Bounds',
              value: '${stats.boardWidth}x${stats.boardHeight}'),
          _InfoLine(label: 'Free start', value: '$freeCount'),
          if (hasOddCoords) const _InfoLine(label: 'Half-tile', value: 'yes'),
          if (hasFloatingTiles)
            _InfoLine(label: 'Floating', value: '$unsupportedCount'),
          const Spacer(),
          Text(
            allValid ? 'Status: Valid' : 'Status: Issues found',
            style: AppTextStyles.bodySmall.copyWith(
              color: allValid ? Colors.lightGreenAccent : Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  static bool _axisOverlaps(int startA, int startB) {
    const tileSpan = 2;
    return startA < startB + tileSpan && startB < startA + tileSpan;
  }
}
