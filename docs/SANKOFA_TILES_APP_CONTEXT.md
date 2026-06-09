# Sankofa Tiles — App Context Document

> Generated: 2026-06-06
> Purpose: Complete reference for Play Store MVP preparation
> Scope: Inspection and documentation only — no code changes

---

# App Identity

| Attribute | Value |
|---|---|
| App name | Sankofa Tiles |
| Package name / Application ID | `com.sankofatiles.sankofa_tiles` |
| Version name | `1.0.0` |
| Version code | `1` (from pubspec `1.0.0+1`) |
| Flutter SDK constraint | `>=3.0.0 <4.0.0` |
| Game type | Adinkra-inspired Mahjong solitaire / tile-matching puzzle game |
| Visual direction | Dark green/teal premium board-table style |
| Main theme | Ghanaian, Adinkra-inspired, calm, premium, casual puzzle |
| Current target | Play Store MVP publication |

## Checklist: What Exists vs. What Doesn't

| Item | Status | Notes |
|---|---|---|
| App name in AndroidManifest | `sankofa_tiles` (underscored) | Should be "Sankofa Tiles" for release |
| Application ID | `com.sankofatiles.sankofa_tiles` | Present |
| Version name / code | `1.0.0` / `1` | Present, driven by pubspec.yaml |
| App icon (Android) | Default Flutter icon | Default `ic_launcher.png` in all mipmap densities |
| Adaptive icon (Android) | Missing | No `ic_launcher.xml` or adaptive icon drawables |
| iOS app icon | Present | Full icon set in `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| macOS app icon | Present | Icon set in `macos/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Web favicon / icons | Present | `web/favicon.png`, `web/icons/Icon-192.png`, `Icon-512.png` |
| Splash screen (Android) | Default white | `launch_background.xml` is default white background |
| Splash screen (iOS) | Present | `LaunchImage` set in assets catalog |
| Portrait lock | Yes | `DeviceOrientation.portraitUp` in `main.dart` |
| Internet permission | None | No `<uses-permission>` tags in AndroidManifest |
| Audio permissions | None | None required — audioplayers uses game/music audio context |
| Notification permissions | None | Not used |
| Firebase / Crashlytics | Missing | Not set up |
| Firebase Analytics | Missing | Not set up |
| Release signing | Debug keys | `build.gradle.kts` line 37: `signingConfig = signingConfigs.getByName("debug")` |
| ProGuard / R8 rules | Default | No custom `proguard-rules.pro` |
| Privacy policy | Missing | Not linked or referenced |
| minSdk / targetSdk | Flutter defaults | `flutter.minSdkVersion` / `flutter.targetSdkVersion` |

---

# User Flow

1. **App launch** → `main.dart` initializes `StorageService` (SharedPreferences), locks portrait, sets status bar to transparent with light icons.
2. **Router check** → `GoRouter` evaluates initial location `/`:
   - If onboarding not complete → redirect to `/onboarding`
   - Otherwise → stay at `/` (HomeScreen)
3. **Home Screen** → User sees logo, subtitle, and four buttons in a parchment panel.
4. **Onboarding** (4-page PageView) → User can swipe or tap Next through pages, or Skip. On finish → `context.go('/')` (Home).
5. **Level Select** → Grid of 14 level cards. Locked levels show lock icon. Unlocked levels show stars. Tap unlocked level → difficulty bottom sheet.
6. **Difficulty Sheet** → Choose Easy / Normal / Relaxed → `context.push('/game/:levelId', extra: difficulty)`.
7. **Gameplay** → Board loads, tiles animate in, timer starts (normal mode only).
   - Match tiles → score, combo streaks
   - Hint → highlights a matching pair (2s glow)
   - Shuffle → rearranges remaining tiles (-50 score cost)
   - Pause → pause overlay with Resume / Quit
   - Settings (gear icon) → in-game settings bottom sheet
8. **Game End** → Auto-navigates to `/result`:
   - **Win** → Stars, score breakdown, Levels / Next buttons
   - **Lose** (no more moves or timer expired) → Score, Lose message, Levels / Retry buttons
9. **Result** → User can go to Level Select or Retry.
10. **Other flows**:
    - Settings (from Home) → Toggle sound, music, haptic, difficulty, show tile names, reset progress
    - Tile Preview (from Home) → Browse all 50+ Adinkra tile symbols
    - Back navigation → Uses `safeBack()` helper that calls `context.pop()` (GoRouter), or `context.go('/')` if can't pop

## Navigation Approach

- **Router**: `GoRouter` (`go_router: ^13.2.0`)
- **Route paths**:
  - `/` — HomeScreen
  - `/onboarding` — OnboardingScreen
  - `/level-select` — LevelSelectScreen
  - `/game/:levelId` — GameScreen (with `DifficultyMode` as extra)
  - `/result` — ResultScreen (with `GameState` as extra)
  - `/settings` — SettingsScreen
  - `/tile-preview` — TilePreviewScreen
- **Error page**: Scaffold with "Page not found" message on Sankofa background
- **Navigation methods**: Mostly `context.push()` for forward, `context.go()` for replacement/redirect, `safeBack()` helper for back
- **PopScope**: Level Select, Settings, Game, and Result all use `PopScope` with `canPop: false` and handle back via safeBack or custom dialogs

---

# Screens

## Home Screen

**File:** `lib/screens/home/home_screen.dart`

**Purpose:** Main menu / landing screen.

**Visible UI:**
- Sankofa circular symbol (◎) — gold, 48px
- "SANKOFA ⟳ TILES" title with gold text and drop shadow
- "A Ghanaian Mahjong Experience" subtitle — italic, muted
- AdinkraDivider (◎ symbol with gold lines)
- Parchment panel containing 4 KenteButtons
- Version text "v1.0.0" at bottom

