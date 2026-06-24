# Sankofa Tiles — Project Report

---

## 1. Project Overview

**Sankofa Tiles** is a culturally-inspired mobile puzzle game built in Flutter. It is a Mahjong solitaire tile-matching game themed around Ghanaian Adinkra symbols — visual icons created by the Akan people of West Africa that encode proverbs, values, and philosophical concepts.

**Core Gameplay:** Players tap pairs of matching Adinkra tiles to clear a 3D-layered board. Tiles must share the same ID to match and follow Mahjong solitaire "free tile" rules. Successfully clearing a board earns a score and star rating and unlocks the next level.

**Target Platforms:** Android and iOS (portrait orientation only). Web, macOS, Linux, and Windows platforms are scaffolded.

**Current Version:** 1.0.0+3 — 50 levels playable.

---

## 2. Technology Stack

| Concern | Library | Version |
|---|---|---|
| UI Framework | Flutter (Dart) | >=3.0.0 <4.0.0 |
| State Management | `flutter_riverpod` | ^2.5.1 |
| Navigation / Routing | `go_router` | ^13.2.0 |
| Local Persistence | `shared_preferences` | ^2.2.3 |
| Audio Playback | `audioplayers` | ^6.0.0 |
| Typography | `google_fonts` | ^6.2.1 |
| SVG Rendering | `flutter_svg` | ^2.0.10+1 |
| Lottie Animations | `lottie` | ^3.1.0 |
| Animation Utilities | `flutter_animate` | ^4.5.0 |
| UUID Generation | `uuid` | ^4.4.0 |
| Firebase Core | `firebase_core` | ^4.10.0 |
| Firebase Analytics | `firebase_analytics` | ^12.4.2 |
| Firebase Crashlytics | `firebase_crashlytics` | ^5.2.3 |
| URL Launcher | `url_launcher` | ^6.3.2 |

**Font Families:** Cinzel (display/headings), Nunito (body).

---

## 3. Architecture

Layered architecture with Riverpod state management:

```
lib/
├── main.dart                        # Firebase init, portrait lock, ProviderScope setup
├── app.dart                         # Root ConsumerWidget, router creation, theme
├── core/
│   ├── config/                      # Developer tools toggle
│   ├── constants/                   # tile_data, level_data (50 levels), layout_data
│   ├── router/                      # GoRouter (7 routes) + safeBack helper
│   ├── theme/                       # SankofaGameTheme + AppColors + AppTextStyles + AppTheme
│   └── utils/                       # Storage, audio, haptics, board solver, analytics, crashlytics, layout geometry, campaign validator
├── models/                          # TileModel, BoardModel, GameState, GameLaunchConfig, LevelResult
├── providers/                       # GameNotifier, SettingsNotifier, ProgressService
├── screens/                         # Home, Onboarding, Game, Result, Settings, TilePreview, DeveloperLevelTester
└── widgets/                         # KenteButton, AdinkraDivider, SankofaBackground, TileBack
```

**Key principles:**
- All models immutable with `copyWith()`
- Riverpod as single source of truth
- `StorageService` injected via `ProviderScope` override
- Audio managed through `audioServiceProvider` auto-syncing with settings
- No `setState` for game logic

---

## 4. Design System

Two color palettes:

