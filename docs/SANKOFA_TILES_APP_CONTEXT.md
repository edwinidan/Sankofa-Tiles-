# Sankofa Tiles — App Context Document

> Generated: 2026-06-24
> Purpose: Complete reference for current codebase state
> Scope: Documentation only — no code changes

> Phase 5 note: this document is a historical pre-Phase-5 context snapshot. The current release-readiness state is documented in `Project_Report.md`, `docs/FINAL_GAME_FLOW.md`, `docs/RELEASE_CHECKLIST.md`, and `docs/PHASE_5_FINAL_REPORT.md`.

---

# App Identity

| Attribute | Value |
|---|---|
| App name | Sankofa Tiles (displayed as "Adinkra Tiles" in MaterialApp title) |
| Package name / Application ID | `com.sankofatiles.sankofa_tiles` |
| Version name | `1.0.0` |
| Version code | `3` (from pubspec `1.0.0+3`) |
| Flutter SDK constraint | `>=3.0.0 <4.0.0` |
| Game type | Adinkra-inspired Mahjong solitaire / tile-matching puzzle game |
| Visual direction | Dark green/teal premium board-table style with parchment accents |
| Main theme | Ghanaian, Adinkra-inspired, calm, premium, casual puzzle |
| Current target | Play Store MVP publication |

## Checklist: What Exists vs. What Doesn't

| Item | Status | Notes |
|---|---|---|
| App name in AndroidManifest | `sankofa_tiles` (underscored) | Should be "Sankofa Tiles" for release |
| Application ID | `com.sankofatiles.sankofa_tiles` | Present |
| Version name / code | `1.0.0` / `3` | Present, driven by pubspec.yaml |
| App icon (Android) | Default Flutter icon | Default `ic_launcher.png` in all mipmap densities |
| Adaptive icon (Android) | Missing | No `ic_launcher.xml` or adaptive icon drawables |
| iOS app icon | Present | Full icon set in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| macOS app icon | Present | Icon set in `macos/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Web favicon / icons | Present | `web/favicon.png`, `web/icons/Icon-192.png`, `Icon-512.png` |
| Splash screen (Android) | Default white | `launch_background.xml` is default white background |
| Splash screen (iOS) | Present | `LaunchImage` set in assets catalog |
| Portrait lock | Yes | `DeviceOrientation.portraitUp` in `main.dart` |
| Internet permission | None | No `<uses-permission>` tags in AndroidManifest |
| Firebase / Crashlytics | Integrated | `firebase_crashlytics: ^5.2.3` |
| Firebase Analytics | Integrated | `firebase_analytics: ^12.4.2` |
| Release signing | Debug keys | `build.gradle.kts`: `signingConfig = signingConfigs.getByName("debug")` |
| Privacy policy | Linked | `url_launcher` opens `https://adinkra-tiles-privacy-policy.vercel.app/` |
| minSdk / targetSdk | Flutter defaults | `flutter.minSdkVersion` / `flutter.targetSdkVersion` |

---

# User Flow

1. **App launch** → `main.dart` initializes Firebase, locks portrait, initializes `StorageService`.
2. **Router check** → `GoRouter` evaluates initial location `/`:
   - If onboarding not complete → redirect to `/onboarding`
   - Otherwise → stay at `/` (HomeScreen)
3. **Home Screen** → User sees logo image, subtitle, and 4 buttons in a parchment panel.
4. **Onboarding** (4-page PageView) → User can swipe, tap Next, or Skip. On finish → `context.go('/')`.
5. **Play** → Home screen computes `nextUnfinishedLevelId`, logs `play_pressed` analytics, navigates directly to `/game/:levelId`.
6. **Gameplay** → Board loads, tiles animate in. No timer.
   - Match tiles → score, combo streaks, particle effects
   - Hint → highlights a matching pair (2s glow)
   - Shuffle → rearranges remaining tiles (-50 score cost)
   - Pause → pause overlay with Resume / Quit
   - Settings (gear icon) → in-game settings bottom sheet
