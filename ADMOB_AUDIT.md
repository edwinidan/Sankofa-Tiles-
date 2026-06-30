# AdMob Audit

## Current Relevant Architecture

Adinkra Tiles is a Flutter/Riverpod game with app startup handled by
`lib/main.dart`, `lib/app_bootstrapper.dart`, and
`lib/core/startup/app_startup.dart`. Firebase initializes before the app UI, and
Crashlytics is wrapped by `CrashReportingService`.

Monetization already exists as an SDK-neutral layer:

- `lib/core/monetization/monetization_models.dart`
- `lib/core/monetization/monetization_config.dart`
- `lib/core/monetization/monetization_service.dart`
- `lib/providers/monetization_provider.dart`

Reward grants are centralized in `MonetizationService`, and screens call the
Riverpod notifier instead of calculating rewards directly. This is the right
place to gate reward grants on completed rewarded-ad callbacks.

Android package/application ID is `com.sankofatiles.sankofa_tiles`.
The Android manifest already uses the release-facing label `Adinkra Tiles`.

## Files Modified Or Created

Created:

- `lib/core/ads/ad_ids.dart`
- `lib/core/ads/consent_service.dart`
- `lib/core/ads/admob_service.dart`
- `lib/providers/admob_provider.dart`
- `ADMOB_AUDIT.md`

Modified:

- `pubspec.yaml`
- `pubspec.lock`
- `android/app/src/main/AndroidManifest.xml`
- `lib/core/startup/app_startup.dart`
- `lib/core/monetization/monetization_config.dart`
- `lib/providers/monetization_provider.dart`
- `lib/screens/settings/settings_screen.dart`
- `lib/core/config/developer_tools_config.dart`
- `test/release_readiness_test.dart`

## Existing Services And Providers Reused

- `CrashReportingService` records non-sensitive AdMob and UMP failures.
- `AnalyticsService` continues to log ad placement events by placement name.
- `MonetizationService` remains responsible for reward idempotency and grants.
- `EconomyService` remains responsible for cowrie and booster mutations.
- `StorageService` remains responsible for interstitial cooldown and cap state.

## Risks And Possible Conflicts

- The manifest deliberately removes advertising ID permissions. AdMob can still
serve ads, but this can affect ad personalization and reporting behavior.
- Live rewarded IDs exist only for Hint and Continue. Other existing rewarded
placements fail safely in production until AdMob units are created for them or
the product decision is changed.
- Continue after loss is not wired as board-state restoration. The current loss
reward is retry assistance, which grants a Shuffle for a retry.
- Ad requests are platform-channel based, so unit tests continue to exercise the
pure Dart monetization service rather than real SDK calls.

## Rewarded Hint

When the player has no Hint boosters and taps Hint, the existing UI calls
`MonetizationNotifier.completeRewardedAd(RewardedPlacement.freeHint)`.
The notifier now attempts to show a rewarded AdMob ad first. The Hint booster is
granted only if the rewarded callback is earned.

Debug and profile builds resolve this placement to Google's official rewarded
test ad unit. A production ad unit is selected only in a release build with:

```sh
flutter build appbundle --release --dart-define=USE_PRODUCTION_ADS=true
```

## Continue After Loss

The current game-state architecture routes a loss to `ResultScreen` with the
final `GameState`, but there is no implemented safe resume operation that
restores a valid playable board after loss. Therefore the provided Rewarded
Continue ad unit is centralized as the production ID for
`RewardedPlacement.retryAssistance`, which matches the existing loss-screen
reward and does not invent restoration behavior.

## Interstitial Placement

Interstitials are safest after completed levels, outside active gameplay. The
existing `recordLevelWinAndMaybeShowInterstitial` path already protects:

- Remove Ads entitlement
- First session
- Tutorial
- Loss flow
- Session cap
- Minimum completed levels
- Completed-level frequency
- Interstitial cooldown
- Rewarded-ad cooldown

The AdMob interstitial is now attempted only after these rules say the placement
is eligible. Frequency state is recorded only after the SDK reports the ad was
shown and dismissed.

## Tutorial And First-Session Protection

Tutorial and first-session flags are already parameters on
`recordLevelWinAndMaybeShowInterstitial` and are enforced in
`MonetizationService.interstitialDecision`. Existing call sites currently use
the default false values, so future tutorial/first-session call sites should
pass explicit context when they invoke interstitial eligibility.

## Production And Test ID Separation

All IDs live in `lib/core/ads/ad_ids.dart`.

- Android app ID is inserted once in `AndroidManifest.xml`.
- Debug/profile builds use Google's official sample test ad-unit IDs.
- Release builds still use test IDs unless `USE_PRODUCTION_ADS=true`.
- Production IDs are selected only when `kReleaseMode && useProductionAds`.
- Android app ID is validated for `~`.
- Ad-unit IDs are validated for `/`.
- iOS returns `null` for ad IDs and remains unsupported for this phase.

## Missing Information Requiring Edwin's Action

No missing ID is blocking the Android Hint, Continue/retry-assistance, or level
transition interstitial setup.

ACTION REQUIRED FROM EDWIN before true loss-continue behavior:

1. Decide whether Rewarded Continue should resume the same failed board, start a
   retry with an assist, or remain disabled.
2. This is needed because current game-state code does not expose a safe board
   restoration flow after loss.
3. The decision belongs in the loss flow shown by `lib/screens/result/result_screen.dart`.
4. Provide the intended UX and reward behavior for "Continue".
5. Work can safely continue without this decision by using the existing retry
   assistance reward.
