# Adinkra Tiles UI redesign — phases 1 and 2

Audit date: 15 October 2026. Scope: the **supplied master UI redesign brief**, phases 1 (project inspection) and 2 (design-reference review). These are discovery phases, separate from older project documents that also use phase numbers. No application code, assets, dependencies, configuration, persistence, or gameplay behavior changed during this audit.

## 1. Project and implementation baseline

| Area | Findings and source |
|---|---|
| Toolchain | Installed Flutter **3.41.7 stable**, Dart **3.11.5**, DevTools 2.54.2; verified with `flutter --version`. |
| Application | Package `sankofa_tiles`; product title Adinkra Tiles; `pubspec.yaml` version **1.0.6+11**, Dart constraint `>=3.0.0 <4.0.0`. Home still displays `v1.0.0`; treat that as stale UI text. |
| Structure | `lib/screens/` contains menu/game screens; `lib/features/entry_flow/` the returning opening; `lib/widgets/` shared controls; `lib/core/` routing, theme, startup, economy, monetization, ads, scoring, constants and utilities; `lib/providers/` Riverpod state; `lib/models/` game and save models. Existing tests live in `test/`; layout audit tools in `tool/`. |
| State | `flutter_riverpod`: settings, progress, game, economy, monetization and AdMob providers. Widgets consume the existing services; wallet and ownership must continue to derive from providers. |
| Navigation | `go_router`, centralized in `lib/core/router/app_router.dart`, with reduced-motion-aware fade/slide transitions and analytics observer. `safeBack` handles fallback navigation. |
| Persistence | `StorageService` uses SharedPreferences. Campaign schema is **4**; active board snapshot is `active_game_v1`. Settings, progression, scores/stars, wallet, boosters, unlocks, achievements, purchase markers and ad limits are local. Existing migration retains earned collection entitlements. |
| Campaign | **280 playable levels, 14 chapters of 20 levels**, defined by `kLevels` and `kChapters`. **400** is a planning target, not the playable count. Legacy ten-level chapter definitions remain for compatibility. |
| Collection | **97 definitions / 97 existing tile asset references**, all present. Ten starter symbols; remaining unlock milestones span levels 4–400. Some future milestones exceed the playable campaign. Preserve both this schedule and previously earned ownership; do not expose future levels as playable. |
| Theme | Existing `SankofaGameTheme`, `AppTheme`, `AppColors`, `AppTextStyles` use forest greens, antique gold and parchment; Cinzel/Nunito via Google Fonts. Existing tokens provide a starting point for the later redesign. |
| Assets | `pubspec.yaml` declares 13 asset entries: six tile directories, audio, Lottie, images, tile back, green background, horizontal logo and Cowrie art. Every declared path exists. The new reference directory is **not bundled**. Merely placing a file in `assets/` does not guarantee registration. |
| Startup | `main.dart` initializes Firebase with a caught-failure path, locks portrait orientation and launches `AppBootstrapper`. Startup loads local storage, starts AdMob initialization asynchronously, and shows loading/error/retry UI in `core/startup/app_startup.dart`. Loading is indeterminate; there is no measurable percentage. |
| Opening | `EntryFlowDirector` adds the returning-user tile reveal after startup, depending on persisted discovery/opening preferences. It supports tap-to-dismiss, automatic dismissal, reduced motion and repeated-skip preference handling. This is distinct from actual initialization and the native splash. |
| First launch | App initial location is `/tutorial` until entry discovery is complete; router also has a home-to-onboarding redirect for incomplete discovery. Preserve existing tutorial/discovery flags and replay behavior. |
| Native splash | Android launch backgrounds/styles, including Android 12+ splash configuration, and iOS `LaunchScreen.storyboard` / LaunchImage exist. Later Flutter splash styling should leave them intact unless separately scoped. |
| Audio/haptics | `settingsProvider`, `AudioService` and `HapticService`: effects, music, volume, haptic intensity, tile names and animated opening are persisted. There is no independent voice channel. |
| Ads/telemetry | Firebase analytics/Crashlytics and Google Mobile Ads/consent are wired in current code. Rewarded flows call `AdMobService` and grant on the earned callback. Live ad delivery, consent and telemetry ingestion were not tested in this audit. |