7. **Game End** → Auto-navigates to `/result`:
   - **Win** → Stars (computed from dynamic thresholds), score breakdown, "NEXT GAME" button (or "All Levels Completed" / "RETURN HOME" at level 200)
   - **Lose** (no more moves after auto-shuffle) → Score, proverb, Home / Retry buttons
8. **Result** → User can go Home, Retry, or (on win) Next Game.
9. **Other flows**:
    - Settings (from Home) → Audio, haptic, show tile names, privacy policy, developer tools section
    - Tile Preview (from Home) → Browse all ~90 Adinkra tile symbols
    - Developer Level Tester (from Settings, debug only) → Test any of 200 levels without saving progress

## Navigation Approach

- **Router**: `GoRouter` (`go_router: ^13.2.0`)
- **Route paths**:
  - `/` — HomeScreen
  - `/onboarding` — OnboardingScreen
  - `/game/:levelId` — GameScreen (with `GameLaunchConfig` as extra)
  - `/result` — ResultScreen (with `GameResultConfig` as extra)
  - `/settings` — SettingsScreen
  - `/tile-preview` — TilePreviewScreen
  - `/developer/levels` — DeveloperLevelTesterScreen (debug-only)

**No level-select route.** Progression is linear — Play always takes you to the next unfinished level.

---

# Screens

## Home Screen

**File:** `lib/screens/home/home_screen.dart`

**Purpose:** Main menu / landing screen.

**Visible UI:**
- Logo image (`adinkra_tiles_homescreen_show-removebg-preview.png`)
- "A Ghanaian Mahjong Experience" subtitle — italic, muted
- AdinkraDivider
- Parchment panel containing 4 KenteButtons: PLAY, SETTINGS, HOW TO PLAY, TILE PREVIEW
- Version text "v1.0.0" at bottom

**PLAY behavior:**
- Reads `progressProvider.nextUnfinishedLevelId`
- If all levels completed → shows "All Levels Completed" snackbar
- Otherwise → `context.push('/game/$levelId')` with `GameLaunchConfig`

**State used:** `ConsumerWidget` — reads `progressProvider` for next level.

---

## Onboarding Screen

**File:** `lib/screens/onboarding/onboarding_screen.dart`

**Purpose:** First-launch tutorial and cultural introduction.

**4 pages:** Welcome (culture), How to Play (4 numbered steps), The Symbols (grid of 6 examples), Ready (closing message).

**State used:** `ConsumerStatefulWidget` — writes onboarding completion to `StorageService`.

---

## Game Screen

**File:** `lib/screens/game/game_screen.dart`

**Purpose:** Main gameplay screen.

**Visible UI:**
- **GameHeader** — Back button, Level/Score/Matches stats, progress bar, Settings gear, "TEST" badge in dev mode
- **Board area** — ParchmentBackground → BoardWidget (stacked tiles with dynamic sizing)
- **GameControlDock** — Hint, Shuffle, Pause/Resume circular buttons
- **Overlays**: Paused, Load Failed, Combo banner

**Key behaviors:**
- Always starts with `DifficultyMode.normal` (but no timer is active)
- Combo overlay on 2+ consecutive matches (1.8s duration)
- Haptic sequences for combos, win, and loss
- Board widget uses `BoardLayoutGeometry` for dynamic tile sizing
- Quit dialog pauses game, offers Stay/Leave

---

## Result Screen

**File:** `lib/screens/result/result_screen.dart`

**Purpose:** Post-game result display.

**Win:** Stars (scale animation), level name, score breakdown (pairs cleared, moves used, total), "NEXT GAME" button (or "All Levels Completed" at level 50).

**Lose:** Empty circle symbol, "No More Moves" title, Sankofa proverb, score/pairs counts, Home + Retry buttons.

**Developer test mode:** Shows BACK TO LEVEL TESTER / RETRY TEST LEVEL / NEXT TEST LEVEL buttons. Never saves progress.

