# App Entry Experience — Interactive Mahjong-Inspired Intro

## Overview

Replace the static startup/onboarding flow with a tactile, animated, mahjong-tile-driven experience. The goal: make opening the app feel like walking up to a real mahjong table — tiles are physical, responsive, and invite touch.

Two distinct flows: one for **first-time users** (discovery + onboarding) and one for **returning users** (fast, beautiful, skippable).

---

## Visual Language

- Tiles have **weight and depth** — 3D-ish shadows, slight rotation on drag, satisfying snap on release
- **Parchment-and-gold palette** matches the existing `SankofaGameTheme` (dark green background, antique gold borders, warm parchment tile faces)
- Adinkra symbols rendered prominently on each tile face
- Subtle particle effects: floating dust motes in light beams, like an old archive
- Sound design: tile click, match chime, page-rustle ambience

---

## Flow A — First-Time User (Onboarding)

### Phase 1: The Archive Reveal (2–3 seconds, unskippable)

1. Screen starts **dark**.
2. A single beam of warm light fades in from top-center, illuminating a **stack of mahjong tiles** face-down in the middle of the screen.
3. Tiles are slightly scattered — some tilted, some overlapping — as if an archivist just left them.
4. Camera pushes in slowly; tiles cast long shadows across a dark wood surface.

### Phase 2: The First Touch (interactive prompt)

1. Text fades in below the stack: **"Tap a tile to begin."**
2. The top tile pulses gently (golden glow) to draw attention.
3. On **tap**: the tapped tile flips over with a 3D card-flip animation, revealing its Adinkra symbol.
4. A subtle particle burst (golden sparkles) radiates from the flipped tile.
5. The tile then slides upward and scales down into a "collected" row at the top of the screen.

### Phase 3: Symbol Discovery (interactive, 5 tiles)

1. More face-down tiles cascade onto the table (staggered animation, like dealing cards).
2. Text updates: **"Discover the symbols. Tap matching pairs."**
3. The tiles are laid out in a mini 3×4 grid (12 tiles, 6 matching pairs).
4. Player taps one tile → it flips and stays face-up.
5. Player taps a second tile:
   - **Match**: both tiles glow, pulse, then slide off together to the collected row. Small score counter increments.
   - **No match**: both tiles shake gently, then flip back face-down after a beat.
6. After all 6 pairs are matched, a brief celebration animation plays (tiles orbit in a circle, then form the app logo).
7. Text: **"You're ready. This is Adinkra Tiles."**

### Phase 4: Name & Preferences (optional, lightweight)

1. A single parchment card slides up with:
   - Optional display name field
   - Sound on/off toggle
   - "Start Journey" button
2. Everything skippable — a "Skip" link at top-right always visible.
3. On completion → route to `/tutorial` (existing flow).

---

## Flow B — Returning User (Splash → Home)

### Phase 1: The Table (1.5 seconds, skippable on tap)

1. Screen fades in to a **top-down view of a mahjong table** with tiles arranged in the shape of the app logo or a simple pattern.
2. Tiles are already face-up, showing Adinkra symbols the player has already unlocked/seen.
3. A subtle ambient animation: tiles hover slightly, shifting up/down by 1–2px with staggered timing (breathing effect).
4. The logo text "Adinkra Tiles" fades in over the table, warm gold.

### Phase 2: Quick Transition

1. On **any tap** or after 1.5s: tiles scatter outward in a radial burst (each tile flies to a random edge with rotation).
2. The table fades to the home screen background.
3. Home screen content fades in.

### Returning User Variant: "Welcome Back" Streak

- If the player is on a daily streak (logged in within the last 24h), a small tile flips in from the right showing: **"Day 5 — Keep the streak alive!"** before the home screen loads.
- If the player missed a day, skip the streak tile.

---

## Tile Interaction Details

### Flip Animation
- 3D perspective transform (not just a scaleX tween).
- Duration: 400ms, ease-out.
- The tile lifts slightly (translateZ feel via scale + shadow darkening) at the midpoint.
- On reveal: a soft golden rim-light sweeps across the tile face.

### Match Effect
- Both matched tiles pulse white-gold.
- Particle burst: 8–12 small diamond/sparkle particles arc outward and fade.
- Tiles shrink slightly then snap back with a bounce (spring physics).
- After 300ms, tiles slide together to the collected position.

