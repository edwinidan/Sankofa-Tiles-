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
> Replace placeholder symbol characters with real hand-crafted Adinkra SVG artwork.

- [x] Polish `TileWidget` — cream face, gold border, 3D edge, suit code, name label, all animation states (normal / selected / hinted / matched)
- [ ] Draw SVG path for **Sankofa** (Wisdom 9) — the bird looking back
- [ ] Draw SVG path for **Nyansapo** (Wisdom 1) — wisdom knot
- [ ] Draw SVG path for **Gye Nyame** (Honor 1) — except God
- [ ] Draw SVG path for **Adinkrahene** (Royalty 1) — concentric circles
- [ ] Draw SVG path for **Aya** (Earth 1) — fern
- [ ] Draw SVG path for **Dwennimmen** (Honor 3) — ram's horns
- [ ] Draw SVG path for **Fawohodie** (Royalty 5) — freedom symbol
- [ ] Draw SVG path for **Akoma** (Honor 7) — heart
- [ ] Draw SVG path for **Nkyinkyim** (Wisdom 2) — adaptability
- [ ] Draw SVG path for **Denkyem** (Earth 2) — crocodile
- [ ] Draw SVG path for **Mpatapo** (Honor 4) — reconciliation knot
- [ ] Draw SVG path for **Pempamsie** (Royalty 3) — readiness chain
- [ ] Draw SVG path for **Tabono** (Honor 6) — paddle/oar
- [ ] Draw SVG path for **Bi Nka Bi** (Honor 2) — peace symbol
- [ ] Draw SVG path for **Mate Masie** (Wisdom 3) — what I hear I keep
- [ ] Draw SVG path for **Osram Ne Nsoromma** (Earth 5) — moon and star
- [ ] Draw SVG path for **Mframadan** (Earth 4) — windproof house
- [ ] Draw SVG path for **Nyame Dua** (Earth 9) — God's tree
- [ ] Draw SVG path for **Akofena** (Royalty 2) — sword of courage
- [ ] Draw SVG path for **Aban** (Royalty 4) — the castle
- [ ] Draw SVG path for **Funtumfunefu** (Royalty 6) — siamese crocodiles
- [ ] Draw SVG path for **Okodee Mmowere** (Royalty 8) — eagle talons
- [ ] Draw SVG path for **Mpuannum** (Royalty 7) — five tufts
- [ ] Draw SVG path for **Hye Wo Nhye** (Honor 5) — imperishability
- [ ] Draw remaining 12 tiles (Wisdom 4–8, Earth 3/6/7/8, Royalty 9, Honor 6–7)
- [ ] Save each symbol as individual SVG file in `assets/tiles/symbols/`
- [ ] Update `TileDefinition` to reference SVG asset path instead of symbol character
- [ ] Test all tiles render correctly at 64×85px on Android

---

## Phase 4 — Android Device Testing
> Stop developing on Chrome. Get it running on a real Android phone.

- [ ] Enable Developer Mode on Android phone (Settings → About → tap Build Number 7×)
- [ ] Enable USB Debugging (Settings → Developer Options → USB Debugging)
- [ ] Connect phone via USB and verify with `flutter devices`
- [ ] Run `flutter run` on physical Android device
- [ ] Verify touch controls feel correct (tap targets big enough)
- [ ] Verify tile sizes look right on phone screen
- [ ] Verify navy/gold theme looks correct on AMOLED screen
- [ ] Fix any layout issues specific to mobile screen size

---

## Phase 5 — Game Loop Polish
> Make the core gameplay feel great before adding more content.

- [ ] Play Level 1 start to finish — verify all pairs match correctly
- [ ] Verify win screen triggers when all tiles matched
- [ ] Verify lose screen triggers when no valid pairs remain
- [ ] Verify score calculation is correct (100pts per match, time bonus in Normal mode)
- [ ] Verify star rating (1–3 stars) saves correctly to SharedPreferences
- [ ] Verify level unlock logic works (Level 2 unlocks after Level 1 complete)
- [ ] Test hint system — verify correct pair highlights with green shimmer
- [ ] Test shuffle button — verify board reshuffles and deducts 50 points
- [ ] Test pause/resume — verify timer pauses in Normal mode
- [ ] Verify matched tile fade-out animation plays cleanly
- [ ] Verify selected tile lift animation feels responsive
- [ ] Fix any bugs found during testing

---

## Phase 6 — All 10 Levels
> Build out the full level progression so the game has real depth.

- [ ] Finalize Level 1 layout — 4×4 grid, 8 pairs, Wisdom suit only
- [ ] Build Level 2 layout — 4×5 grid, 10 pairs, Wisdom + Earth
- [ ] Build Level 3 layout — 5×4 grid, 12 pairs, Wisdom + Earth
- [ ] Build Level 4 layout — 5×5 grid, 14 pairs, all 3 suits
- [ ] Build Level 5 layout — 6×6 grid, 18 pairs, all suits
- [ ] Build Level 6 layout — 6×6 grid, 20 pairs, include Honor tiles
- [ ] Build Level 7 layout — 7×6 grid, 22 pairs, all tiles
- [ ] Build Level 8 layout — 7×7 grid, 24 pairs, harder arrangement
- [ ] Build Level 9 layout — 8×7 grid, 26 pairs
- [ ] Build Level 10 layout — 7×8 grid, 28 pairs, full tile set
- [ ] Name each level with a Ghanaian concept (e.g. "The Village", "The Chief's Court")
- [ ] Test each level is solvable (no impossible board states)
- [ ] Verify level select screen shows all 10 levels with correct lock/unlock state