**Button behavior:**
- PLAY → `context.push('/level-select')`
- SETTINGS → `context.push('/settings')`
- HOW TO PLAY → `context.push('/onboarding')`
- TILE PREVIEW → `context.push('/tile-preview')`

**State used:** None (StatelessWidget). Theme colors from `SankofaGameTheme`.

**Notes:** Uses `SankofaBackground` for the textured green background. All content is scrollable via `SingleChildScrollView`.

---

## Onboarding Screen

**File:** `lib/screens/onboarding/onboarding_screen.dart`

**Purpose:** First-launch tutorial and cultural introduction.

**Visible UI:**
- Skip button (top-right)
- PageView with 4 pages, dot indicators
- Page 1: Welcome to Sankofa Tiles — cultural explanation
- Page 2: How to Play — 4 numbered steps, hint/shuffle note
- Page 3: The Symbols — grid of 6 example tiles with names/meanings
- Page 4: Ready? — Gye Nyame closing message
- Next / Start Playing button at bottom

**Button behavior:**
- Skip → Calls `_finish()` — sets onboarding complete flag, `context.go('/')`
- Next → Advances PageView to next page
- Start Playing (page 4) → Calls `_finish()`

**State used:** `ConsumerStatefulWidget` — reads `storageServiceProvider` to persist onboarding completion.

**Notes:** Uses parchment panel styling. Each page is wrapped in `_OnboardingPage` shared layout widget.

---

## Level Select Screen

**File:** `lib/screens/level_select/level_select_screen.dart`

**Purpose:** Grid showing all available levels with lock/unlock state and star ratings.

**Visible UI:**
- AppBar with "Choose Your Level" title, back button
- 2-column grid of level cards
- Each card: badge number (top-left), lock icon or stars (top-right), level name, pair count × grid size
- Tapping a card opens a difficulty selection bottom sheet

**Button behavior:**
- Back → `safeBack(context)` (returns to Home)
- Level card (unlocked) → Opens `_DifficultySheet` bottom sheet
- Level card (locked) → No action
- Difficulty sheet "BEGIN" → `Navigator.pop(context)` then `context.push('/game/:levelId', extra: difficulty)`

**State used:**
- `progressProvider` — determines unlock state and stars per level
- `settingsProvider` — reads `defaultDifficulty`

**Notes:** 14 hardcoded levels. Unlock requires stars > 0 on previous level. Difficulty modes: Easy (unlimited hints, no timer), Normal (3 hints, 5-min timer), Relaxed (no timer, unlimited hints).

---

## Game Screen

**File:** `lib/screens/game/game_screen.dart`

**Purpose:** Main gameplay screen. The largest and most complex screen.

**Visible UI:**
- **GameHeader** — Back button, "LEVEL N" title with ornament lines, Settings gear icon
- **GameStatsPanel** — Score (star icon) and Timer display in parchment panel
- **Board area** — ParchmentBackground → GameBoardBackdrop (dark green board with Adinkra motif, gold border) → BoardWidget (stacked tiles with layer staggering)
- **GameControlDock** — Hint, Shuffle, Pause/Resume buttons in parchment strip
- **Overlays**: Paused overlay, Load Failed overlay, Combo banner (+50/+100/+200 bonus)

**Button behavior:**
- Back → `_confirmQuit()` — pauses game, shows quit dialog (Stay / Leave)
- Settings (gear) → `_openGameSettings()` — bottom sheet with sound, music, volume, show tile names, haptic controls
- Hint → `gameProvider.notifier.useHint()` — highlights a matching pair (2s glow)
- Shuffle → `gameProvider.notifier.shuffleRemaining()` — rearranges tiles, -50 score
- Pause → `gameProvider.notifier.pauseGame()` — shows paused overlay
- Resume → `gameProvider.notifier.resumeGame()`
- Tile tap → `gameProvider.notifier.selectTile(uid)` — Mahjong selection/match logic

**State used:** `gameProvider` (StateNotifierProvider<GameNotifier, GameState>) — the core gameplay state.

**Status overlays:**
- **Paused** (`GameStatus.paused`) — "PAUSED" text, Resume button, Quit to Menu text button
- **Load Failed** (`GameStatus.loadFailed`) — "BOARD UNAVAILABLE", error message, Try Again / Back to Levels buttons
- **Playing** — Normal tile-matching board

**Notes:** Combo system tracks fast consecutive matches. Haptic feedback on match, mismatch, combo, win, and loss. Background music starts on level start, stops on leave/win/lose.

---

## Result Screen

**File:** `lib/screens/result/result_screen.dart`

**Purpose:** Post-game result display — win celebration or lose encouragement.

**Visible UI (Win):**
- Star burst symbol (✦) with scale animation
- "Level Complete!" title
- Level name
- 3 stars (animated scale, filled or outlined based on score thresholds)
- Score breakdown: Matches (moves × 100), Time Bonus (if normal mode: (300 - seconds) × 2), TOTAL
- LEVELS button (back to level select)
- NEXT button (also goes to level select currently — same as LEVELS)

**Visible UI (Lose):**
- Empty circle symbol (◌)
- "No More Moves" title
- Sankofa proverb quote: "Se wo were firi na wosan kofa a, yenkyiri" / "Go back and try again!"
- Score reached and Pairs matched counts
- LEVELS button
- RETRY button (restarts same level with same difficulty)

**Button behavior:**
- LEVELS → `context.go('/level-select')`
- NEXT → `context.go('/level-select')` (note: currently same as LEVELS, not "next level") if levelId < 14
- RETRY → `context.go('/game/:levelId', extra: difficulty)`

**State used:** Receives `GameState` as route extra. Saves result via `progressProvider.saveLevelResult()`.

