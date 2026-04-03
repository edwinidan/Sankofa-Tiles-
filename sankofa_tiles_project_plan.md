# Sankofa Tiles — Project Plan

> Ghanaian Adinkra Mahjong solitaire game for Android (Play Store)
> Built with Flutter + Riverpod · Monetized via AdMob + RevenueCat IAP

---

## Phase 1 — Concept & Planning
> Define what we are building before writing a single line of code.

- [x] Decide game type — Mahjong solitaire (tile matching pairs)
- [x] Choose cultural theme — Adinkra symbols, Kente colors, Ghanaian music
- [x] Name the app — **Sankofa Tiles**
- [x] Choose target platform — Android first, Google Play Store
- [x] Define monetization model — Ads (AdMob) + IAP tile packs + remove ads (RevenueCat)
- [x] Choose tech stack — Flutter + Riverpod
- [x] Define screens for v1 — Home, Gameplay, Level Select, Win/Lose, Settings, Onboarding
- [x] Decide offline-first — no backend in v1
- [x] Choose game modes — Easy, Normal, Relaxed
- [x] Define hint system — unlimited hints (casual)
- [x] Design full Adinkra tile set — 36 unique symbols across 3 suits + honor tiles
- [x] Design tile back — Midnight Kente (navy + gold, vertical Kente strips, starburst center)
- [x] Write master prompt for Claude Code

---

## Phase 2 — Project Scaffold
> Get a working, runnable Flutter project with all files and structure in place.

- [x] Scaffold Flutter project with correct package name (`com.sankofatiles.app`)
- [x] Add all dependencies to `pubspec.yaml` (Riverpod, go_router, flutter_svg, audioplayers, etc.)
- [x] Create full folder structure (`core`, `models`, `providers`, `screens`, `widgets`)
- [x] Implement `AppColors`, `AppTheme`, `AppTextStyles`
- [x] Define `TileDefinition` data model and full `kAllTiles` constant (all 36 tiles)
- [x] Define `LevelData` constants (10 levels with layouts and star thresholds)
- [x] Implement `StorageService` (SharedPreferences wrapper)
- [x] Implement `AudioService` (graceful stubs — no crash if files missing)
- [x] Implement `GameNotifier` (full game logic — select, match, hint, shuffle, win, lose)
- [x] Implement all 6 screens with navigation wired up via `go_router`
- [x] Create `tile_back.svg` — Midnight Kente design
- [x] App compiles and runs (`flutter run`)
- [x] Level 1 playable end-to-end in browser (Chrome)

---

## Phase 3 — Tile Artwork
> Replace placeholder symbol characters with real high-resolution Adinkra PNG artwork.

- [x] Polish `TileWidget` — cream face, gold border, 3D edge, suit code, name label, all animation states (normal / selected / hinted / matched)
- [x] Integrate High-Resolution PNG assets for all Adinkra symbols
- [x] Update `TileDefinition` to reference PNG asset path (Asset v2)
- [x] Implement "Image-Asset" mode in `TileWidget` to hide decorative frames for custom artwork
- [x] Test all tiles render correctly at 64×85px on Android

---

## Phase 4 — Android Device Testing
> Verified on physical Android hardware for touch responsiveness and visual fidelity.

- [x] Enable Developer Mode on Android phone
- [x] Enable USB Debugging
- [x] Connect phone via USB and verify with `flutter devices`
- [x] Run `flutter run` on physical Android device
- [x] Verify touch controls feel correct (tap targets big enough)
- [x] Verify tile sizes look right on phone screen
- [x] Verify navy/gold theme looks correct on AMOLED screen
- [x] Fix any layout issues specific to mobile screen size

---

## Phase 5 — Game Loop Polish
> Core gameplay refined with Mahjong Solitaire mechanics and responsive feedback.

- [x] Implement Mahjong Solitaire rules (layered stacking and "free tile" availability logic)
- [x] Verify win screen triggers when all tiles matched
- [x] Verify lose screen triggers when no valid pairs remain
- [x] Verify score calculation is correct (100pts per match + dynamic streak bonuses)
- [x] Verify star rating (1–3 stars) saves correctly to SharedPreferences
- [x] Verify level unlock logic works (Level 2 unlocks after Level 1 complete)
- [x] Test hint system — verify correct pair highlights with green shimmer (limited to available matches)
- [x] Test shuffle button — verify board reshuffles remaining tiles while preserving layout structure
- [x] Test pause/resume — verify timer pauses in Normal mode
- [x] Verify matched tile fade-out and scale-down animation plays cleanly
- [x] Verify selected tile lift animation feels responsive

---

## Phase 6 — All 10 Levels
> Full level progression implemented with complex 3D tile arrangements.