**Star thresholds:** Computed dynamically from level complexity formula, not hardcoded.

---

## Settings Screen

**File:** `lib/screens/settings/settings_screen.dart`

**Sections:**
- **Audio:** Sound Effects toggle, Background Music toggle, Music Volume slider (0–100%, 10 divisions)
- **Haptic Feedback:** Off / Low / Medium / High selector
- **Gameplay:** Show Tile Names toggle with description
- **Legal:** Privacy Policy link (opens external browser via `url_launcher`)
- **Developer Tools** (debug-only): Level Tester link, Reset Real Player Progress

**No default difficulty selector.** Difficulty is always `normal`.

---

## Tile Preview Screen

**File:** `lib/screens/preview/tile_preview_screen.dart`

**Purpose:** Browse all ~90 Adinkra tile symbols with names and meanings.

Shows large preview image (or rendered TileWidget), name/meaning info panel, and horizontal scrollable thumbnail strip of all tiles.

**Note:** No longer has "OPEN FULL TILE SET LEVEL" button (removed).

---

## Developer Level Tester Screen

**File:** `lib/screens/developer/developer_level_tester_screen.dart`

**Purpose:** Developer tool for testing all 200 levels.

**Route:** `/developer/levels` (only available when `developerToolsEnabled` is true — debug mode or `ENABLE_DEVELOPER_TOOLS=true`).

Shows grid of 200 level cards with layout stats, validation status, board-fit checks, and difficulty category. Buttons: TEST NEXT UNFINISHED, TEST ALL SEQUENTIALLY, RESET TEST SESSION. Developer tests never save to real progress.

---

# Gameplay Loop

## Level Start

1. `GameNotifier.startLevel()` builds symbol deck from `SymbolCopyPlan`, generates board (reverse-solved for ≥40 tiles, random+check for <40), runs final solvability check.
2. If unsolvable → `GameStatus.loadFailed` with error message.
3. If solvable → `playing`, background music starts, no timer.

## Matching Logic

1. Player taps free tile → selected.
2. Same tile tapped → deselected.
3. Two tiles selected with same ID:
   - **Unsafe move** (would make board unsolvable AND safe alternative exists) → BLOCKED (mismatch feedback)
   - Otherwise → matched: +100 pts + streak bonus, particle burst, collision animation
4. Different IDs → mismatch animation, streak reset.

## Scoring

- Base match: +100 points
- Streak bonus: 3x→+50, 4x→+100, 5x+→+200
- Shuffle penalty: -50 points (clamped to 0)
- **No time bonus** (no timer)

## Hint System

Finds available matching pairs via `BoardSolver.findAvailableMatchingPairs()`. Prefers safe moves. Highlights pair with pulse animation for 2 seconds. Unlimited uses.

## Shuffle

Redistributes positions of unmatched tiles, preserves pyramid structure. Checks solvability (up to 80 attempts, 50,000 search nodes each). -50 score penalty.

## Win Condition

All tiles matched → `GameStatus.won` → win sound, music stops → result screen.

## Lose Condition

No available matching pairs → auto-shuffle attempt (no penalty) → if shuffle fails → `GameStatus.lost` → lose sound, music stops → result screen.

**No time-based loss.**

---

# Level System

200 levels across 20 chapters with dynamic star thresholds:

| Chapter | Levels | Difficulty Category | Symbol Types |
|---|---|---|---|
| First Symbols | 1–10 | Novice | 7–15 |
| Paths of Wisdom | 11–20 | Apprentice | 16–24 |
| Heritage | 21–30 | Strategic | 25–33 |
| Ancestral Trials | 31–40 | Advanced | 34–40 |
| Grand Archive | 41–50 | Master | 40–46 |
| Chapters 6–20 (Extended Campaign) | 51–200 | Expert to Mythic | Progressive |

Progression: Complete level N to unlock N+1. Tracked via `completed_N` boolean keys and `highest_completed_level` integer.

---

# State Management