**Notes:** Stars computed from level's `starThresholds` via `computeStars()` helper. Win animations use `AnimationController` with `Curves.elasticOut`.

---

## Settings Screen

**File:** `lib/screens/settings/settings_screen.dart`

**Purpose:** App-wide settings configuration.

**Visible UI:**
- AppBar with "Settings" title, back button
- SankofaBackground body with ListView
- Sections: Audio, Gameplay, Data (each with section header)
- Sound Effects toggle (SwitchListTile)
- Background Music toggle (SwitchListTile)
- Music Volume slider (0–100%, 10 divisions)
- Haptic Feedback selector (Off / Low / Medium / High) — segmented button style
- Show Tile Names toggle
- Default Difficulty selector (Easy / Normal / Relaxed) — segmented button style
- Reset All Progress — red text, opens confirmation dialog

**Button behavior:**
- Back → `safeBack(context)`
- All toggles/selectors → Call corresponding `settingsProvider.notifier` method
- Reset All Progress → Opens confirmation AlertDialog → Calls `notifier.resetProgress()` → shows SnackBar

**State used:** `settingsProvider` (StateNotifierProvider<SettingsNotifier, SettingsState>).

**Notes:** Persisted via `SharedPreferences` through `StorageService`.

---

## Tile Preview Screen

**File:** `lib/screens/preview/tile_preview_screen.dart`

**Purpose:** Browse all Adinkra tile symbols with their names and meanings.

**Visible UI:**
- AppBar with "Tile Preview" title, back button
- Large display area showing selected tile (PNG image or rendered TileWidget)
- Info panel: tile name (gold), meaning (light), "PNG asset" label if applicable
- Horizontal scrollable strip of all tiles (thumbnails)
- Gold border highlights the selected tile
- "OPEN FULL TILE SET LEVEL" button at bottom

**Button behavior:**
- Back → `safeBack(context)`
- Tap tile in strip → Selects that tile, updates main display
- OPEN FULL TILE SET LEVEL → `context.push('/game/6', extra: DifficultyMode.relaxed)` — launches level 6 (Complete Set) in relaxed mode

**State used:** `ConsumerStatefulWidget` with local `_selectedIndex` state. Defaults to Gye Nyame tile.

**Notes:** 50+ tiles from `kAllTiles`. Shows PNG image for tiles with `assetPath`, or rendered `TileWidget` for others.

---

## Error Page (GoRouter)

**File:** `lib/core/router/app_router.dart` (lines 68-80)

**Purpose:** Catch-all for unknown routes.

**Visible UI:** Scaffold with Sankofa background, centered "Page not found: {error}" text in parchment light color.

---

# Gameplay Loop

## Level Start

1. `GameScreen.initState()` calls `gameProvider.notifier.startLevel(levelId, difficulty)` via `addPostFrameCallback`.
2. `GameNotifier.startLevel()`:
   - Looks up `LevelDefinition` by ID
   - Builds tile definition list from `tileIds`, cycling through available definitions to reach required pair count
   - **Board generation strategy** (two approaches):
     - **Tiles ≥ 40** (reverse-solved threshold): Uses `_buildReverseSolvedBoard()` — starts with empty removal order, greedily removes free tile pairs in random order to build a valid removal sequence, then assigns tile definitions in reverse. Up to 100 attempts.
     - **Tiles < 40** (random + solvability check): Generates random boards via `_buildRandomBoard()`, checks solvability with `BoardSolver.profileSolvability()` (max 6,000 search nodes). Up to 12 attempts. Falls back to reverse-solved if all random attempts fail.
   - Final solvability check (50,000 node budget) on generated board
   - If unsolvable → `GameStatus.loadFailed` with error message
   - If solvable → Sets state to `playing`, starts timer if normal mode, starts background music
3. Tiles animate in with staggered fade-in + slide-up animation (each tile 25ms delay).

## Matching Logic

1. Player taps a tile → `selectTile(uid)` called.
2. **Tile must be free** (Mahjong rule): not covered by tiles in higher layers, and at least one side (left or right) is open.
3. If no tile selected → Tile is selected (highlighted, lifts up 10px).
4. If same tile tapped → Deselects.
5. If two tiles selected:
   - **Same `def.id` (matching pair)**:
     - If the move is unsafe (would make remaining board unsolvable) AND there exists at least one safe matching move elsewhere → BLOCK the move (haptic + mismatch animation, streak reset, `Future.delayed` clear)
     - Otherwise → **Match!** — Both tiles marked matched with smash animation (scale → shake → shatter out), score +100 plus streak bonus (3x→+50, 4x→+100, 5x+→+200), streak incremented
     - Check win, check stuck
   - **Different `def.id` (no match)**: Both tiles show mismatch animation (shake), streak reset to 0, `Future.delayed` clears after 600ms. Check stuck.

## Unblocked Matching Guard

The game blocks moves that would make the remaining board unsolvable — BUT only when a safer alternative move exists. If there's no safe alternative, the move is allowed (to prevent softlocks).

## Scoring

- Base match: **+100 points**
- Streak bonus: 3 consecutive fast matches → +50, 4 → +100, 5+ → +200
- Time bonus (normal mode only): `(300 - secondsElapsed) * 2` points
- Shuffle penalty: **-50 points** (clamped to 0 minimum)

## Timer

- Only active in **Normal** difficulty mode
- 5-minute limit (300 seconds)
- At 300s → GameStatus.lost, timer stops, music stops, lose sound plays
- Timer warning: time display turns red at 240s (4 minutes)

## Hint System

1. `useHint()` finds all available matching pairs via `BoardSolver.findAvailableMatchingPairs()`.
2. Prefers a safe move (solvable after removal). Falls back to first available pair if no safe move found.
3. Hinted tiles glow with antique-gold pulsing border for 2 seconds.
4. No hint limit enforced in code for easy/relaxed modes. Normal mode has unlimited hints in the current code (despite the UI description saying "3 hints").

