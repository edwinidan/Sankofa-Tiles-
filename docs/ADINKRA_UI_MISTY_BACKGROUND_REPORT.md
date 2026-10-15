# Home background replacement — Misty Emerald Monument Courtyard

15 October 2026. Scope: replace Home scenery and correct bottom-navigation label wrapping. Other screens, gameplay, saves, billing simulation, ads and Firebase remain unchanged.

## Asset

Found `images for new home screen/png images for new homescreen /Misty Emerald Monument Courtyard.png` (the directory has a trailing space). Visually inspected before use.

- PNG, opaque RGB, **941 × 1672 pixels**.
- **1,940,989 bytes / 1.85 MiB** on disk, about 24% smaller than the previous background.
- Copied unchanged to `assets/menu/misty_emerald_monument_courtyard.png`; hashes verified identical.
- Already covered by the existing `assets/menu/` registration. No pubspec or dependency change was needed in this task.
- Approximately **6.00 MiB** as decoded RGBA pixels, matching the previous background's resolution/memory footprint. Normal Flutter image caching is retained.
- The source and previous `assets/menu/home_environment.png` remain in the project.

## Files changed in this task

| File | Change |
|---|---|
| `lib/screens/home/home_screen.dart` | Changed `HomeArtwork.environment` to the new asset. |
| `lib/widgets/game_menu_components.dart` | Consistent 14-point navigation labels using the theme's label font, zero added letter spacing, single-line text; measure labels before choosing a horizontal or stacked group. Equal widths and padding remain consistent. |
| `test/home_redesign_test.dart` | Reproduce the wider inherited button styling; assert each destination label has one text line and fits within its render width. Existing interaction and layout tests retained. |
| `assets/menu/misty_emerald_monument_courtyard.png` | New runtime asset. |
| `output/misty-home/*.png` | New rendered review captures, preserving earlier bright-background screenshots. |
| `docs/ADINKRA_UI_MISTY_BACKGROUND_REPORT.md` | This report. |

Other changes already present in the working tree belong to earlier redesign stages.

## Layout and appearance

Retained `BoxFit.cover` and `Alignment.topCenter` after inspecting the image and rendered Home. The image fills the background with no stretching, empty bands, blur or color overlay. Interactive content retains existing safe areas. Cover fitting on taller screens crops peripheral foliage; the central architectural region stays inside the image bounds.

Logo, Cowries, top actions, medallion, Continue/Resume, saved-level details and bottom destinations retain their existing placement and callbacks. Controls remain readable against the emerald image with the established gold/cream contrast. The primary button's existing muted amber treatment is unchanged.

The centered distant monument is largely occluded by the existing medallion. This is overlap with preserved UI, not loss of the central monument to background cropping. Its upper outline is visible in the compact render. Fully exposing it would require repositioning the composition or different artwork; neither was introduced in this background-only task.

Daily, Journey and Collection fit on a single line in all tested configurations. Normal mobile sizes retain three equally sized buttons in a row. When enlarged text or font metrics cannot fit a row, the existing stacked layout is selected using actual label measurements rather than assuming a fixed minimum width. Text is not shrunk below 14 points or ellipsized.

## Validation

- `flutter analyze --no-pub`: **no issues found**.
- **142 selected tests passed**, including the 15 Home tests, six shared-component tests and existing startup, entry flow, save/undo, progression, economy, monetization, ad UX, collection migration/unlocks, retention, release configuration and campaign-boundary tests used in the previous Home stage.
- Home tests verify Continue, saved-board Resume and its launch flag, alternate-level launch without deleting the save, Daily, Journey, Collection, Shop, Settings, progress details and tutorial access.
- Rendered and opened actual Flutter Home captures at **320 × 568**, **390 × 844**, **430 × 932**, plus **320 × 568 at 2× text** and a saved-board state. No layout-overflow exceptions. Scroll reachability remains tested for large text.
- Captures are in `output/misty-home/`: `compact.png`, `standard.png`, `tall.png`, `large-text.png`, `resume.png`.
- The rendering harness checks artwork decoding, simulates safe-area insets and uses 2× image output. It uses local Arial for readable review text, not a physical device or the exact production font rendering. The normal app retains its existing fonts; the navigation label explicitly uses the theme's label font rather than the wider inherited button font.
- Runtime/source asset equality, existing asset-directory registration and retention of the old background verified. No new packages.

Render command:

```sh
flutter test --no-pub test/home_redesign_test.dart \
  --dart-define=HOME_PREVIEW_DIR=output/misty-home \
  --dart-define=HOME_PREVIEW_FONT=/System/Library/Fonts/Supplemental/Arial.ttf \
  --reporter expanded
```

No emulator/physical-device visual run or live advertising/billing/Firebase service test was performed. The only remaining visual limitation observed is monument overlap behind the unchanged centerpiece; enlarged text intentionally requires scrolling.
