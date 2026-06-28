# Tile Back Reveal and 100-Level Progression Plan

> Project: Adinkra Tiles  
> Purpose: Track the phased implementation for richer covered tiles, tap-to-reveal gameplay, 100 levels, tile unlocks, collection updates, and post-level unlock popups.

---

## Goal

Make gameplay feel closer to a polished Mahjong Blast-style experience:

- Covered/back-facing tiles use `assets/adinkra tile back tile.png`.
- Covered tiles visually sit on the board as real tiles, not placeholders.
- Tapping an eligible covered tile flips it and reveals the Adinkra face tile.
- The campaign grows to at least 100 levels.
- New Adinkra symbols unlock as the player progresses.
- Unlocked symbols appear in the Tile Collection.
- When a new tile unlocks after a level, the player sees a popup with the tile image, name, and short cultural meaning.

---

## Current Context

The project already has:

- A campaign level system in `lib/core/constants/level_data.dart`.
- Board layouts in `lib/core/constants/layout_data.dart`.
- Face tile definitions in `lib/core/constants/tile_data.dart`.
- A Tile Collection route at `/tile-preview`.
- Result rewards that already mention collection unlocks in the current flow docs.
- A reusable tile-back widget at `lib/widgets/tile_back.dart`.
- A current SVG back asset at `assets/tiles/tile_back.svg`.

The new PNG exists at:

```text
assets/adinkra tile back tile.png
```

Important setup note: this PNG must be added to `pubspec.yaml` before Flutter can load it.

---

## Implementation Rules

1. Work one phase at a time.
2. Do not rewrite the board engine unless a phase explicitly requires it.
3. Keep existing matching rules stable: only free/selectable tiles should be interactable.
4. Preserve current progression, economy, analytics, and collection behavior unless the phase says to extend it.
5. Add or update tests for important behavior in each phase.
6. After each phase, run:

```text
dart format .
flutter analyze
flutter test
```

---

## Phase Tracker

| Phase | Status | Name | Main Outcome |
|---|---|---|---|
| Phase 1 | Completed | PNG Tile Back Asset | Covered/back tiles render with the new Adinkra PNG |
| Phase 2 | Completed | Covered Tile State Model | Game state can distinguish hidden, covered, revealed, matched, and blocked tiles |
| Phase 3 | Completed | Temporary Peek Reveal | Tapping an eligible back tile flips it face-up only while it is selected or being compared |
| Phase 4 | Not Started | Peek-Aware Gameplay Logic | Match, mismatch, hint, shuffle, and stuck logic respect temporary face-up state |
| Phase 5 | Not Started | Board Layout Polish | Levels visually resemble stacked Mahjong boards with clean depth and intentional backs |
| Phase 6 | Not Started | 100-Level Campaign Expansion | Campaign grows from 50 to at least 100 levels |
| Phase 7 | Not Started | Progressive Tile Unlock Rules | New symbols unlock at planned level milestones |
| Phase 8 | Not Started | Collection Integration | Newly unlocked symbols appear in the Tile Collection |
| Phase 9 | Not Started | Unlock Popup After Level | Result flow shows tile image, name, and short meaning when a new tile unlocks |
| Phase 10 | Not Started | Balance, QA, and Documentation | Verify difficulty curve, tests, docs, and release readiness |

---

## Phase 1 — PNG Tile Back Asset

**Status:** Completed

**Implementation Notes:**

- Added `assets/adinkra tile back tile.png` to `pubspec.yaml`.
- Updated `TileBackWidget` to render the PNG asset.
- Updated gameplay tile rendering so blocked/non-free tiles display with the new back artwork.
- Removed the extra gold/brown border and shadow from back-facing tiles so the PNG artwork reads cleanly.

### Scope

- Add `assets/adinkra tile back tile.png` to `pubspec.yaml`.
- Update `TileBackWidget` to render the PNG instead of `assets/tiles/tile_back.svg`.
- Keep the same tile dimensions and rounded clipping, but let the PNG artwork carry the back-tile design without extra border or shadow.
- Confirm the PNG scales cleanly on different tile sizes.

### Acceptance Criteria

- Back-facing tiles use the new PNG.
- No missing asset errors.
- Existing tile face rendering is unchanged.
- Existing tests still pass.

---

## Phase 2 — Covered Tile State Model

**Status:** Completed

**Implementation Notes:**

- Added `TileVisibility.hidden`, `TileVisibility.covered`, and `TileVisibility.revealed`.
- New tiles default to `revealed` so current gameplay stays unchanged until Phase 3.
- Hidden tiles are skipped by the board renderer.
- Covered tiles can render with the back artwork and are not currently matchable.
- Available tile, hint, open-path, and shuffle logic now preserves or respects reveal state.