## Shuffle

1. `shuffleRemaining()` takes all unmatched tiles, shuffles their (row, col, layer) positions to preserve the pyramid structure.
2. Checks solvability of candidate shuffle (up to 80 attempts, 50,000 search nodes each).
3. If solvable → Applies shuffle, -50 score penalty
4. If unsolvable after 80 attempts → No-op (board unchanged)

## Win Condition

- All tiles matched → `_checkWin()` triggers
- Time bonus added (normal mode)
- Status → `GameStatus.won`
- Win sound plays, background music stops
- Haptic celebration sequence fires
- GameScreen listener detects status change → navigates to `/result`

## Lose Conditions

1. **No more moves** (`isStuck`): Remaining unmatched tiles > 0 AND `BoardSolver.hasAvailableMove()` returns false → `GameStatus.lost`
2. **Timer expired** (normal mode): secondsElapsed ≥ 300 → `GameStatus.lost`
3. Lose sound plays, music stops, haptic "sombre" sequence fires
4. Board shows red overlay + shake animation

## Pause / Resume

- **Pause**: `pauseGame()` cancels timer, sets status to `paused`
- **Resume**: `resumeGame()` sets status to `playing`, restarts timer if normal mode

## Load Failure

If board generation fails entirely (all strategies exhausted or exception thrown):
- Status → `GameStatus.loadFailed`
- Error message displayed
- Retry / Back to Levels buttons

## Leave / Quit

- Exit dialog: "Leave Game? Your progress will be lost." → Stay / Leave
- Leave calls `leaveGame()`: cancels timer, stops audio, resets state to initial
- Audio also stopped in `dispose()` as safety net

---

# Buttons and Interactions Map

| Screen | Button/Action | File/Widget | Current Behavior | Destination/Effect |
|---|---|---|---|---|
| Home | PLAY | `KenteButton` | Pushes to level select | `/level-select` |
| Home | SETTINGS | `KenteButton` | Pushes to settings | `/settings` |
| Home | HOW TO PLAY | `KenteButton` | Pushes to onboarding | `/onboarding` |
| Home | TILE PREVIEW | `KenteButton` | Pushes to tile preview | `/tile-preview` |
| Onboarding | Skip | `TextButton` | Marks onboarding complete, goes home | `/` |
| Onboarding | NEXT | `KenteButton` | Advances PageView | Stays on onboarding |
| Onboarding | START PLAYING | `KenteButton` | Marks complete, goes home | `/` |
| Level Select | Back | `IconButton` (AppBar) | safeBack() → pop or go home | Home |
| Level Select | Level card (unlocked) | `_LevelCard` → `GestureDetector` | Opens difficulty bottom sheet | Difficulty sheet |
| Level Select | Level card (locked) | `_LevelCard` | No action | — |
| Difficulty Sheet | BEGIN | `KenteButton` | Pop sheet, push game | `/game/:levelId` |
| Game | Back | `GameHeader` → `_HeaderIconButton` | Pause + quit confirmation dialog | Level Select or Resume |
| Game | Settings (gear) | `GameHeader` → `_HeaderIconButton` | Open in-game settings bottom sheet | Settings sheet |
| Game | Hint | `GameControlDock` → `_DockButton` | `useHint()` — highlights matching pair | Stays on gameplay |
| Game | Shuffle | `GameControlDock` → `_DockButton` | `shuffleRemaining()` — rearranges, -50 score | Stays on gameplay |
| Game | Pause | `GameControlDock` → `_DockButton` | `pauseGame()` — pauses, shows overlay | Pause overlay |
| Game | Resume (in pause) | `_PausedOverlay` → `ElevatedButton` | `resumeGame()` | Back to gameplay |
| Game | Quit to Menu (in pause) | `_PausedOverlay` → `TextButton` | `leaveGame()`, goes to level select | `/level-select` |
| Game | Tile tap (free tile) | `TileWidget` → `GestureDetector` | `selectTile(uid)` — select/match logic | Board state update |
| Game | Try Again (load failed) | `_LoadFailedOverlay` → `ElevatedButton` | Retries `startLevel()` | Same level |
| Game | Back to Levels (load failed) | `_LoadFailedOverlay` → `TextButton` | `_returnToLevelSelect()` | `/level-select` |
| In-Game Settings | Sound Effects toggle | `_SheetSwitchTile` | `setSoundEnabled(bool)` | Settings sheet |
| In-Game Settings | Background Music toggle | `_SheetSwitchTile` | `setMusicEnabled(bool)` | Settings sheet |
| In-Game Settings | Music Volume slider | `_SheetVolumeTile` | `setMusicVolume(double)` | Settings sheet |
| In-Game Settings | Show Tile Names toggle | `_SheetSwitchTile` | `setShowTileNames(bool)` | Settings sheet |
| In-Game Settings | Haptic selector | `_SheetHapticTile` | `setHapticIntensity(HapticIntensity)` | Settings sheet |
| Result (Win) | LEVELS | `KenteButton` | Goes to level select | `/level-select` |
| Result (Win) | NEXT | `KenteButton` | Goes to level select (if not last level) | `/level-select` |
| Result (Lose) | LEVELS | `KenteButton` | Goes to level select | `/level-select` |
| Result (Lose) | RETRY | `KenteButton` | Restarts same level with same difficulty | `/game/:levelId` |
| Settings | Back | `IconButton` (AppBar) | safeBack() | Previous screen |
| Settings | Sound Effects toggle | `_ToggleTile` | `setSoundEnabled(bool)` | Settings |
| Settings | Background Music toggle | `_ToggleTile` | `setMusicEnabled(bool)` | Settings |
| Settings | Music Volume slider | `_MusicVolumeTile` | `setMusicVolume(double)` | Settings |
| Settings | Haptic selector | `_HapticTile` | `setHapticIntensity(HapticIntensity)` | Settings |
| Settings | Show Tile Names toggle | `_ToggleTile` | `setShowTileNames(bool)` | Settings |
| Settings | Default Difficulty selector | `_DifficultyTile` | `setDefaultDifficulty(DifficultyMode)` | Settings |
| Settings | Reset All Progress | `_ResetTile` | Opens confirmation dialog → reset | Settings |
| Tile Preview | Back | `IconButton` (AppBar) | safeBack() | Previous screen |
| Tile Preview | Tile thumbnail tap | `GestureDetector` | Selects tile for detail view | Tile Preview |
| Tile Preview | OPEN FULL TILE SET LEVEL | `KenteButton` | Pushes game level 6 in relaxed mode | `/game/6` (relaxed) |

