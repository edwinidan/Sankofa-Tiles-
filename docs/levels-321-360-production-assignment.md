# Levels 321–360 production assignment

The campaign contains 360 playable levels across eighteen chapters. Levels
321–340 form **Northern Weaves**; Levels 341–360 form **Festival of Light**.
The planned horizon remains 400. Level 361 is unavailable.

## Board design

This batch continues the broad, readable Mahjong boards of Levels 281–320.
Northern Weaves uses basket courts, interlaced passages, and market terraces;
Festival of Light uses stepped lanterns, fans, gateways, and processions.
These are visual themes using the existing free-tile matching rules.

All forty boards have two broad foundation layers and smaller supported
third-layer shelves. Their explicit masks are stored in
`lib/core/constants/levels_321_360_data.dart`; production does not generate
layout shapes randomly. Only tile deals vary. The shared mask builder was
extracted from the previous batch without changing its boards or symbol plans.

Boards contain 54–88 tiles. Every occupied foundation-row run has at least two
tiles. All boards classify as bulky under the existing fullness analysis.
Compact, standard, and tall previews use the conservative 304×390, 344×460,
and 384×520 gameplay areas in 360×640, 390×844, and 430×932 phone canvases.
The smallest compact tile width is 44.7 px, above the existing 44 px minimum.
Geometry checks cover support, unique coordinates, even totals, opening
accessibility, overlaps, and all three viewport fits.

Breathers: 321, 326, 332, 336, 341, 346, 353, 357.
Showcases: 325, 330, 335, 340, 345, 350, 355, 360.

The maximum silhouette similarity against any other campaign board is
0.814, below the existing 0.900 near-clone threshold. All forty standard
renders and their compact-phone contact sheets are reviewed as part of the
batch workflow. No additional tile art or game modes are introduced.

## Progression and compatibility

A player who finished Level 320 continues at Level 321. Level 340 completes
Northern Weaves and continues to Level 341. Level 360 shows Current Journey
Complete and returns home. Level 361 remains locked out of the catalogue.
New games use Relaxed rules: clean play earns three stars without a time target.

Existing IDs, authored boards, saved games, stars, best scores, collection
ownership, purchases, currency, boosters, settings, achievements, and claimed
chapter rewards retain their existing keys. No storage schema change is needed.
The existing collection schedule automatically makes rewards in 321–360
reachable; its 400-level horizon and earlier entitlements are unchanged.

## Board catalogue

| Level | Board | Tiles | Free opening tiles | Compact tile width | Nearest layout / score |
|---:|---|---:|---:|---:|---|
| 321 | Welcome to the Weave | 58 | 17 | 51.7 px | 291 / 0.756 |
| 322 | Basket Makers Court | 70 | 21 | 45.1 px | 338 / 0.745 |
| 323 | Woven Passage | 70 | 16 | 46.2 px | 331 / 0.800 |
| 324 | Market Terraces | 72 | 19 | 51.7 px | 348 / 0.773 |
| 325 | Bolga Gathering | 76 | 17 | 45.4 px | 333 / 0.814 |
| 326 | Shade by the Loom | 56 | 15 | 52.6 px | 337 / 0.814 |
| 327 | Crossed Threads | 74 | 19 | 45.1 px | 335 / 0.763 |
| 328 | Potters Courtyard | 82 | 24 | 44.7 px | 300 / 0.778 |
| 329 | Northern Steps | 66 | 18 | 52.6 px | 337 / 0.814 |
| 330 | Golden Basket | 78 | 19 | 46.2 px | 340 / 0.800 |
| 331 | Interlaced Paths | 64 | 15 | 45.1 px | 323 / 0.800 |
| 332 | Quiet Veranda | 60 | 16 | 52.1 px | 356 / 0.766 |
| 333 | Courts of Counsel | 76 | 17 | 44.7 px | 325 / 0.814 |
| 334 | Braided Terrace | 84 | 22 | 44.7 px | 342 / 0.790 |
| 335 | Weavers Assembly | 82 | 21 | 45.1 px | 327 / 0.763 |
| 336 | Resting Shuttle | 60 | 17 | 51.7 px | 329 / 0.781 |
| 337 | Twin Baskets | 68 | 18 | 52.6 px | 326 / 0.814 |
| 338 | Sunlit Market | 68 | 17 | 46.2 px | 345 / 0.753 |
| 339 | Threads of Kinship | 68 | 16 | 46.2 px | 347 / 0.808 |
| 340 | The Great Weave | 84 | 20 | 45.1 px | 330 / 0.800 |
| 341 | First Lanterns | 58 | 14 | 52.6 px | 323 / 0.743 |
| 342 | Festival Courtyard | 84 | 22 | 44.7 px | 334 / 0.790 |
| 343 | Ribbon Procession | 80 | 21 | 45.1 px | 351 / 0.798 |
| 344 | Coastal Steps | 84 | 22 | 45.4 px | 334 / 0.712 |
| 345 | Lantern Assembly | 84 | 22 | 46.2 px | 330 / 0.786 |
| 346 | Evening Pavilion | 60 | 17 | 45.1 px | 338 / 0.724 |
| 347 | Dancing Fans | 74 | 16 | 46.2 px | 339 / 0.808 |
| 348 | Festival Gateway | 68 | 20 | 51.7 px | 324 / 0.773 |
| 349 | Gathering Lights | 80 | 17 | 45.4 px | 325 / 0.794 |
| 350 | Winneba Celebration | 82 | 26 | 44.7 px | 316 / 0.786 |
| 351 | Torchlit Terrace | 76 | 21 | 45.1 px | 343 / 0.798 |
| 352 | Courtyard of Song | 70 | 19 | 44.7 px | 305 / 0.751 |
| 353 | Quiet Interlude | 60 | 17 | 52.1 px | 337 / 0.723 |
| 354 | Shared Radiance | 70 | 20 | 51.7 px | 288 / 0.755 |
| 355 | Circle of Lanterns | 78 | 19 | 46.2 px | 323 / 0.777 |
| 356 | Ribbon Crossing | 66 | 18 | 51.7 px | 329 / 0.787 |
| 357 | Moonlit Rest | 54 | 16 | 52.1 px | 341 / 0.709 |
| 358 | Procession of Stars | 70 | 18 | 45.4 px | 307 / 0.791 |
| 359 | Lights Together | 68 | 18 | 52.6 px | 282 / 0.727 |
| 360 | Festival of Unity | 88 | 22 | 44.7 px | 334 / 0.709 |

## Reproduce validation and previews

```bash
dart run tool/audit_levels_321_360.dart
flutter test --no-pub test/levels_321_360_test.dart
flutter test --no-pub test/levels_321_360_preview_test.dart
dart run tool/generate_levels_321_360_sheets.dart
flutter test --no-pub test/levels_321_360_production_flow_test.dart
flutter analyze --no-pub
```

The deal validation covers 100 deterministic seeds per board (4,000 total),
full solvability, legal opening pairs, and safe opening choices: at least four
on breathers, five on showcases, and three on other boards. Production startup
is separately exercised through GameNotifier for all new levels and the full
campaign. Progression checks cover 320→321, 340→341, the 360 ending, and the
unavailable 361 boundary. Save-compatibility checks preserve veteran player
state and previously claimed chapter rewards.

Generated artifacts are under the ignored directory
`artifacts/layout-previews/levels-321-360-production/`: geometry CSV, all forty
boards at each phone size, diagnostics, silhouettes, standard and compact
ten-board contact sheets, and two chapter overviews. Regenerate these locally
using the commands above; they are not app assets.