**SankofaGameTheme** (primary, used on most screens):
- Dark green/teal gradient background (#101A16 → #17241F)
- Antique gold accents (#B88A3A)
- Cream parchment panels (#F1E6CF, #EDE0C4)
- Board surface (#203329)

**AppColors** (archive/navy palette, used in overlays and in-game settings):
- Navy deep (#0A2240) through gold (#EF9F27)
- Archive gold, archive ink, parchment warm tones

**Background system:** `SankofaBackground` (gradient + texture + vignette), `ParchmentBackground` (similar with custom-painted parchment edges), `GameBoardBackdrop` (dark board surface with Adinkra motif).

---

## 5. Game Mechanics

### Board Generation
Two strategies based on tile count:
- **≥40 tiles:** Reverse-solved generation (greedy pair removal, up to 100 attempts)
- **<40 tiles:** Random generation + solvability check (6,000 search nodes, up to 12 attempts, falls back to reverse-solved)
- Final solvability check with 50,000 node budget

### Matching
Mahjong solitaire free-tile rules:
- Tile must not be covered by higher-layer tiles (2-unit span overlap)
- At least one lateral side must be open
- Unsafe moves blocked when safe alternatives exist
- Match animation styles: `directCollision` and `secondHitsFirst` (randomly selected, one in four uses the latter)

### Scoring
- Base: +100 per match
- Streak bonus: 3x→+50, 4x→+100, 5x+→+200
- Shuffle: -50 (clamped at 0)
- Star thresholds computed dynamically from complexity formula

### Auto-Shuffle on Stuck
When no available matching pairs remain, the game automatically attempts a penalty-free shuffle. Only if the shuffle also fails does the game declare a loss.

### No Timer
The game has no time limit. `secondsElapsed` exists in the model but is never incremented. All difficulty modes behave identically.

---

## 6. Level System

**50 levels** across 5 chapters:

| Chapter | Levels | Difficulty |
|---|---|---|
| First Symbols | 1–10 | Novice |
| Paths of Wisdom | 11–20 | Apprentice |
| Heritage | 21–30 | Strategic |
| Ancestral Trials | 31–40 | Advanced |
| Grand Archive | 41–50 | Master |

Each level uses `SymbolCopyPlan` for tile distribution and `NamedLayout` for board structure. Star thresholds are computed dynamically from a formula factoring tile count, layer count, covered tiles, symbol pool size, and max layer.

Progression is linear: complete level N to unlock N+1. Stored as `completed_N` boolean keys and `highest_completed_level` integer. Legacy migration handles old key formats.

---

## 7. Screens

| Screen | Route | Purpose |
|---|---|---|
| Home | `/` | Main menu with PLAY/SETTINGS/HOW TO PLAY/TILE PREVIEW |
| Onboarding | `/onboarding` | 4-page first-launch tutorial |
| Game | `/game/:levelId` | Core gameplay |
| Result | `/result` | Win/lose display |
| Settings | `/settings` | Audio, haptic, gameplay, privacy policy, developer tools |
| Tile Preview | `/tile-preview` | ~90 Adinkra symbol reference gallery |
| Developer Level Tester | `/developer/levels` | Debug-only — test all 50 levels |

**No level select screen.** PLAY navigates directly to the next unfinished level via `ProgressService.nextUnfinishedLevelId`.

---

## 8. Audio & Haptics

**Audio:** 4 SFX players + 1 music player. SFX use `.ogg` format (`tile_tap.ogg`, `match.ogg`, `no_match.ogg`, `win.ogg`, `lose.ogg`, `hint.ogg`, `shuffle.ogg`). Music uses `background_music.mp3`. Togglable with per-SFX volume.

**Haptics:** `HapticIntensity` levels: off/low/medium/high. Triggered on tile press, match, mismatch, combo, win, and loss. Combo haptics scale with streak count.

---

## 9. Firebase Integration

- **Analytics:** 14 custom event types — level lifecycle, gameplay actions, settings, navigation. No PII.
- **Crashlytics:** Fatal Flutter errors + platform errors + non-fatal reports for storage, audio, and board generation failures.

---

## 10. Developer Tools

- **Developer Level Tester:** `ENABLE_DEVELOPER_TOOLS=true` or debug mode. Tests any level without saving progress.
- **Campaign validator:** `lib/core/utils/campaign_validator.dart` — validates 50-level structure.
- **Board generation benchmark:** `tool/board_generation_benchmark.dart`.

---

## 11. Tests

7 test files, all passing:
- `widget_test.dart` — placeholder
- `game_provider_startup_test.dart` — campaign structure, level startup speed, all-50 generation, failure handling, progression, migration
- `progression_flow_test.dart` — next level resolution, legacy migration, final level clamping, developer test isolation
- `board_layout_geometry_test.dart` — geometry calculations
- `board_widget_ghost_tile_test.dart` — ghost tile rendering during match animations
- `game_header_layout_test.dart` — header layout validation
- `result_screen_dispose_test.dart` — result screen lifecycle

---

## 12. Known Issues

1. **No timer** — game has no time pressure
2. **No level select screen** — direct linear progression only (by design, but limits player choice)
3. **No custom app icon** on Android
4. **White Android splash screen** — should match dark theme
5. **Debug release signing** — needs Play Store key
6. **No Lottie animations** — directory exists but empty
7. **In-game settings palette mismatch** — uses AppColors (navy) while game uses SankofaGameTheme (dark green)
8. **No custom screen transitions** between routes
9. **No tutorial mode** — only static onboarding pages
10. **No accessibility features**

---

*Last updated: 2026-06-24 — 50 levels, Firebase integrated, no timer, linear progression, 7 test files.*
