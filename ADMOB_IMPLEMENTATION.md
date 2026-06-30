# AdMob Implementation — Adinkra Tiles

## Architecture

AdMob integration follows a layered architecture:

```
┌─────────────────────┐
│   UI Screens         │  result_screen, game_control_dock, settings_screen
├─────────────────────┤
│   Riverpod Providers │  monetization_provider, admob_provider
├─────────────────────┤
│   Services           │  MonetizationService, AdMobService, ConsentService
├─────────────────────┤
│   Configuration      │  AdIds, MonetizationConfig
├─────────────────────┤
│   Storage            │  StorageService (SharedPreferences)
└─────────────────────┘
```

**Key design principles:**
- Screens call Riverpod notifiers, not ad services directly.
- `MonetizationService` owns reward idempotency and grant logic.
- `AdMobService` handles SDK interactions (load, show, callbacks).
- `ConsentService` manages UMP consent flow.
- `AdIds` centralizes all ad-unit IDs with build-mode gating.
- All errors are caught and reported via `CrashReportingService` (Crashlytics).

---

## Files Changed

### Created

| File | Purpose |
|---|---|
| `lib/core/ads/ad_ids.dart` | Centralized ad-unit IDs with production/test gating |
| `lib/core/ads/admob_service.dart` | Rewarded and interstitial ad loading/showing |
| `lib/core/ads/consent_service.dart` | UMP consent information and privacy options |
| `lib/providers/admob_provider.dart` | Riverpod providers for AdMob and consent services |
| `test/ad_ids_test.dart` | Focused ad ID safety and build-mode tests |
| `ADMOB_AUDIT.md` | Initial architecture audit notes |
| `ADMOB_IMPLEMENTATION.md` | This document |
| `ACTION_REQUIRED.md` | Edwin's personal action items |
| `PHYSICAL_DEVICE_TEST_CHECKLIST.md` | Manual testing matrix |

### Modified

| File | Changes |
|---|---|
| `pubspec.yaml` | Added `google_mobile_ads: ^9.0.0` |
| `pubspec.lock` | Updated lock file |
| `android/app/src/main/AndroidManifest.xml` | Added AdMob app ID, removed AD_ID permissions |
| `lib/core/startup/app_startup.dart` | Added `AdMobService.shared.initialize()` call |
| `lib/core/utils/storage_service.dart` | Added first-session completion tracking |
| `lib/core/monetization/monetization_config.dart` | Added `AdIds` import and ad unit ID helpers |
| `lib/providers/monetization_provider.dart` | Wired `AdMobService` for rewarded/interstitial ads |
| `lib/screens/result/result_screen.dart` | Wired interstitial context, improved retry UX |
| `lib/screens/settings/settings_screen.dart` | Added privacy choices menu item |
| `lib/core/config/developer_tools_config.dart` | No changes (already correct) |
| `test/release_readiness_test.dart` | Added interstitial context, first-session, and UX tests |

---

## Consent Flow

```
App launch
  → StorageService.init()
  → AdMobService.shared.initialize() [unawaited]
    → ConsentService.gatherConsent()
      → requestConsentInfoUpdate()
      → loadAndShowConsentFormIfRequired()  [if required]
      → refreshPrivacyOptionsRequirement()
      → canRequestAds()  →  if true → MobileAds.instance.initialize()
```

**Error handling:**
- All UMP errors are caught and logged, never blocking the game.
- If consent update fails, `canRequestAds()` may return false; no ads are requested.
- `MobileAds.instance.initialize()` is called at most once (`_initializeFuture` guard).
- Duplicate `gatherConsent()` calls return the same future (`_startupConsentFuture` guard).

**Privacy options in Settings:**
- Shown only when `privacyOptionsRequired` is true (UMP says required).
- Opens the official UMP privacy-options form.
- Never shows a custom consent dialog.

**Debug geography:**
- Debug builds automatically set `DebugGeography.debugGeographyEea` so the consent form appears for testing.
- Release builds use real geography detection.

---

## Rewarded Hint Behavior

**Trigger:** Player taps Hint with zero Hint boosters.

**Flow:**
1. UI calls `monetizationProvider.completeRewardedAd(placement: freeHint)`.
2. `AdMobService.showRewardedAd()` loads and shows the ad.
3. If the player watches the full ad, `onUserEarnedReward` fires → `earnedReward = true`.
4. On ad dismiss, `showRewardedAd()` returns `earnedReward`.
5. `MonetizationService.completeRewardedAd()` grants 1 Hint booster only if `completed == true`.
6. Duplicate callback IDs are rejected (idempotency).

**If closed early:** No reward granted. Player can try again.

---

## Retry-Assistance Behavior

**Trigger:** Player loses a level (no more moves).

**UX wording:**
- Title: "Retry with help"
- Description: "Watch an ad to retry this level with one free Shuffle."
- Button: "WATCH AD & RETRY"

**Flow:**
1. Player taps the button. Button shows "LOADING…" and is disabled.
2. `monetizationProvider.completeRewardedAd(placement: retryAssistance)` is called.
3. If ad completed: 1 Shuffle booster granted, level immediately restarts.
4. If ad closed early: No reward. Button re-enables. Snackbar shows failure.
5. After reward granted, button disappears (`_rewardGranted = true`).

**Safety:**
- `_isLoading` prevents duplicate ad loads from rapid taps.
- `_rewardGranted` prevents the reward from being granted twice.
- Navigation happens exactly once after reward confirmation.
- No board restoration is attempted — the level restarts.

---