Older `README.md`, `docs/SCREEN_INVENTORY.md` and `docs/STATE_AND_STORAGE_MAP.md` describe 200 levels, schema 3, older collection rules or sandbox-only ads. Current code and tests take precedence for this redesign; those historical documents were not rewritten.

## 2. Feature audit

“Implemented” below means connected in code, with automated evidence where stated; it is not a claim of a production device/store test. “Partial” distinguishes local simulations or incomplete product experiences from production integrations.

| Feature | Classification | Evidence / redesign treatment |
|---|---|---|
| Home, Journey and level selection | Implemented | Current chapter/progress/stars and locks derive from providers; all 280 levels are available through chapter grids. Preserve normal level launch gates. |
| Continue and saved-board resume | Implemented | Home reads `getActiveGameSummary()`. A saved game launches `/game/:id` with `resumeSavedGame: true`; otherwise next unfinished level opens `/level/:id`. “Start another level” is separate. Persistence round-trip test passes. |
| Cowries and boosters | Implemented | Central economy service owns add/spend, inventory, idempotent rewards and wallet. Hint, Shuffle and Open Path exist. No visible Cowrie-priced item-buying flow was found; do not invent one. |
| Daily rewards | Implemented | `/daily-reward`, seven-day local reward cycle, once-per-local-date claim, optional rewarded bonus chest. Label the redesign destination Daily or Daily Reward. |
| Daily playable challenge | Not implemented | No separate daily puzzle, challenge route or leaderboard found. A daily reward does not imply a challenge mode. |
| Achievements/rewards | Implemented | Economy grants achievements automatically on qualifying results; persisted claimed markers prevent repeats. There is no standalone task list/claim screen. |
| Task button/notification badge | Not implemented | No existing destination corresponding to the mockup’s Task button and red “1”. Omit it in later work. |
| Collection and unlock reveal | Implemented | `/tile-preview`, pageable symbol browser, thumbnail navigation, ownership/locks, next-unlock preview and result reveal. Unlock and migration tests pass. Use existing artwork/metadata, not mockup symbol guesses. |
| Symbol rarities | Not implemented | Mockup Common/Rare/Epic/Legendary categories are unsupported; omit. |
| Shop catalog/purchases | Partially implemented | Shop exposes catalog and Buy controls. `MonetizationService.purchaseProduct` simulates statuses and grants locally; it does not call StoreKit/Play Billing or validate receipts, even when environment is called production. No billing dependency exists. Do not describe these as verified real purchases. |
| Restore Purchases | Partially implemented; UI hidden | Local entitlement restoration from saved owned-product markers exists and is tested. Shop filters out the Restore tab (and Remove Ads tab). No store account restoration exists. Do not surface a production Restore button. |
| Remove Ads | Partially implemented | Entitlement affects interstitial eligibility, but payment is simulated and its shop tab is hidden. Do not re-enable it as part of visual styling. |
| Tile skins | Partially implemented | Kente Gold tile-back catalog/entitlement exists; no user-facing equip/selection and applied skin system was found. Do not add an apparently functional skins browser. |
| Background customization | Not implemented | Current background is a fixed theme asset; no ownership/selection system. Omit the mockup tab. |
| Heritage Bundle | Not implemented | Not a current product. Existing catalog has starter pack, boosters, Cowrie packs, Remove Ads and Kente Gold tile back. Do not substitute invented offers. |
| Local automatic save | Implemented | Progress and active-game serialization use SharedPreferences. Existing storage/settings tests use isolated mock preferences. |
| Cloud Save / Save Progress action | Not implemented | No authentication or remote player-save service. Firebase analytics/Crashlytics are not cloud backup. Omit cloud-save controls and claims. |
| Account/profile/avatar | Not implemented | No meaningful player profile, sign-in, name or avatar experience. Omit profile control. |
| Social sharing/community links | Not implemented | No configured sharing flow or official social account destinations found in `lib/`. Omit mockup social controls. |
| Privacy policy | Implemented | Existing external URL and launch/failure handling in settings; network destination availability was not verified. Conditional advertising privacy choices also exist. |
| Feedback/About | Not implemented | No dedicated existing actions/screens found. Do not invent these destinations. |
| Sound/music/volume | Implemented | Persisted settings connect to audio service; audio lifecycle coverage also exists in the suite but was not part of this selected run. |
| Vibration | Implemented | Preserve current intensity selection, including off, rather than losing intensity options in a simple toggle. |
| Independent Voice/SFX switch | Not implemented | Effects are already controlled by Sound Effects. No separate voice control. |
| Tutorial, tile names, animated opening | Implemented | Settings exposes replay tutorial, show tile names and animated-opening preference; all must remain accessible. |
| Hint/shuffle/Open Path/undo | Implemented | Existing gameplay and booster controls plus free undo and dead-end recovery. Preserve algorithms, costs, availability and state. |
| Settings ad/privacy/developer surfaces | Implemented | Settings has conditional privacy options, banner ad and gated developer tools/reset. Retain existing gating and behavior. Do not add reset to normal player UI. |