- **`gameProvider`** — `StateNotifierProvider<GameNotifier, GameState>` — core gameplay
- **`settingsProvider`** — `StateNotifierProvider<SettingsNotifier, SettingsState>` — user preferences
- **`progressProvider`** — `Provider<ProgressService>` — level progress adapter
- **`storageServiceProvider`** — `Provider<StorageService>` (overridden at ProviderScope)
- **`audioServiceProvider`** — `Provider<AudioService>` — auto-syncs with settings

Game states: `idle | playing | paused | won | lost | loadFailed`

---

# Analytics & Crash Reporting

**Analytics events** (all in `analytics_service.dart`):
`play_pressed`, `next_game_pressed`, `level_retried`, `screen_view`, `level_started`, `level_completed`, `level_failed`, `hint_used`, `shuffle_used`, `pause_used`, `settings_opened`, `tile_preview_opened`, `onboarding_completed`, `reset_progress`

**Crashlytics:** Fatal Flutter/platform errors + non-fatal reports for storage failures, audio errors, and board generation failures.

No PII is logged. No advertising IDs.

---

# Assets

## Tile PNG Assets
`assets/Tile V2 png/`, `assets/Tile V2 png.2/`, `assets/Tile v.3 png/`, `assets/Tile v.4 png/`, `assets/Tile v.5 png/` — ~90+ tile PNGs.

## Background
`assets/background green option 2.png` — Dark green textured background.

## Home Screen Logo
`assets/adinkra_tiles_homescreen_show-removebg-preview.png`

## Audio (all in `assets/audio/`)
- `background_music.mp3` — Looping background music
- SFX (all `.ogg`): `tile_tap.ogg`, `match.ogg`, `no_match.ogg`, `win.ogg`, `lose.ogg`, `hint.ogg`, `shuffle.ogg`

## Empty Directories
`assets/lottie/`, `assets/images/` — contain only README files.

---

# Known Issues / Limitations

1. **No timer** — `secondsElapsed` always 0. No timed gameplay.
2. **No difficulty selection** — removed from both home and settings.
3. **No level select screen** — direct linear progression only.
4. **Default Flutter app icon** on Android.
5. **No adaptive icon** on Android.
6. **White Android splash screen** — should match dark theme.
7. **Debug release signing** — needs Play Store key configuration.
8. **In-game settings uses different color palette** than game screen.
9. **No Lottie animations** — directory empty.
10. **No custom screen transitions** between routes.
11. **No accessibility features** — no screen reader support, no colorblind mode.
12. **No tutorial mode** — onboarding explains rules but no interactive guided play.

---

# Play Store MVP Readiness

| Item | Status |
|---|---|
| Custom app icon | Missing |
| Adaptive icon | Missing |
| Release signing key | Debug only |
| Dark-themed splash screen | Missing (white default) |
| Privacy policy | Linked |
| Firebase Crashlytics | Integrated |
| Firebase Analytics | Integrated |
| 200 levels | Complete |
| Onboarding/tutorial | Complete |
| Settings | Complete |
| Monetization (ads/IAP) | Not started |
| Tablet/landscape support | Not implemented |

---

# Tests

| File | Tests |
|---|---|
| `test/widget_test.dart` | 1 placeholder test |
| `test/game_provider_startup_test.dart` | 7 tests — campaign structure, level startup speed, all-200 startup, reverse generation failure, progression, migration |
| `test/progression_flow_test.dart` | 4 tests — next level resolution, legacy migration, final level clamping, developer test isolation |
| `test/board_layout_geometry_test.dart` | Board layout geometry tests |
| `test/board_widget_ghost_tile_test.dart` | Ghost tile rendering tests |
| `test/game_header_layout_test.dart` | Game header layout tests |
| `test/result_screen_dispose_test.dart` | Result screen lifecycle tests |

All tests pass. `flutter analyze` returns no issues.

---

*Last updated: 2026-06-30 — 200 levels, Firebase integrated, no timer, linear progression.*
