import '../economy/economy_models.dart';

enum MonetizationEnvironment {
  sandbox,
  production,
}

enum ShopSection {
  featured,
  boosters,
  cowries,
  cosmetics,
  removeAds,
  restorePurchases,
}

extension ShopSectionLabel on ShopSection {
  String get label => switch (this) {
        ShopSection.featured => 'Featured',
        ShopSection.boosters => 'Boosters',
        ShopSection.cowries => 'Cowries',
        ShopSection.cosmetics => 'Cosmetics',
        ShopSection.removeAds => 'Remove Ads',
        ShopSection.restorePurchases => 'Restore',
      };
}

enum ProductType {
  nonConsumable,
  oneTimeBundle,
  consumable,
  cosmetic,
}

enum PurchaseStatus {
  idle,
  loading,
  unavailable,
  pending,
  success,
  cancelled,
  failed,
  offline,
  alreadyOwned,
  restoring,
  restored,
  nothingToRestore,
  verificationPending,
}

enum RewardedPlacement {
  doubleCompletionCowries,
  freeRescueShuffle,
  freeHint,
  bonusDailyChest,
  smallShopReward,
  retryAssistance,
}

extension RewardedPlacementLabel on RewardedPlacement {
  String get label => switch (this) {
        RewardedPlacement.doubleCompletionCowries => 'Double Cowries',
        RewardedPlacement.freeRescueShuffle => 'Free Shuffle',
        RewardedPlacement.freeHint => 'Free Hint',
        RewardedPlacement.bonusDailyChest => 'Daily Bonus',
        RewardedPlacement.smallShopReward => 'Shop Gift',
        RewardedPlacement.retryAssistance => 'Retry Assist',
      };
}

enum InterstitialPlacement {
  afterCompletedLevels,
  returningHome,
  beforeNewChapter,
}

class MonetizationReward {
  const MonetizationReward({
    this.cowries = 0,
    this.boosters = const {},
    this.entitlementIds = const [],
    this.cosmeticIds = const [],
  });

  final int cowries;
  final Map<BoosterType, int> boosters;
  final List<String> entitlementIds;
  final List<String> cosmeticIds;

  bool get isEmpty =>
      cowries <= 0 &&
      boosters.isEmpty &&
      entitlementIds.isEmpty &&
      cosmeticIds.isEmpty;
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.storeProductId,
    required this.title,
    required this.description,
    required this.section,
    required this.type,
    required this.priceLabel,
    required this.reward,
    this.oneTime = false,
    this.available = true,
  });

  final String id;
  final String storeProductId;
  final String title;
  final String description;
  final ShopSection section;
  final ProductType type;
  final String priceLabel;
  final MonetizationReward reward;
  final bool oneTime;
  final bool available;
}

class MonetizationState {
  const MonetizationState({
    required this.environment,
    required this.products,
    required this.entitlementIds,
    required this.ownedProductIds,
    this.purchaseStatus = PurchaseStatus.idle,
    this.activeProductId,
    this.lastMessage,
    this.offline = false,
    this.productsLoaded = true,
  });

  final MonetizationEnvironment environment;
  final List<ShopProduct> products;
  final Set<String> entitlementIds;
  final Set<String> ownedProductIds;
  final PurchaseStatus purchaseStatus;
  final String? activeProductId;
  final String? lastMessage;
  final bool offline;
  final bool productsLoaded;

  bool get removeAdsActive =>
      entitlementIds.contains(MonetizationEntitlements.removeAds);

  MonetizationState copyWith({
    MonetizationEnvironment? environment,
    List<ShopProduct>? products,
    Set<String>? entitlementIds,
    Set<String>? ownedProductIds,
    PurchaseStatus? purchaseStatus,
    String? activeProductId,
    String? lastMessage,
    bool? offline,
    bool? productsLoaded,
    bool clearActiveProductId = false,
  }) =>
      MonetizationState(
        environment: environment ?? this.environment,
        products: products ?? this.products,
        entitlementIds: entitlementIds ?? this.entitlementIds,
        ownedProductIds: ownedProductIds ?? this.ownedProductIds,
        purchaseStatus: purchaseStatus ?? this.purchaseStatus,
        activeProductId: clearActiveProductId
            ? null
            : activeProductId ?? this.activeProductId,
        lastMessage: lastMessage ?? this.lastMessage,
        offline: offline ?? this.offline,
        productsLoaded: productsLoaded ?? this.productsLoaded,
      );
}

class RewardedAdResult {
  const RewardedAdResult({
    required this.status,
    this.summary = const MonetizationReward(),
    this.message = '',
  });

  final PurchaseStatus status;
  final MonetizationReward summary;
  final String message;

  bool get completed => status == PurchaseStatus.success && !summary.isEmpty;
}

class InterstitialDecision {
  const InterstitialDecision({
    required this.canShow,
    required this.reason,
  });

  final bool canShow;
  final String reason;
}

class MonetizationEntitlements {
  const MonetizationEntitlements._();

  static const removeAds = 'remove_ads';
  static const tileBackKenteGold = 'tile_back_kente_gold';
}
