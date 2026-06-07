# Privacy Policy Findings — Adinkra Tiles (Sankofa Tiles)

This document catalogs every privacy-relevant aspect of the codebase as of 2026-06-06, so you can draft an accurate privacy policy. Each section covers what data is collected, how it's stored, which third parties see it, and whether the user can control or delete it.

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

### 2.4 Google Fonts

**SDK:** `google_fonts` v6.2.1

The app uses Google Fonts (`cinzel` and `nunito` font families) via the `google_fonts` package. On first launch, this package downloads font files from `fonts.googleapis.com` and caches them locally. No user data is sent during this request; Google may receive standard HTTP information (IP address, User-Agent) as part of serving the font files.

---

## 3. Data NOT Collected

The following are explicitly **not** collected or accessed by this app:

- **No user accounts or authentication** — no login, sign-up, email, or password
- **No personal identifiers** — no name, phone number, address, or date of birth
- **No precise location** — no GPS or fine-location permission
- **No advertising ID** — no `google_mobile_ads` or AdMob SDK
- **No in-app purchases** — no RevenueCat, no `in_app_purchase` plugin
- **No photos, media, or files** — no camera, microphone, photo library, or file system access
- **No contacts or calendars**
- **No health or fitness data**
- **No device sensor data** beyond what Firebase Analytics/Crashlytics collect by default
- **No external links or web views** within the app

---

## 4. Platform Permissions

### 4.1 Android

The app requests **no runtime permissions**. The `AndroidManifest.xml` contains:
- `android.intent.action.MAIN` / `LAUNCHER` — standard launcher activity
- `ACTION_PROCESS_TEXT` — Flutter engine text processing (not user-initiated)
- Firebase Google Services plugin (for Analytics + Crashlytics)

**No** `INTERNET` permission is declared explicitly, but the Firebase SDK and Google Fonts require network access at runtime.

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

## 8. Monetization Plans (NOT yet implemented)

The project plan (`sankofa_tiles_project_plan.md`) references planned features that are **not currently in the codebase**:

- Google AdMob ads (`google_mobile_ads` package)
- In-app purchases for tile packs
- RevenueCat for "remove ads" purchase management

If any of these are added later, the privacy policy must be updated to disclose:
- Advertising ID usage (AdMob)
- Purchase history collection
- RevenueCat's data handling practices

---

## 9. What You Need to Include in Your Privacy Policy

Based on the findings above, your privacy policy must at minimum disclose:

1. **Data controller identity** — your name/company and contact information
2. **Firebase Analytics** — what gameplay events are tracked, that an app-instance ID and coarse device/location data is collected automatically by Google
3. **Firebase Crashlytics** — that crash reports including stack traces and device info are sent to Google
4. **Google Fonts** — that font files are fetched from Google servers on first launch
5. **Local storage** — that game progress and preferences are stored on-device only
6. **No account/personal data** — that the app does not require registration or collect personal identifiers
7. **Data retention periods** — for Firebase Analytics (14 months default) and Crashlytics (90 days default)
8. **User controls** — the in-app "Reset All Progress" option and that uninstalling deletes all local data
9. **Children's privacy** — a clear statement about whether the app targets children and what measures are in place
10. **Third-party links** — links to Google's privacy policies
11. **No ads/IAP** — that the current version has no advertisements or in-app purchases

---

## 10. Reference Files

| File | Relevance |
|---|---|
| `pubspec.yaml` | All third-party SDK dependencies |
| `lib/main.dart` | Firebase + Crashlytics initialization, error handlers |
| `lib/core/utils/analytics_service.dart` | All analytics event definitions |
| `lib/core/utils/crash_reporting_service.dart` | Non-fatal error reporting |
| `lib/core/utils/storage_service.dart` | All SharedPreferences keys and what they store |
| `lib/core/utils/audio_service.dart` | Audio playback (no data collection; Crashlytics on failure) |
| `lib/core/theme/app_text_styles.dart` | Google Fonts usage (Cinzel, Nunito) |
| `android/app/src/main/AndroidManifest.xml` | Android permissions declared |
| `android/app/google-services.json` | Firebase project configuration |
| `ios/Runner/Info.plist` | iOS permissions and configuration |
| `macos/Runner/DebugProfile.entitlements` | macOS network entitlement (debug only) |
| `web/index.html` | Web app configuration (PWA) |
| `web/manifest.json` | PWA manifest |
| `docs/FIREBASE_TRACKING_NOTES.md` | Internal tracking notes |
| `sankofa_tiles_project_plan.md` | Future monetization plans (not yet implemented) |