### Scope

Define the game behavior clearly before adding animation.

Possible tile visibility states:

- `hidden`: not shown on the board, if needed by future layouts.
- `covered`: visible with back artwork.
- `revealed`: visible with face artwork and matchable.
- `matched`: removed or animating out.
- `blocked`: visible face tile but not selectable because another tile overlaps or side rules block it.

### Decisions Resolved

- Back tiles are a temporary peek mechanic, not simply a visual state for every blocked tile.
- Only free/eligible back tiles should respond to taps.
- A peeked tile returns face-down when it is deselected, mismatched, or left unmatched.
- A correctly matched peeked tile is removed instead of returning face-down.
- Peek state is per attempt and should not be treated as a permanent collection unlock.

### Recommended Rule

Back tiles should use a temporary peek rule. Only free/eligible back tiles can be tapped. When tapped, the tile flips face-up and becomes the active selection. If the player completes a correct match, the tiles are removed. If the player makes a wrong match, cancels selection, or moves to a different unmatched selection flow, any unmatched peeked tile returns face-down.

### Acceptance Criteria

- Tile model/state can represent whether a tile face is revealed.
- Board generation still creates solvable levels.
- Existing match and availability rules remain intact.

---

## Phase 3 — Temporary Peek Reveal

**Status:** Completed

**Implementation Notes:**

- Added `isPeeked` to `TileModel` to distinguish temporary face-up peeks from normal revealed tiles.
- Layered levels now start with a controlled mix of back tiles and face-up tiles; not every blocked tile is hidden.
- Back-tile coverage scales by level difficulty so later levels can introduce more memory pressure.
- Free covered tiles are tappable, flip face-up, and become selected immediately.
- Deselecting a peeked tile returns it face-down.
- Wrong matches return unmatched peeked tiles face-down after mismatch feedback.
- Correct matches remove matched peeked tiles without flipping them back.
- Added a quick 3D flip transition when tile visibility changes between back and face.

### Scope

- Add a flip animation to `TileWidget` or a dedicated wrapper.
- On first tap of an eligible covered tile:
  - play tap haptic/audio,
  - animate from back artwork to face artwork,
  - mark the tile as temporarily face-up,
  - select it immediately for matching.
- If the same peeked tile is tapped again to deselect it, flip it back to the back artwork.
- If a wrong pair is selected, show the mismatch feedback, then flip unmatched peeked tiles back to the back artwork.
- If a correct pair is selected, remove the matched tiles without flipping them back.

### Recommended Interaction

Use a one-tap peek-and-select interaction:

```text
Tap eligible back tile
  -> flip face-up
  -> tile is selected

Tap matching eligible tile
  -> if correct: matched tiles are removed
  -> if wrong: mismatch feedback, then unmatched peeked tile(s) flip back face-down
```

This makes back tiles feel like a memory mechanic instead of a permanent reveal.

### Acceptance Criteria

- Flip animation is smooth.
- A face-down back tile cannot be matched until tapped.
- First tap on an eligible back tile reveals and selects it.
- Deselecting a peeked tile returns it to the back.
- Wrong matches return unmatched peeked tiles to the back after mismatch feedback.
- Correct matches remove the matched tiles.
- Peeked state is not treated as a permanent collection/progression unlock.

---

## Phase 4 — Peek-Aware Gameplay Logic

**Status:** Not Started

### Scope

- Decide which level tiles start as normal face-up tiles and which start as back/peek tiles.
- Keep traditional Mahjong availability rules: a tile must still be free before it can be tapped.
- Make hint behavior understandable with back tiles.
- Make shuffle preserve face-down/peek identity where appropriate.
- Make stuck detection avoid declaring a board lost just because possible pairs are still face-down.
- Add tests for correct match, wrong match, deselect, hint, shuffle, and no-move scenarios.

### Recommended Rules

- Free face-up tiles are selectable normally.
- Free back tiles are tappable, flip face-up, and become selected.
- Blocked back tiles remain face-down and untappable until free.
- Blocked face-up tiles can show their face but remain untappable.
- Hints should prefer currently face-up available pairs. If none exist, hint may highlight eligible back tiles as a clue without exposing their faces permanently.
- Shuffle should keep whether each unmatched tile is face-up or back-facing unless a level rule explicitly resets all peeks.
- Stuck detection should consider that unrevealed eligible back tiles may contain possible matches, so the level should not fail while peekable back tiles remain.

### Acceptance Criteria

