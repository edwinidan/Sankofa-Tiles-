# Phase 4 Implementation Report

## Scope

Phase 4 added the monetization layer around the Phase 3 economy. The implementation includes a Shop screen, centralized product catalog, sandbox/test monetization environment, purchase and restore state handling, rewarded-ad reward flows, controlled interstitial eligibility, Remove Ads entitlement persistence, monetization analytics, and unit tests.

No banner ads were added. No live Google Mobile Ads or platform billing SDK was added in this pass; the app now has SDK-ready service boundaries and sandbox behavior for development.

## Key Files

| Area | Files |
|---|---|
| Monetization models and config | `lib/core/monetization/monetization_models.dart`, `lib/core/monetization/monetization_config.dart` |
| Monetization logic | `lib/core/monetization/monetization_service.dart`, `lib/providers/monetization_provider.dart` |
| Persistence | `lib/core/utils/storage_service.dart` |
| Analytics | `lib/core/utils/analytics_service.dart` |
| UI | `lib/screens/shop/shop_screen.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/result/result_screen.dart`, `lib/screens/daily/daily_reward_screen.dart`, `lib/screens/game/widgets/game_control_dock.dart` |
| Routes | `lib/core/router/app_router.dart` |
| Tests | `test/monetization_service_test.dart` |

## Product Catalog

Product ids are centralized in `ProductIds` and translated into environment-aware store ids by `MonetizationConfig`.

| Product | Internal id | Sandbox store id | Type | Reward |
|---|---|---|---|---|
| Remove Ads | `remove_ads` | `sandbox.adinkra_tiles.remove_ads` | Non-consumable | `remove_ads` entitlement |
| Starter Pack | `starter_pack` | `sandbox.adinkra_tiles.starter_pack` | One-time bundle | Remove Ads, 300 Cowries, 5 Hints, 3 Shuffles, 2 Open Path, Kente Gold tile back |
| Hint Pack | `hint_pack` | `sandbox.adinkra_tiles.hint_pack` | Consumable | 8 Hints |
| Shuffle Pack | `shuffle_pack` | `sandbox.adinkra_tiles.shuffle_pack` | Consumable | 6 Shuffles |
| Mixed Booster Pack | `mixed_booster_pack` | `sandbox.adinkra_tiles.mixed_booster_pack` | Consumable | 4 Hints, 4 Shuffles, 2 Open Path |
| Cowrie Pouch | `cowrie_pouch` | `sandbox.adinkra_tiles.cowrie_pouch` | Consumable | 250 Cowries |
| Cowrie Basket | `cowrie_basket` | `sandbox.adinkra_tiles.cowrie_basket` | Consumable | 900 Cowries |
| Kente Gold Tile Back | `kente_gold_tile_back` | `sandbox.adinkra_tiles.kente_gold_tile_back` | Cosmetic | Cosmetic entitlement |

Production ids intentionally use the `adinkra_tiles.<product_id>` shape but must be mapped to real App Store / Play Console products before release.

## Entitlement Rules

- `remove_ads` permanently suppresses forced interstitial eligibility.
- Rewarded ads remain available to Remove Ads owners because they are voluntary.
- One-time products are blocked after ownership is recorded.
- Consumables are granted through transaction ids and cannot be granted twice for the same callback.
- Restore Purchases restores non-consumable and cosmetic entitlements from owned product markers.
- Consumable products are not restored.

## Rewarded Ad Placements

| Placement | UI | Reward |
|---|---|---|
| Double completion Cowries | Win result screen | Adds the same Cowrie amount earned by the level reward summary |
| Free Hint | Gameplay Hint button when inventory is empty | Grants 1 Hint, then spends it on the action |
| Free rescue Shuffle | Gameplay Shuffle button when inventory is empty | Grants 1 Shuffle, then spends it on the action |
| Bonus daily chest | Daily Reward screen | 30 Cowries and 1 Hint |
| Small Shop reward | Shop Featured section | 25 Cowries |
| Retry assistance | Loss result screen | 1 Shuffle |

Rewarded ad callbacks are idempotent. Failed, cancelled, unavailable, or offline rewarded flows do not deduct inventory or grant rewards.

## Interstitial Rules

Interstitials are controlled by `MonetizationService.interstitialDecision`.

Current conservative defaults:

| Rule | Value |
|---|---|
| Minimum completed levels | 2 |
| Completed-level frequency | 3 completed levels since last interstitial |
| Time cooldown | 8 minutes |
| Rewarded-ad cooldown | 2 minutes |
| Session cap | 2 |

Interstitials are suppressed:

- During the first session.
- During tutorial.
- After a loss.
- During gameplay.
- For Remove Ads owners.
- Immediately after a rewarded ad cooldown window.
- When frequency, cooldown, or session caps are not satisfied.

The current code records eligible interstitial display through analytics and state, but does not present a live ad SDK overlay yet.

## Storage Schema

| Key or prefix | Purpose |
|---|---|
| `monetization_entitlement_<id>` | Permanent entitlement flags such as Remove Ads and cosmetics |
| `monetization_purchase_<productId>` | Owned one-time/restorable product markers |
| `monetization_callback_<callbackId>` | Idempotency markers for ad and purchase callbacks |
| `monetization_interstitial_completed_since_last` | Completed-level frequency counter |
| `monetization_interstitial_session_count` | Current app-session interstitial count, reset on storage initialization |
| `monetization_last_interstitial_millis` | Last interstitial timestamp |
| `monetization_last_rewarded_ad_millis` | Last rewarded ad completion timestamp |

## Analytics

Added monetization analytics wrappers:

- `shop_viewed`
- `product_viewed`
- `purchase_attempt`
- `purchase_success`
- `purchase_failure`
- `restore_purchases`
- `rewarded_ad_requested`
- `rewarded_ad_completed`
- `rewarded_ad_failed`
- `interstitial_shown`
- `interstitial_skipped`
- `remove_ads_entitlement`

No sensitive billing payloads, receipts, or personal data are logged.

## Privacy and Store Notes

- The privacy findings now distinguish the current SDK-neutral sandbox implementation from future live AdMob and billing SDK integration.
- Before production release, update the published privacy policy, App Store privacy labels, Google Play Data Safety form, and consent flow based on the actual ad and billing SDKs selected.
- Production ad unit ids and billing product ids must be environment-configured and verified with store sandbox accounts.

## Verification

Commands run:

```text
dart format lib/core/monetization lib/providers/monetization_provider.dart lib/core/utils/storage_service.dart lib/core/utils/analytics_service.dart lib/core/router/app_router.dart lib/screens/home/home_screen.dart lib/screens/shop/shop_screen.dart lib/screens/result/result_screen.dart lib/screens/daily/daily_reward_screen.dart lib/screens/game/widgets/game_control_dock.dart test/monetization_service_test.dart
flutter test test/monetization_service_test.dart
flutter analyze
flutter test
```

Current result:

```text
Monetization service tests passed.
No analyzer issues found.
All tests passed.
```

## Known Limitations

- Live Google Mobile Ads and platform billing SDKs are not integrated yet.
- Purchase verification is local-only; server-side receipt validation is still required for production-grade fraud resistance.
- The Shop shows sandbox/test labels instead of live localized store prices.
- Cosmetic ownership exists as an entitlement, but tile-back selection and rendering are not yet implemented.
- Consent UI is documented but not implemented because no live ad SDK initializes in this phase.