- [x] Implement 10 unique levels with varying grid sizes and stacking layouts
- [x] Define levels in `level_data.dart` with (row, col, layer) coordinates
- [x] Name each level with a Ghanaian concept (e.g. "Awakening", "Heritage", "Sankofa")
- [x] Test each level is solvable and progression is balanced
- [x] Verify level select screen shows all 10 levels with correct lock/unlock state

---

## Phase 7 — Audio
> Immersive soundscape added.

- [x] Integrate tile tap, match success, no-match error, win, and lose sound effects
- [x] Integrate Ghanaian highlife background music loop
- [x] Test music loops seamlessly and respects settings toggles
- [x] Verify sound on/off toggle works from Settings screen

---

## Phase 8 — Onboarding & Settings
> Complete user experience flow.

- [x] Implement 4-page onboarding PageView (Culture, Rules, Symbols, Ready)
- [x] Auto-show onboarding only on first launch (persisted in SharedPreferences)
- [x] Settings screen — Audio toggles (Sound/Music)
- [x] Settings screen — Gameplay toggles (Show Tile Names, Difficulty)
- [x] Settings screen — Data management (Reset Progress)

---

## Phase 9 — Visual Polish (Juice)
> Make the game look and feel premium before monetization.

- [x] Add **Particle Burst** effect on tile matches
- [x] Add **Score Pop** animation at match coordinates
- [x] Add **No-Match Shake** feedback
- [x] Add **Press Dip** and **Hover Glow** (Available) feedback
- [x] Implement **Streak Combo** system with time-gated "Speed Streak" logic (2s, 5s windows)
- [x] Integrate full **Haptic Feedback Profile** (impacts for taps, matches, errors, and combos)
- [x] Refine **Match Burst** animations (e.g. single-color Gold confetti)
- [/] Add Lottie win animation (fireworks / confetti) on win screen
- [ ] Polish home screen — add animated Adinkra pattern background
- [ ] Add board entrance animation (tiles deal in one by one on level start)
- [ ] Add screen transitions between all routes
- [x] Verify app icon is set (navy background, gold Sankofa symbol)
- [x] Verify splash screen is set (navy + gold, app name)

---

## Phase 10 — Monetization
> Add revenue features before Play Store submission.

- [ ] Set up Google AdMob account
- [ ] Create Android app in AdMob dashboard, get App ID
- [ ] Add `google_mobile_ads` package to `pubspec.yaml`
- [ ] Implement banner ad on Level Select screen (bottom)
- [ ] Implement interstitial ad between levels (every 3 levels)
- [ ] Implement rewarded ad for extra hints ("Watch ad for 3 hints")
- [ ] Set up RevenueCat account and create project
- [ ] Define IAP products in Google Play Console
- [ ] Add `purchases_flutter` (RevenueCat) to `pubspec.yaml`
- [ ] Implement remove ads purchase flow
- [ ] Implement tile pack unlock flow
- [ ] Implement hint pack consumable flow

---

## Phase 11 — Pre-Launch
> Everything needed before submitting to the Play Store.

- [ ] Create Google Play Developer account ($25 one-time fee)
- [ ] Generate signed APK / App Bundle (`flutter build appbundle --release`)
- [ ] Test release build on physical Android device
- [ ] Run `flutter analyze` — zero errors
- [ ] Write Play Store listing
- [ ] Design Play Store graphics
- [ ] Set content rating (Everyone)
- [ ] Set pricing (Free)
- [ ] Upload to internal testing track first
- [ ] Add 5–10 beta testers
- [ ] Collect feedback and fix critical bugs
- [ ] Submit for Play Store review

---

## Phase 12 — Post-Launch & Growth
> After the game is live on the Play Store.

- [ ] Monitor Firebase Crashlytics for crashes
- [ ] Set up Firebase Analytics to track level completion rates
- [ ] Respond to Play Store reviews
- [ ] Plan v1.1 update based on user feedback
- [ ] Design additional tile packs (Ewe, Ga, Northern Ghana themes)
- [ ] Market on TikTok targeting Ghanaian diaspora

---

## Current Status

| Phase | Status |
|---|---|
| Phase 1 — Concept & Planning | ✅ Complete |
| Phase 2 — Project Scaffold | ✅ Complete |
| Phase 3 — Tile Artwork (PNG) | ✅ Complete |
| Phase 4 — Android Testing | ✅ Complete |
| Phase 5 — Game Loop Polish | ✅ Complete |
| Phase 6 — All 10 Levels | ✅ Complete |
| Phase 7 — Audio | ✅ Complete |
| Phase 8 — Onboarding & Settings | ✅ Complete |
| Phase 9 — Visual Polish (Juice) | 🔄 In progress |
| Phase 10 — Monetization | ⏳ Not started |
| Phase 11 — Pre-Launch | ⏳ Not started |
| Phase 12 — Post-Launch & Growth | ⏳ Not started |

---

*Last updated: Phase 9 in progress — Haptic profile and time-based Speed Streak banner implemented. Next: Lottie animations and screen transitions.*
