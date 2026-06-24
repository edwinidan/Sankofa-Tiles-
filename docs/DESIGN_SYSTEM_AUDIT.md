# Design System Audit

## Primary Visual Identity

The current game identity is defined mainly in `SankofaGameTheme`:

- Dark green backgrounds: `backgroundTop`, `backgroundMiddle`, `backgroundBottom`.
- Antique gold accent: `antiqueGold`, `mutedGold`.
- Cream/parchment surfaces: `parchment`, `appParchment`, `parchmentLight`.
- Dark panel surfaces for board and level cards.
- Shared gradients and panel decorations.

Typography is split between `AppTextStyles` and app-specific uses of archive/display/body styles.

## Screens Using SankofaGameTheme

Home, onboarding, settings, game, result, developer level tester, router error page, and most reusable widgets use `SankofaGameTheme` for primary surfaces and text colors.

## Legacy or Inconsistent AppColors Usage

`AppColors` still appears in:

- `lib/screens/settings/settings_screen.dart` reset dialog border/action colors.
- `lib/screens/game/game_screen.dart` game settings bottom sheet background, border, drag handle, and some sheet icon colors.
- Potential older game widgets that still import `AppColors`.

The most visible mismatch before Phase 1 is the in-game settings sheet, which uses navy/panel colors while the surrounding game uses the green/gold/parchment theme.

## Shared Components Present

- `KenteButton` gives a branded button pattern.
- `SankofaBackground` provides the dark image-backed background.
- `AdinkraDivider` provides decorative section separation.
- `SankofaGameTheme` provides reusable panel decorations.

## Shared Components Missing or Incomplete

- No central startup/loading/error component before Phase 1.
- No general game scaffold for non-game screens.
- No central route transition helpers.
- No shared modal/dialog style helper.
- No currency badge yet; that belongs to later phases as a placeholder only.

## Native Splash and Icons

Android already has a dark launch background color (`#101A16`) and launch logo drawables for both pre-Android-12 and Android 12+ splash APIs. iOS still has a white LaunchScreen storyboard background. Web manifest colors still use default Flutter blue.

App icons exist for Android mipmaps, iOS app icon set, macOS icon set, and web icons. The source assets include Adinkra Tiles logo/splash images.

## Assets

Existing asset folders:

- `assets/audio/` contains SFX and background music.
- `assets/lottie/` contains only `README.md`; no animations are present.
- `assets/images/` contains only `README.md`; image assets currently live mostly at the root of `assets/`.
- Tile artwork exists across several `assets/Tile...` folders.
- `assets/tiles/tile_back.svg` and custom tile-back widgets exist.

## Accessibility Notes

Current strengths:

- Many icon buttons include tooltips.
- Switches and sliders use platform controls.
- Most primary buttons are text-labeled.

Current gaps:

- Major navigation buttons do not consistently have explicit `Semantics` labels.
- Custom gesture targets such as haptic segmented controls should be reviewed for minimum 48x48 touch targets.
- Tile board semantics are limited and should be improved in later gameplay phases.
- Motion does not consistently check reduced-motion preferences.
- Text scaling behavior is partially handled through scroll views but not audited screen by screen.