There is no need to add unavailable controls to mirror screenshots. Existing visible simulated Buy controls are a pre-existing product limitation to resolve explicitly before any later shop redesign is presented as production-ready; this audit does not change them.

## 3. Current screen integration map

| Surface | Existing file(s) | Later integration boundary |
|---|---|---|
| Startup | `lib/app_bootstrapper.dart`, `lib/core/startup/app_startup.dart` | Replace presentation only; preserve ready/error/retry behavior. |
| Returning opening | `lib/features/entry_flow/entry_flow_director.dart` | Keep opening preference, skip handling and initialization distinction. |
| Home | `lib/screens/home/home_screen.dart` | Replace stacked dashboard panels with responsive scenic composition; preserve wallet, continue/resume, alternate level, tutorial prompt, next unlock and all destinations. |
| Settings | `lib/screens/settings/settings_screen.dart` | Cream panel, scrollable content, existing settings and privacy/banner behavior. Keep route/back handling. |
| Journey | `lib/screens/journey/journey_screen.dart` | Render real chapters/level nodes, locks and stars; preserve access to every implemented level. |
| Collection | `lib/screens/preview/tile_preview_screen.dart` | Restyle the full real inventory and next-unlock preview. |
| Shop | `lib/screens/shop/shop_screen.dart` | Separate route remains; visual direction can be shared without adding absent collection tabs or billing. |
| Related panels | daily, pre-level, result, chapter-complete, game settings/pause | Later consistency pass only; leave board/mechanics intact. |

Routes also include `/onboarding`, `/tutorial?replay=1`, `/result`, `/chapter-complete/:levelId`, and gated `/developer/levels`. Preserve analytics events and route extras alongside destinations.

Current responsive patterns include SafeArea, scroll views, LayoutBuilder, bounded content widths, Wrap and constrained game sheets. Journey currently nests fixed five-column grids in a chapter list; large text and compact widths need special attention during the later redesign. Existing patterns are useful but do not establish that all future layouts are overflow-free.

## 4. Design references: location, review and intended use

One new reference hierarchy was found: `images for new home screen/`. Its `design references/` subfolder contains the five UI targets; its parent contains the five supporting scenic images. These serve distinct roles, so there is no competing new authoritative reference folder to resolve. Existing `assets/` art is legacy/runtime material. No alternative newer screen versions were found in the new hierarchy. Both home and settings use a `03` prefix; identify them by full filename.

All ten PNGs were visually opened and reviewed. All are **opaque RGB**, with no alpha channel. Together they occupy **21,866,327 bytes (20.85 MiB)** on disk. None has been copied, cropped, optimized or registered during phases 1–2.

