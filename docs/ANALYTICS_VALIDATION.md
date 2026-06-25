# Analytics Validation

## Current Analytics Surface

`AnalyticsService` is a no-op when Firebase is unavailable. No event intentionally includes PII, receipt payloads, ad identifiers, or account data.

## Event Coverage

| Area | Events |
|---|---|
| Startup/navigation | `app_open`, `screen_view` |
| Home/progression | `play_pressed`, `next_game_pressed`, `level_retried` |
| Level lifecycle | `level_started`, `level_completed`, `level_failed` |
| Gameplay actions | `hint_used`, `shuffle_used`, `pause_used` |
| Tutorial/onboarding | `onboarding_completed`, `tutorial_started`, `tutorial_step_completed`, `tutorial_skipped`, `tutorial_completed` |
| Economy | `wallet_changed`, `booster_changed`, `daily_reward_claimed`, `collection_unlocked`, `achievement_unlocked` |
| Monetization | `shop_viewed`, `product_viewed`, `purchase_attempt`, `purchase_success`, `purchase_failure`, `restore_purchases`, `rewarded_ad_requested`, `rewarded_ad_completed`, `rewarded_ad_failed`, `interstitial_shown`, `interstitial_skipped`, `remove_ads_entitlement` |
| Settings | `settings_opened`, `tile_preview_opened`, `reset_progress` |

## Validation Status

- Static event inventory is documented in `docs/ANALYTICS_EVENT_MAP.md`.
- Automated tests protect important state transitions, but they do not verify Firebase dashboard delivery.
- Crashlytics non-fatal hooks exist for storage, board generation, startup, and audio failures.

## Required Manual Validation Before Release

1. Run a debug or internal-test build with Firebase configured.
2. Complete onboarding and tutorial; verify tutorial events.
3. Start, win, lose, retry, and complete a chapter; verify level events.
4. Claim daily reward and unlock collection symbols; verify economy events.
5. Open Shop, purchase sandbox products, cancel/fail a purchase, restore purchases; verify monetization events.
6. Trigger a non-fatal Crashlytics test path or controlled test exception in an internal build only.
7. Confirm no event parameters contain PII, receipts, or advertising identifiers.

## Known Gaps

- `logAppOpen()` exists but startup does not currently call it.
- Firebase delivery is not verified by automated tests.
- Live ad impression and billing receipt analytics are not present because live SDKs are not integrated.
