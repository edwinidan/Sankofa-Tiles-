# Adinkra Tiles — Home implementation

15 October 2026. Implements the approved visual foundation and Home stage. The three requested clean PNG layers were supplied in `images for new home screen/png images for new homescreen /` and visually reviewed before implementation. This supersedes the artwork blocker in the earlier foundation report.

## Delivered

Home now uses separate architectural scenery, transparent stacked logo and decorative wooden medallion, composed with real Flutter controls. No flattened UI screenshot is used as a screen or a hit-target layer.

- Real Cowries balance at the top, alongside progress details, existing Shop and Settings access.
- Gold Continue button with the actual next unfinished level; saved boards show Resume and their saved level, remaining tiles and separate Start another level action.
- Continue retains the existing pre-level route; Resume retains `GameLaunchConfig(resumeSavedGame: true)` and normal progression mode.
- Emerald Daily, Journey and Collection buttons retain their existing destinations and collection/settings analytics calls.
- Progress, chapter, stars, Hint/Shuffle/Open Path inventory and the next collection unlock remain available through the top progress control. This avoids reinstating the previous dashboard-card stack on Home. The progress sheet reuses the existing next-unlock widget; its styling is intentionally retained for this stage.
- Early tutorial access and the gated developer symbol-reveal preview remain available. Completed campaign state reports completion without offering Level 281.
- The medallion remains decorative and excluded from accessibility navigation. The logo announces the product name; controls have labels and the wallet announces the full balance.
- Safe areas, bounded width and scrolling support compact screens and large text. At compact widths the wallet displays its shell and amount, with the full currency name retained in semantics. At large text sizes the play icon and navigation stack vertically.

The actual 280 levels, 14 chapters and 97 symbols remain unchanged. No changes to gameplay, save schema, progression, scoring, economy, ads, Firebase, platform identity, signing or billing simulation. No unsupported profiles, tasks, social links, cloud save or purchase restoration controls were added. Settings, Journey, Collection, Shop and splash were not redesigned.

## Files

| File | Change |
|---|---|
| `lib/screens/home/home_screen.dart` | Replaced the dashboard-style Home presentation with the layered scenic layout; added progress-detail sheet using existing data. |
| `lib/widgets/game_menu_components.dart` | Integrated the foundation widgets; extended primary action with optional level detail and large-text stacking; added compact currency-label option. |
| `lib/core/theme/game_menu_theme.dart` | Existing new foundation tokens reused; kept the global/gameplay theme separate. |
| `pubspec.yaml` | Registered only `assets/menu/`; no dependency/platform changes. |
| `assets/menu/home_environment.png` | Runtime copy of supplied clean architectural environment. |
| `assets/menu/adinkra_tiles_logo.png` | Runtime copy of supplied transparent stacked logo. |
| `assets/menu/wooden_medallion.png` | Runtime copy of supplied transparent medallion. |
| `test/home_redesign_test.dart` | 15 focused layout, artwork decode, navigation, Continue/Resume, completion and retained-feature tests; opt-in screenshots. |
| `test/phase2_flow_test.dart` | Updated the next-level assertion to the new dynamic `LEVEL 2` text; retained its Continue assertion. |
| `output/home-redesign/*.png` | Actual Flutter-rendered Home review captures. |
| `docs/ADINKRA_UI_VISUAL_FOUNDATION_REPORT.md` | Added pointer to this subsequent completed Home stage. |

The earlier foundation test and audit files remain in the working tree. No new dependencies were added. The source PNGs are preserved unchanged; the runtime copies have shorter stable names.

## Assets

| Runtime asset | Supplied source filename | Dimensions / mode | File size |
|---|---|---|---|
| `home_environment.png` | `Clean portrait architectural environment without UI..png` | 941 × 1672, opaque RGB | 2,549,905 bytes |
| `adinkra_tiles_logo.png` | `Transparent stacked Adinkra Tiles logo..png` | 1448 × 1086, RGBA | 1,758,137 bytes |
| `wooden_medallion.png` | `1. Transparent wooden medallion with a validated symbol..png` | 1254 × 1254, RGBA | 1,730,872 bytes |

The existing registered Cowrie asset is reused through `CowrieIcon`. The medallion is used as supplied decorative art; collectible identities/artwork and unlock metadata remain authoritative in the existing collection system. No generated mockup symbol replaces a collectible.