## Interstitial Rules

Interstitials are shown only after completed levels, subject to ALL of these:

| Rule | Implementation |
|---|---|
| Remove Ads entitlement | `hasMonetizationEntitlement('remove_ads')` |
| Not first session | `isFirstSessionCompleted()` from StorageService |
| Not tutorial | `isTutorialComplete()` from StorageService |
| Not after loss | `afterLoss` parameter (always false on win path) |
| Session cap (2) | `getInterstitialSessionCount()` |
| Minimum completed levels (2) | `getHighestCompletedLevel()` |
| Level frequency (every 3) | `getInterstitialCompletedSinceLast()` |
| Cooldown (8 min) | `getLastInterstitialAt()` |
| Rewarded-ad cooldown (2 min) | `getLastRewardedAdAt()` |

**Context protection:**
- Tutorial and first-session flags are read from `StorageService` at the call site.
- The first completed level always has `isFirstSession: true` (set immediately after).
- Progress is saved before any interstitial is attempted.
- Ad failure or unavailability continues navigation exactly once.

---

## Test vs Production ID Selection

```
         ┌──────────────┐
         │ kReleaseMode? │
         └──────┬───────┘
                │
        ┌───────┴───────┐
        │ No            │ Yes
        ▼               ▼
   Test IDs      ┌──────────────────┐
                 │ USE_PRODUCTION_ADS│
                 │ == true?          │
                 └──────┬───────────┘
                        │
                ┌───────┴───────┐
                │ No            │ Yes
                ▼               ▼
           Test IDs      Production IDs
```

- `productionAdsEnabled = kReleaseMode && useProductionAds`
- Test IDs: `ca-app-pub-3940256099942544/*` (Google's official test units)
- Production IDs: `ca-app-pub-5484820744037011/*`
- iOS returns `null` for all ad IDs (unsupported this release).

---

## Build Commands

### Debug Build (development)
```bash
flutter run --dart-define=ENABLE_DEVELOPER_TOOLS=true
```
Uses test ad IDs. Developer tools visible. UMP debug geography enabled.

### Debug APK
```bash
flutter build apk --debug
```
Uses test ad IDs.

### Internal-Test Build
```bash
flutter build appbundle --release
```
Uses **test ad IDs** (no `USE_PRODUCTION_ADS`). Safe for internal testing and Google Play internal track.

### Final Production AAB
```bash
flutter build appbundle --release --dart-define=USE_PRODUCTION_ADS=true
```
Uses **production ad IDs**. Only use for the production release track.

---

## Ad Inspector Instructions

1. Install a debug build on a physical device.
2. Open the app and allow it to initialize.
3. In the app, navigate to Developer Tools (if available) or use:
   ```dart
   MobileAds.instance.openAdInspector();
   ```
4. Ad Inspector shows recent ad requests, responses, and configuration.
5. Use it to verify:
   - Ad units are being requested
   - Consent status is correct
   - Test mode is active

---

## UMP Debug Geography Instructions

Debug builds automatically configure UMP with EEA geography:

```dart
ConsentDebugSettings(
  debugGeography: DebugGeography.debugGeographyEea,
)
```

This causes the consent form to appear on every fresh install in debug mode, regardless of actual location. To test non-EEA behavior, build in release mode without production ads.

To add a test device ID for UMP (if needed):
```dart
ConsentDebugSettings(
  debugGeography: DebugGeography.debugGeographyEea,
  testIdentifiers: ['YOUR_TEST_DEVICE_HASH'],
)
```

---

## Known Limitations

1. **No board restoration**: The "Continue after loss" rewarded ad unit is mapped to retry assistance (grants 1 Shuffle for a level restart). True board restoration requires game-state architecture changes.
2. **iOS not supported**: Ad IDs return `null` on iOS. AdMob setup is Android-only for this release.
3. **No pre-caching**: Ads are loaded on-demand when requested, not pre-cached. This means a brief loading delay when the player triggers a rewarded ad.
4. **Placements without production IDs**: `doubleCompletionCowries`, `freeRescueShuffle`, `bonusDailyChest`, `smallShopReward` use test IDs in all builds until AdMob units are created.
5. **Advertising ID removed**: AD_ID permissions are explicitly removed in the manifest. This may affect ad personalization and reporting.
6. **Session cap resets on app restart**: The interstitial session cap is reset in `StorageService.init()` on each app launch.

---

## Rollback Instructions

To completely remove AdMob integration:

1. Remove `google_mobile_ads: ^9.0.0` from `pubspec.yaml`.
2. Delete `lib/core/ads/` directory (3 files).
3. Delete `lib/providers/admob_provider.dart`.
4. Remove `import '../core/ads/admob_service.dart'` and `AdMobService` references from `lib/providers/monetization_provider.dart`.
5. Remove the `unawaited(AdMobService.shared.initialize())` call from `lib/core/startup/app_startup.dart`.
6. Remove the AdMob app ID `<meta-data>` from `android/app/src/main/AndroidManifest.xml`.
7. Remove privacy choices items from `lib/screens/settings/settings_screen.dart`.
8. Remove `admob_provider.dart` imports from settings screen.
9. Run `flutter pub get` and `flutter analyze` to verify clean removal.
10. In `MonetizationNotifier.completeRewardedAd`, remove the `_adMobService.showRewardedAd()` call and always pass `completed: true` to simulate the old behavior.
11. In `MonetizationNotifier.recordLevelWinAndMaybeShowInterstitial`, remove the `_adMobService.showInterstitialAd()` call.
