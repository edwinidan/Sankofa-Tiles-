# Home UI polish — Phase 2

15 October 2026. Refines the existing Misty Emerald Home and shared menu controls. No artwork was replaced or edited; no other screen layouts, gameplay, economy, saves, unlocks, ads, billing, Firebase or release configuration changed.

## Files modified in this stage

- `lib/core/theme/game_menu_theme.dart`: muted primary surface/border, restrained depth and corner radii.
- `lib/widgets/game_menu_components.dart`: smaller primary/navigation typography and padding, consistent navigation heights, compact header surfaces with preserved touch targets.
- `lib/screens/home/home_screen.dart`: proportional spacing, slightly smaller medallion, background crop/alignment.
- `test/home_redesign_test.dart`: sizing, touch targets, left-aligned play icon, safe-area, large-balance and notched-viewport coverage; opt-in before/after measurement logging.
- `docs/ADINKRA_UI_HOME_POLISH_PHASE_2_REPORT.md`: this report.
- `output/home-polish-before/*.png` and `output/home-polish/*.png`: rendered review artifacts. The earlier preview folders remain intact.

Other working-tree changes predate this stage. No dependencies, manifest entries or source image files were changed.

## Inspection and causes

The earlier primary combined 20/24-point text with 14 pixels of top/bottom padding; the navigation combined 26-pixel icons, a 6-pixel icon gap and the same vertical padding. Both inherited broad rounded shapes. The logo-to-medallion gap grew to 10% of available height on larger phones, while the primary-to-navigation gap remained 12 pixels. The header surfaces were also larger than necessary.

The existing full-screen background sits outside SafeArea; interactive content stays in SafeArea, within a scroll view and a 560-pixel maximum content width. This structure is retained. All existing providers, routes and saved-board launch extras remain unchanged.

## Measured before and after

Logical-pixel widget dimensions from the actual Flutter review harness, at 1× text. These measurements use local Arial, so production font rasterization may differ slightly. Control minimums and responsive constraints apply with the app's existing fonts as well.

| Viewport | Continue before → after | Each bottom button before → after |
|---|---|---|
| 320 × 568 | 248 × 79 → **248 × 64** | 88 × 80 → **88 × 65** |
| 390 × 844 | 318 × 79 → **318 × 64** | 111.3 × 80 → **111.3 × 65** |
| 430 × 932 | 358 × 79 → **358 × 64** | 124.7 × 80 → **124.7 × 65** |

Continue height decreases **19%**; bottom button height decreases **18.75%**. Navigation widths remain responsive and equal; heights are identical across Daily, Journey and Collection. At 2× text the buttons grow and navigation stacks rather than clipping: primary **169 → 103** pixels tall; each bottom button **100 → 82** pixels tall in the review font.

### Primary action

- Surface `#E6A62E` → muted antique gold **`#C5A05A`**.
- Thin 1.5-pixel dark-gold edge **`#795D32`**.
- Elevation 2 → 1; radius 32 → 28.
- Text 20/24 → **16/20 points**, with explicit 1.15 line height and two separate dynamic labels (Continue/Resume and Level).
- Vertical padding 14 → 10 per side; normal minimum height 64, allowed to grow for accessibility.
- Play icon 32 → 28, gap 12 → 10; icon remains left of the text, including large text.

### Bottom navigation

- Icons 26 → **24** pixels, icon-label gap 6 → 4, vertical padding 14 → 10 per side.
- Shared 14-point, weight-600 labels now have an explicit 1.2 line height. Each stays on one line.
- Radius 32 → **24**, elevation 2 → **0**; emerald fill and thin gold outline retained.
- Existing font measurement selects equal-width horizontal buttons when they fit and stacked controls when needed. No label shrinking, ellipsis or sub-48-pixel touch targets.

### Header

- Circular visual outline **48 → 40** pixels; actual labelled/tooltip button target remains **48 × 48**.
- Icons use consistent **22** pixels; all original icons/callbacks retained.
- Cowrie surface normally **49 → 40** pixels tall, padding 14/10 → **10 horizontal / 6 vertical**; shell 26 → 22 and shell-label gap 8 → 6.
- Amount typography 16 → **15** points, with zero added letter spacing. Large balances remain dynamic and can grow the wallet vertically rather than clipping; the full balance remains announced in semantics.
- Control gaps **8 → 6** pixels. The wallet gains six pixels of available width: at 320-pixel viewport, **120 → 126**; at 390, **190 → 196**. No tap area was reduced to obtain this space.