Artwork retains its aspect ratio and uses Flutter's image cache. Original-resolution decoding preserves the supplied transparent edges; the three images total approximately 18 MiB of decoded RGBA pixels. There are no additional continuous background animations or decorative glow effects.

## Visual verification and differences

Actually rendered Home using Flutter widget tests at:

| Capture | Logical viewport | Text scale | Notes |
|---|---|---|---|
| `compact.png` | 320 × 568 | 1× | Main action and three bottom destinations fit the returning-player viewport. Wallet uses shell + amount. |
| `standard.png` | 390 × 844 | 1× | Full scenic composition, logo, medallion, live-value fixture, primary action and navigation. |
| `tall.png` | 430 × 932 | 1× | Tall portrait composition checked. |
| `large-text.png` | 320 × 568 | 2× | Primary label stays readable; navigation stacks below and remains scroll-reachable. |
| `resume.png` | 390 × 844 | 1× | Saved-board Resume Level 7, remaining tiles and alternate-level action. Extra saved-game details can require scrolling to the bottom destinations. |

All five final captures were opened and visually checked against the supplied home reference. The harness waits for the exact image providers and asserts decoded images before capture. Captures use a simulated 2× device pixel ratio and safe-area insets of 24 top / 20 bottom.

No overflow exceptions occurred in the tested scenarios. The tests verify that Collection can be scrolled into view. Scrolling at large text sizes is intentional. No emulator or physical-device visual test was performed.

Known differences from the reference:

- Widget controls use simpler flat emerald/gold fills, thinner outlines, standard Material icon shapes and dark text on the primary gold surface. No engraved end caps, ornamental panels or added glow.
- Provided artwork retains its baked metallic relief. The supplied medallion is a smooth disc, rather than the mockup's two-panel wooden door.
- Cover-fitting the portrait environment crops side scenery on taller aspect ratios: the statue's raised arm and lighthouse edge can be partially outside the viewport. The logo, medallion and all functional controls remain contained and undistorted. A wider scenic export would preserve more peripheral architecture on tall phones.
- Layout proportions adapt to mobile height instead of tracking screenshot coordinates. The compact medallion/logo are smaller to keep controls usable.
- Unsupported profile and Task controls are omitted. Progress details replace the redundant map-like top action; Journey appears once in bottom navigation. Shop and Settings retain existing routes.
- The new-player tutorial and saved-game details are retained even though absent from the mockup.
- PNG tests use local Arial in their test theme for readable, deterministic review. The app retains its existing Cinzel/Nunito theme; these captures do not verify the exact final app typography, font loading or device rasterization.
- Screenshot balance/level values come from isolated test storage, not hardcoded application values.

## Tests

`flutter analyze --no-pub`: no issues found.

The selected combined run passed **142 tests** across:

```text
game_menu_components_test.dart
home_redesign_test.dart
app_startup_test.dart
entry_flow_test.dart
player_convenience_test.dart
progression_flow_test.dart
journey_city_progression_test.dart
economy_service_test.dart
monetization_service_test.dart
ad_monetization_ux_test.dart
collection_migration_test.dart
tile_collection_integration_test.dart
tile_unlock_rules_test.dart
retention_flow_test.dart
release_readiness_test.dart
phase2_flow_test.dart
levels_201_240_production_flow_test.dart
levels_241_280_production_flow_test.dart
```

Home-specific tests verify real next-level routing, the saved-board launch flag and score retention, alternate-level routing without deleting the saved board, all five menu destinations, progress/booster/unlock information, early tutorial replay and campaign completion. Existing tests cover storage round-trips, migrations and reward idempotency. Live billing, live ads, remote services and a physical app restart were not exercised.

To regenerate the Home captures on this Mac:

```sh
flutter test --no-pub test/home_redesign_test.dart \
  --dart-define=HOME_PREVIEW_DIR=output/home-redesign \
  --dart-define=HOME_PREVIEW_FONT=/System/Library/Fonts/Supplemental/Arial.ttf \
  --reporter expanded
```

The flags are optional; ordinary test runs do not depend on that system-font file or write screenshots. No tests access or reset real player storage.

## Remaining work

No essential Home artwork is missing. A wider environment export is optional for reducing side cropping. Recommend a device/simulator pass with the app's actual typography, status bar and gesture area before release. Stop here as requested; any Settings/Journey/Collection/Shop redesign is a separate stage.
