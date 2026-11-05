# Levels 361–380 production assignment

The campaign contains 380 playable levels across nineteen chapters.
**Still Waters** owns Levels 361–380. The planned horizon remains 400;
Levels 381–400 are reserved for the final chapter and are not playable yet.

## Board design and review

This lakeside chapter continues the readable, layered Mahjong style of the
previous batches. Courts, harbours, island crossings, and stepped terraces
provide different silhouettes using the existing matching and free-tile rules.
Production stores explicit masks in `levels_361_380_data.dart`; only tile deals
vary at runtime. No new mechanics, tile art, or game modes are introduced.

All twenty boards have two broad foundations and smaller supported third-layer
shelves. Boards contain 56–80 tiles, with no foundation-row runs narrower than
two tiles. All layouts classify as bulky under the existing fullness analysis.
The compact tile-width minimum is 44.7 px, above the app's 44 px threshold.
The maximum similarity against any other campaign board is 0.797, below the
existing 0.900 near-clone threshold.

Breathers: 361, 366, 372, 376.
Showcases: 365, 370, 375, 380.

All twenty boards are rendered at 360×640, 390×844, and 430×932, with conservative
304×390, 344×460, and 384×520 gameplay areas. Standard and compact contact sheets
are visually reviewed; diagnostics and silhouettes are generated too. Geometry
checks cover unique coordinates, even tile totals, supported stacks, openings,
no same-layer overlaps, and safe fit on all three phone sizes.

## Progression and compatibility

A player who finished Level 360 continues at Level 361. Level 360 now shows the
next chapter instead of the campaign ending. Level 380 is the current-content
ending and returns home; Level 381 remains unavailable.

All existing level IDs, masks, names, and symbol plans remain unchanged. Saved
games, stars, best scores, currency, boosters, collection ownership, purchases,
settings, achievements, reminder preferences, and claimed chapter rewards retain
their existing keys. No storage migration is needed. The new Level-380 chapter
reward uses `chapter:19:level:380:complete`, so a legacy ten-level chapter-19
receipt cannot suppress it. Existing chapter reward keys remain unchanged;
the new receipt also prevents duplicate grants on retries. New boards use Relaxed rules.
Existing collection milestones in 361–380 become reachable through the unchanged
400-level unlock schedule. Reminder taps for previous Level-360 finishers now
open Level 361, while taps after Level 380 open Journey.

## Board catalogue

| Level | Board | Tiles | Free opening tiles | Compact tile width | Nearest layout / score |
|---:|---|---:|---:|---:|---|
| 361 | Lakeside Welcome | 60 | 21 | 51.7 px | 281 / 0.724 |
| 362 | Quiet Harbour | 68 | 17 | 45.1 px | 338 / 0.720 |
| 363 | Rippled Courtyard | 72 | 19 | 44.7 px | 371 / 0.780 |
| 364 | Waterline Steps | 72 | 16 | 46.2 px | 378 / 0.694 |
| 365 | Lake of Reflections | 80 | 23 | 44.7 px | 358 / 0.794 |
| 366 | Shaded Landing | 58 | 16 | 45.1 px | 374 / 0.765 |
| 367 | Twin Jetties | 80 | 21 | 46.2 px | 330 / 0.720 |
| 368 | Terraces of the Lake | 66 | 18 | 45.4 px | 326 / 0.794 |
| 369 | Island Crossing | 66 | 19 | 51.7 px | 281 / 0.772 |
| 370 | Gathering Waters | 80 | 21 | 45.1 px | 346 / 0.696 |
| 371 | Reed Courtyard | 68 | 20 | 44.7 px | 363 / 0.780 |
| 372 | Resting Shore | 56 | 15 | 52.1 px | 366 / 0.741 |
| 373 | Currents of Wisdom | 70 | 21 | 45.4 px | 358 / 0.732 |
| 374 | Harbour Gates | 66 | 18 | 45.1 px | 366 / 0.765 |
| 375 | Lake Assembly | 80 | 21 | 46.2 px | 343 / 0.797 |
| 376 | Evening Anchorage | 60 | 14 | 51.7 px | 341 / 0.751 |
| 377 | Paths Between Islands | 64 | 19 | 45.1 px | 333 / 0.716 |
| 378 | Reservoir Terraces | 72 | 15 | 46.2 px | 344 / 0.722 |
| 379 | Shoreline Together | 80 | 17 | 44.7 px | 333 / 0.714 |
| 380 | Still Waters Sanctuary | 80 | 19 | 45.1 px | 345 / 0.772 |

## Reproduce validation and previews

```sh
dart run tool/audit_levels_361_380.dart
flutter test --no-pub test/levels_361_380_test.dart
flutter test --no-pub test/levels_361_380_preview_test.dart
dart run tool/generate_levels_361_380_sheets.dart
flutter test --no-pub test/levels_361_380_production_flow_test.dart
flutter analyze --no-pub
```

Deal checks cover 100 deterministic seeds per board (2,000 total), full
solvability, at least four safe opening pairs on breathers, five on showcases,
and three elsewhere. The verifier stops counting safe pairs once it has proved
the required minimum. Production startup is separately checked through
GameNotifier for every campaign level and all recent levels' production decks.

Boundary and save tests cover 360→361, 379→380, the 380 ending, unavailable 381,
and preservation of a Level-360 veteran's progress, entitlements, rewards, and
settings. Regression tests also cover home, Journey, reminders, economy,
collection unlocks, and earlier frozen chapter definitions.

Generated files live in the ignored directory
`artifacts/layout-previews/levels-361-380-production/`: geometry CSV, individual
phone-size previews, diagnostics, silhouettes, two standard contact sheets, two
compact contact sheets, two silhouette sheets, and a chapter overview. They are
review artifacts, not app assets, and can be regenerated with the commands above.