---

# State Management

## Approach

**Riverpod** (`flutter_riverpod: ^2.5.1`) with `StateNotifierProvider` for mutable state and `Provider` for read-only services.

## Main Providers

### `gameProvider` — `StateNotifierProvider<GameNotifier, GameState>`
**File:** `lib/providers/game_provider.dart`

The core gameplay state machine. Manages:
- `GameState` — tiles, status, score, moves, hintsUsed, secondsElapsed, selected tile, currentStreak, pendingScorePops
- `GameNotifier` — startLevel, selectTile, useHint, shuffleRemaining, pauseGame, resumeGame, leaveGame, tick
- Board generation with solvability guarantees
- Timer management

### `settingsProvider` — `StateNotifierProvider<SettingsNotifier, SettingsState>`
**File:** `lib/providers/settings_provider.dart`

App-wide settings persisted via `StorageService`:
- `SettingsState` — soundEnabled, musicEnabled, musicVolume, defaultDifficulty, showTileNames, hapticIntensity
- Each setter persists to SharedPreferences and updates state

### `progressProvider` — `Provider<ProgressService>`
**File:** `lib/providers/progress_provider.dart`

Read-only view of level progress:
- `isLevelUnlocked(levelId)` — level 1 always unlocked, rest require stars on previous level
- `getStars(levelId)`, `getLevelResult(levelId)`, `saveLevelResult(levelId, score, stars)`

### `storageServiceProvider` — `Provider<StorageService>`
**File:** `lib/providers/settings_provider.dart` (line 6-9)

Throws UnimplementedError — must be overridden in `ProviderScope`. The actual instance is created in `main.dart`.

### `audioServiceProvider` — `Provider<AudioService>`
**File:** `lib/providers/game_provider.dart` (line 15-38)

Creates and manages the `AudioService` singleton. Listens to settings changes to sync sound/music/volume.

## Game State Enum

```dart
enum GameStatus { idle, playing, paused, won, lost, loadFailed }
enum DifficultyMode { easy, normal, relaxed }
enum HapticIntensity { off, low, medium, high }
```

## Local Persistence

**SharedPreferences** via `StorageService` (`lib/core/utils/storage_service.dart`):
- `best_score_{levelId}` — best score per level
- `stars_{levelId}` — star count per level
- `default_difficulty` — preferred difficulty mode
- `sound_enabled`, `music_enabled`, `music_volume` — audio prefs
- `onboarding_complete` — first-launch flag
- `show_tile_names` — tile name display toggle
- `haptic_intensity` — haptic feedback level
- Unlock logic: Level N is unlocked if `stars_{N-1} > 0`

---

# Level System

**File:** `lib/core/constants/level_data.dart`

## Overview

14 hardcoded levels, each with:
- `id`, `name`, `boardRows`, `boardCols`, `tileCount`
- `tileIds` — which Adinkra symbols are used (from `kTileIds` list)
- `unlockRequirement` — sequential (level ID - 1)
- `starThresholds` — 3-tier score thresholds for 1/2/3 stars
- `layout` — `TilePosition` list defining (row, col, layer) for each tile slot

## Layout System

**File:** `lib/core/constants/layout_data.dart`

Uses `_mahjongLayout()` to generate multi-layer pyramid/turtle layouts from row-count specifications. Each tile spans 2 row units × 2 column units, with odd offsets for Mahjong-style staggering. Layouts range from 2-layer beginner pyramids to 4-5 layer complex shapes.

## Level Table

| # | Name | Grid | Tiles | Pairs | Layout |
|---|---|---|---|---|---|
| 1 | First Look | 4×6 | 28 | 14 | level4Layout — 3-tier diamond |
| 2 | New Roots | 5×6 | 36 | 18 | level5Layout — wide stepped pyramid |
| 3 | Council | 5×7 | 44 | 22 | level7Layout — broad council diamond |
| 4 | Heritage | 5×7 | 52 | 26 | level9Layout — elongated diamond |
| 5 | Legacy | 5×8 | 60 | 30 | level11Layout — long turtle with spine |
| 6 | Complete Set | 6×7 | 68 | 34 | level13Layout — shrine diamond |
| 7 | New Symbols | 6×8 | 72 | 36 | level14Layout — elder turtle |
| 8 | Gathering | 6×8 | 76 | 38 | level15Layout — oracle pyramid |
| 9 | Deep Roots | 6×8 | 80 | 40 | level16Layout — throne turtle |
| 10 | Living Archive | 6×9 | 84 | 42 | level17Layout — genesis diamond |
| 11 | Ancestral Map | 7×9 | 88 | 44 | level18Layout — cosmos tower (5 layers) |
| 12 | Many Voices | 7×9 | 92 | 46 | level19Layout — triumph turtle |
| 13 | Long Memory | 7×10 | 96 | 48 | level20Layout — eternal pyramid |
| 14 | Full Archive | 7×10 | 102 | 51 | level21Layout — full symbol archive |