- Current normal face-up gameplay still works.
- Peek tiles do not break solvability.
- Wrong peeked pairs hide again.
- Correct peeked pairs match and clear.
- Boosters/hints do not permanently reveal back tiles unless explicitly designed to do so.

---

## Phase 5 — Board Layout Polish

**Status:** Not Started

### Scope

- Tune board rendering so stacked layers feel closer to the reference image.
- Covered tiles should create visual mystery without making the board unreadable.
- Keep touch targets comfortable on small phones.
- Verify overlapping tiles do not block important controls.

### Acceptance Criteria

- Boards feel layered and dimensional.
- Back tiles are visually distinct from face tiles.
- UI remains readable on common mobile sizes.
- No tile text or images clip awkwardly.

---

## Phase 6 — 100-Level Campaign Expansion

**Status:** Not Started

### Scope

- Expand `kLevels` from 50 to at least 100 levels.
- Reuse existing layout patterns where appropriate.
- Add new layout variants only when needed to avoid repetition.
- Preserve chapter pacing and unlock requirements.
- Update final-level logic that currently assumes level 50.

### Areas To Check

- `lib/core/constants/level_data.dart`
- `lib/core/constants/chapter_data.dart`
- Home continue logic
- Result screen next-level logic
- Chapter-complete routing
- Developer level tester
- Tests that assume 50 levels
- Docs that mention 50 levels

### Acceptance Criteria

- At least 100 campaign levels are playable.
- The app does not treat level 50 as the final campaign level.
- Chapter milestones are updated for the larger campaign.
- Developer level tester can launch the new levels.

---

## Phase 7 — Progressive Tile Unlock Rules

**Status:** Not Started

### Scope

- Define when each new Adinkra tile unlocks.
- Early levels should use fewer symbols.
- Later levels should introduce new symbols gradually.
- Unlock rules should be deterministic and easy to test.

### Suggested Unlock Pattern

```text
Levels 1-10: starter symbols
Levels 11-50: steady symbol unlocks
Levels 51-100: advanced and rarer symbols
Milestone levels: guaranteed special unlocks
```

### Acceptance Criteria

- Every unlock has a level requirement.
- Unlocks are saved persistently.
- Replaying old levels does not duplicate unlock rewards.
- Unlock logic is covered by tests.

---

## Phase 8 — Collection Integration

**Status:** Not Started

### Scope

- Ensure the Tile Collection only shows full details for unlocked symbols.
- Locked symbols can show silhouettes, backs, or mystery states.
- Newly unlocked symbols should become visible immediately after the level result is saved.

### Acceptance Criteria

- Collection reflects current progress.
- New unlocks appear without needing an app restart.
- Locked and unlocked states are visually clear.

---

## Phase 9 — Unlock Popup After Level

**Status:** Not Started

### Scope

After a level win, if the player unlocked a new tile:

- Show a popup or reveal card.
- Include tile image.
- Include tile name.
- Include short meaning/cultural information.
- Include a clear continue action.

### Recommended Flow

```text
Win level
  -> Result rewards calculate
  -> New tile unlock detected
  -> Unlock popup appears
  -> Player taps Continue
  -> Normal result actions continue
```

### Acceptance Criteria

- Popup appears only for new unlocks.
- Popup does not repeat for already claimed unlocks.
- Popup works before continuing to next level or chapter-complete screen.
- Accessibility labels identify the tile and meaning.

---

## Phase 10 — Balance, QA, and Documentation

**Status:** Not Started

### Scope

- Verify 100-level difficulty curve.
- Verify unlock pacing feels rewarding.
- Verify tile-back reveal mechanic does not make levels too slow or confusing.
- Update project docs that mention 50 levels or old tile-back behavior.
- Add final implementation report.

### Acceptance Criteria

- `flutter analyze` passes.
- `flutter test` passes.
- Key manual flows are verified:
  - new game
  - peek back tile
  - deselect peeked tile and see it return face-down
  - wrong match returns peeked tiles face-down
  - correct peeked match clears matched tiles
  - win level
  - unlock tile
  - view popup
  - see tile in collection
  - continue beyond level 50
  - complete level 100

---

## Open Questions

1. Should every tile start as a back tile, or should each level mix face-up normal tiles with back/peek tiles?
2. Should hints reveal the face of a back tile temporarily, or only point at back tiles that are worth peeking?
3. Should tile unlock popups appear on the result screen itself or before the result screen?
4. Should chapter milestones be every 10 levels, every 20 levels, or themed groups with uneven lengths?
5. Should locked collection entries show the new back tile image or a dimmed silhouette of the face tile?

---

## Current Next Step

Start with Phase 4:

```text
Tune hints, shuffle, stuck detection, and boosters around temporary peek tiles.
```