| File relative to `images for new home screen/` | Dimensions | Size (MiB) | Classification and intended later use |
|---|---|---|---|
| `design references/01 splash.png` | 941 × 1672 | 2.19 | Complete mockup: architectural scene, baked logo/tile art and loading bar. Visual target only; bar must be a real indeterminate widget unless measurable progress exists. |
| `design references/03. home.png` | 941 × 1672 | 2.28 | Complete mockup: illustrated world, logo, wooden medallion, wallet, controls and fixed Level 9. Target composition and simple green/gold navigation; rebuild all dynamic controls/text. Omit unsupported profile/task. |
| `design references/03. settings.png` | 941 × 1672 | 1.97 | Complete mockup: cream panel, green/gold controls and multiple unsupported actions. Recreate panel and existing settings as widgets; exclude cloud save, store restore, voice and social placeholders. Brief calls for a simpler title/border than the heavier image treatment. |
| `design references/04.journey.png` | 941 × 1672 | 2.59 | Complete mockup: coastal path, chapter card, fixed nodes/stars/locks and `8/15`. Use as map composition reference, never as level data; current chapters contain 20 levels. |
| `design references/05. collection shop.png` | 941 × 1672 | 2.20 | Complete mockup: cream/wood tile cards, bundle, rarity labels and tabs. Borrow card/material styling only; real symbols/ownership, no fabricated bundle, rarity, skins or background selection. Keep current Collection and Shop destinations reachable. |
| `Ghana Landmarks in 3D Cartoon Style.png` | 1536 × 1024 | 2.09 | Four-panel scenic collage (memorial, mosque, lighthouse, arch), not one seamless background or isolated transparent buildings. Architectural/style reference; individual rectangular crops are technically possible but would retain sky/ground. |
| `Stylized Sahelian Mosque Facade.png` | 1672 × 941 | 1.78 | Standalone opaque landscape scene; candidate chapter/header artwork with crop review. Not a transparent facade cutout. |
| `Ghana’s Independence Arch in Bloom.png` | 1448 × 1086 | 2.03 | Standalone opaque landscape scene; candidate chapter/header artwork. Distinct composition from the combined portrait mockup world. |
| `Stylized Coastal Lighthouse Panorama.png` | 1672 × 941 | 1.66 | Standalone opaque coastal landscape; candidate chapter/header artwork. Portrait cover-fit would crop architecture substantially. |
| `Bronze Hero at the Memorial Plaza.png` | 1536 × 1024 | 2.05 | Standalone opaque memorial landscape; candidate chapter/header artwork. Tiny lower-left mark is visible and should be reviewed before any production reuse. |

The home reference establishes simple emerald pill buttons, gold outlines, cream/gold iconography, a prominent amber play action and a wood centerpiece. Use the written brief’s simpler border/shadow requirements wherever a mockup still shows heavier relief, scrollwork or shine. Do not revive more ornate styling from legacy assets.

### Reusable existing assets

- `assets/adinkra_tiles_homescreen_show-removebg-preview.png`: 1000 × 250 RGBA, approximately 156 KiB. Existing transparent horizontal wordmark with two wooden tiles; visually reviewed. Functional fallback, but its proportions/design differ from the new stacked plaque logo.
- `assets/adinkra_tiles_splash_icon-removebg-preview.png`: 500 × 500 RGBA, approximately 185 KiB. Existing transparent wooden tile pair; visually reviewed. Present on disk but not explicitly registered in the current Flutter manifest.
- `assets/adinkra tile back tile.png`: 433 × 577 RGBA; existing tile back.
- `assets/cowries currency.png`: 500 × 500 RGBA; already registered and used by `CowrieIcon` / `CowrieAmount`.
- `assets/background green option 2.png`: 941 × 1672 opaque texture; already used by `SankofaBackground`. Suitable fallback while scene assets are resolved.
- Tile metadata in `lib/core/constants/tile_data.dart` references all 97 existing symbol PNGs. Keep these authoritative instead of extracting potentially inaccurate symbols from generated mockups.
- Existing square logo/splash PNGs are opaque and are not clean replacement layers for the redesigned logo.

### Missing layers / limitations

For close fidelity with responsive placement, obtain:

1. A clean portrait home/splash environment, without logo, loading bar, medallion, wallet, icons or buttons, with safe crop space at the edges.
2. The new stacked logo with wooden tiles and transparent edges at sufficient resolution.
3. An isolated circular wooden medallion with transparent surroundings, clean rim and a validated symbol (or a clean wooden disc plus existing validated symbol artwork).
4. A clean Journey coastal environment/path without baked numbers, nodes, chapter card, stars, locks or labels; suitable as scrollable or per-chapter scenery.
5. Optional clean chapter vignettes if later chapters need more visual variety than the supplied landscapes offer.

Panels, loading indicators, buttons, toggles, node circles and labels should be Flutter widgets; standalone bitmap controls are unnecessary. The opaque screenshot layers cannot be cleanly recovered by simple cropping: original background pixels are hidden under logos/panels/buttons. Transparent extraction or reconstruction needs suitable source artwork or separately approved image work. Do not place screenshot UI behind transparent hit targets. Do not download or generate substitute art without authorization.

The landscapes can support an explicitly accepted adaptation using bounded image regions. They do not reproduce the coherent portrait world by themselves. Exact mockup fidelity is asset-dependent, but shared controls can proceed once the later code plan is approved.

