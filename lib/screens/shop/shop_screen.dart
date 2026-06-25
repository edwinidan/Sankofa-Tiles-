import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/economy/economy_models.dart';
import '../../core/monetization/monetization_models.dart';
import '../../core/router/navigation_helpers.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/sankofa_game_theme.dart';
import '../../providers/economy_provider.dart';
import '../../providers/monetization_provider.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopSection _section = ShopSection.featured;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(monetizationProvider.notifier).viewShopSection(_section);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final economy = ref.watch(economyProvider);
    final monetization = ref.watch(monetizationProvider);
    final products = monetization.products
        .where((product) => product.section == _section)
        .toList();

    return Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      appBar: AppBar(
        backgroundColor: SankofaGameTheme.backgroundTop,
        foregroundColor: SankofaGameTheme.parchmentLight,
        title: Text(
          'Shop',
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
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WalletStrip(economy: economy, monetization: monetization),
                    const SizedBox(height: 14),
                    _SectionTabs(
                      selected: _section,
                      onSelected: (section) {
                        setState(() => _section = section);
                        ref
                            .read(monetizationProvider.notifier)
                            .viewShopSection(section);
                      },
                    ),
                    const SizedBox(height: 14),
                    if (monetization.offline || !monetization.productsLoaded)
                      _StatusPanel(
                        icon: Icons.wifi_off_outlined,
                        text: monetization.offline
                            ? 'Shop is offline. Gameplay remains available.'
                            : 'Products are unavailable right now.',
                      )
                    else if (_section == ShopSection.restorePurchases)
                      _RestorePanel(monetization: monetization)
                    else ...[
                      if (_section == ShopSection.featured)
                        const _RewardedShopGift(),
                      for (final product in products)
                        _ProductCard(
                          product: product,
                          state: monetization,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({
    required this.economy,
    required this.monetization,
  });

  final EconomyState economy;
  final MonetizationState monetization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Text(
            '${economy.cowries} Cowries',
            style: AppTextStyles.titleMedium.copyWith(
              color: SankofaGameTheme.parchmentLight,
            ),
          ),
          Text(
            'Hint ${economy.boosterCount(BoosterType.hint)} · '
            'Shuffle ${economy.boosterCount(BoosterType.shuffle)} · '
            'Open Path ${economy.boosterCount(BoosterType.openPath)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: SankofaGameTheme.mutedLightText,
            ),
          ),
          if (monetization.removeAdsActive)
            Text(
              'Remove Ads active',
              style: AppTextStyles.labelSmall.copyWith(
                color: SankofaGameTheme.antiqueGold,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.selected,
    required this.onSelected,
  });

  final ShopSection selected;
  final ValueChanged<ShopSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final section in ShopSection.values)
          ChoiceChip(
            label: Text(section.label),
            selected: selected == section,
            onSelected: (_) => onSelected(section),
            selectedColor: SankofaGameTheme.antiqueGold,
            backgroundColor: SankofaGameTheme.boardEdge,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: selected == section
                  ? SankofaGameTheme.darkText
                  : SankofaGameTheme.parchmentLight,
            ),
            side: BorderSide(
              color: SankofaGameTheme.antiqueGold.withValues(alpha: 0.42),
            ),
          ),
      ],
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({
    required this.product,
    required this.state,
  });

  final ShopProduct product;
  final MonetizationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = product.oneTime && state.ownedProductIds.contains(product.id);
    final pending = state.purchaseStatus == PurchaseStatus.pending &&
        state.activeProductId == product.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SankofaGameTheme.appParchmentPanelDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: AppTextStyles.archiveTitleLarge.copyWith(
                      color: SankofaGameTheme.darkText,
                    ),
                  ),
                ),
                Text(
                  owned ? 'Owned' : product.priceLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: SankofaGameTheme.mutedGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: AppTextStyles.archiveBodyMedium.copyWith(
                color: SankofaGameTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            _RewardLine(reward: product.reward),
            const SizedBox(height: 14),
            KenteButton(
              label: pending ? 'PENDING' : (owned ? 'OWNED' : 'BUY'),
              icon: owned ? Icons.check : Icons.shopping_bag_outlined,
              width: double.infinity,
              onTap: owned || pending
                  ? null
                  : () async {
                      ref
                          .read(monetizationProvider.notifier)
                          .viewProduct(product.id);
                      final messenger = ScaffoldMessenger.of(context);
                      final result = await ref
                          .read(monetizationProvider.notifier)
                          .purchaseProduct(product.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text(result.message)),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardedShopGift extends ConsumerWidget {
  const _RewardedShopGift();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SankofaGameTheme.darkPanelDecoration(emphasized: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Free Shop Gift',
              style: AppTextStyles.titleMedium.copyWith(
                color: SankofaGameTheme.antiqueGold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Watch an optional rewarded test ad for 25 Cowries.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: SankofaGameTheme.parchmentLight,
              ),
            ),
            const SizedBox(height: 12),
            KenteButton(
              label: 'WATCH',
              icon: Icons.ondemand_video_outlined,
              width: double.infinity,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await ref
                    .read(monetizationProvider.notifier)
                    .completeRewardedAd(
                      placement: RewardedPlacement.smallShopReward,
                    );
                messenger.showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RestorePanel extends ConsumerWidget {
  const _RestorePanel({required this.monetization});

  final MonetizationState monetization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoring = monetization.purchaseStatus == PurchaseStatus.restoring;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: SankofaGameTheme.appParchmentPanelDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.restore_outlined,
            color: SankofaGameTheme.antiqueGold,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'Restore Purchases',
            style: AppTextStyles.archiveTitleLarge.copyWith(
              color: SankofaGameTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Restores permanent entitlements such as Remove Ads and cosmetics. Consumable packs are not restored.',
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: SankofaGameTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          if (monetization.lastMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              monetization.lastMessage!,
              style: AppTextStyles.archiveBodyMedium.copyWith(
                color: SankofaGameTheme.mutedGold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          KenteButton(
            label: restoring ? 'RESTORING' : 'RESTORE',
            icon: Icons.restore,
            width: double.infinity,
            onTap: restoring
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final result = await ref
                        .read(monetizationProvider.notifier)
                        .restorePurchases();
                    messenger.showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _RewardLine extends StatelessWidget {
  const _RewardLine({required this.reward});

  final MonetizationReward reward;

  @override
  Widget build(BuildContext context) {
    final lines = [
      if (reward.cowries > 0) '${reward.cowries} Cowries',
      for (final entry in reward.boosters.entries)
        '${entry.value} ${entry.key.label}',
      if (reward.entitlementIds.contains(MonetizationEntitlements.removeAds))
        'Remove Ads',
      if (reward.cosmeticIds.isNotEmpty) 'Cosmetic unlock',
    ];

    return Text(
      lines.isEmpty ? 'Permanent unlock' : lines.join(' · '),
      style: AppTextStyles.labelSmall.copyWith(
        color: SankofaGameTheme.mutedGold,
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: SankofaGameTheme.appParchmentPanelDecoration,
      child: Column(
        children: [
          Icon(icon, color: SankofaGameTheme.antiqueGold, size: 42),
          const SizedBox(height: 10),
          Text(
            text,
            style: AppTextStyles.archiveBodyMedium.copyWith(
              color: SankofaGameTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