## Progression

- Level 1 always unlocked
- Level N requires at least 1 star on level N-1
- Stars: 1 star = score ≥ threshold[0], 2 = score ≥ threshold[1], 3 = score ≥ threshold[2]
- Thresholds scale from [700, 1100, 1400] (level 1) to [3600, 5600, 7000] (level 14)

---

# Assets

## Tile PNG Assets

| Directory | Count | Description |
|---|---|---|
| `assets/Tile V2 png/` | ~20 | Tile V2 PNG set (individual Adinkra symbols) |
| `assets/Tile V2 png.2/` | ~20 | Additional Tile V2 PNGs |
| `assets/Tile v.3 png/` | ~12 | Tile V3 PNGs |

All tile PNGs use `-removebg-preview.png` suffix (transparent backgrounds).

## Background

| File | Description |
|---|---|
| `assets/background green option 2.png` | Dark green textured background image |

## Audio

| File | Format | Size | Purpose |
|---|---|---|---|
| `background_music.mp3` | MP3 | 362 KB | Looping background music |
| `tile_tap.ogg` | OGG | 5.0 KB | Tile selection SFX |
| `match.ogg` | OGG | 4.6 KB | Successful match SFX |
| `no_match.ogg` | OGG | 4.6 KB | Failed match SFX |
| `win.ogg` | OGG | 8.2 KB | Level win SFX |
| `lose.ogg` | OGG | 4.6 KB | Level lose SFX |
| `hint.ogg` | OGG | 6.1 KB | Hint activation SFX |
| `shuffle.ogg` | OGG | 5.8 KB | Shuffle SFX |

## Other Assets

| Directory | Contents |
|---|---|
| `assets/tiles/` | `tile_back.svg` (SVG tile back design) |
| `assets/lottie/` | Empty (README only) — Lottie animations not used |
| `assets/images/` | Empty (README only) |

## Fonts

No bundled font files. Fonts are loaded via `google_fonts` package:
- **Cinzel** — Display/heading text (title, buttons)
- **Nunito** — Body text

## pubspec.yaml Asset Registration

All asset directories are registered:
```yaml
assets:
  - assets/tiles/
  - assets/Tile V2 png/
  - assets/Tile V2 png.2/
  - assets/Tile v.3 png/
  - assets/audio/
  - assets/lottie/
  - assets/images/
  - assets/background green option 2.png
```

---

# Visual Theme

## Overview

The app has two theming layers:

1. **`AppTheme`** (`lib/core/theme/app_theme.dart`) — Google Fonts-based Material 3 dark theme using navy/gold color scheme. Used as the base `MaterialApp` theme.
2. **`SankofaGameTheme`** (`lib/core/theme/sankofa_game_theme.dart`) — The actual visual theme used across all screens. Dark green/teal color palette with parchment accents, antique gold borders, and textured backgrounds.

## Color Palette (`SankofaGameTheme`)

| Token | Hex | Usage |
|---|---|---|
| `backgroundTop` | `#101A16` | Screen background top |
| `backgroundMiddle` | `#13241E` | Screen gradient middle |
| `backgroundBottom` | `#17241F` | Screen gradient bottom |
| `boardSurface` | `#203329` | Board/panel surface |
| `boardSurfaceAlt` | `#263A30` | Panel gradient top |
| `boardEdge` | `#17271F` | Panel gradient bottom |
| `parchment` | `#F1E6CF` | Light parchment |
| `parchmentLight` | `#F8F0DE` | Bright parchment |
| `parchmentDark` | `#E2D2AD` | Dark parchment |
| `appParchment` | `#EDE0C4` | UI panel parchment |
| `appParchmentLight` | `#F1E6CF` | UI panel parchment light |
| `appParchmentDark` | `#E8D8B7` | UI panel parchment dark |
| `antiqueGold` | `#B88A3A` | Gold accents, borders |
| `mutedGold` | `#8B6A35` | Subdued gold text |
| `darkText` | `#2B2418` | Text on parchment |
| `mutedText` | `#74664E` | Muted text |
| `lightText` | `#F1E6CF` | Light text |
| `mutedLightText` | `#CBBFA8` | Muted light text |

## Background System

- `SankofaBackground` widget — Gradient overlay (3-color dark green) + `background green option 2.png` texture + radial vignette
- `ParchmentBackground` widget — Similar gradient + texture + custom-painted parchment edges with corner motifs
- `GameBoardBackdrop` widget — Dark board surface with gradient, Adinkra circular motif, gold border rings, texture dots

## Key Decorations

- `parchmentPanelDecoration` — Parchment gradient + rounded corners + gold border + drop shadow
- `appParchmentPanelDecoration` — Lighter parchment variant
- `darkPanelDecoration()` — Dark green panel with gold border, optional emphasis/disabled states
- `levelCardDecoration(unlocked:)` — Green gradient card, gold border when unlocked, dimmed when locked

## Component Themes

- **Buttons**: `KenteButton` — Parchment-colored ElevatedButton with antique gold border, Cinzel font
- **Dividers**: `AdinkraDivider` — Gold line with ◎ symbol center
- **Tiles**: `TileWidget` — Cream tile face with dark gold 3D edge, Georgia font for suit codes. PNG-backed for all tiles.
- **Stats**: Parchment panel with score (star icon) and timer

## Screens Using Shared Theme

All screens use `SankofaGameTheme` and either `SankofaBackground` or `ParchmentBackground`:
- Home Screen ✓
- Onboarding Screen ✓
- Level Select Screen ✓
- Game Screen ✓
- Result Screen ✓
- Settings Screen ✓
- Tile Preview Screen ✓

