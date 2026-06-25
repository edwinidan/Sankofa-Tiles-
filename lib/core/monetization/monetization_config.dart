import 'package:flutter/foundation.dart';

import '../economy/economy_models.dart';
import 'monetization_models.dart';

class MonetizationConfig {
  const MonetizationConfig._();

  static const bool enableSandboxMonetization = bool.fromEnvironment(
    'ADINKRA_SANDBOX_MONETIZATION',
    defaultValue: kDebugMode,
  );

  static MonetizationEnvironment get environment =>
      enableSandboxMonetization || kDebugMode
          ? MonetizationEnvironment.sandbox
          : MonetizationEnvironment.production;

  static const int completedLevelFrequency = 3;
  static const int minimumCompletedLevels = 2;
  static const int sessionInterstitialCap = 2;
  static const Duration interstitialCooldown = Duration(minutes: 8);
  static const Duration rewardedAdCooldown = Duration(minutes: 2);

  static String adUnitId(RewardedPlacement placement) {
    final prefix = environment == MonetizationEnvironment.sandbox
        ? 'test-rewarded'
        : 'configured-rewarded';
    return '$prefix-${placement.name}';
  }

  static String interstitialAdUnitId(InterstitialPlacement placement) {
    final prefix = environment == MonetizationEnvironment.sandbox
        ? 'test-interstitial'
        : 'configured-interstitial';
    return '$prefix-${placement.name}';
  }

  static List<ShopProduct> get products => [
        ShopProduct(
          id: ProductIds.removeAds,
          storeProductId: _storeId(ProductIds.removeAds),
          title: 'Remove Ads',
          description: 'Permanently removes forced interstitial ads.',
          section: ShopSection.removeAds,
          type: ProductType.nonConsumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            entitlementIds: [MonetizationEntitlements.removeAds],
          ),
          oneTime: true,
        ),
        ShopProduct(
          id: ProductIds.starterPack,
          storeProductId: _storeId(ProductIds.starterPack),
          title: 'Starter Pack',
          description:
              'Remove Ads, 300 Cowries, helpful boosters, and a gold tile back.',
          section: ShopSection.featured,
          type: ProductType.oneTimeBundle,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            cowries: 300,
            boosters: {
              BoosterType.hint: 5,
              BoosterType.shuffle: 3,
              BoosterType.openPath: 2,
            },
            entitlementIds: [
              MonetizationEntitlements.removeAds,
              MonetizationEntitlements.tileBackKenteGold,
            ],
            cosmeticIds: [MonetizationEntitlements.tileBackKenteGold],
          ),
          oneTime: true,
        ),
        ShopProduct(
          id: ProductIds.hintPack,
          storeProductId: _storeId(ProductIds.hintPack),
          title: 'Hint Pack',
          description: 'Adds 8 Hints to your inventory.',
          section: ShopSection.boosters,
          type: ProductType.consumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            boosters: {BoosterType.hint: 8},
          ),
        ),
        ShopProduct(
          id: ProductIds.shufflePack,
          storeProductId: _storeId(ProductIds.shufflePack),
          title: 'Shuffle Pack',
          description: 'Adds 6 Shuffles for difficult boards.',
          section: ShopSection.boosters,
          type: ProductType.consumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            boosters: {BoosterType.shuffle: 6},
          ),
        ),
        ShopProduct(
          id: ProductIds.mixedBoosterPack,
          storeProductId: _storeId(ProductIds.mixedBoosterPack),
          title: 'Mixed Booster Pack',
          description: 'Hints, Shuffles, and Open Path boosters together.',
          section: ShopSection.boosters,
          type: ProductType.consumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            boosters: {
              BoosterType.hint: 4,
              BoosterType.shuffle: 4,
              BoosterType.openPath: 2,
            },
          ),
        ),
        ShopProduct(
          id: ProductIds.smallCowries,
          storeProductId: _storeId(ProductIds.smallCowries),
          title: 'Cowrie Pouch',
          description: 'Adds 250 Cowries.',
          section: ShopSection.cowries,
          type: ProductType.consumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(cowries: 250),
        ),
        ShopProduct(
          id: ProductIds.largeCowries,
          storeProductId: _storeId(ProductIds.largeCowries),
          title: 'Cowrie Basket',
          description: 'Adds 900 Cowries.',
          section: ShopSection.cowries,
          type: ProductType.consumable,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(cowries: 900),
        ),
        ShopProduct(
          id: ProductIds.kenteGoldTileBack,
          storeProductId: _storeId(ProductIds.kenteGoldTileBack),
          title: 'Kente Gold Tile Back',
          description: 'A cosmetic tile back. No gameplay advantage.',
          section: ShopSection.cosmetics,
          type: ProductType.cosmetic,
          priceLabel: environment == MonetizationEnvironment.sandbox
              ? 'Sandbox'
              : 'Store price',
          reward: const MonetizationReward(
            entitlementIds: [MonetizationEntitlements.tileBackKenteGold],
            cosmeticIds: [MonetizationEntitlements.tileBackKenteGold],
          ),
          oneTime: true,
        ),
      ];

  static MonetizationReward rewardedReward(
    RewardedPlacement placement, {
    int baseCowries = 0,
  }) =>
      switch (placement) {
        RewardedPlacement.doubleCompletionCowries => MonetizationReward(
            cowries: baseCowries.clamp(0, 999999),
          ),
        RewardedPlacement.freeRescueShuffle => const MonetizationReward(
            boosters: {BoosterType.shuffle: 1},
          ),
        RewardedPlacement.freeHint => const MonetizationReward(
            boosters: {BoosterType.hint: 1},
          ),
        RewardedPlacement.bonusDailyChest => const MonetizationReward(
            cowries: 30,
            boosters: {BoosterType.hint: 1},
          ),
        RewardedPlacement.smallShopReward => const MonetizationReward(
            cowries: 25,
          ),
        RewardedPlacement.retryAssistance => const MonetizationReward(
            boosters: {BoosterType.shuffle: 1},
          ),
      };

  static String _storeId(String productId) {
    final prefix = environment == MonetizationEnvironment.sandbox
        ? 'sandbox.adinkra_tiles'
        : 'adinkra_tiles';
    return '$prefix.$productId';
  }
}

class ProductIds {
  const ProductIds._();

  static const removeAds = 'remove_ads';
  static const starterPack = 'starter_pack';
  static const hintPack = 'hint_pack';
  static const shufflePack = 'shuffle_pack';
  static const mixedBoosterPack = 'mixed_booster_pack';
  static const smallCowries = 'cowrie_pouch';
  static const largeCowries = 'cowrie_basket';
  static const kenteGoldTileBack = 'kente_gold_tile_back';
}