---

## Phase 7 — Audio
> Add sound and music to bring the game to life.

- [ ] Source or create tile tap sound effect (.mp3)
- [ ] Source or create match success chime (.mp3)
- [ ] Source or create no-match error sound (.mp3)
- [ ] Source or create win celebration sound (.mp3)
- [ ] Source or create lose/fail sound (.mp3)
- [ ] Source Ghanaian highlife background music loop (.mp3)
- [ ] Add all audio files to `assets/audio/`
- [ ] Test all sounds play correctly in-game
- [ ] Test music loops seamlessly
- [ ] Verify sound on/off toggle works from Settings screen
- [ ] Verify music on/off toggle works from Settings screen

---

## Phase 8 — Onboarding & Settings
> First-time user experience and app configuration.

- [ ] Build 4-page onboarding PageView (Welcome, How to Play, The Symbols, Ready?)
- [ ] Auto-show onboarding only on first launch (check SharedPreferences)
- [ ] "Skip" button available on all onboarding pages
- [ ] "Start Playing" button on final page navigates to Level Select
- [ ] Settings screen — sound effects toggle wired to AudioService
- [ ] Settings screen — music toggle wired to AudioService
- [ ] Settings screen — default difficulty selector (Easy / Normal / Relaxed)
- [ ] Settings screen — show tile names toggle works in gameplay
- [ ] Settings screen — reset progress with confirmation dialog
- [ ] Test all settings persist after app restart

---

## Phase 9 — Visual Polish
> Make the game look and feel premium before monetization.

- [ ] Add Lottie win animation (fireworks / confetti) on win screen
- [ ] Add particle burst effect when tiles match
- [ ] Polish home screen — add animated Adinkra pattern background
- [ ] Polish level select — smooth card entrance animations
- [ ] Add board entrance animation (tiles deal in one by one on level start)
- [ ] Add screen transitions between all routes
- [ ] Verify app icon is set (navy background, gold Sankofa symbol)
- [ ] Verify splash screen is set (navy + gold, app name)
- [ ] Test visual polish on at least 2 different Android screen sizes

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
- [ ] Define IAP products in Google Play Console:
  - `remove_ads` — one-time purchase
  - `ashanti_tile_pack` — premium tile theme
  - `hint_pack_20` — consumable hint bundle
- [ ] Add `purchases_flutter` (RevenueCat) to `pubspec.yaml`
- [ ] Implement remove ads purchase flow
- [ ] Implement tile pack unlock flow
- [ ] Implement hint pack consumable flow
- [ ] Test all purchases with sandbox test accounts
- [ ] Verify ads disappear after remove_ads purchase

---

## Phase 11 — Pre-Launch
> Everything needed before submitting to the Play Store.

- [ ] Create Google Play Developer account ($25 one-time fee)
- [ ] Generate signed APK / App Bundle (`flutter build appbundle --release`)
- [ ] Test release build on physical Android device
- [ ] Run `flutter analyze` — zero errors
- [ ] Write Play Store listing:
  - App title: Sankofa Tiles
  - Short description (80 chars)
  - Full description (4000 chars) — highlight Ghanaian cultural theme
  - Keywords: adinkra, mahjong, ghana, puzzle, african, tile matching
- [ ] Design Play Store graphics:
  - App icon (512×512px)
  - Feature graphic (1024×500px)
  - At least 4 screenshots (phone)
- [ ] Set content rating (Everyone)
- [ ] Set pricing (Free)
- [ ] Upload to internal testing track first
- [ ] Add 5–10 beta testers (friends, family in Ghana and diaspora)
- [ ] Collect feedback and fix critical bugs
- [ ] Submit for Play Store review

---

## Phase 12 — Post-Launch & Growth
> After the game is live on the Play Store.

- [ ] Monitor Firebase Crashlytics for crashes (add `firebase_crashlytics` package)
- [ ] Set up Firebase Analytics to track level completion rates
- [ ] Monitor AdMob revenue dashboard
- [ ] Monitor RevenueCat IAP dashboard
- [ ] Respond to Play Store reviews
- [ ] Plan v1.1 update based on user feedback
- [ ] Design additional tile packs (Ewe, Ga, Northern Ghana themes)
- [ ] Plan multiplayer mode research (future v2)
- [ ] Market on TikTok targeting Ghanaian diaspora
- [ ] Reach out to Ghanaian cultural blogs and influencers
- [ ] Submit to "Made in Ghana" / African app directories

---

## Current Status

| Phase | Status |
|---|---|
| Phase 1 — Concept & Planning | ✅ Complete |
| Phase 2 — Project Scaffold | ✅ Complete |
| Phase 3 — Tile Artwork | 🔄 In progress |
| Phase 4 — Android Device Testing | ⏳ Not started |
| Phase 5 — Game Loop Polish | ⏳ Not started |
| Phase 6 — All 10 Levels | ⏳ Not started |
| Phase 7 — Audio | ⏳ Not started |
| Phase 8 — Onboarding & Settings | ⏳ Not started |
| Phase 9 — Visual Polish | ⏳ Not started |
| Phase 10 — Monetization | ⏳ Not started |
| Phase 11 — Pre-Launch | ⏳ Not started |
| Phase 12 — Post-Launch & Growth | ⏳ Not started |

---

*Last updated: Phase 3 in progress — TileWidget polished, SVG artwork next.*