## Ancient vs. Legacy Colors

There's a secondary color set in `AppColors` (`lib/core/theme/app_colors.dart`) using navy/gold ("living archive" palette). Some game widgets still reference `AppColors` directly:
- `GameScreen` in-game settings sheet uses `AppColors` archive palette
- `_PausedOverlay`, `_LoadFailedOverlay`, `_ComboOverlay`, `_QuitDialog` use `AppColors` archive palette
- `GameHud` (not used in current game screen — `GameStatsPanel` is used instead) references `AppColors`
- `TileWidget` uses some `AppColors` for tile faces

This creates a slight visual inconsistency between the game board (SankofaGameTheme greens) and overlays (AppColors archive parchment tones).

---

# Play Store MVP Readiness

| Item | Status | Notes |
|---|---|---|
| Release app name | "sankofa_tiles" | Should be "Sankofa Tiles" — currently underscore-separated in AndroidManifest `android:label` |
| Package / Application ID | `com.sankofatiles.sankofa_tiles` | Present and unique |
| versionName / versionCode | `1.0.0` / `1` | Driven by pubspec.yaml |
| App icon (Android) | Default Flutter | `ic_launcher.png` is the default Flutter icon in all densities |
| Adaptive icon (Android) | Missing | No adaptive icon XML or drawables |
| Splash screen (Android) | Default white | `launch_background.xml` shows plain white |
| Signed release build | Debug signing | `build.gradle.kts` uses debug signing for release |
| Internet permission | Not declared | Not needed for current functionality |
| Privacy policy | Missing | No link or reference in the app |
| Firebase / Crashlytics | Missing | Not integrated |
| Firebase Analytics | Missing | Not integrated |
| ProGuard / R8 | Default only | No custom rules file |
| minSdk / targetSdk | Flutter defaults | `flutter.minSdkVersion` / `flutter.targetSdkVersion` |
| Orientation lock | Portrait only | Set in `main.dart` |
| Audio permissions | Not needed | audioplayers uses game/media audio context |
| Google Mobile Ads | Not present | No AdMob or ad SDK |
| In-app purchases | Not present | No IAP integration |
| Onboarding / tutorial | Present | 4-page onboarding flow |
| App size | Unknown | Needs APK build to measure |

---

# Tests and Quality

## Test Files

| File | Tests | Coverage |
|---|---|---|
| `test/widget_test.dart` | 1 test | Placeholder: `1 + 1 == 2` |
| `test/game_provider_startup_test.dart` | 3 tests | Level startup speed, reverse generation failure, full tile set progression |

## Test Results (2026-06-06)

```
flutter analyze  →  No issues found! (2.4s)
dart format lib/ →  Formatted 42 files (0 changed)
flutter test     →  00:00 +4: All tests passed!
```

### Test: "representative levels start quickly with solvable boards"
Tests levels 1, 3, 6, 14 in relaxed mode. Asserts: status is playing, correct tile count, board is solvable, startup < 1 second. All passed.

### Test: "reverse generation exhaustion fails safely without a board"
Tests level 6 with `reverseSolvedAttempts: 0`. Asserts: status is loadFailed, tiles empty, error message present. Passed.

### Test: "main progression reaches the full 51 pair tile set"
Tests level 1 and level 14. Asserts: status is playing, correct tile count, board solvable. Verifies level 14 has 102 tiles / 51 pairs. Passed.

## Tool: Board Generation Benchmark

`tool/board_generation_benchmark.dart` — Benchmarks board generation for levels 1, 5, 6, 10, 12, 14. Not run as part of test suite.

---

# Known Issues / Risks

## Before Play Store

1. **No custom app icon** — Default Flutter icon is used on Android. Must be replaced before Play Store listing.
2. **No adaptive icon** — Required for modern Android. Missing `ic_launcher.xml` and foreground/background layers.
3. **Debug release signing** — Release builds signed with debug keys. Must configure Play Store signing key.
4. **No Crashlytics** — No crash reporting. Any crashes in production will be invisible.
5. **No Analytics** — No user behavior tracking. Won't know how players interact with the game.
6. **No privacy policy** — Required for Play Store. Must link to a valid privacy policy URL.
7. **App label is "sankofa_tiles"** — AndroidManifest `android:label` uses the package name, not "Sankofa Tiles".
8. **White splash screen** — Default launch background. Should match the app's dark theme.
9. **No real-device testing** — All testing appears to be on simulator/emulator only.

## Functional / UX

10. **Result screen "NEXT" button always goes to Level Select** — Both LEVELS and NEXT buttons navigate to `/level-select`. NEXT should go to the next level.
11. **No level restart from pause menu** — Pause overlay only has Resume and Quit. No Retry/Restart option.
12. **Hint count not enforced** — UI says "3 hints" for normal mode but code has no per-game hint limit.
13. **Empty Lottie/images asset directories** — Registered in pubspec but contain only README files. No animations or image assets used.
14. **In-game settings uses different color palette** — The settings bottom sheet uses `AppColors` archive palette (warm parchment), while the rest of the game screen uses `SankofaGameTheme` dark greens.
15. **No sound effect for tile mismatch block** — When a move is blocked for being unsafe, the mismatch sound plays but there's no distinct "unsafe move" SFX.
16. **Background music loops continuously** — No pause between loops, no crossfade.
17. **No tutorial mode / first-level guided play** — Onboarding explains rules but there's no interactive tutorial.

## Platform / Technical

18. **iOS app icon present but may need updating** — iOS icon set exists but appears to be default Flutter icon.
19. **No tablet/landscape layout** — Portrait-locked, no adaptive layout for tablets.
20. **No accessibility features** — No screen reader support, no colorblind mode.
21. **Flutter SVG for tile backs but not used** — `tile_back.svg` exists, `TileBackWidget` uses `flutter_svg`, but currently tiles use PNG assets.
22. **No ProGuard/R8 custom rules** — Default only, may need rules for release optimization.