## Spacing, artwork and background

Available content height still excludes safe areas and layout padding. Gaps are derived from that height, with compact bounds:

| Gap | Before | After |
|---|---|---|
| Header to logo | 12 px | 1.2%, bounded 6–10 px |
| Logo to medallion | 5% compact / 10% larger, bounded 18–85 px | **2.5% compact / 3.5% larger**, bounded 10–28 px |
| Medallion to primary | 12 px | **2.5%**, bounded 12–20 px |
| Primary/details to navigation | 12 px | **4.5%**, bounded 20–36 px |

The logo is unchanged. The decorative medallion keeps its aspect ratio, gold rim and behavior. Its image-frame size changes from 25% → **24%** of available height on compact layouts and 29% → **27%** on larger layouts; the maximum changes 250 → 230 pixels. No added glow or engraving.

The same Misty Emerald image is still cover-fitted, now **bottom-center aligned with a clipped uniform 1.28× scale around the bottom-center**. The crop raises the arch's star/upper silhouette into the logo-medallion interval. Compact, larger and notched renders were inspected before accepting this crop. It trims peripheral foliage; the distant central monument remains inside the image bounds. No image stretching, color overlay, new architecture or brightness change. This is a visual crop of the existing layer, not an edit to the image asset.

## Assets retained

| Existing asset | Dimensions |
|---|---|
| `assets/menu/misty_emerald_monument_courtyard.png` | 941 × 1672 |
| `assets/menu/adinkra_tiles_logo.png` | 1448 × 1086, transparent |
| `assets/menu/wooden_medallion.png` | 1254 × 1254, transparent |

Existing Cowrie artwork also retained. No asset loading or package configuration changes were required.

## Validation and previews

- `flutter analyze --no-pub`: **no issues found**.
- **144 selected widget/regression tests passed**: 17 Home tests, six component tests, plus the existing startup, entry flow, saved-board/undo, progression, journey, economy, monetization/ad UX, collection migration/unlock, retention, release and campaign-boundary coverage used in the preceding stage.
- Continue, Resume with the saved launch flag, alternate-level launch, Daily, Journey, Collection, Shop, Settings, tutorial and progress-detail access verified by tests.
- Tests assert equal navigation heights, one-line/unclipped labels, touch targets ≥48, play icon left of the text, safe-area positioning and ≥20-pixel separation before navigation.
- Rendered and opened Home at **320 × 568**, **390 × 844**, **430 × 932**, **393 × 852 with 59/34-pixel top/bottom safe insets**, and **320 × 568 with 2× text**. Also captured saved-board Resume and a nine-digit balance. No RenderFlex overflow detected; scroll reachability retained at large text.

Final captures:

```text
output/home-polish/compact.png
output/home-polish/standard.png
output/home-polish/tall.png
output/home-polish/notched.png
output/home-polish/large-text.png
output/home-polish/large-balance.png
output/home-polish/resume.png
```

Before-polish captures and measured dimensions are preserved in `output/home-polish-before/`. The test harness uses 2× pixel output and local Arial for review; this is actual Flutter widget rendering, not a device/simulator run or exact production Cinzel/Nunito typography verification. Normal tests do not require the font path or write PNGs.

```sh
flutter test --no-pub test/home_redesign_test.dart \
  --dart-define=HOME_PREVIEW_DIR=output/home-polish \
  --dart-define=HOME_PREVIEW_FONT=/System/Library/Fonts/Supplemental/Arial.ttf \
  --dart-define=HOME_MEASUREMENTS=true \
  --reporter expanded
```

## Remaining visual limits

The medallion continues to overlap the lower monument, while the upper silhouette is now visible in the reviewed normal-text layouts. Very large balances may wrap on narrow/large-text layouts, preserving all digits and semantics; nothing is abbreviated or clipped. Accessibility text and saved-game details may require scrolling. A device pass with the app's actual fonts remains recommended before release. No other screen redesign was performed.
