# Privacy Policy Findings — Adinkra Tiles (Sankofa Tiles)

This document catalogs every privacy-relevant aspect of the codebase as of 2026-07-01, so you can draft an accurate privacy policy. Each section covers what data is collected, how it's stored, which third parties see it, and whether the user can control or delete it.

---

## 1. App Identity

| Field | Value |
|---|---|
| App name (user-facing) | Adinkra Tiles |
| Android package | `com.sankofatiles.sankofa_tiles` |
| iOS bundle display name | Adinkra Tiles |
| Firebase project | `adinkra-tiles` (project #1015163967198) |
| Version | 1.0.0+1 |
| Developer contact | *you must fill this in* |

---

## 2. Data Collected & Purpose

### 2.1 Firebase Analytics (Google)

**SDK:** `firebase_analytics` v12.4.2

The app sends the following events to Google Firebase Analytics. None of these events contain personally identifiable information (PII) — no names, emails, device IDs, phone numbers, or advertising identifiers are attached by the app code.

| Event | Parameters sent | Source file |
|---|---|---|
| `app_open` | *(automatic — no custom parameters)* | `analytics_service.dart:15` |
| `screen_view` | `screen_name`, `screen_class` | `analytics_service.dart:17` |
| `level_started` | `level_id`, `difficulty` | `analytics_service.dart:24` |
| `level_completed` | `level_id`, `difficulty`, `score`, `stars`, `seconds_elapsed` | `analytics_service.dart:29` |
| `level_failed` | `level_id`, `difficulty`, `score`, `reason` | `analytics_service.dart:44` |
| `hint_used` | `level_id`, `difficulty` | `analytics_service.dart:57` |
| `shuffle_used` | `level_id`, `difficulty` | `analytics_service.dart:62` |
| `pause_used` | `level_id`, `difficulty` | `analytics_service.dart:67` |
| `settings_opened` | `source` | `analytics_service.dart:72` |
| `tile_preview_opened` | *(no parameters)* | `analytics_service.dart:75` |
| `onboarding_completed` | *(no parameters)* | `analytics_service.dart:77` |
| `reset_progress` | *(no parameters)* | `analytics_service.dart:79` |
| `shop_viewed` | `section` | `analytics_service.dart` |
| `product_viewed` | `product_id` | `analytics_service.dart` |
| `purchase_attempt` | `product_id` | `analytics_service.dart` |
| `purchase_success` | `product_id` | `analytics_service.dart` |
| `purchase_failure` | `product_id`, `reason` | `analytics_service.dart` |
| `restore_purchases` | `result`, `restored_count` | `analytics_service.dart` |
| `rewarded_ad_requested` | `placement` | `analytics_service.dart` |
| `rewarded_ad_completed` | `placement` | `analytics_service.dart` |
| `rewarded_ad_failed` | `placement`, `reason` | `analytics_service.dart` |
| `interstitial_shown` | `placement` | `analytics_service.dart` |
| `interstitial_skipped` | `placement`, `reason` | `analytics_service.dart` |
| `remove_ads_entitlement` | `active`, `source` | `analytics_service.dart` |

**Important note about Firebase Analytics defaults:** Even though the app does not explicitly pass advertising IDs or device identifiers, Firebase Analytics can automatically collect:
- App-instance ID (a random identifier tied to each app install)
- Coarse device information (OS version, device model, screen resolution)
- Approximate location (IP-based, country/city level)
- User engagement metrics (session duration, first-open time)

Google's own disclosure for Firebase Analytics states these are used for aggregate reporting and are not linked to user identity in the default configuration. Your privacy policy should mention this default collection.

### 2.2 Firebase Crashlytics (Google)

**SDK:** `firebase_crashlytics` v5.2.3

Crashlytics captures:

- **Fatal errors:** Uncaught Flutter exceptions and platform-level crashes (`main.dart:22-30`). Includes stack traces, device state at crash time, and OS version.
- **Non-fatal errors:** Explicitly reported for these failure scenarios:
  - SharedPreferences initialization failure (`storage_service.dart:23-30`)
  - Level result save failure (`storage_service.dart:44-51`)
  - Progress reset persistence failure (`storage_service.dart:132-139`)
  - Audio SFX playback failure (`audio_service.dart:92-99`)
  - Background music playback/stop failure (`audio_service.dart:134-141`, `153-163`)
  - Audio SFX stop failure (`audio_service.dart:167-175`)
  - Background music volume update failure (`audio_service.dart:187-194`)

Crashlytics may automatically attach:
- Crash-instance identifiers (not tied to a user account)
- Device model, OS version, free RAM/disk
- App version and build number

### 2.3 Local Storage — SharedPreferences

**SDK:** `shared_preferences` v2.2.3

All data stored by SharedPreferences lives **only on the device**. It is never uploaded, shared, or synced to a server (except as crash metadata if a persistence failure triggers a Crashlytics report).

| Key prefix / name | Data stored | Source file |
|---|---|---|
| `best_score_{levelId}` | Best score integer per level | `storage_service.dart:8` |
| `stars_{levelId}` | Star count integer per level | `storage_service.dart:9` |
| `default_difficulty` | Preferred difficulty mode string (easy/normal/hard) | `storage_service.dart:10` |
| `sound_enabled` | Boolean — sound effects on/off | `storage_service.dart:11` |
| `music_enabled` | Boolean — background music on/off | `storage_service.dart:12` |
| `music_volume` | Double (0.0–1.0) — music volume level | `storage_service.dart:13` |
| `onboarding_complete` | Boolean — whether onboarding was finished | `storage_service.dart:14` |
| `show_tile_names` | Boolean — whether Adinkra symbol names appear on tiles | `storage_service.dart:15` |
| `haptic_intensity` | String enum — haptic feedback level (off/low/medium/high) | `storage_service.dart:16` |
| `economy_cowries` and `economy_booster_*` | Local Cowrie wallet and booster inventory | `storage_service.dart` |
| `economy_tx_*` | Local reward idempotency markers | `storage_service.dart` |
| `daily_reward_day`, `daily_last_claim_date` | Local daily reward cycle state | `storage_service.dart` |
| `collection_unlocked_*`, `achievement_claimed_*` | Local collection and achievement unlock flags | `storage_service.dart` |
| `monetization_entitlement_*` | Local permanent entitlements such as Remove Ads or cosmetics | `storage_service.dart` |
| `monetization_purchase_*` | Local one-time/restorable product ownership markers | `storage_service.dart` |
| `monetization_callback_*` | Local purchase/rewarded-callback idempotency markers | `storage_service.dart` |
| `monetization_last_*`, `monetization_interstitial_*` | Local ad frequency and cooldown state | `storage_service.dart` |

### 2.4 Google Fonts

**SDK:** `google_fonts` v6.2.1

The app uses Google Fonts (`cinzel` and `nunito` font families) via the `google_fonts` package. On first launch, this package downloads font files from `fonts.googleapis.com` and caches them locally. No user data is sent during this request; Google may receive standard HTTP information (IP address, User-Agent) as part of serving the font files.

### 2.5 Google Mobile Ads (AdMob)

**SDK:** `google_mobile_ads` v9.0.0

The app integrates the Google Mobile Ads SDK to display interstitial and rewarded ads. To request, serve, and measure ads, the SDK automatically collects and shares certain user and device data with Google and its advertising partners:

- **Device or other identifiers:** Device-specific hardware identifiers (like screen resolution, OS version, and brand) are transmitted. The Google Advertising ID (`AD_ID`) is used for ad personalization and capping, although the app currently contains manifest configurations that attempt to opt-out/disable it (see Section 4).
- **Approximate location:** Coarse location derived from IP address (country, state, city) is sent to target geographically relevant ads.
- **App activity / interactions:** The SDK tracks user interaction with ads (such as impressions, clicks, and video completion status) to calculate ad revenue and prevent fraud.
- **App info and performance:** Diagnostic information, SDK latency, load times, and performance analytics are collected to monitor ad health.

**Consent Management (GDPR/EEA/UK compliance):**
The app integrates the Google User Messaging Platform (UMP) SDK (via `ConsentService`) to present users in the EEA/UK with a consent dialogue. Users can choose whether to allow personalized ads, non-personalized ads, or deny consent entirely. Privacy choices can be updated at any time via the in-game settings.

---

## 3. Data NOT Collected

The following are explicitly **not** collected or accessed by this app:

- **No user accounts or authentication** — no login, sign-up, email, or password
- **No personal identifiers** — no name, phone number, address, or date of birth
- **No precise location** — no GPS or fine-location permission
- **Advertising ID usage:** The app now includes the `google_mobile_ads` SDK, which uses the Android Advertising ID (`AD_ID`) for ad personalization, subject to user consent and OS level settings. *Note: The app's manifest currently includes tags to remove `AD_ID` permissions (see Section 4.1).*
- **No live billing SDK in the current code** — Phase 4 adds local sandbox purchase states and entitlement handling but no RevenueCat or `in_app_purchase` plugin yet.
- **No photos, media, or files** — no camera, microphone, photo library, or file system access
- **No contacts or calendars**
- **No health or fitness data**
- **No device sensor data** beyond what Firebase Analytics/Crashlytics collect by default
- **No external links or web views** within the app

---

## 4. Platform Permissions

### 4.1 Android

The app requests the following permissions, which may be declared either explicitly in the manifest or merged automatically by third-party SDKs:
- `android.permission.INTERNET` (merged automatically by Firebase and Google Mobile Ads SDKs) — required to download fonts, send analytics/crashes, and fetch ads.

**Special Manifest Directives for Advertising ID:**
The `AndroidManifest.xml` explicitly includes rules to **remove** the standard Advertising ID permissions:
- `com.google.android.gms.permission.AD_ID` with `tools:node="remove"`
- `android.permission.ACCESS_ADSERVICES_AD_ID` with `tools:node="remove"`
- Metadata flag `google_analytics_adid_collection_enabled` is set to `false`.

These directives prevent the app (including Firebase Analytics and Google Mobile Ads) from accessing the hardware Advertising ID on Android 12+ devices, limiting ad delivery to non-personalized or contextual ads unless these nodes are restored.

The manifest also declares:
- `android.intent.action.MAIN` / `LAUNCHER` — standard launcher activity
- `ACTION_PROCESS_TEXT` — Flutter engine text processing (not user-initiated)
- Firebase Google Services plugin (for Analytics + Crashlytics)
- `com.google.android.gms.ads.APPLICATION_ID` — metadata to identify your AdMob app ID.

### 4.2 iOS

No privacy-sensitive plist keys (`NSCamera`, `NSLocation`, `NSMicrophone`, etc.) are present in `Info.plist`. The app uses no background modes.

### 4.3 macOS

- `com.apple.security.app-sandbox` — app sandbox is enabled
- `com.apple.security.cs.allow-jit` — JIT compilation (Flutter engine requirement)
- `com.apple.security.network.server` — network server entitlement (debug profile only; absent in release)

### 4.4 Web

The app is a PWA (`manifest.json`): `"display": "standalone"`, no special permissions requested. The web build does not reference Firebase in the `index.html` (Firebase initialization happens in Dart code).

---

## 5. Third-Party Services Summary

| Service | Purpose | Data shared | Privacy policy link (you fill in) |
|---|---|---|---|
| Google Firebase Analytics | Gameplay analytics & usage metrics | Level progress events, screen views, app-instance ID, coarse device info, IP-based approximate location | `https://firebase.google.com/support/privacy` |
| Google Firebase Crashlytics | Crash reporting & stability monitoring | Stack traces, device/OS info, non-fatal error reports | `https://firebase.google.com/support/privacy` |
| Google Fonts | Font file delivery | HTTP request metadata (IP, User-Agent) at font download time | `https://policies.google.com/privacy` |
| Google AdMob | Ad serving and monetization | Device/Advertising ID, approximate location, ad interaction events, performance diagnostics | `https://policies.google.com/privacy` |

---

## 6. Data Retention & Deletion

### 6.1 Local data (SharedPreferences)

Users can delete all local game progress (scores, stars, unlocked levels) from the **Settings > Data > Reset All Progress** button (`settings_screen.dart:90-91`). This does not affect sound/volume/difficulty preferences, which remain in SharedPreferences.

Uninstalling the app removes all SharedPreferences data.

### 6.2 Firebase data

- **Analytics data:** Retained by Google according to your Firebase project's data retention settings (default is **14 months** for event-level data). You can adjust this in the Firebase Console under **Project Settings > Data Privacy**.
- **Crashlytics data:** Crash events and stack traces are retained for **90 days** by default. You can adjust this in the Firebase Console.

The app provides **no in-app mechanism to request deletion** of Firebase-collected data. Users would need to contact you (the developer) to request deletion, or you can implement the Firebase data deletion API.

---

## 7. Children's Privacy (COPPA / age-appropriate design)

- The app does **not** have an age gate, age screen, or parental consent mechanism.
- The app does **not** explicitly target children, nor does it prevent children from playing (it's a family-friendly tile-matching game with Ghanaian cultural content).
- Firebase Analytics does **not** treat users as children by default. If the app is directed at children under 13, you **must** disable personalized analytics and ad features in Firebase (or use Firebase in a COPPA-compliant mode).
- Google Fonts does **not** serve personalized content and is generally considered COPPA-neutral.

**Action required:** Decide whether this app is "directed to children" under COPPA/UK AADC / similar laws. If it is, you need to either:
- Strip Firebase Analytics/Crashlytics entirely, or
- Configure Firebase to treat all users as children (disabling advertising features, personalization, and certain data collection), **and** disclose this in the privacy policy.

---

## 8. Monetization Status

The app now implements a live ad monetization flow alongside a local sandbox shop layer:

- **Google Mobile Ads (AdMob) Integration:** Live SDK integration (`google_mobile_ads` v9.0.0) is configured. Interstitial ads are shown at key gameplay transitions, and Rewarded ads are shown for opt-in rewards (e.g., getting hints or continuing level attempts).
- **Consent Collection (UMP):** Fully integrated via Google's User Messaging Platform (UMP) SDK to collect and manage user consent in GDPR-applicable jurisdictions.
- **Local Sandbox Shop & Entitlements:** Local implementation for purchase states, item inventory (Cowries, Boosters), and a "Remove Ads" entitlement.
- **Note on Billing SDK:** The code does **not** yet contain live store billing APIs (such as `in_app_purchase` or RevenueCat). If a live billing SDK is added in the future, the privacy policy must be updated to disclose purchase history collection and the respective payment provider's policies.

---

## 9. What You Need to Include in Your Privacy Policy

Based on the findings above, your privacy policy must at minimum disclose:

1. **Data controller identity** — your name/company and contact information
2. **Google AdMob (Advertising)** — that the app displays ads using Google AdMob, which collects and shares Device IDs, advertising ID (AD_ID), approximate location, and ad interaction history to personalize ads and measure performance.
3. **User Consent and Privacy Settings** — mention that users in the EEA/UK can customize or revoke their consent choices at any time using the in-game Privacy Options menu.
4. **Firebase Analytics** — what gameplay events are tracked, and that an app-instance ID and coarse device/location data is collected automatically by Google.
5. **Firebase Crashlytics** — that crash reports including stack traces and device info are sent to Google.
6. **Google Fonts** — that font files are fetched from Google servers on first launch.
7. **Local storage** — that game progress and preferences are stored on-device only.
8. **No account/personal data** — that the app does not require registration or collect personal identifiers.
9. **Data retention periods** — for Firebase Analytics (14 months default), Crashlytics (90 days default), and standard Google advertising data retention profiles.
10. **User controls** — the in-app "Reset All Progress" option, the "Privacy Options" form trigger (for ad consent), and that uninstalling deletes all local data.
11. **Children's privacy** — a clear statement about whether the app targets children and what measures are in place (under COPPA, UK AADC, GDPR, etc.). If you serve ads, ensure they are configured correctly for children if your app is directed at minors.
12. **Third-party links** — links to Google's privacy policies and AdMob's partner network policies.

---

## 10. Reference Files

| File | Relevance |
|---|---|
| `pubspec.yaml` | All third-party SDK dependencies |
| `lib/main.dart` | Firebase + Crashlytics initialization, error handlers |
| `lib/core/startup/app_startup.dart` | Startup sequence including AdMob and consent checks |
| `lib/core/ads/admob_service.dart` | AdMob initialization, loading, and display logic for interstitial and rewarded ads |
| `lib/core/ads/consent_service.dart` | Consent gatherer using Google User Messaging Platform (UMP) |
| `lib/core/ads/ad_ids.dart` | Test and production AdMob App ID and Ad Unit IDs |
| `lib/providers/admob_provider.dart` | Riverpod providers for the AdMob services |
| `lib/core/utils/analytics_service.dart` | All analytics event definitions (including ad placement events) |
| `lib/core/utils/crash_reporting_service.dart` | Non-fatal error reporting |
| `lib/core/utils/storage_service.dart` | All SharedPreferences keys and what they store (including ad limits/cooldown states) |
| `lib/core/utils/audio_service.dart` | Audio playback (no data collection; Crashlytics on failure) |
| `lib/core/theme/app_text_styles.dart` | Google Fonts usage (Cinzel, Nunito) |
| `android/app/src/main/AndroidManifest.xml` | Android permissions and AdMob App ID declarations |
| `android/app/google-services.json` | Firebase project configuration |
| `ios/Runner/Info.plist` | iOS permissions and configuration |
| `macos/Runner/DebugProfile.entitlements` | macOS network entitlement (debug only) |
| `web/index.html` | Web app configuration (PWA) |
| `web/manifest.json` | PWA manifest |
| `docs/FIREBASE_TRACKING_NOTES.md` | Internal tracking notes |
| `sankofa_tiles_project_plan.md` | Future monetization plans |