---

# Recommended Next Steps

## Must do before Play Store closed testing / production

1. **Replace default app icon** — Create custom Sankofa Tiles icon for all mipmap densities
2. **Add adaptive icon** — Create `ic_launcher.xml` with foreground/background drawables
3. **Set Play Store signing key** — Generate upload key, configure `build.gradle.kts` release signing
4. **Fix app label** — Change `android:label` to "Sankofa Tiles"
5. **Add Firebase Crashlytics** — Crash reporting for production
6. **Add Firebase Analytics** — Basic event tracking (level starts, completes, settings changes)
7. **Prepare privacy policy** — Host a privacy policy page, link in app
8. **Test on real Android device** — At minimum, test on one physical device
9. **Build and test release APK** — `flutter build apk --release` or `flutter build appbundle --release`
10. **Customize splash screen** — Replace white launch background with dark-themed splash matching the app

## Should do soon

11. **Fix NEXT button on result screen** — Navigate to next level instead of level select
12. **Add Retry button to pause overlay** — So players can restart without quitting to menu
13. **Enforce hint limits per difficulty** — Or update UI descriptions to match actual behavior
14. **Unify color palettes** — Replace `AppColors` references in game overlays with `SankofaGameTheme` equivalents
15. **Add interactive first-level tutorial** — Guided play with overlay instructions
16. **Add sound effect for unsafe move block** — Distinct SFX for blocked moves
17. **Prepare Play Store listing assets** — Screenshots (phone + tablet), feature graphic, short description, full description

## Can wait for MVP2

18. **Tablet / landscape support** — Adaptive layouts for larger screens
19. **Accessibility improvements** — Semantic labels, colorblind mode
20. **Lottie animations** — Add celebration/transition animations
21. **Daily challenges / more levels** — Content expansion
22. **Leaderboards** — Google Play Games integration
23. **Achievements** — Google Play Games achievements
24. **In-app purchases** — Hint packs, theme unlocks, etc.
25. **AdMob integration** — Ads for monetization
26. **Multi-language support** — Localization for Twi, French, etc.
27. **Cloud save** — Cross-device progress sync

---

# Agent Summary

## Files Inspected

All source files in the project were read:

- `lib/main.dart`, `lib/app.dart`
- `lib/core/router/app_router.dart`, `navigation_helpers.dart`
- `lib/screens/home/home_screen.dart`
- `lib/screens/onboarding/onboarding_screen.dart`
- `lib/screens/level_select/level_select_screen.dart`
- `lib/screens/game/game_screen.dart`
- `lib/screens/result/result_screen.dart`
- `lib/screens/settings/settings_screen.dart`
- `lib/screens/preview/tile_preview_screen.dart`
- `lib/screens/game/widgets/tile_widget.dart`, `board_widget.dart`, `game_control_dock.dart`, `game_header.dart`, `game_stats_panel.dart`, `game_hud.dart`, `game_board_backdrop.dart`, `parchment_background.dart`, `hint_overlay.dart`
- `lib/providers/game_provider.dart`, `progress_provider.dart`, `settings_provider.dart`
- `lib/models/game_state.dart`, `tile_model.dart`, `board_model.dart`, `level_model.dart`
- `lib/core/constants/tile_data.dart`, `level_data.dart`, `layout_data.dart`
- `lib/core/theme/sankofa_game_theme.dart`, `app_theme.dart`, `app_colors.dart`, `app_text_styles.dart`
- `lib/core/utils/audio_service.dart`, `storage_service.dart`, `board_solver.dart`, `haptic_service.dart`
- `lib/widgets/kente_button.dart`, `sankofa_background.dart`, `adinkra_divider.dart`, `tile_back.dart`
- `pubspec.yaml`, `analysis_options.yaml`
- `android/app/build.gradle.kts`, `AndroidManifest.xml`, `gradle.properties`, `styles.xml`
- `test/widget_test.dart`, `test/game_provider_startup_test.dart`
- `tool/board_generation_benchmark.dart`
- Asset directories: `assets/audio/`, `assets/tiles/`, `assets/lottie/`, `assets/images/`

## Files Changed

**None.** No app files were modified. Only the new documentation file was created.

## Commands Run and Results

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib/` | 42 files, 0 changed |
| `flutter analyze` | No issues found! (2.4s) |
| `flutter test` | 4 tests passed (0:00 +4) |

## Important Findings

1. **The app is technically solid** — 0 analyzer issues, all tests pass, clean formatting.
2. **Board generation is robust** — Reverse-solved strategy guarantees solvable boards, with fallback safety. Load failure handling exists and is tested.
3. **The visual theme is cohesive** — Dark green/teal + parchment + antique gold identity is consistently applied across all screens.
4. **14 levels, 51 unique Adinkra symbols** — Substantial content for an MVP.
5. **Play Store blockers are mostly configuration, not code** — App icon, signing, Crashlytics, privacy policy, splash screen.
6. **Minor bugs found**: Result screen "NEXT" goes to level select (not next level); hint limit not enforced; in-game settings uses different color palette.
7. **No internet permission, no ads, no IAP** — The app is fully offline and self-contained.
8. **Portrait-locked, no tablet support** — Fine for MVP, needs work for larger screens later.

## Open Questions

- What should the app icon look like? (Adinkra symbol? Sankofa bird?)
- What signing key store will be used for Play Store?
- Where will the privacy policy be hosted?
- What Firebase project will Crashlytics/Analytics connect to?
- Are there plans for iOS release as well? (iOS app icon and signing already partially set up)
