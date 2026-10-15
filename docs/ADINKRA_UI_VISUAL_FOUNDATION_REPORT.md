# Visual foundation and home artwork gate

Update: the requested artwork has since been supplied and Home implemented. See `ADINKRA_UI_HOME_IMPLEMENTATION_REPORT.md` for the current status; this report records the earlier foundation-only stage.

15 October 2026. Follow-up to `ADINKRA_UI_REDESIGN_PHASES_1_2_AUDIT.md` and the approved visual-foundation/home stage.

The reusable foundation is implemented and rendered in widget tests. **Home implementation is pending clean artwork**, following the user's explicit instruction to finish practical shared components and stop before a compromised home replacement. The foundation is not wired into production screens yet. Home, Settings, Journey, Collection, Shop and startup retain their existing presentation and behavior.

## Files created in this stage

| File | Purpose |
|---|---|
| `lib/core/theme/game_menu_theme.dart` | Menu-only emerald, forest, gold, amber, cream and ink tokens; simple bordered button styling with subtle elevation. No changes to the existing board/global theme. |
| `lib/widgets/game_menu_components.dart` | Reusable presentation widgets listed below. No state management, routing, persistence or simulated billing logic. |
| `test/game_menu_components_test.dart` | Interaction, disabled-control, accessibility balance-label, text-scaling, overflow and scroll-reachability checks; opt-in PNG rendering. |
| `output/ui-foundation/compact.png` | Rendered component gallery at 320 × 568 logical pixels, 1× text. |
| `output/ui-foundation/standard.png` | Rendered component gallery at 390 × 844 logical pixels, 1× text. |
| `output/ui-foundation/large-text.png` | Rendered component gallery at 320 × 568 logical pixels, 2× text. |
| `output/ui-foundation/largest-text.png` | Rendered component gallery at 430 × 932 logical pixels, 3× text. |
| `docs/ADINKRA_UI_VISUAL_FOUNDATION_REPORT.md` | This handoff and the precise artwork request. |

The previous audit remains in the working tree; it was read and not modified in this stage. No existing application files or configuration were modified. No dependencies added.

## Components

- `GameNavigationButton`: dark emerald, thin gold border, icon above a wrapping label; no glow or ornamentation.
- `GameNavigationGroup`: equal-width horizontal buttons at normal mobile widths, stacked controls at narrow widths or large text sizes.
- `GamePrimaryButton`: warm gold surface, play icon by default, wrapping caller-supplied text; supports disabled state. The later Home supplies the real Continue/Resume level and callback.
- `GameIconButton`: circular emerald control, gold outline/icon, tooltip/accessibility label, at least 48 × 48 logical-pixel target.
- `GameCurrencyDisplay`: caller-supplied amount with the existing Cowrie icon asset; full semantic balance, wrapping visible balance/label and no implied purchase action.
- `GamePanel`: cream surface, thin gold outline and subtle shadow.
- `GameToggle`: controlled green/gold switch with caller-owned state and callback; disabled state supported. Creating this widget does not redesign Settings or add new settings.
- `GameMenuLayout`: separately supplied decorative background, SafeArea for controls, bounded content width and scrollable vertical content. The later scene can fill the screen without intercepting input or accessibility focus.

No placeholder home, guessed medallion or substitute architectural composition was added. Preview callbacks/sample balance/level exist only in the test gallery and are not reachable in the app. Existing 280 levels, 14 chapters, 97 symbols, save/resume, daily rewards, settings, economy, unlocks and navigation remain untouched. Ads, Firebase, signing, identifiers, store simulation and configuration were not modified.

## Artwork reviewed and used

Re-read the audit, inspected the current asset inventory, and reopened the authoritative `images for new home screen/design references/03. home.png`, supporting landmark collage and legacy transparent horizontal logo. The inventory still contains the same five flattened UI references and five opaque scenic images documented in the audit; no new clean layers were found.

The simplified home reference informs palette, rounded silhouettes, restrained outlines and action hierarchy. The written simplicity rules take precedence over any residual relief/shine in the mockup. All controls are Flutter widgets. The only bitmap used by the new components is the existing registered `assets/cowries currency.png`, through `CowrieIcon`. No screenshot or new image has been registered, cropped, extracted, generated or downloaded.

### Required before completing Home

Provide these three separate exports, matching the approved home composition:

