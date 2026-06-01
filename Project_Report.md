# Sankofa Tiles — Project Report

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Architecture](#3-architecture)
4. [Design System](#4-design-system)
5. [Data Layer](#5-data-layer)
6. [State Management](#6-state-management)
7. [Screens](#7-screens)
8. [Widgets](#8-widgets)
9. [Game Mechanics](#9-game-mechanics)
10. [Progression & Persistence](#10-progression--persistence)
11. [Audio & Haptics](#11-audio--haptics)
12. [Routing & Navigation](#12-routing--navigation)
13. [Tile Catalogue](#13-tile-catalogue)
14. [Level Catalogue](#14-level-catalogue)
15. [Recent Changes](#15-recent-changes)
16. [Visual Feedback & Juice](#16-visual-feedback--juice)
17. [Known Issues](#17-known-issues)

---

## 1. Project Overview

**Sankofa Tiles** is a culturally-inspired mobile puzzle game built in Flutter. It is a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols — visual icons created by the Akan people of West Africa that encode proverbs, values, and philosophical concepts.

The name **Sankofa** (⟳) comes from the Akan proverb *"Se wo were fi na wosankofa a yenkyi"* — "It is not wrong to go back for what you forgot." The game embodies this spirit by encouraging players to engage deeply with ancestral symbols and their meanings.

**Core Gameplay:** Players tap pairs of matching Adinkra tiles to clear a 3D-layered board. Tiles must share the same ID (definition) to match. Tiles follow Mahjong solitaire "free tile" rules — a tile must not be covered from above and must have at least one lateral side open. Successfully clearing a board earns a score and star rating and unlocks the next level.

**Target Platforms:** Android and iOS (portrait orientation only). Web, macOS, Linux, and Windows platforms are scaffolded for future use.

**Current Version:** 1.0.0+1 — 20 levels playable, Phases 1-8 complete, Phase 9 (Visual Polish) in progress.

---

## 2. Technology Stack

| Concern | Library | Version |
|---|---|---|
| UI Framework | Flutter (Dart) | >=3.38.4 |
| State Management | `flutter_riverpod` | ^2.5.1 (resolved 2.6.1) |
| Navigation / Routing | `go_router` | ^13.2.0 (resolved 13.2.5) |
| Local Persistence | `shared_preferences` | ^2.2.3 (resolved 2.5.5) |
| Audio Playback | `audioplayers` | ^6.0.0 (resolved 6.6.0) |
| Typography | `google_fonts` | ^6.2.1 (resolved 6.3.3) |
| SVG Rendering | `flutter_svg` | ^2.0.10+1 (resolved 2.2.4) |
| Lottie Animations | `lottie` | ^3.1.0 (resolved 3.3.2) |
| Animation Utilities | `flutter_animate` | ^4.5.0 (resolved 4.5.2) |
| UUID Generation | `uuid` | ^4.4.0 (resolved 4.5.3) |
| Collection Utils | `collection` | ^1.18.0 (resolved 1.19.1) |

**Dev Dependencies:** `flutter_lints`, `build_runner`, `riverpod_generator`, `custom_lint`, `riverpod_lint`

**Font Families:**
- **Cinzel** (Google Fonts) — Display headings, level names, button labels
- **Nunito** (Google Fonts) — Body text, descriptive content
- **Georgia / system serif** — Tile face suit codes and Adinkra symbols

---

## 3. Architecture

The project follows a **layered architecture** with strict separation of concerns:

```
lib/
├── main.dart                        # App bootstrap, orientation lock, ProviderScope setup
├── app.dart                         # Root ConsumerWidget, router creation, theme application
│
├── core/
│   ├── constants/
│   │   ├── tile_data.dart           # TileSuit enum + TileDefinition + kAllTiles (~54 tiles)
│   │   ├── level_data.dart          # LevelDefinition + kLevels (20 levels) + getLevelById()
│   │   └── layout_data.dart         # TilePosition(row, col, layer) + 20 layout constants
│   ├── router/
│   │   └── app_router.dart          # GoRouter with 7 routes + onboarding redirect
│   ├── theme/
│   │   ├── app_colors.dart          # All color constants (~17 named colors)
│   │   ├── app_text_styles.dart     # All TextStyle definitions (14 styles)
│   │   └── app_theme.dart           # ThemeData (Material 3 dark, Kente-inspired)
│   └── utils/
│       ├── storage_service.dart     # SharedPreferences wrapper (scores, stars, settings)
│       ├── audio_service.dart       # AudioPlayer wrapper (SFX + music)
│       └── haptic_service.dart      # Haptic feedback wrapper with intensity levels
│
├── models/
│   ├── tile_model.dart              # TileModel — runtime tile instance (immutable)
│   ├── board_model.dart             # BoardModel — row/col container with tileAt() lookup
│   ├── game_state.dart              # GameState + GameStatus + DifficultyMode enums
│   └── level_model.dart             # LevelResult — levelId, bestScore, stars
│
├── providers/
│   ├── game_provider.dart           # GameNotifier — full game logic (~367 lines)
│   ├── progress_provider.dart       # ProgressService + computeStars() helper
│   └── settings_provider.dart       # SettingsNotifier + SettingsState + storageServiceProvider
│
├── screens/
│   ├── home/
│   │   └── home_screen.dart         # Main menu — Play, Settings, How to Play, Tile Preview
│   ├── onboarding/
│   │   └── onboarding_screen.dart   # 4-page PageView (Culture, Rules, Symbols, Ready)
│   ├── level_select/
│   │   └── level_select_screen.dart # 20-level grid + difficulty bottom sheet
│   ├── game/
│   │   ├── game_screen.dart         # Core gameplay — HUD, board, combo overlays, pause
│   │   └── widgets/
│   │       ├── board_widget.dart    # Responsive 3D board renderer with particle effects
│   │       ├── game_hud.dart        # Score, time, moves, remaining pairs chips
│   │       ├── hint_overlay.dart    # Hint active indicator modal
│   │       └── tile_widget.dart     # Single tile rendering with all animation states
│   ├── result/
│   │   └── result_screen.dart       # Win/lose screen with stars, score breakdown
│   ├── settings/
│   │   └── settings_screen.dart     # Audio, haptic, gameplay, data management
│   └── preview/
│       └── tile_preview_screen.dart # Scrollable Adinkra symbol catalogue
│
└── widgets/
    ├── kente_button.dart            # Reusable gold-on-navy styled button
    ├── adinkra_divider.dart         # Decorative divider with centered Adinkra symbol
    └── tile_back.dart               # SVG tile back face rendering widget
```

**Key architectural decisions:**

- All models are **immutable** with `copyWith()` methods. State is never mutated in place.
- **Riverpod** providers are the single source of truth. Widgets only read and dispatch actions.
- `StorageService` is injected via `ProviderScope` override in `main.dart`, enabling it to be swapped for tests.
- Audio is managed through an `audioServiceProvider` that auto-syncs with settings and disposes on removal.
- The `HapticService` is a static utility class that reads the current haptic intensity from settings.

---

## 4. Design System

### 4.1 Color Palette

```dart
// Background layers
navyDeep      = #0A2240   // Primary background (screens)
navyMid       = #0D2D52   // Secondary background (cards)
navyLight     = #1A4060   // Tertiary background (chips)

// Accent
kenteGold     = #EF9F27   // Primary action / selected border
kenteGoldDim  = #BA7517   // Secondary text / muted accent

// Tile surface
tileFace      = #F5E6C8   // Cream/ivory tile background
tileBorder    = #C8A96E   // Default tile border
tileEdge      = #8B6914   // 3D bottom slab + symbol color
tileSelected  = #FFF8E8   // Brighter cream when selected

// Board
boardGreen    = #1A5C38   // Semi-transparent board background

// Feedback
matchGreen    = #2E8B57   // Hint border / match flash
errorRed      = #CC3333   // Destructive actions (reset)
```

### 4.2 Typography

| Style | Font | Size | Weight | Usage |
|---|---|---|---|---|
| `displayLarge` | Cinzel | 32px | Bold | Screen titles |
| `displayMedium` | Cinzel | 24px | Bold | Section headers |
| `displaySmall` | Cinzel | 18px | SemiBold | Sub-headers |
| `headlineMedium` | Cinzel | 20px | Normal | Level names |
| `titleLarge` | Nunito | 18px | SemiBold | Card titles |
| `titleMedium` | Nunito | 16px | Bold | Sub-titles |
| `bodyLarge` | Nunito | 16px | Normal | Body copy |
| `bodyMedium` | Nunito | 14px | Normal | Descriptions |
| `bodySmall` | Nunito | 12px | Normal | Fine print |
| `buttonText` | Cinzel | 16px | Normal | Buttons |
| `tileSymbol` | Cinzel | 28px | Bold | Tile symbols (legacy) |
| `tileName` | Nunito | 9px | SemiBold | Tile label (legacy) |

### 4.3 Component Conventions

- **Buttons:** Navy fill, 1px gold border, Cinzel label. Disabled state uses muted colours.
- **Cards:** `navyMid` background, subtle `kenteGoldDim` border.
- **Chips (HUD):** `navyLight` fill, small Nunito label + bold value.
- **Dividers:** `AdinkraDivider` — thin dim-gold lines flanking a centered symbol.
- **App Bar:** `navyDeep` background, centred Cinzel title, gold back icon, no elevation.

---

## 5. Data Layer

### 5.1 Tile Definition (`TileDefinition`)

Every Adinkra tile type is described by an immutable `TileDefinition`:

| Field | Type | Description |
|---|---|---|
| `id` | String | Unique kebab-case identifier (e.g., `nyansapo`) |
| `name` | String | Display name (e.g., `Nyansapo`) |
| `meaning` | String | English meaning (e.g., `Wisdom knot`) |
| `symbol` | String | Unicode character rendered on the tile face |
| `suit` | `TileSuit` | `wisdom`, `earth`, `royalty`, or `honor` |
| `suitNumber` | int | Position within suit (1–9) |
| `assetPath` | String? | Optional path to high-res PNG artwork |

There are **~54 tile definitions** in `kAllTiles`, divided across 4 suits and an extended set.

### 5.2 Runtime Tile (`TileModel`)

Each tile on the board is a `TileModel` wrapping a `TileDefinition`:

| Field | Type | Description |
|---|---|---|
| `uid` | String | UUID v4 — unique per placed tile instance |
| `def` | `TileDefinition` | Reference to the tile type |
| `row`, `col` | int | Grid position |
| `layer` | int | Stack layer (0 = base, up to 5 for tall pyramids) |
| `isMatched` | bool | Cleared from board |
| `isSelected` | bool | Currently selected by the player |
| `isHinted` | bool | Highlighted by hint system |
| `isMismatched` | bool | Currently showing mismatch shake animation |

### 5.3 Game State (`GameState`)

```
GameState
├── tiles              List<TileModel>
├── status             GameStatus (idle | playing | paused | won | lost)
├── difficulty         DifficultyMode (easy | normal | relaxed)
├── score              int
├── moves              int
├── hintsUsed          int
├── secondsElapsed     int
├── levelId            int
├── selectedTileUid    String?
├── pendingScorePops   List of score pop animations
└── currentStreak      int (consecutive successful matches)
```

Computed properties:
- `remainingPairs` → unmatched tile count ÷ 2
- `hasWon` → all tiles matched
- `availableTileUids` → tiles that are "free" by Mahjong rules (not covered + one side open)
- `isStuck` → no available matching pairs remain

### 5.4 Level Definition (`LevelDefinition`)

| Field | Type | Description |
|---|---|---|
| `id` | int | Numeric level ID (1–20) |
| `name` | String | Level display name |
| `boardRows`, `boardCols` | int | Grid dimensions |
| `tileCount` | int | Number of tiles (always even) |
| `tileIds` | List<String> | Tile definition IDs used in this level |
| `unlockRequirement` | int | Stars required on previous level |
| `starThresholds` | List<int> | Min scores for 1★, 2★, 3★ |
| `layout` | List<TilePosition> | Exact (row, col, layer) positions for every tile |

### 5.5 Persistence Keys (SharedPreferences)

| Key | Type | Default | Description |
|---|---|---|---|
| `best_score_{levelId}` | int | 0 | Best score ever on that level |
| `stars_{levelId}` | int | 0 | Best star count on that level |
| `sound_enabled` | bool | true | Sound effects on/off |
| `music_enabled` | bool | true | Background music on/off |
| `show_tile_names` | bool | true | Show names under symbols |
| `default_difficulty` | String | `normal` | Selected difficulty enum name |
| `onboarding_complete` | bool | false | Whether tutorial was finished |
| `haptic_intensity` | String | `medium` | Haptic intensity level |

---

## 6. State Management

All state is managed with **Riverpod** (`StateNotifierProvider`). No `setState` is used for game logic.

### 6.1 `gameProvider` / `GameNotifier`

The most complex provider. Owns all in-game logic (~367 lines).

**Public actions:**

| Method | Description |
|---|---|
| `startLevel(levelId, difficulty)` | Builds the tile grid, starts timer (normal mode), plays music |
| `selectTile(uid)` | Core matching logic — select, deselect, match, no-match |
| `useHint()` | Highlights a valid pair for 2 seconds, increments `hintsUsed` |
| `shuffleRemaining()` | Redistributes unmatched tiles; costs 50 points |
| `pauseGame()` | Pauses timer, sets status `paused` |
| `resumeGame()` | Resumes timer, sets status `playing` |
| `tick()` | Called each second by internal `Timer`; triggers lose at 300s (normal mode) |

**Match logic flow:**
1. First tap → `isSelected = true`
2. Second tap on same tile → deselect
3. Second tap on different tile:
   - **Same `def.id`** → both marked `isMatched`, score +100, move +1, streak bonus applied, check win
   - **Different id** → both show mismatch animation, deselected after 600ms, streak reset, check stuck

**Win condition:** `_checkWin()` fires after every match. If no unmatched tiles remain, status → `won`, time bonus calculated.

**Lose conditions:** Timer reaches 300s (normal difficulty) or `isStuck` returns true.

### 6.2 `settingsProvider` / `SettingsNotifier`

Reads initial values from `StorageService` on construction. Exposes async setters that update both state and persistent storage atomically. Manages: sound/music toggles, show tile names, default difficulty, haptic intensity, and progress reset.

### 6.3 `progressProvider` / `ProgressService`

A thin adapter over `StorageService` that exposes level unlock checks and result queries to the UI layer without exposing raw storage keys.

**`computeStars(score, thresholds)`** — Pure function used by both the result screen and the progress service to convert a raw score to a 0–3 star count.

---

## 7. Screens

### 7.1 Home Screen (`/`)

Static screen. No state management. Displays the game logo (⟳ symbol, "SANKOFA TILES" title), a decorative divider, subtitle "A Ghanaian Mahjong Experience", and four navigation buttons: **Play**, **Settings**, **How to Play**, **Tile Preview**. Shows version "v1.0.0".

### 7.2 Onboarding Screen (`/onboarding`)

4-page `PageView` tutorial:

| Page | Content |
|---|---|
| 1 | Cultural welcome — what Adinkra symbols are |
| 2 | How to play — 4 numbered steps, hints and shuffle explained |
| 3 | Symbol preview — grid of 6 sample tile previews |
| 4 | Closing philosophy — Gye Nyame and the Sankofa concept |

Navigation: Skip button (any page), dot indicators, "START PLAYING" on final page. On finish: `setOnboardingComplete()` is called and the player is routed to level select. The router's redirect logic sends first-time users here automatically.

### 7.3 Level Select Screen (`/level-select`)

2-column `GridView` of 20 level cards. Each card shows:
- Level number badge
- Lock icon (if not unlocked) or star row (if played)
- Level name, tile/pair count, board dimensions

Tapping an unlocked card opens a modal bottom sheet (`_DifficultySheet`) where the player picks Easy, Normal, or Relaxed before starting. The selected difficulty is passed as a route `extra` to the game screen.

### 7.4 Game Screen (`/game/:levelId`)

Main gameplay view. A `ConsumerStatefulWidget` that calls `startLevel()` on first frame.

**Layout (top to bottom):**
1. Top bar — back/quit button, level name
2. `GameHud` — score, timer (normal only), moves, pairs remaining
3. `BoardWidget` — the playable 3D tile pyramid
4. Bottom bar — Hint, Shuffle (-50 pts), Pause/Resume action buttons

**Overlays:**
- **Combo overlay:** "X streak!" banner on consecutive matches
- **Pause overlay:** Semi-transparent overlay with Resume and Quit buttons
- **Quit dialog:** Confirmation alert when back button pressed while playing

Status transitions trigger navigation: `won` or `lost` → navigate to `/result` after 600ms.

### 7.5 Result Screen (`/result`)

Receives `GameState` as route extra.

**Win view:** Scale+fade animation on entry (600ms elasticOut). Shows ★ rating (1-3 stars), level name, score breakdown (matches, time bonus, total). Buttons: **Menu** and **Next Level**.

**Lose view:** Shows lose icon, Akan proverb, score reached, pairs matched. Buttons: **Menu** and **Try Again**.

`_saveResult()` is called once on won state, writing to `ProgressService` only if the new score/stars exceeds the previous best.

### 7.6 Settings Screen (`/settings`)

Four sections rendered as a `ListView`:

| Section | Controls |
|---|---|
| **Audio** | Sound effects toggle, background music toggle |
| **Haptic Feedback** | Off / Low / Medium / High selector |
| **Gameplay** | Show tile names toggle, default difficulty selector |
| **Data** | Reset all progress (confirmation dialog) |

All toggles are wired directly to `SettingsNotifier` methods; persistence is immediate.

### 7.7 Tile Preview Screen (`/tile-preview`)

A scrollable reference gallery of all Adinkra symbols. Shows one large tile at a time (rendered via `TileWidget` or PNG asset) with the tile's name and meaning displayed below, and a horizontal scrollable strip of all ~54 tiles at the bottom for selection.

---

## 8. Widgets

### 8.1 `TileWidget`

The most visually complex widget (~395 lines). Renders a physical Mahjong-style tile.

**Dimensions:** 64×85 px aspect ratio, scaled dynamically by `BoardWidget` based on available screen space (up to 1.634× scaling).

**3D construction:**
```
SizedBox (w × h)
└── Stack
    ├── Positioned.fill → Container (dark gold #8B6914, rounded 9px)
    │     ← full-height "slab" — the bottom portion shows as the raised edge
    └── Positioned (top=0, height=h-5) → Container (ivory face, gold border)
          └── Stack (tile content)
              ├── Positioned top-left  → suit code text ("W1", "E3", etc.)
              ├── Center               → Adinkra symbol or PNG image
              └── Positioned bottom    → tile name (if show_tile_names enabled)
```

**State rendering:**

| State | Visual |
|---|---|
| Normal | Cream face, 1.5px gold border |
| Available (free tile) | Pulsing gold glow border |
| Selected | Brighter cream (#FFF8E8), 2.5px gold (#EF9F27), lifts 10px |
| Hinted | Green border (#2E8B57) 2.5px, opacity pulses 0.6→1.0 over 800ms |
| Mismatched | Shake animation via `TweenSequence` |
| Matched | Scale-up burst then shatter-out fade (400ms) |
| Pressed | Scale(0.93) on tap-down for tactile "dip" effect |

When a tile has an `assetPath` (PNG image), the image is rendered scaled 1.634× and the decorative frame is hidden, allowing the artwork to fill the tile face.

### 8.2 `BoardWidget`

Responsive grid renderer (~190 lines). Uses `LayoutBuilder` to compute tile sizes from available space. Key features:
- Tiles sorted by `layer` (lower to higher) and rendered with 24px layer offsets for 3D depth
- Each `TileWidget` placed at computed (x, y) from its (row, col) position
- Unavailable tiles wrapped in `IgnorePointer`
- Staggered entry animations (fade+slide) on level start
- Particle burst overlays on match (3 random variants: Inferno, Confetti, Nova)
- "+100" score pop overlays at match coordinates
- Win shimmer / lose red tint + shake board-level overlays

### 8.3 `GameHud`

Four `_HudChip` widgets in a horizontal row: Score, Time (hidden in easy/relaxed), Moves, Pairs Left. Time chip turns red when `secondsElapsed >= 240` (last minute). Time formatted as MM:SS.

### 8.4 `HintOverlay`

An instructional modal shown the first time a player uses a hint. Displays a lightbulb icon, "Hint Active" title, "Matching tiles are glowing green" description, and "Tap anywhere to dismiss". Semi-transparent dark background.

### 8.5 `KenteButton`

Reusable `ElevatedButton` with the app's gold-on-navy style. Supports:
- Optional leading icon
- Optional fixed width
- `small` variant for compact layouts
- Disabled state (null `onTap`)

### 8.6 `AdinkraDivider`

Thin decorative separator: `—— ◎ ——`. Used on Home, Onboarding, Level Select, Result, and Settings screens. Configurable symbol and height.

---

## 9. Game Mechanics

### 9.1 Board Generation

On `startLevel(levelId, difficulty)`:
1. Fetch `LevelDefinition` by ID.
2. Build pairs from `tileIds` (each ID appears twice).
3. Shuffle the pairs.
4. Assign tiles to specific 3D coordinates `(row, col, layer)` defined in the level layout.
5. Store in `GameState.tiles`.

### 9.2 Mahjong Solitaire Logic (Layered Stacking)

The game follows classic Mahjong Solitaire rules for tile interaction:

- **Availability:** A tile is only "free" (selectable) if:
    1. It is not covered by any tile in a layer above it.
    2. It has at least one side (left or right) completely clear of adjacent tiles on the same layer.
- **Visual Stacking:** Tiles are rendered with 24px layer offsets to create 3D depth.
- **Selection:** Only "available" tiles can be tapped. Unavailable tiles have no interactive glow.

### 9.3 Match Logic

```
Player taps Tile A (Available):
  → Tile A becomes selected.

Player taps Tile A again:
  → Tile A is deselected.

Player taps Tile B (Available, Tile A already selected):
  if A.def.id == B.def.id:
    → Both marked isMatched.
    → score += 100 + Streak Bonus.
    → Particle burst and score pop triggered.
    → _checkWin() called.
  else:
    → Both shake (mismatch animation).
    → Deselected after 600ms.
    → Streak reset to 0.
    → _checkStuck() called.
```

### 9.4 Scoring & Streaks

| Component | Formula |
|---|---|
| Match points | 100 per matched pair |
| Streak Bonus | Bonus points for consecutive matches (3+ streak) |
| Time bonus (normal only) | `max(0, 300 - secondsElapsed) × 2` |
| Shuffle penalty | -50 per use (clamped at 0) |

### 9.5 Difficulty Modes

| Mode | Timer | Hints | Description |
|---|---|---|---|
| Easy | None | Unlimited | Casual play |
| Normal | 5 min | 3 | Standard challenge |
| Relaxed | None | Unlimited | Exploration mode |

### 9.6 Win / Lose Conditions

| Condition | Trigger |
|---|---|
| **Win** | All tiles matched (`remainingPairs == 0`) |
| **Lose (stuck)** | No remaining *available* pairs can be matched (`isStuck == true`) |
| **Lose (time)** | Normal difficulty, `secondsElapsed >= 300` (5 minutes) |

---

## 10. Progression & Persistence

### 10.1 Unlock System

Level 1 is always available. Level N is unlocked if the player has earned at least 1 star on level N−1. Checked via `StorageService.isLevelUnlocked(id)`.

### 10.2 Star Thresholds

Each level has three score thresholds. `computeStars(score, thresholds)` returns 0–3:

```
score >= thresholds[2] → 3 stars
score >= thresholds[1] → 2 stars
score >= thresholds[0] → 1 star
otherwise              → 0 stars
```

### 10.3 Best Score Logic

`StorageService.saveLevelResult(levelId, score, stars)` only writes if the new score exceeds the stored best. Stars are saved independently and also only updated upward.

### 10.4 Progress Reset

`SettingsNotifier.resetProgress()` calls `StorageService.resetAllProgress()`, which removes all `best_score_*` and `stars_*` keys from SharedPreferences. Level 1 immediately becomes the only accessible level again.

---

## 11. Audio & Haptics

### 11.1 Audio

Managed by `AudioService`, which owns two `AudioPlayer` instances:

| Player | Role | File |
|---|---|---|
| `_sfxPlayer` | Sound effects (one-shot) | Multiple |
| `_musicPlayer` | Background music (looping) | `audio/background_music.mp3` |

**Sound effect triggers:**

| Event | File |
|---|---|
| Tile tapped | `audio/tile_tap.mp3` |
| Successful match | `audio/match.mp3` |
| Failed match | `audio/no_match.mp3` |
| Board cleared (win) | `audio/win.mp3` |
| Game lost | `audio/lose.mp3` |

Audio failures (e.g., missing files) are caught silently and logged via `debugPrint` — they do not crash the game.

Settings changes take immediate effect: disabling music calls `stopBackgroundMusic()` instantly; re-enabling it does not auto-restart (the next `startLevel` call will start music if enabled).

### 11.2 Haptics

Managed by `HapticService`, a static utility class with configurable `HapticIntensity` levels:

| Level | Behavior |
|---|---|
| `off` | No haptic feedback |
| `low` | Light selection clicks only |
| `medium` | Tile press + match impacts + error vibrations |
| `high` | All of above + heavy impacts for combos and win/lose sequences |

Haptic triggers include: `selectionClick` on tile press, `tilePress` on selection confirmation, `heavyImpact` for combos, and `sequence` (timed burst) for win/lose events.

---

## 12. Routing & Navigation

Implemented with **GoRouter**. All routes are defined in `createAppRouter()`.

| Route | Path | Extra | Description |
|---|---|---|---|
| Home | `/` | — | Main menu |
| Onboarding | `/onboarding` | — | First-launch tutorial |
| Level Select | `/level-select` | — | Level grid |
| Game | `/game/:levelId` | `DifficultyMode` | Core gameplay |
| Result | `/result` | `GameState` | Win/lose screen |
| Settings | `/settings` | — | Settings |
| Tile Preview | `/tile-preview` | — | Tile catalogue |

**Redirect logic:** If the user navigates to `/` and `StorageService.isOnboardingComplete()` returns false, the router redirects to `/onboarding`.

**Parameter passing:**
- `levelId` is a path parameter (`:levelId`) extracted as a String and parsed to int in `GameScreen`.
- `difficulty` (DifficultyMode) and `gameState` (GameState) are passed as `extra` objects in `GoRouterState`.

---

## 13. Tile Catalogue

The tile system has transitioned from unicode symbols to **High-Resolution PNG Assets** (Asset v2) for better cultural representation and visual fidelity.

### Suit Summary

| Suit | Code | Count | Examples |
|---|---|---|---|
| Wisdom | W | 13 | Nyansapo, Nkyinkyim, Mate Masie, Hwehwemudua, Sankofa |
| Earth & Nature | E | 5 | Denkyem, Abe Dua, Nyame Dua, Fihankra, Fofo |
| Royalty & Power | R | 8 | Adinkrahene, Akofena, Aban, Fawohodie, Kwatakye Atiko |
| Honor | H | 28 | Gye Nyame, Dwennimmen, Mpatapo, Akoben, Nsoromma |

### Image Assets

Most tiles use custom artwork located in `assets/tiles/symbols/asset v2/` (36 files, ~200-300 KB each). Legacy v1 assets are in `assets/tiles/symbols/` (18 files, ~1-1.6 MB each). When an `assetPath` is provided, `TileWidget` renders the PNG and hides the default decorative frame.

---

## 14. Level Catalogue

| # | Name | Grid | Tiles | Layers | 1★ | 2★ | 3★ |
|---|---|---|---|---|---|---|---|
| 1 | Awakening | 4×3 | 16 | 2 | 400 | 650 | 800 |
| 2 | Roots | 4×4 | 20 | 2 | 500 | 800 | 1000 |
| 3 | Harvest | 4×5 | 24 | 2 | 600 | 950 | 1200 |
| 4 | River | 4×6 | 28 | 3 | 700 | 1100 | 1400 |
| 5 | Confluence | 5×6 | 36 | 3 | 900 | 1400 | 1800 |
| 6 | Kingdom | 5×6 | 40 | 3 | 1000 | 1600 | 2000 |
| 7 | Council | 5×7 | 44 | 3 | 1100 | 1750 | 2200 |
| 8 | Heritage | 5×6 | 48 | 4 | 1200 | 1900 | 2400 |
| 9 | Ancestors | 5×7 | 52 | 4 | 1300 | 2100 | 2600 |
| 10 | Sankofa | 5×7 | 56 | 4 | 1400 | 2300 | 2800 |
| 11 | Legacy | 5×8 | 60 | 4 | 1600 | 2600 | 3200 |
| 12 | Covenant | 6×7 | 64 | 4 | 1800 | 2900 | 3600 |
| 13 | Shrine | 6×7 | 68 | 4 | 2000 | 3200 | 4000 |
| 14 | Elders | 6×7 | 72 | 5 | 2200 | 3500 | 4400 |
| 15 | Oracle | 6×8 | 76 | 5 | 2400 | 3900 | 4800 |
| 16 | Throne | 6×8 | 80 | 5 | 2600 | 4200 | 5200 |
| 17 | Genesis | 6×8 | 84 | 5 | 2800 | 4600 | 5600 |
| 18 | Cosmos | 6×9 | 88 | 5 | 3000 | 5000 | 6000 |
| 19 | Triumph | 6×9 | 92 | 5 | 3200 | 5400 | 6600 |
| 20 | Eternal | 6×9 | 96 | 6 | 3500 | 5800 | 7200 |

Each level requires 1 star on the previous level to unlock. Level 1 is always accessible.

---

## 15. Recent Changes

### 15.1 Levels 11-20 Added
- Added 10 new levels (Legacy through Eternal) with increasing complexity.
- Levels progress from 60 to 96 tiles, from 4 to 6 layers.
- Introduced 15 extended tile IDs with v2 artwork.

### 15.2 Layer Offset Increase
- Layer rendering offset increased from 11px to 24px for pronounced 3D depth effect.

### 15.3 BoardWidget Visual Refinement
- Removed teal background box for a "floating tiles" aesthetic.
- Board renders tiles directly on the dark navy background.

### 15.4 UI Fixes
- Fixed UI overflow on result screen retry button.

### 15.5 Audio Service Simplified
- Streamlined `AudioService` for better stability and error handling.

### 15.6 Advanced Visual & Tactile Feedback (Juice Phase)
- **Haptic Feedback Profile:** Comprehensive tactile vibration system using `lightImpact` for taps, `mediumImpact` for matches, `vibrate` for errors, and `heavyImpact` for speed bursts.
- **Particle Burst System:** High-performance particle effects (Gold Confetti, Inferno, Nova) triggered on successful matches.
- **Score Pops & Combo Indicators:** Repositioned, scaled-down banner rewarding rapid play with a time-gated Speed Streak.
- **No-Match Shake & Ripple:** Tactile and visual feedback for invalid moves.
- **Available Glow:** Subtle outer pulse on "free" tiles to guide the player.

### 15.7 Mahjong Solitaire Implementation
- **3D Stacking:** Full coordinate system `(row, col, layer)` for complex pyramid and bridge layouts.
- **Layer Offsets:** 24px for pronounced 3D effect.
- **Availability Logic:** Strict "free tile" rules (no top cover, one side open).
- **Auto-Stuck Detection:** Game detects when no available matches remain.

### 15.8 Visual Refinement
- **Asset Migration:** Moves all tile symbols to high-res transparent PNGs (v2 set).
- **Scale Update:** Increased tile scaling to 1.634× on larger screens.
- **Layout Precision:** Zero-gap tile spacing for a "solid block" feel.

---

## 16. Visual Feedback & Juice

To create a "Premium" feel, several micro-interaction systems were added:

- **The "Dip" Effect:** Tapping a tile briefly scales it down (0.93×) for tactile feedback.
- **Match Variants:** Different match animations (bursts, streaks, pulses) randomly selected.
- **Speed Combo Indicators:** Visual "X x Combo!" banner that is time-gated to reward high-intensity play.
- **Adaptive Spacing:** `BoardWidget` dynamically calculates tile dimensions to fit any mobile screen.
- **Physical Feedback:** Haptic click on every tile press, enhancing the "clicky" feel.
- **Board Entrance:** Tiles animate in with staggered fade+slide on level start.

---

## 17. Known Issues

1. **`tile_tap.mp3` is a 0-byte empty file** — tile tap sound effects are silent even when enabled.
2. **No Lottie JSON files** — the `lottie` dependency exists but `win_starburst.json` is missing.
3. **No image assets** in `assets/images/` — directory is empty (placeholder README only).
4. **Two PNGs have `-removebg-preview` suffixes** — `fawohodie-removebg-preview.png` and `mekyea_wo-removebg-preview.png` appear to be unprocessed tool outputs.
5. **No actual tests** — only a Flutter scaffolding placeholder test (`1 + 1 == 2`).
6. **Web manifest `description`** still says "A new Flutter project."
7. **No custom screen transitions** — all routes use default slide transitions.

---

*Last updated: 2026-06-01 — 20 levels, ~54 tile definitions, Phase 9 (Visual Polish) in progress.*
