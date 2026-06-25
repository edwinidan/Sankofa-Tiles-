# State and Storage Map

## Riverpod Providers

| Provider | File | Responsibility |
|---|---|---|
| `storageServiceProvider` | `lib/providers/settings_provider.dart` | Requires a `ProviderScope` override. Supplies initialized `StorageService`. |
| `settingsProvider` | `lib/providers/settings_provider.dart` | Reads/writes sound, music, volume, tile-name display, and haptic intensity. |
| `progressProvider` | `lib/providers/progress_provider.dart` | Wraps storage progress reads, unlock checks, next unfinished level, and result saving. |
| `economyServiceProvider` | `lib/providers/economy_provider.dart` | Supplies the centralized economy service for wallet, boosters, rewards, daily claims, achievements, and collection unlocks. |
| `economyProvider` | `lib/providers/economy_provider.dart` | Owns the derived `EconomyState`, refreshes after economy writes, and logs economy analytics. |
| `monetizationServiceProvider` | `lib/providers/monetization_provider.dart` | Supplies the centralized monetization service for catalog, purchases, rewarded ads, interstitial eligibility, and restore. |
| `monetizationProvider` | `lib/providers/monetization_provider.dart` | Owns `MonetizationState`, refreshes after monetization writes, and logs shop/ad/purchase analytics. |
| `audioServiceProvider` | `lib/providers/game_provider.dart` | Creates `AudioService` from current settings and listens for setting changes. |
| `gameProvider` | `lib/providers/game_provider.dart` | Owns active `GameState`, level startup, tile selection, hint, shuffle, Open Path, pause/resume, win/loss. |

## SharedPreferences Keys

| Key or prefix | Type | Owner | Meaning |
|---|---|---|---|
| `best_score_<levelId>` | int | `StorageService` | Highest score for a level. |
| `stars_<levelId>` | int | `StorageService` | Best star rating for a level. |
| `completed_<levelId>` | bool | `StorageService` | Level completion flag. |
| `highest_completed_level` | int | `StorageService` | Highest completed campaign level id. |
| `sound_enabled` | bool | `StorageService` | Sound effects toggle, default true. |
| `music_enabled` | bool | `StorageService` | Music toggle, default true. |
| `music_volume` | double | `StorageService` | Music volume, default 0.7. |
| `onboarding_complete` | bool | `StorageService` | First-launch/onboarding completion flag, default false. |
| `tutorial_complete` | bool | `StorageService` | Interactive tutorial completion flag, default false. |
| `show_tile_names` | bool | `StorageService` | Tile name display toggle, default true. |
| `haptic_intensity` | string | `StorageService` | `HapticIntensity.name`, default high. |
| `campaign_progress_schema_version` | int | `StorageService` | Migration schema marker, current value 3. |
| `economy_cowries` | int | `StorageService` | Non-negative Cowrie wallet balance, clamped on read/write. |
| `economy_booster_<type>` | int | `StorageService` | Non-negative booster inventory count for `hint`, `shuffle`, and `openPath`. |
| `economy_tx_<transactionId>` | bool | `StorageService` | Idempotency marker for one-time reward grants. |
| `daily_reward_day` | int | `StorageService` | Next day in the seven-day local daily reward cycle, clamped to 1-7. |
| `daily_last_claim_date` | string | `StorageService` | Last local claim date in `yyyy-mm-dd` form. |
| `collection_unlocked_<tileId>` | bool | `StorageService` | Adinkra Collection unlock flag for a symbol id. |
| `achievement_claimed_<achievementId>` | bool | `StorageService` | One-time achievement claim marker. |
| `monetization_entitlement_<id>` | bool | `StorageService` | Permanent monetization entitlement such as Remove Ads or cosmetics. |
| `monetization_purchase_<productId>` | bool | `StorageService` | Owned one-time/restorable product marker. |
| `monetization_callback_<callbackId>` | bool | `StorageService` | Idempotency marker for purchase and rewarded-ad callbacks. |
| `monetization_interstitial_completed_since_last` | int | `StorageService` | Completed-level counter for interstitial frequency rules. |
| `monetization_interstitial_session_count` | int | `StorageService` | Interstitial count for the current app session; reset on storage initialization. |
| `monetization_last_interstitial_millis` | int | `StorageService` | Last interstitial timestamp in epoch milliseconds. |
| `monetization_last_rewarded_ad_millis` | int | `StorageService` | Last rewarded ad completion timestamp in epoch milliseconds. |

## Migration Behavior

`StorageService.init()` calls `_migrateCampaignProgressIfNeeded()`.

When stored schema version is below 3, it:

- Scans `stars_<levelId>` keys and treats any positive stars as completed progress.
- Reads legacy `highest_completed_level`, `highest_unlocked_level`, and `current_level`.
- Converts `highest_unlocked_level` and `current_level` to completed level by subtracting 1.
- Clamps migrated progress to the campaign length.
- Writes `highest_completed_level`.
- Backfills `completed_<levelId>` for completed levels.
- Writes `campaign_progress_schema_version = 3`.

Phase 3 economy data is additive. Corrupted negative Cowrie and booster values are clamped to safe non-negative values by `StorageService`, reward transaction ids prevent duplicate first-clear/star/chapter/achievement grants, and `EconomyService.backfillCollectionUnlocks()` unlocks the first two symbols from each previously completed level.

## Next Unfinished Level

`ProgressService.nextUnfinishedLevelId` returns `kLevels[highestCompletedLevel].id` when progress is incomplete. Because level ids are 1-based and `highestCompletedLevel` is the count/id of the highest completed level, a new player gets level 1 and a player with level 1 completed gets level 2.

## Game State

`GameState` is immutable and updated by `GameNotifier`. Important status values are `initial`, `playing`, `paused`, `won`, `lost`, and `loadFailed`.

Game result persistence happens only in `ResultScreen._saveResult()` for normal wins. Developer test results skip persistence and economy rewards. Normal wins calculate previous stars/completion before saving progress, grant idempotent economy rewards, then save the level result.

## Economy State

`EconomyState` contains the Cowrie balance, booster counts, unlocked collection ids, claimed achievement ids, daily reward day, and last daily claim date. Screens do not write balances directly; all writes go through `EconomyService` via `EconomyNotifier`.

Reward rules are centralized in `lib/core/economy/economy_config.dart`:

- First clear: 40 Cowries once per level.
- Star improvement: 12 Cowries per newly earned star.
- Replay without improvement: 0 Cowries.
- Chapter completion: 120 Cowries once on chapter-final levels.
- Daily rewards: seven-day local cycle.
- Achievements: claim-once Cowrie or booster grants.

## Monetization State

`MonetizationState` contains the current sandbox/production environment, product catalog, entitlement ids, owned product ids, product loading status, offline status, active product id, purchase state, and last user-facing monetization message.

Product ids, sandbox store ids, rewarded ad rewards, and interstitial frequency constants are centralized in `lib/core/monetization/monetization_config.dart`. Reward grants still flow through `EconomyService` so the Phase 3 wallet and booster inventory remain the source of truth.

Important rules:

- Remove Ads is a permanent entitlement and suppresses forced interstitial eligibility.
- Rewarded ad rewards are voluntary and remain available to Remove Ads owners.
- Purchase and ad callbacks use idempotency markers before granting value.
- Restore Purchases restores non-consumable and cosmetic entitlements only.

## Audio and Haptics

`AudioService` is created lazily through `audioServiceProvider` after storage/settings are available. It starts background music when a level starts, plays SFX for interactions, and is disposed with the provider.

`HapticService` is stateless and uses the persisted `HapticIntensity` from `settingsProvider`.