### No-Match Feedback
- Both tiles shake horizontally (3 oscillations, 200ms, decaying amplitude).
- A subtle "thud" haptic.
- After 400ms pause, tiles flip back face-down.

### Stacking / Layering
- Tiles in a stack cast shadows on tiles below them.
- When the top tile lifts (on tap), shadows adjust in real time.
- Uses `tileShadowsForLayer(layer)` from `SankofaGameTheme` — already built.

---

## Technical Architecture

### New Widgets

| Widget | Purpose |
|---|---|
| `EntryFlowDirector` | Top-level widget that decides Flow A vs Flow B based on `storage.isOnboardingComplete()` |
| `AnimatedMahjongTile` | Core tile widget with flip, shake, glow, and particle states |
| `TileStack` | Renders a scattered stack of overlapping tiles |
| `TileGrid` | Renders an interactive grid for the symbol discovery mini-game |
| `ArchiveSplashScene` | The cinematic intro with light beam, camera push, and tile stack |
| `ReturningSplashScene` | The top-down table view with breathing tiles and scatter transition |
| `StreakTile` | Small animated tile showing daily streak count |

### State Management

- Use Riverpod providers scoped to the entry flow (not global).
- `entryFlowProvider` — holds current phase, tile states, discovery game progress.
- Dispose all providers when the entry flow completes.

### Routing

- The entry flow sits **before** the GoRouter in the widget tree — it's a full-screen overlay, not a route.
- After the flow completes, the `AppBootstrapper` proceeds to `SankofaTilesApp` as it does today.
- This avoids polluting the navigation stack with entry screens.

### Asset Requirements

| Asset | Description |
|---|---|
| `light_beam.png` | Soft god-ray overlay for the archive scene |
| `particle_sparkle.png` | Small diamond sparkle for match effects |
| `wood_table_bg.png` | Dark wood table texture (or generate via shader) |
| `dust_mote.png` | Tiny soft dot for floating dust particles |
| Tile symbol images | Already exist — used on tile faces |

### Performance Notes

- Particle systems should use `CustomPainter` or a lightweight sprite batching approach, not full widget trees per particle.
- Tile flip uses `Transform` with a `Matrix4` perspective — avoid `AnimatedContainer`/`AnimatedSwitcher` for this specific animation.
- The entire entry flow is torn down after completion — no memory retained.

---

## Accessibility & Preferences

- **Reduced motion**: When `MediaQuery.of(context).disableAnimations` is true, skip all cinematic animations. Tile grid still works but flips are instant, no particles, no breathing effect.
- **Skip always available**: Both flows show a "Skip" affordance. Tapping it tears down the entry flow immediately and proceeds to the appropriate destination (tutorial for new users, home for returning).
- **Screen reader**: Tile states announced via `Semantics` — "Gye Nyame tile, face down, tap to reveal" / "Match found, Gye Nyame and Sankofa."
- Remember the user's skip preference: if they skip the returning splash 3+ times, stop showing Phase 1 and go directly to home.

---

## Success Metrics

- **Onboarding completion rate**: % of new users who finish the tile discovery game vs. skip
- **Time to home**: returning users should reach the home screen in <2s (including skippable splash)
- **Tutorial engagement**: did the interactive tile intro improve tutorial completion? (A/B test against static onboarding)
- **Day-1 retention**: does the cinematic entry improve return rate?

---

## Implementation Phases

### Phase 1 — Core Tile Widget
- Build `AnimatedMahjongTile` with flip, shake, glow states.
- Integrate with existing `SankofaGameTheme` tile shadows.
- Unit test all animation states.

### Phase 2 — Returning User Splash
- Build `ReturningSplashScene` with breathing tiles and scatter transition.
- Wire into `AppBootstrapper`.
- This ships first because it touches every session.

### Phase 3 — First-Time Archive + Discovery Game
- Build `ArchiveSplashScene` (light beam, tile stack, first tap).
- Build `TileGrid` with match/no-match logic.
- Build name/preferences card.
- Wire into `AppBootstrapper` for first-launch path.

### Phase 4 — Polish
- Sound design integration.
- Particle system optimization.
- Accessibility pass (reduced motion, screen reader).
- Skip-preference tracking.