| Suggested filename | Required content and export |
|---|---|
| `home_environment.png` | One coherent **portrait Ghanaian architectural environment**, including the intended monuments, mosque, lighthouse, greenery, sky and stone surroundings. Remove every baked UI element: profile, wallet, buttons, text/logo, Task art/badge and medallion. The scene beneath those elements must be present. Export at original quality, ideally around 1440 × 2560 or larger, with additional crop space for tall/compact devices. Opaque PNG is appropriate. |
| `adinkra_tiles_logo.png` | The **stacked Adinkra Tiles logo with its wooden tiles**, isolated on transparent surroundings, tightly bounded without clipped leaves/edges, ideally at least 1200 pixels wide. No scene or other controls baked in. |
| `wooden_medallion.png` | A **smooth circular wooden medallion** on transparent surroundings, simple gold rim, no carved outer patterns or halo; ideally at least 1024 × 1024. Use an authenticated existing Adinkra symbol, or provide a plain wooden disc and a separate validated symbol layer. Do not substitute the reference's generated symbol without checking it against the project's approved metadata/artwork. |

Suggested dimensions are export guidance, not final layout coordinates. Preserve original aspect ratios and transparent edge quality. Button, panel and toggle bitmap exports are unnecessary.

The old 1000 × 250 logo has a different horizontal shape. The available scenic landscapes do not contain the combined portrait world. The medallion exists only inside the flattened home mockup. Simple cropping cannot reconstruct the scene hidden behind its logo, buttons and centerpiece or cleanly separate all occluded edges. Using those as final layers would compromise the approved visual target, so Home has not been changed.

## Rendered review and design differences

All four PNGs were actually generated by Flutter widget rendering and opened for visual review. PNG output uses 2× pixel density; listed sizes above are logical viewport sizes. The opt-in preview uses local Arial for readable text and the bundled Material icon font. This validates component appearance/layout; it does **not** verify final Cinzel/Nunito typography or device rasterization. No emulator/device run was performed.

Observed after refinement:

- Compact and standard galleries show readable labels and real icons, the intended emerald/gold/cream palette, thin borders and restrained shadows.
- Large text wraps the primary label and wallet; the navigation group stacks to avoid splitting short destination labels into cramped columns.
- No layout overflow exceptions occurred in the tested scenarios. Content extends beyond compact/large-text viewports intentionally; tests scroll to the final control and verify it remains reachable.
- The palette/material treatment follows the reference but intentionally uses simpler flat fills, dark readable primary text, standard icons and lighter borders rather than reproducing metallic bevels, shine and ornamental plaque details.
- The gallery has no background scene, replacement logo or wooden centerpiece. It is labelled as a foundation preview and is not a proposed Home layout. Full Home-to-reference composition, crop, navigation and saved-progress integration verification remains pending artwork and implementation.

An initial preview run exposed missing icon-font loading and large-text label crowding. The harness now loads the icon font; navigation stacks at large text sizes and wallet text wraps. Final previews were regenerated and visually checked after those fixes. A test-only semantics-handle cleanup issue was also corrected before the final passing run.

## Validation

- `flutter analyze --no-pub`: no issues found.
- `test/game_menu_components_test.dart`: **6 passed**. Callback execution/disabled state, 48-pixel icon target, controlled toggle update, full wallet semantics, four responsive/scrolling scenarios and actual Cowrie asset decoding in the rendered preview path.
- Existing regression selection from the phase 1–2 audit: **106 passed** across `app_startup_test`, `entry_flow_test`, `player_convenience_test`, `progression_flow_test`, `journey_city_progression_test`, `economy_service_test`, `monetization_service_test`, `ad_monetization_ux_test`, `collection_migration_test`, `tile_collection_integration_test`, `tile_unlock_rules_test`, `retention_flow_test` and `release_readiness_test`.
- **112 tests passed total** in the selected runs. The full repository suite, live store billing, live ad delivery, external services and a redesigned Home were not tested.

Reproduce local review PNGs on this Mac:

```sh
flutter test --no-pub test/game_menu_components_test.dart \
  --dart-define=MENU_PREVIEW_DIR=output/ui-foundation \
  --dart-define=MENU_PREVIEW_FONT=/System/Library/Fonts/Supplemental/Arial.ttf \
  --reporter expanded
```

The screenshot flags are optional. Normal widget tests do not require that system-font path or write PNGs. Preview images are review artifacts, not golden baselines.

## Next stage

Supply the three clean layers above. Then register suitable runtime exports, compose Home using the new components and the existing providers/routes, preserve Continue versus saved-board Resume and all existing player actions, and validate the actual Home at multiple viewport/text sizes. Stop after Home; Settings, Journey, Collection and Shop are separate later stages.
