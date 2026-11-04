# Levels 281–320 production assignment

The campaign now contains 320 playable levels across sixteen chapters. Levels
281–300 belong to **Royal Roads**; Levels 301–320 belong to **Voices of the Drum**.
The planned horizon remains 400. Level 321 is unavailable.

## Board design and visual review

All forty boards use substantial Mahjong masses: two broad foundation layers
with smaller third-layer shelves. Every horizontal run in the foundation and
middle layer is at least two tiles wide. Themes guide stepped courts, shields,
terraces, drums, and fans without relying on thin literal tower outlines.

The batch has 50–88 tiles per board, eight lighter boards, eight showcases,
and two chapter finales. Every board classifies as bulky under the existing
fullness analysis. All forty clean renders were visually reviewed in ten-board
contact sheets. Compact, standard, and tall previews use the conservative
304×390, 344×460, and 384×520 gameplay areas inside 360×640, 390×844, and
430×932 phone canvases. Tile widths remain at least 44 px even on the compact
preset. Geometry checks also cover support, unique coordinates, even totals,
and same-layer overlaps.

No new board crosses the existing 0.900 near-clone threshold against any other
campaign board; the maximum is 0.873 (296/317). Each board has distinct authored
base and upper-shelf coordinates. Themes do not change the Mahjong rules.

Breathers: 281, 286, 292, 296, 301, 306, 313, 317.
Showcases: 285, 290, 295, 300, 305, 310, 315, 320.

## Progression and compatibility

A player who finished Level 280 automatically continues at Level 281. Level
300 completes Royal Roads and continues at Level 301. Level 320 shows Current
Journey Complete and returns home. All previous level definitions remain
unchanged; existing IDs, saves, rewards, purchases, collection ownership,
settings, scores, and achievements retain their keys. Existing scheduled
collection milestones in the new range become reachable without new faces.

## Board catalogue

|Level|Board|Tiles|Free opening tiles|Compact tile width|Nearest layout / score|
|---:|---|---:|---:|---:|---|
|281|Royal Welcome|58|18|52.6 px|286 / 0.718|
|282|Seat of Counsel|66|20|51.7 px|291 / 0.675|
|283|Palace Forecourt|68|22|45.4 px|289 / 0.826|
|284|Shield of Welcome|70|20|45.4 px|289 / 0.742|
|285|Twin Royal Courts|76|26|44.7 px|315 / 0.794|
|286|Resting Pavilion|50|18|52.6 px|301 / 0.782|
|287|Processional Steps|74|21|44.7 px|298 / 0.782|
|288|Golden Threshold|70|20|51.7 px|307 / 0.814|
|289|Council Chamber|78|20|45.4 px|283 / 0.826|
|290|Royal Canopy|80|24|45.4 px|319 / 0.713|
|291|Courtyard Crossing|70|22|44.7 px|307 / 0.766|
|292|Quiet Audience|52|19|52.6 px|317 / 0.760|
|293|Stepped Bastion|74|23|44.7 px|318 / 0.739|
|294|Banner Court|80|22|44.7 px|299 / 0.763|
|295|Palace Assembly|76|24|45.4 px|283 / 0.781|
|296|Guardians Rest|56|19|51.7 px|317 / 0.873|
|297|Royal Causeway|76|21|44.7 px|289 / 0.669|
|298|Crown Terrace|80|24|44.7 px|287 / 0.782|
|299|Hall of Elders|80|26|44.7 px|312 / 0.792|
|300|Golden Procession|88|22|44.7 px|318 / 0.761|
|301|The Rhythm Opens|58|17|52.6 px|286 / 0.782|
|302|Talking Drum|80|22|44.7 px|298 / 0.750|
|303|Paired Bells|72|24|51.7 px|309 / 0.681|
|304|Echo Terrace|70|20|44.7 px|314 / 0.752|
|305|Ceremonial Fan|76|22|44.7 px|311 / 0.719|
|306|Soft Cadence|54|19|51.7 px|287 / 0.703|
|307|Gathering Rhythm|72|24|44.7 px|288 / 0.814|
|308|Rolling Thunder|76|20|44.7 px|287 / 0.774|
|309|Festival Calabash|74|22|44.7 px|285 / 0.774|
|310|Chorus of Bells|78|24|45.4 px|295 / 0.702|
|311|Alternating Beats|80|20|44.7 px|300 / 0.737|
|312|Resonant Chamber|82|22|44.7 px|299 / 0.792|
|313|Evening Refrain|54|18|52.6 px|301 / 0.778|
|314|Festival Steps|74|20|44.7 px|304 / 0.752|
|315|Double Drum|86|24|44.7 px|285 / 0.794|
|316|Call and Response|74|26|44.7 px|293 / 0.716|
|317|Moonlit Rhythm|54|18|51.7 px|296 / 0.873|
|318|Ceremonial Resonance|78|20|44.7 px|300 / 0.761|
|319|Rhythm of Return|76|24|45.4 px|290 / 0.713|
|320|Grand Drum Assembly|86|20|44.7 px|300 / 0.747|

## Reproducing validation and previews

```sh
dart run tool/audit_levels_281_320.dart
flutter test --no-pub test/levels_281_320_test.dart
flutter test --no-pub test/levels_281_320_preview_test.dart
dart run tool/generate_levels_281_320_sheets.dart
flutter test --no-pub test/levels_281_320_production_flow_test.dart
flutter test --no-pub test/campaign_expansion_boundary_test.dart test/game_provider_startup_test.dart
flutter analyze --no-pub
```

The new board suite checks 100 deterministic seeds per level (4,000 boards),
using production symbol IDs and copy distributions. It requires three safe
opening pairs on ordinary boards, four on breathers, and five on showcases.
Each generated board must solve and preserve the authored coordinates.
The runtime startup suite additionally starts every new production level in
every difficulty mode and checks the resulting deck and solvability.

Generated evidence is written to
`artifacts/layout-previews/levels-281-320-production/`: geometry CSV, clean,
diagnostic, silhouette, compact and tall PNGs for every board, four ten-board
contact sheets, four silhouette sheets, and two chapter overviews. Artifacts
are generated locally and remain outside Git, following repository convention.

## Completed verification — 2026-11-04

- New-board suite: 43 tests passed, including all 4,000 seeded boards.
- Campaign/startup/compatibility/UI integration group: 47 tests passed.
- Final gameplay-area preview suite: 40 tests passed (200 PNGs).
- All remaining regression files: 1,579 tests passed.
- Total across these disjoint runs: 1,709 tests passed.
- `flutter analyze --no-pub`: no issues found.
- `git diff --check`: clean.
- All forty final arrangements were visually reviewed; the compact Level-320
  render was also inspected individually.

This assignment updates local project source. Store distribution requires a
new app build and release.