## 5. Proposed implementation structure for later approval

This is a plan, not an implementation performed in phases 1–2.

1. Extend the existing theme rather than replace the architecture. Add a menu-specific palette/material treatment so broad theme changes do not unintentionally restyle the board. Proposed reusable controls under `lib/widgets/`: `GameIconButton`, `GameNavigationButton`, `GamePrimaryButton`, `GamePanel`, `GameToggle`. Reuse `CowrieAmount` and existing tile components. Compare `KenteButton` callers before any shared change.
2. Resolve artwork using the standalone asset list above or an agreed adaptation using supplied scenes and the existing logo. Register only runtime assets in `pubspec.yaml`; leave full mockups outside the app bundle. Choose decode dimensions/variants after deciding actual display sizes. A 941 × 1672 RGBA decode is about 6 MiB regardless of PNG compression; avoid preloading every scene.
3. Style startup and the returning opening without changing initialization, skip preferences, errors or destinations; no fake loading percentage or added wait.
4. Rebuild Home with existing live wallet, correct continue/resume action, decorative medallion, top Shop/Settings and bottom Daily/Journey/Collection. Keep tutorial, alternate-level and next-unlock access. No duplicate Journey control, fake profile or Task badge.
5. Restyle Settings as a constrained, scrollable cream panel while retaining volume, haptic intensity, tile-name and opening preferences, tutorial/collection links, privacy options, banner and developer gating.
6. Rebuild Journey using `kChapters`, `chapter.levels` and `progressProvider`; chapter navigation plus scrollable dynamic nodes must reach all 280 levels. Use real star/progress/lock values and launch existing pre-level flow.
7. Restyle Collection using existing symbols, paging/browsing and ownership. Restyle the separate Shop only within existing capability boundaries; resolve the simulated-purchase presentation explicitly before shipping it as a real store. No new billing or catalog products.
8. Apply shared styling to directly related menu panels, then check compact portrait layouts, safe areas, large text, scroll reachability and image crops. Leave game rules, layouts, generation, scoring, economy, unlocks, ads, product IDs, Firebase/analytics, signing and save schemas unchanged.

Later validation: analyzer; targeted widget tests for changed controls/screens; asset loading; route/resume/unlock integration checks; compact and typical iPhone/Android portrait sizes; larger text; screenshots on an available device/simulator. Check restart persistence with test data. Tests must not reset a real player save.

## 6. Baseline validation performed

- `flutter --version`: Flutter 3.41.7 / Dart 3.11.5 verified. The SDK initially could not update its cache under the restricted filesystem; the approved escalated command succeeded.
- `flutter analyze --no-pub`: **No issues found**.
- Selected existing tests: **106 passed**, across the 13 files below. These cover startup, returning opening, saved-board serialization, progression, chapter boundaries, economy/reward idempotency, local simulated purchases/restore, rewarded-ad callback/limit behavior, collection migrations/unlocks and release configuration checks.

```sh
flutter test --no-pub \
  test/app_startup_test.dart \
  test/entry_flow_test.dart \
  test/player_convenience_test.dart \
  test/progression_flow_test.dart \
  test/journey_city_progression_test.dart \
  test/economy_service_test.dart \
  test/monetization_service_test.dart \
  test/ad_monetization_ux_test.dart \
  test/collection_migration_test.dart \
  test/tile_collection_integration_test.dart \
  test/tile_unlock_rules_test.dart \
  test/retention_flow_test.dart \
  test/release_readiness_test.dart \
  --reporter compact
```

- Filesystem asset audit: all **13 manifest entries** and **97 referenced symbol assets** exist; PNG header dimensions/color modes were inspected for all ten new images and existing top-level PNG assets. This is not a device-level asset decode test.
- Visual review: all ten new images and the two transparent legacy logo/tile-pair images opened successfully. No redesigned Flutter screens exist yet; no device/simulator interaction, live billing, live ads or external-link availability was verified.
- No new tests were added for this documentation-only phase, and the full repository test suite was not run.

## 7. Deliverable and next decision

Created only this report. No visual changes have been implemented; existing functionality remains unchanged. Phases 1 and 2 are complete. Before changing application code, approve the later implementation plan and choose between supplying the clean layers above or accepting an adaptation using the available artwork. This follows the supplied brief’s explicit instruction to report findings and obtain approval before modifying code.
