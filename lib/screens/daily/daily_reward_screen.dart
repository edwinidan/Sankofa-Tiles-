import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/economy/economy_models.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../providers/economy_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class DailyRewardScreen extends ConsumerWidget {
  const DailyRewardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final economy = ref.watch(economyProvider);
    final notifier = ref.read(economyProvider.notifier);
    final reward = notifier.currentDailyReward;
    final canClaim = notifier.canClaimDailyReward();

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        foregroundColor: SankofaGameTheme.parchmentLight,
        title: Text(
          'Daily Reward',
          style: AppTextStyles.displaySmall.copyWith(
            color: SankofaGameTheme.antiqueGold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => safeBack(context),
        ),
      ),
      body: SankofaBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              decoration: SankofaGameTheme.appParchmentPanelDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: SankofaGameTheme.antiqueGold,
                    size: 54,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Day ${reward.day}',
                    style: AppTextStyles.archiveDisplayLarge.copyWith(
                      color: SankofaGameTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.label,
                    style: AppTextStyles.archiveTitleLarge.copyWith(
                      color: SankofaGameTheme.mutedGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cowrie shells were historically used in trade across parts of West Africa. In Adinkra Tiles, Cowries are earned only through play and rewards.',
                    style: AppTextStyles.archiveBodyMedium.copyWith(
                      color: SankofaGameTheme.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  _RewardBreakdown(reward: reward),
                  const SizedBox(height: 18),
                  Text(
                    'Balance: ${economy.cowries} Cowries',
                    style: AppTextStyles.archiveBodyMedium.copyWith(
                      color: SankofaGameTheme.mutedGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  KenteButton(
                    label: canClaim ? 'CLAIM' : 'CLAIMED TODAY',
                    icon: canClaim ? Icons.redeem_outlined : Icons.check,
                    width: double.infinity,
                    onTap: canClaim
                        ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final summary = await notifier.claimDailyReward();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  summary.hasRewards
                                      ? 'Daily reward claimed.'
                                      : 'Already claimed today.',
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardBreakdown extends StatelessWidget {
  const _RewardBreakdown({required this.reward});

  final DailyReward reward;

  @override
  Widget build(BuildContext context) {
    final lines = [
      if (reward.cowries > 0) '${reward.cowries} Cowries',
      for (final entry in reward.boosters.entries)
        '${entry.value} ${entry.key.label}',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: SankofaGameTheme.darkPanelDecoration(),
      child: Text(
        lines.join('\n'),
        style: AppTextStyles.bodyMedium.copyWith(
          color: SankofaGameTheme.parchmentLight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
