# 400-Level Campaign Architecture Audit and Roadmap

Status: architecture proposal only. Production campaign definitions, unlock behavior, saved data, monetization, and Levels 6–400 were not changed. Audit date: 2026-07-12. Branch: `feature/admob-integration`. Baseline: `flutter test` passed all 204 tests in approximately 9 seconds. The worktree contained pre-existing modified and untracked files; they were preserved.

The full machine-readable roadmap is also available in [`400-level-campaign-roadmap.csv`](400-level-campaign-roadmap.csv). Levels 1–5 retain their approved assignments; every later row is explicitly a proposal, not production content.

## 1. Current campaign architecture

`lib/core/constants/level_data.dart` owns `SymbolCopyPlan`, `LevelDefinition`, `_level`, `_extendedCampaignLevels`, `kLevels`, `kCampaignLevelCount`, `kFinalCampaignLevelId`, `kMaximumCampaignStars`, and `getLevelById`. IDs 1–50 are declared individually; 51–200 are generated as 15 ten-level chapters. `_level` makes unlocking sequential with `unlockRequirement: id - 1`, although the UI/storage currently unlocks from the preceding completion flag rather than reading that field.

`lib/core/constants/chapter_data.dart` owns `ChapterDefinition`, twenty current ten-level `kChapters`, `chapterForLevel`, and `isChapterFinalLevel`. Chapter state is derived; it has no independent persisted progress key. `chapterForLevel` silently returns Chapter 1 for an out-of-range ID, which should become a fail-fast or nullable lookup before expansion.

`lib/core/constants/layout_data.dart` owns integer half-grid `TilePosition`, layout builders/statistics, 43 named layouts in `kLayoutLibrary` (including pilots and the five approved early layouts), and the coordinate templates. `LevelDefinition.namedLayout` performs assignment. `SymbolCopyPlan` and `symbolStartIndex` assign gameplay symbols independently of collection ownership.

`lib/core/utils/storage_service.dart` persists `best_score_{id}`, `stars_{id}`, `completed_{id}`, and `highest_completed_level`; `isLevelUnlocked(id)` is Level 1 or completion of `id - 1`. Schema migration is currently version 3 and reconstructs completion from old highest/current/unlocked and star keys. Cowries, boosters, economy transaction IDs, collection flags, achievement flags, monetization entitlements, purchases, and callbacks are separate additive keys.

`lib/providers/progress_provider.dart` exposes `ProgressService`: clamped highest completion, sequential next level, campaign-complete state, stars, and save forwarding. `lib/screens/result/result_screen.dart::_saveResult` is the completion orchestrator: compute stars → log analytics → grant rewards → save result → update monetization/session state. Rewards happen before completion persistence, so `wasCompleted` is captured correctly, while transaction IDs make most grants replay-safe.

`lib/core/economy/economy_service.dart` owns reward and collection flow. `grantLevelRewards` grants first-clear/star cowries, unlocks rules matching the completed level, grants a chapter bonus, and evaluates achievements. `loadState` calls `backfillCollectionUnlocks`, which adds every rule through highest completion. `lib/providers/economy_provider.dart` refreshes UI state and logs collection/achievement events. `ResultScreen._RewardReveal` shows symbol counts and reward lines; the result flow reveals new collection cards before normal actions. `lib/screens/preview/tile_preview_screen.dart` reads the explicit collection set and unlock-source labels.

`lib/screens/journey/journey_screen.dart` displays chapters and levels. It uses a lazy outer `ListView`, but creates all chapter widgets with a collection `for`, and each chapter embeds a shrink-wrapped non-scrolling grid. `lib/screens/developer/developer_level_tester_screen.dart` correctly uses `SliverGrid.builder` for campaign and layout catalogues. `lib/core/utils/campaign_validator.dart` validates IDs, coordinates, pair/copy totals, opening geometry, direct-lower-layer support, and viewport fit. `tool/campaign_report.dart`, `tool/board_generation_benchmark.dart`, `tool/render_layout_diagram.dart`, and `tool/report_pilot_layouts.dart` provide current developer reporting/preview support.

Tutorial state is independent (`tutorial_complete`) and the tutorial does not consume campaign IDs. Analytics in `lib/core/utils/analytics_service.dart` accepts integer level IDs without a 200 cap.

### Real completion and restore flow

1. A win routes to `ResultScreen`; `_saveResult` computes stars from the current `LevelDefinition`.
2. It records `level_completed`, calls `EconomyNotifier.grantLevelRewards`, then `ProgressService.saveLevelResult`.
3. `StorageService.saveLevelResult` writes best score/stars, `completed_N`, and monotonic `highest_completed_level`.
4. Level N+1 becomes available because `StorageService.isLevelUnlocked(N+1)` checks `completed_N`.
5. `EconomyService.grantLevelRewards` uses first-clear/star/chapter transaction keys and `tileIdsUnlockedAtLevel(N)`; collection IDs are persisted as `collection_unlocked_{tileId}=true`.
6. `EconomyNotifier` refreshes its `EconomyState`; `ResultScreen` receives `RewardGrantSummary.unlockedSymbols` and presents reveal UI.
7. On restart, `StorageService.init` runs schema migration, providers reconstruct progress, and `EconomyService.loadState` additively backfills earned rule IDs before reading the explicit set.

### Direct answers to architecture questions

1. Progression is effectively keyed by numeric level ID and sequential predecessor completion. Names/layout IDs are not save keys.
2. Chapter progression is derived from numeric ranges and completion flags; it is not stored independently.
3. Tile eligibility is derived from the highest completed numeric level through a rule table during backfill.
4. Yes. Earned tile IDs are also explicitly and additively stored as boolean keys.
5. Existing explicit flags will not be cleared, but a schedule change can make unlock-source text inconsistent and can withhold a formerly due-but-never-backfilled tile. A destructive reset/recalculation would relock tiles, so it must never be introduced.
6. Yes: versioned migration in `StorageService._migrateCampaignProgressIfNeeded`, currently schema 3. It covers campaign completion, not a dedicated collection schedule version.
7. Yes. Append IDs 201–400 and preserve every ID/key from 1–200.
8. Yes; detailed below. Most runtime completion code derives the end from `kLevels`, but chapter and unlock constants/tests encode 200.
9. Tests and chapter data hardcode 200; Journey hardcodes ten levels per chapter. Home progress already derives totals.
10. No analytics method enforces 200. Downstream Firebase/warehouse dashboards, audiences, and validation rules are outside this repository and require an operational audit.
11. The final UI derives `kFinalCampaignLevelId`/`kLevels.last.id`, so appending levels fixes it. The `complete_campaign` achievement incorrectly uses the tile-unlock final constant, currently 200, and must be separated.
12. Journey groups levels by chapter but eagerly instantiates all chapter cards; the developer catalogue is lazy.
13. Four hundred simple cards are unlikely to create memory trouble, but twenty embedded grids plus all chapters should be changed to expansion panels or a chapter route. Render only the selected/current chapter for predictable performance.

## 2. Current tile-unlock architecture

There are **97 collectible faces**, four `TileSuit` categories, and no separate persisted tile-theme unlock system in the audited code. `kStarterTileUnlockCount` is 10, but those ten rules are assigned to **Level 1**, so a brand-new player has zero explicit collection faces until completing Level 1 (unless another fixture/migration seeded them). Level 1 then awards ten at once. Forty more faces are spread across Levels 2–80, thirty across 81–150, and the final 17 across 151–200. Rounding sometimes co-locates milestones.

Copy count does not unlock collection content. `SymbolCopyPlan` only distributes 2/4 copies across the board. Board symbol pools come from `LevelDefinition.tileIds` and do **not** filter by collection ownership: locked faces can and do appear in gameplay, and gameplay does not require prior collection unlock. This decoupling is important and should remain explicit in product copy.

### Current schedule, Levels 1–50

| Level | Faces unlocked at completion | Cumulative faces |
|---:|---|---:|
| 1 | aban, abe_dua, abode_santann, abusua_pa, adinkrahene, agyindawuru, akoben, denkyem, dwennimmen, gye_nyame | 10 |
| 2 | nea_onnim | 11 |
| 3 | — | 11 |
| 4 | nkyinkyim | 12 |
| 5 | — | 12 |
| 6 | nsoromma | 13 |
| 7 | — | 13 |
| 8 | odo_nnyew_fie_kwan | 14 |
| 9 | — | 14 |
| 10 | akoma | 15 |
| 11 | — | 15 |
| 12 | akoma_ntoaso | 16 |
| 13 | — | 16 |
| 14 | ananse_ntentan | 17 |
| 15 | — | 17 |
| 16 | ani_bere_a_enso_gya | 18 |
| 17 | — | 18 |
| 18 | anyi_me_aye_a | 19 |
| 19 | — | 19 |
| 20 | aponkyerene_wu_a | 20 |
| 21 | — | 20 |
| 22 | asaawa | 21 |
| 23 | — | 21 |
| 24 | asae_ye_duru | 22 |
| 25 | — | 22 |
| 26 | asetena_pa | 23 |
| 27 | — | 23 |
| 28 | aya | 24 |
| 29 | — | 24 |
| 30 | bese_saka | 25 |
| 31 | — | 25 |
| 32 | bi_nka_bi | 26 |
| 33 | — | 26 |
| 34 | boa_me_na_me_mmoa_wo | 27 |
| 35 | — | 27 |
| 36 | boafo_ye_na | 28 |
| 37 | — | 28 |
| 38 | dame_dame | 29 |
| 39 | — | 29 |
| 40 | dono | 30 |
| 41 | — | 30 |
| 42 | dono_ntoaso | 31 |
| 43 | — | 31 |
| 44 | duafe | 32 |
| 45 | — | 32 |
| 46 | dwantire | 33 |
| 47 | — | 33 |
| 48 | eban | 34 |
| 49 | — | 34 |
| 50 | akofena | 35 |

The early surge is caused by treating the ten-face “starter” set as a Level 1 batch, followed by forty unlocks in only 79 levels (roughly one every two levels). It is not caused by tile copy counts.

## 3. Hardcoded or semantically coupled 200-level assumptions

| Location | Assumption / impact |
|---|---|
| `lib/core/constants/chapter_data.dart:kChapters` | Last range ends at 200; all chapters are ten levels. |
| `lib/core/constants/tile_unlock_data.dart:kFinalCampaignUnlockLevel` | Collection schedule ends at 200; its name incorrectly implies campaign end. |
| `lib/core/economy/economy_service.dart:_isAchievementEarned` | `complete_campaign` compares against the unlock constant, so Level 200 remains a false finale after expansion unless fixed. |
| `lib/screens/journey/journey_screen.dart:_ChapterCard.build` | Label says `$completed/10 complete`; incompatible with 20-level chapters. |
| `test/game_provider_startup_test.dart` | Expects length/IDs through 200, samples Level 200, and migration/unlock behavior around that boundary. |
| `test/board_layout_geometry_test.dart` | Expects exactly 200 boards. |
| `test/tile_unlock_rules_test.dart` | Requires final unlock at 200 and checks ranges ending at 200. |
| `test/economy_service_test.dart` | Uses Level 200 as final collection source. |
| Current generated `kLevels` | `_extendedCampaignLevels` generates only IDs 51–200. |

Literal `200` values in `game_provider.dart`, `game_screen.dart`, and animation widgets are score bonuses, durations, widths, or speeds—not campaign caps. Home percentages, star totals, next-level behavior, result finish routing, chapter-complete finale, and progress clamping derive from `kLevels` and will follow 400 after content exists. `ProgressService.nextUnfinishedLevelId` indexes `kLevels[highestCompletedLevel]`, so it also relies on contiguous, ordered IDs; tests must formalize that invariant.

## 4. Feasibility and recommended chapter structure

The expansion is technically safe if IDs remain contiguous and the campaign-end constant is separated from collection completion. Adopt **20 chapters × 20 levels**. This preserves the current chapter count and cultural/place identities while changing only ranges; it avoids forty chapters in the Journey UI. Existing chapter transaction IDs use chapter indices, so keeping indices 1–20 avoids collisions and preserves already-claimed chapter rewards. However, changing old boundaries would make a player who completed Level 10 no longer “chapter complete” under the new structure. Protect old chapter grants and define new 20-level grants with a new reward-schedule namespace/version; do not revoke the old transactions.

| Ch. | Levels | Stage | Tiles / layers | Families introduced or foregrounded | Milestone | Visual identity | Expected skill |
|---:|---|---|---|---|---|---|---|
| 1 | 1–20 | Beginner | 24–46 / 2–3 | open-diamond, bridge, shrine, layered-diamond | chapter chest; tile if scheduled; cosmetic shard | Accra — beginner visual motif | recognition and free-tile rules |
| 2 | 21–40 | Beginner | 24–46 / 2–3 | shrine, layered-diamond, courtyard, temple-gate | chapter chest; tile if scheduled; cosmetic shard | Kumasi — beginner visual motif | recognition and free-tile rules |
| 3 | 41–60 | Developing | 36–62 / 3 | courtyard, temple-gate, turtle, wings | chapter chest; tile if scheduled; cosmetic shard | Sekondi-Takoradi — developing visual motif | planning two moves ahead |
| 4 | 61–80 | Developing | 36–62 / 3 | turtle, wings, crown, staircase | chapter chest; tile if scheduled; cosmetic shard | Obuasi — developing visual motif | planning two moves ahead |
| 5 | 81–100 | Developing | 36–62 / 3 | crown, staircase, ring, butterfly | chapter chest; tile if scheduled; cosmetic shard | Ho — developing visual motif | planning two moves ahead |
| 6 | 101–120 | Intermediate | 48–80 / 3–4 | ring, butterfly, twin-bridge, split-islands | chapter chest; tile if scheduled; cosmetic shard | Kokrobite — intermediate visual motif | reading bridges and negative space |
| 7 | 121–140 | Intermediate | 48–80 / 3–4 | twin-bridge, split-islands, fortress, twin-towers | chapter chest; tile if scheduled; cosmetic shard | Amanfrom — intermediate visual motif | reading bridges and negative space |
| 8 | 141–160 | Intermediate | 48–80 / 3–4 | fortress, twin-towers, cross, river-path | chapter chest; tile if scheduled; cosmetic shard | Cape-Coast — intermediate visual motif | reading bridges and negative space |
| 9 | 161–180 | Intermediate | 48–80 / 3–4 | cross, river-path, mask, royal-stool | chapter chest; tile if scheduled; cosmetic shard | Tamale — intermediate visual motif | reading bridges and negative space |
| 10 | 181–200 | Advanced | 64–96 / 3–5 | mask, royal-stool | chapter chest; tile if scheduled; cosmetic shard | Koforidua — advanced visual motif | managing constrained openings |
| 11 | 201–220 | Advanced | 64–96 / 3–5 |  | chapter chest; tile if scheduled; cosmetic shard | Ada-Foah — advanced visual motif | managing constrained openings |
| 12 | 221–240 | Advanced | 64–96 / 3–5 |  | chapter chest; tile if scheduled; cosmetic shard | Sunyani — advanced visual motif | managing constrained openings |
| 13 | 241–260 | Advanced | 64–96 / 3–5 |  | chapter chest; tile if scheduled; cosmetic shard | Techiman — advanced visual motif | managing constrained openings |
| 14 | 261–280 | Expert | 78–112 / 4–5 |  | chapter chest; tile if scheduled; cosmetic shard | Wa — expert visual motif | long-sequence planning |
| 15 | 281–300 | Expert | 78–112 / 4–5 |  | chapter chest; tile if scheduled; cosmetic shard | Elmina — expert visual motif | long-sequence planning |
| 16 | 301–320 | Expert | 78–112 / 4–5 |  | chapter chest; tile if scheduled; cosmetic shard | Axim — expert visual motif | long-sequence planning |
| 17 | 321–340 | Expert | 78–112 / 4–5 |  | chapter chest; tile if scheduled; cosmetic shard | Bolgatanga — expert visual motif | long-sequence planning |
| 18 | 341–360 | Master | 90–130 / 4–6 |  | chapter chest; tile if scheduled; cosmetic shard | Winneba — master visual motif | mastery and recovery |
| 19 | 361–380 | Master | 90–130 / 4–6 |  | chapter chest; tile if scheduled; cosmetic shard | Akosombo — master visual motif | mastery and recovery |
| 20 | 381–400 | Master | 90–130 / 4–6 |  | chapter chest; tile if scheduled; cosmetic shard | Aburi — master visual motif | mastery and recovery |

Each chapter should use an internal difficulty wave: levels 1–4 teach/refresh, 5 rewards, 6–8 build, 9 breathes, 10 tests, 11–16 develop, 17 breathes, 18–19 peak, and 20 showcases. Difficulty must be scored across opening choices, density, footprint width/height, layers, bridge count, negative space, symmetry/asymmetry, multipart structure, and symbol-pool size—not tile count alone.

## 5. Recommended data-driven unlock cadence

With 97 faces and a recommended **10-face true starter set at completed level 0**, 87 faces remain. Option A (every 3 levels) finishes around Level 261; B (every 4) around 348; C (every 5) needs 435 levels and cannot unlock all faces; a naive chapter bonus that adds faces accelerates exhaustion. **Option D is best:** spread one face per milestone over Levels 4–400, an average of 4.60 levels, while chapter/ten-level celebrations primarily grant non-face rewards. This uses all 400 levels and never batches ordinary faces.

Model this as immutable data (`TileUnlockMilestone(completedLevel, tileId, rewardType)`) with validation for ordering, unique tile IDs, known IDs, and range 0–400. “Starter” must be an explicit reward type at Level 0, not ten Level 1 rules. Chapter rewards may visually celebrate the scheduled single face but should not add an extra ordinary face unless the collectible catalogue grows.

### Full proposed unlock milestone schedule

| Completed level | Reward type | Tile ID | Chapter | Placement reason |
|---:|---|---|---|---|
| 0 | Starter set | aban | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | abe_dua | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | abode_santann | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | abusua_pa | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | adinkrahene | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | agyindawuru | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | akoben | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | denkyem | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | dwennimmen | Before Chapter 1 | Useful ten-face first board/collection set |
| 0 | Starter set | gye_nyame | Before Chapter 1 | Useful ten-face first board/collection set |
| 4 | Ordinary tile | nea_onnim | 1 | Maintains roughly 4.6-level collection cadence |
| 9 | Ordinary tile | nkyinkyim | 1 | Maintains roughly 4.6-level collection cadence |
| 13 | Ordinary tile | nsoromma | 1 | Maintains roughly 4.6-level collection cadence |
| 18 | Ordinary tile | odo_nnyew_fie_kwan | 1 | Maintains roughly 4.6-level collection cadence |
| 22 | Ordinary tile | akoma | 2 | Maintains roughly 4.6-level collection cadence |
| 27 | Ordinary tile | akoma_ntoaso | 2 | Maintains roughly 4.6-level collection cadence |
| 32 | Ordinary tile | ananse_ntentan | 2 | Maintains roughly 4.6-level collection cadence |
| 36 | Ordinary tile | ani_bere_a_enso_gya | 2 | Maintains roughly 4.6-level collection cadence |
| 41 | Ordinary tile | anyi_me_aye_a | 3 | Maintains roughly 4.6-level collection cadence |
| 45 | Ordinary tile | aponkyerene_wu_a | 3 | Maintains roughly 4.6-level collection cadence |
| 50 | Ordinary tile | asaawa | 3 | Maintains roughly 4.6-level collection cadence |
| 55 | Ordinary tile | asae_ye_duru | 3 | Maintains roughly 4.6-level collection cadence |
| 59 | Ordinary tile | asetena_pa | 3 | Maintains roughly 4.6-level collection cadence |
| 64 | Ordinary tile | aya | 4 | Maintains roughly 4.6-level collection cadence |
| 68 | Ordinary tile | bese_saka | 4 | Maintains roughly 4.6-level collection cadence |
| 73 | Ordinary tile | bi_nka_bi | 4 | Maintains roughly 4.6-level collection cadence |
| 78 | Ordinary tile | boa_me_na_me_mmoa_wo | 4 | Maintains roughly 4.6-level collection cadence |
| 82 | Ordinary tile | boafo_ye_na | 5 | Maintains roughly 4.6-level collection cadence |
| 87 | Ordinary tile | dame_dame | 5 | Maintains roughly 4.6-level collection cadence |
| 91 | Ordinary tile | dono | 5 | Maintains roughly 4.6-level collection cadence |
| 96 | Ordinary tile | dono_ntoaso | 5 | Maintains roughly 4.6-level collection cadence |
| 101 | Ordinary tile | duafe | 6 | Maintains roughly 4.6-level collection cadence |
| 105 | Ordinary tile | dwantire | 6 | Maintains roughly 4.6-level collection cadence |
| 110 | Ordinary tile | eban | 6 | Maintains roughly 4.6-level collection cadence |
| 115 | Ordinary tile | akofena | 6 | Maintains roughly 4.6-level collection cadence |
| 119 | Ordinary tile | akoko_nan | 6 | Maintains roughly 4.6-level collection cadence |
| 124 | Ordinary tile | funtumfunefu_denkyemfunefu | 7 | Maintains roughly 4.6-level collection cadence |
| 128 | Ordinary tile | sankofa2 | 7 | Maintains roughly 4.6-level collection cadence |
| 133 | Ordinary tile | fawohodie | 7 | Maintains roughly 4.6-level collection cadence |
| 138 | Ordinary tile | fafanto | 7 | Maintains roughly 4.6-level collection cadence |
| 142 | Ordinary tile | fihankra | 8 | Maintains roughly 4.6-level collection cadence |
| 147 | Ordinary tile | fofo | 8 | Maintains roughly 4.6-level collection cadence |
| 151 | Ordinary tile | epa | 8 | Maintains roughly 4.6-level collection cadence |
| 156 | Ordinary tile | ese_ne_tekrema | 8 | Maintains roughly 4.6-level collection cadence |
| 161 | Ordinary tile | esono_anatam | 9 | Maintains roughly 4.6-level collection cadence |
| 165 | Ordinary tile | gyamu_atiko | 9 | Maintains roughly 4.6-level collection cadence |
| 170 | Ordinary tile | hwehwemudua | 9 | Maintains roughly 4.6-level collection cadence |
| 174 | Ordinary tile | hye_wo_nhye | 9 | Maintains roughly 4.6-level collection cadence |
| 179 | Ordinary tile | kete_pa | 9 | Maintains roughly 4.6-level collection cadence |
| 184 | Ordinary tile | kokuromotie | 10 | Maintains roughly 4.6-level collection cadence |
| 188 | Ordinary tile | kramo_bone_amma_yeanhu_kramo_pa | 10 | Maintains roughly 4.6-level collection cadence |
| 193 | Ordinary tile | krapa | 10 | Maintains roughly 4.6-level collection cadence |
| 197 | Ordinary tile | kuronti_ne_akwamu | 10 | Maintains roughly 4.6-level collection cadence |
| 202 | Ordinary tile | kyemfere | 11 | Maintains roughly 4.6-level collection cadence |
| 207 | Ordinary tile | mako | 11 | Maintains roughly 4.6-level collection cadence |
| 211 | Ordinary tile | mate_masie | 11 | Maintains roughly 4.6-level collection cadence |
| 216 | Ordinary tile | mekyea_wo | 11 | Maintains roughly 4.6-level collection cadence |
| 220 | Tile + chapter milestone | menso_wo_kenten | 11 | Pairs discovery with chapter celebration |
| 225 | Ordinary tile | mframadan | 12 | Maintains roughly 4.6-level collection cadence |
| 230 | Ordinary tile | mmeramubere | 12 | Maintains roughly 4.6-level collection cadence |
| 234 | Ordinary tile | mmeramutene | 12 | Maintains roughly 4.6-level collection cadence |
| 239 | Ordinary tile | mmere_dane | 12 | Maintains roughly 4.6-level collection cadence |
| 243 | Ordinary tile | mpatapo | 13 | Maintains roughly 4.6-level collection cadence |
| 248 | Ordinary tile | mpuannum | 13 | Maintains roughly 4.6-level collection cadence |
| 253 | Ordinary tile | nea_oretwa_sa | 13 | Maintains roughly 4.6-level collection cadence |
| 257 | Ordinary tile | neo_ope_se_obedi_hene | 13 | Maintains roughly 4.6-level collection cadence |
| 262 | Ordinary tile | nkonsonkonson | 14 | Maintains roughly 4.6-level collection cadence |
| 266 | Ordinary tile | nkotimsefo_mpua | 14 | Maintains roughly 4.6-level collection cadence |
| 271 | Ordinary tile | nkrabea | 14 | Maintains roughly 4.6-level collection cadence |
| 276 | Ordinary tile | nkyemu | 14 | Maintains roughly 4.6-level collection cadence |
| 280 | Tile + chapter milestone | nnamfo_pa_baanu | 14 | Pairs discovery with chapter celebration |
| 285 | Ordinary tile | nsaa | 15 | Maintains roughly 4.6-level collection cadence |
| 289 | Ordinary tile | nserewa | 15 | Maintains roughly 4.6-level collection cadence |
| 294 | Ordinary tile | nteasee | 15 | Maintains roughly 4.6-level collection cadence |
| 299 | Ordinary tile | nyame_baatanpa | 15 | Maintains roughly 4.6-level collection cadence |
| 303 | Ordinary tile | nyame_biribi_wo_soro | 16 | Maintains roughly 4.6-level collection cadence |
| 308 | Ordinary tile | nyame_dua | 16 | Maintains roughly 4.6-level collection cadence |
| 313 | Ordinary tile | nyame_nti | 16 | Maintains roughly 4.6-level collection cadence |
| 317 | Ordinary tile | nyame_nwa_na_mawu | 16 | Maintains roughly 4.6-level collection cadence |
| 322 | Ordinary tile | nyansapo | 17 | Maintains roughly 4.6-level collection cadence |
| 326 | Ordinary tile | obohemaa | 17 | Maintains roughly 4.6-level collection cadence |
| 331 | Ordinary tile | okodee_mmowere | 17 | Maintains roughly 4.6-level collection cadence |
| 336 | Ordinary tile | okuafo_pa | 17 | Maintains roughly 4.6-level collection cadence |
| 340 | Tile + chapter milestone | osram_ne_nsoromma | 17 | Pairs discovery with chapter celebration |
| 345 | Ordinary tile | owo_foro_adobe | 18 | Maintains roughly 4.6-level collection cadence |
| 349 | Ordinary tile | owuo_atwedee | 18 | Maintains roughly 4.6-level collection cadence |
| 354 | Ordinary tile | pempamsie | 18 | Maintains roughly 4.6-level collection cadence |
| 359 | Ordinary tile | sepow | 18 | Maintains roughly 4.6-level collection cadence |
| 363 | Ordinary tile | sesa_wo_suban | 19 | Maintains roughly 4.6-level collection cadence |
| 368 | Ordinary tile | som_onyankopon | 19 | Maintains roughly 4.6-level collection cadence |
| 372 | Ordinary tile | sunsum | 19 | Maintains roughly 4.6-level collection cadence |
| 377 | Ordinary tile | tabono | 19 | Maintains roughly 4.6-level collection cadence |
| 382 | Ordinary tile | tamfo_bebre | 20 | Maintains roughly 4.6-level collection cadence |
| 386 | Ordinary tile | uac_nkanea | 20 | Maintains roughly 4.6-level collection cadence |
| 391 | Ordinary tile | wawa_aba | 20 | Maintains roughly 4.6-level collection cadence |
| 395 | Ordinary tile | wo_nsa_da_mu_a | 20 | Maintains roughly 4.6-level collection cadence |
| 400 | Tile + chapter milestone | woforo_dua_pa_a | 20 | Pairs discovery with chapter celebration |

## 6. Existing-player protection and migration

Use **Approach B**, with Approach A as the storage invariant: effective unlocks are the union of the explicit persisted set, all starter IDs, legacy-schedule entitlements through the player’s pre-migration completion, and new-schedule milestones through current completion. Never write `false`, delete an unlock key, or rebuild the set from only the new formula. A one-time snapshot alone (C) is less robust if interrupted or if old states contain sparse completion evidence.

Introduce campaign progress schema 4 plus a distinct collection schedule version, e.g. `collection_unlock_schedule_version=2`. Before migration, read and retain the explicit set and infer legacy entitlements with the frozen v1 rule table using the pre-migration highest completion. Write the union one key at a time, then write the version marker last. Re-running is idempotent. On any write failure, leave the marker old so startup retries; additive writes already completed are harmless. SharedPreferences has no transaction/backup, so optionally persist a compact migration audit snapshot (old version, highest completion, hash/count of prior IDs) before writes and never use it to overwrite currency, purchases, themes, entitlements, boosters, stars, or completion.

Keep IDs 1–200 and their result keys unchanged. Levels 201–400 naturally remain locked because Level 201 checks completion of 200; players who already completed 200 should immediately unlock 201, which is forward progress, not a regression. Preserve old `economy_tx_` keys. Version new chapter milestone transaction IDs (`chapter_v2:...`) and explicitly decide whether legacy Chapter-10 completions qualify for the newly positioned 20-level chest.

Test fresh, partially progressed, Level-200-complete, sparse/corrupt-but-readable, already-migrated, interrupted, and purchased-entitlement fixtures. Rollback must keep schema-4 additive unlock flags; an older binary will ignore unknown Levels 201–400 but must not erase them. Do not ship a rollback that resets preferences.

## 7. Layout-library strategy and reuse rules

Target **72 strong base templates**, **3–5 production variants per family/template as needed**, and **12 one-off showcase layouts**, yielding roughly **220–260 coordinate-distinct production layouts** assigned across 400 levels. The remaining assignments are controlled returns, not symbol-only reskins. Organize about 20–24 visual families (diamonds, shrines, gates, bridges, turtles, butterflies/wings, crowns, courtyards, fortresses/towers, stairs/crosses/rings, masks/stools, river/split-islands, and Adinkra-inspired finales).

Rules:

- Never repeat identical coordinates in adjacent levels; set the exact minimum identical-coordinate repetition distance to **40 levels (two chapters)**.
- Never reuse a showcase layout within **100 levels**; finale layouts are single-use.
- A family may return after four levels only with a visibly different silhouette, density, layer topology, bridge structure, or negative space. Mirroring alone is insufficient within the same chapter.
- Symbol changes, copy-plan changes, names, or color changes do not constitute a layout variant.
- Each chapter needs at least six families, four chapter-distinct templates/variants, two breathers, and one showcase.
- Cap any one family at three appearances per chapter and avoid the same family at both adjacent chapter boundaries.
- Track coordinate hashes, family IDs, template IDs, variant IDs, and last-use distance in validation tooling.

The current 43-entry library includes pilots and five approved early layouts, so not every entry should be counted as production-ready. Build the 72-template target gradually after a duplicate-coordinate/family inventory.

## 8. Full Levels 1–400 assignment roadmap

All rows below are planning estimates. Placeholder IDs do not exist in production. “New template proposal” is a production checkpoint request, not authorization to create coordinates. Levels 9 and 17 within each chapter are deliberate breathers. The CSV is authoritative for tooling.

| ID | Ch. | Band | Layout ID | Family | Variant | Tiles | Pairs | Layers | Opening target | Strategy | Reward | Tile unlock | Display concept |
|---:|---:|---|---|---|---|---:|---:|---:|---|---|---|---|---|
| 1 | 1 | Beginner | earlyOpenDiamond01 | open-diamond | approved-01 | 24 | 12 | 2 | 2+ legal, safe pairs | approved existing template | normal |  | First Symbols |
| 2 | 1 | Beginner | earlyOpenDiamond02 | open-diamond | approved-02 | 28 | 14 | 2 | 2+ legal, safe pairs | approved existing template | normal |  | New Roots |
| 3 | 1 | Beginner | earlyBridge01 | bridge | approved-01 | 30 | 15 | 2 | 2+ legal, safe pairs | approved existing template | normal |  | Side Paths |
| 4 | 1 | Beginner | earlyShrine01 | shrine | approved-01 | 32 | 16 | 3 | 2+ legal, safe pairs | approved existing template | normal | nea_onnim | Small Turtle |
| 5 | 1 | Beginner | earlyLayeredDiamond01 | layered-diamond | approved-01 | 34 | 17 | 3 | 2+ legal, safe pairs | approved existing template | 5 |  | Shrine Steps |
| 6 | 1 | Beginner | proposal_open_diamond_dense_01 | open-diamond | dense | 30 | 15 | 2 | 2+ legal, safe pairs | new template proposal | normal |  | Golden Staircase |
| 7 | 1 | Beginner | proposal_open_diamond_tall_02 | open-diamond | tall | 32 | 16 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Ancestral Ring |
| 8 | 1 | Beginner | proposal_bridge_asymmetric_03 | bridge | asymmetric | 32 | 16 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Royal Butterfly |
| 9 | 1 | Beginner | proposal_bridge_more_bridges_04 | bridge | more-bridges | 30 | 15 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal | nkyinkyim | Memory Twin Bridge |
| 10 | 1 | Beginner | proposal_shrine_stepped_05 | shrine | stepped | 34 | 17 | 2 | 2+ legal, safe pairs | reused meaningful variant | 10+5 |  | Wisdom Split Islands |
| 11 | 1 | Beginner | proposal_shrine_twin_crown_06 | shrine | twin-crown | 36 | 18 | 3 | 2+ legal, safe pairs | new template proposal | normal |  | Unity Fortress |
| 12 | 1 | Beginner | proposal_layered_diamond_open_07 | layered-diamond | open | 38 | 19 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Courage Twin Towers |
| 13 | 1 | Beginner | proposal_layered_diamond_wide_08 | layered-diamond | wide | 38 | 19 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal | nsoromma | Journey Cross |
| 14 | 1 | Beginner | proposal_courtyard_hollow_centre_09 | courtyard | hollow-centre | 40 | 20 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Heritage River Path |
| 15 | 1 | Beginner | proposal_courtyard_layered_10 | courtyard | layered | 40 | 20 | 3 | 2+ legal, safe pairs | reused meaningful variant | 5 |  | River Mask |
| 16 | 1 | Beginner | proposal_temple_gate_mirrored_11 | temple-gate | mirrored | 42 | 21 | 3 | 2+ legal, safe pairs | new template proposal | normal |  | Golden Royal Stool |
| 17 | 1 | Beginner | proposal_temple_gate_compact_12 | temple-gate | compact | 30 | 15 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Ancestral Open Diamond |
| 18 | 1 | Beginner | proposal_turtle_expanded_base_13 | turtle | expanded-base | 44 | 22 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal | odo_nnyew_fie_kwan | Royal Bridge |
| 19 | 1 | Beginner | proposal_turtle_dense_14 | turtle | dense | 46 | 23 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Memory Shrine |
| 20 | 1 | Beginner | proposal_wings_tall_15 | wings | tall | 46 | 23 | 3 | 2+ legal, safe pairs | new template proposal | chapter+10+5 |  | Wisdom Layered Diamond |
| 21 | 2 | Beginner | proposal_wings_more_bridges_16 | wings | more-bridges | 24 | 12 | 2 | 2+ legal, safe pairs | new template proposal | normal |  | Courage Courtyard |
| 22 | 2 | Beginner | proposal_crown_stepped_17 | crown | stepped | 26 | 13 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal | akoma | Journey Temple Gate |
| 23 | 2 | Beginner | proposal_crown_twin_crown_18 | crown | twin-crown | 26 | 13 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Heritage Turtle |
| 24 | 2 | Beginner | proposal_staircase_open_19 | staircase | open | 28 | 14 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | River Wings |
| 25 | 2 | Beginner | proposal_staircase_wide_20 | staircase | wide | 30 | 15 | 2 | 2+ legal, safe pairs | reused meaningful variant | 5 |  | Golden Crown |
| 26 | 2 | Beginner | proposal_ring_hollow_centre_21 | ring | hollow-centre | 30 | 15 | 2 | 2+ legal, safe pairs | new template proposal | normal |  | Ancestral Staircase |
| 27 | 2 | Beginner | proposal_ring_layered_22 | ring | layered | 32 | 16 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal | akoma_ntoaso | Royal Ring |
| 28 | 2 | Beginner | proposal_butterfly_mirrored_23 | butterfly | mirrored | 32 | 16 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Memory Butterfly |
| 29 | 2 | Beginner | proposal_butterfly_compact_24 | butterfly | compact | 30 | 15 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Wisdom Twin Bridge |
| 30 | 2 | Beginner | proposal_twin_bridge_expanded_base_25 | twin-bridge | expanded-base | 34 | 17 | 2 | 2+ legal, safe pairs | reused meaningful variant | 10+5 |  | Unity Split Islands |
| 31 | 2 | Beginner | proposal_twin_bridge_dense_26 | twin-bridge | dense | 36 | 18 | 3 | 2+ legal, safe pairs | new template proposal | normal |  | Courage Fortress |
| 32 | 2 | Beginner | proposal_split_islands_tall_27 | split-islands | tall | 38 | 19 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal | ananse_ntentan | Journey Twin Towers |
| 33 | 2 | Beginner | proposal_split_islands_asymmetric_28 | split-islands | asymmetric | 38 | 19 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Heritage Cross |
| 34 | 2 | Beginner | proposal_fortress_more_bridges_29 | fortress | more-bridges | 40 | 20 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | River River Path |
| 35 | 2 | Beginner | proposal_fortress_stepped_30 | fortress | stepped | 40 | 20 | 3 | 2+ legal, safe pairs | reused meaningful variant | 5 |  | Golden Mask |
| 36 | 2 | Beginner | proposal_twin_towers_twin_crown_31 | twin-towers | twin-crown | 42 | 21 | 3 | 2+ legal, safe pairs | new template proposal | normal | ani_bere_a_enso_gya | Ancestral Royal Stool |
| 37 | 2 | Beginner | proposal_twin_towers_open_32 | twin-towers | open | 30 | 15 | 2 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Royal Open Diamond |
| 38 | 2 | Beginner | proposal_cross_wide_33 | cross | wide | 44 | 22 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Memory Bridge |
| 39 | 2 | Beginner | proposal_cross_hollow_centre_34 | cross | hollow-centre | 46 | 23 | 3 | 2+ legal, safe pairs | reused meaningful variant | normal |  | Wisdom Shrine |
| 40 | 2 | Beginner | proposal_river_path_layered_35 | river-path | layered | 46 | 23 | 3 | 2+ legal, safe pairs | new template proposal | chapter+10+5 |  | Unity Layered Diamond |
| 41 | 3 | Developing | proposal_river_path_compact_36 | river-path | compact | 36 | 18 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal | anyi_me_aye_a | Journey Courtyard |
| 42 | 3 | Developing | proposal_mask_expanded_base_37 | mask | expanded-base | 38 | 19 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Heritage Temple Gate |
| 43 | 3 | Developing | proposal_mask_dense_38 | mask | dense | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | River Turtle |
| 44 | 3 | Developing | proposal_royal_stool_tall_39 | royal-stool | tall | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Golden Wings |
| 45 | 3 | Developing | proposal_royal_stool_asymmetric_40 | royal-stool | asymmetric | 42 | 21 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 | aponkyerene_wu_a | Ancestral Crown |
| 46 | 3 | Developing | proposal_open_diamond_more_bridges_41 | open-diamond | more-bridges | 44 | 22 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Royal Staircase |
| 47 | 3 | Developing | proposal_open_diamond_stepped_42 | open-diamond | stepped | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Memory Ring |
| 48 | 3 | Developing | proposal_bridge_twin_crown_43 | bridge | twin-crown | 46 | 23 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Wisdom Butterfly |
| 49 | 3 | Developing | proposal_bridge_open_44 | bridge | open | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Unity Twin Bridge |
| 50 | 3 | Developing | proposal_shrine_wide_45 | shrine | wide | 48 | 24 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 10+5 | asaawa | Courage Split Islands |
| 51 | 3 | Developing | proposal_shrine_hollow_centre_46 | shrine | hollow-centre | 50 | 25 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Journey Fortress |
| 52 | 3 | Developing | proposal_layered_diamond_layered_47 | layered-diamond | layered | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Heritage Twin Towers |
| 53 | 3 | Developing | proposal_layered_diamond_mirrored_48 | layered-diamond | mirrored | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | River Cross |
| 54 | 3 | Developing | proposal_courtyard_compact_49 | courtyard | compact | 54 | 27 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Golden River Path |
| 55 | 3 | Developing | proposal_courtyard_expanded_base_50 | courtyard | expanded-base | 56 | 28 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 | asae_ye_duru | Ancestral Mask |
| 56 | 3 | Developing | proposal_temple_gate_dense_51 | temple-gate | dense | 58 | 29 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Royal Royal Stool |
| 57 | 3 | Developing | proposal_temple_gate_tall_52 | temple-gate | tall | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Memory Open Diamond |
| 58 | 3 | Developing | proposal_turtle_asymmetric_53 | turtle | asymmetric | 60 | 30 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Wisdom Bridge |
| 59 | 3 | Developing | proposal_turtle_more_bridges_54 | turtle | more-bridges | 62 | 31 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | asetena_pa | Unity Shrine |
| 60 | 3 | Developing | proposal_wings_stepped_55 | wings | stepped | 62 | 31 | 3 | 2+ safe pairs; moderate choice | new template proposal | chapter+10+5 |  | Courage Layered Diamond |
| 61 | 4 | Developing | proposal_wings_open_56 | wings | open | 36 | 18 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Heritage Courtyard |
| 62 | 4 | Developing | proposal_crown_wide_57 | crown | wide | 38 | 19 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | River Temple Gate |
| 63 | 4 | Developing | proposal_crown_hollow_centre_58 | crown | hollow-centre | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Golden Turtle |
| 64 | 4 | Developing | proposal_staircase_layered_59 | staircase | layered | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | aya | Ancestral Wings |
| 65 | 4 | Developing | proposal_staircase_mirrored_60 | staircase | mirrored | 42 | 21 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 |  | Royal Crown |
| 66 | 4 | Developing | proposal_ring_compact_61 | ring | compact | 44 | 22 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Memory Staircase |
| 67 | 4 | Developing | proposal_ring_expanded_base_62 | ring | expanded-base | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Wisdom Ring |
| 68 | 4 | Developing | proposal_butterfly_dense_63 | butterfly | dense | 46 | 23 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | bese_saka | Unity Butterfly |
| 69 | 4 | Developing | proposal_butterfly_tall_64 | butterfly | tall | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Courage Twin Bridge |
| 70 | 4 | Developing | proposal_twin_bridge_asymmetric_65 | twin-bridge | asymmetric | 48 | 24 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 10+5 |  | Journey Split Islands |
| 71 | 4 | Developing | proposal_twin_bridge_more_bridges_66 | twin-bridge | more-bridges | 50 | 25 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Heritage Fortress |
| 72 | 4 | Developing | proposal_split_islands_stepped_67 | split-islands | stepped | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | River Twin Towers |
| 73 | 4 | Developing | proposal_split_islands_twin_crown_68 | split-islands | twin-crown | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | bi_nka_bi | Golden Cross |
| 74 | 4 | Developing | proposal_fortress_open_69 | fortress | open | 54 | 27 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Ancestral River Path |
| 75 | 4 | Developing | proposal_fortress_wide_70 | fortress | wide | 56 | 28 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 |  | Royal Mask |
| 76 | 4 | Developing | proposal_twin_towers_hollow_centre_71 | twin-towers | hollow-centre | 58 | 29 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Memory Royal Stool |
| 77 | 4 | Developing | proposal_twin_towers_layered_72 | twin-towers | layered | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Wisdom Open Diamond |
| 78 | 4 | Developing | proposal_cross_mirrored_01 | cross | mirrored | 60 | 30 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | boa_me_na_me_mmoa_wo | Unity Bridge |
| 79 | 4 | Developing | proposal_cross_compact_02 | cross | compact | 62 | 31 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Courage Shrine |
| 80 | 4 | Developing | proposal_river_path_expanded_base_03 | river-path | expanded-base | 62 | 31 | 3 | 2+ safe pairs; moderate choice | new template proposal | chapter+10+5 |  | Journey Layered Diamond |
| 81 | 5 | Developing | proposal_river_path_tall_04 | river-path | tall | 36 | 18 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | River Courtyard |
| 82 | 5 | Developing | proposal_mask_asymmetric_05 | mask | asymmetric | 38 | 19 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | boafo_ye_na | Golden Temple Gate |
| 83 | 5 | Developing | proposal_mask_more_bridges_06 | mask | more-bridges | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Ancestral Turtle |
| 84 | 5 | Developing | proposal_royal_stool_stepped_07 | royal-stool | stepped | 40 | 20 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Royal Wings |
| 85 | 5 | Developing | proposal_royal_stool_twin_crown_08 | royal-stool | twin-crown | 42 | 21 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 |  | Memory Crown |
| 86 | 5 | Developing | proposal_open_diamond_open_09 | open-diamond | open | 44 | 22 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal |  | Wisdom Staircase |
| 87 | 5 | Developing | proposal_open_diamond_wide_10 | open-diamond | wide | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal | dame_dame | Unity Ring |
| 88 | 5 | Developing | proposal_bridge_hollow_centre_11 | bridge | hollow-centre | 46 | 23 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Courage Butterfly |
| 89 | 5 | Developing | proposal_bridge_layered_12 | bridge | layered | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Journey Twin Bridge |
| 90 | 5 | Developing | proposal_shrine_mirrored_13 | shrine | mirrored | 48 | 24 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 10+5 |  | Heritage Split Islands |
| 91 | 5 | Developing | proposal_shrine_compact_14 | shrine | compact | 50 | 25 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal | dono | River Fortress |
| 92 | 5 | Developing | proposal_layered_diamond_expanded_base_15 | layered-diamond | expanded-base | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Golden Twin Towers |
| 93 | 5 | Developing | proposal_layered_diamond_dense_16 | layered-diamond | dense | 52 | 26 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Ancestral Cross |
| 94 | 5 | Developing | proposal_courtyard_tall_17 | courtyard | tall | 54 | 27 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Royal River Path |
| 95 | 5 | Developing | proposal_courtyard_asymmetric_18 | courtyard | asymmetric | 56 | 28 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | 5 |  | Memory Mask |
| 96 | 5 | Developing | proposal_temple_gate_more_bridges_19 | temple-gate | more-bridges | 58 | 29 | 3 | 2+ safe pairs; moderate choice | new template proposal | normal | dono_ntoaso | Wisdom Royal Stool |
| 97 | 5 | Developing | proposal_temple_gate_stepped_20 | temple-gate | stepped | 44 | 22 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Unity Open Diamond |
| 98 | 5 | Developing | proposal_turtle_twin_crown_21 | turtle | twin-crown | 60 | 30 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Courage Bridge |
| 99 | 5 | Developing | proposal_turtle_open_22 | turtle | open | 62 | 31 | 3 | 2+ safe pairs; moderate choice | reused meaningful variant | normal |  | Journey Shrine |
| 100 | 5 | Developing | proposal_wings_wide_23 | wings | wide | 62 | 31 | 3 | 2+ safe pairs; moderate choice | new template proposal | major+chapter+10+5 |  | Heritage Layered Diamond |
| 101 | 6 | Intermediate | proposal_wings_layered_24 | wings | layered | 48 | 24 | 3 | 2 safe pairs; constrained | new template proposal | normal | duafe | Golden Courtyard |
| 102 | 6 | Intermediate | proposal_crown_mirrored_25 | crown | mirrored | 50 | 25 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Ancestral Temple Gate |
| 103 | 6 | Intermediate | proposal_crown_compact_26 | crown | compact | 52 | 26 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Royal Turtle |
| 104 | 6 | Intermediate | proposal_staircase_expanded_base_27 | staircase | expanded-base | 54 | 27 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Memory Wings |
| 105 | 6 | Intermediate | proposal_staircase_dense_28 | staircase | dense | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | 5 | dwantire | Wisdom Crown |
| 106 | 6 | Intermediate | proposal_ring_tall_29 | ring | tall | 56 | 28 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Unity Staircase |
| 107 | 6 | Intermediate | proposal_ring_asymmetric_30 | ring | asymmetric | 58 | 29 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Courage Ring |
| 108 | 6 | Intermediate | proposal_butterfly_more_bridges_31 | butterfly | more-bridges | 60 | 30 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Journey Butterfly |
| 109 | 6 | Intermediate | proposal_butterfly_stepped_32 | butterfly | stepped | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Heritage Twin Bridge |
| 110 | 6 | Intermediate | proposal_twin_bridge_twin_crown_33 | twin-bridge | twin-crown | 64 | 32 | 3 | 2 safe pairs; constrained | reused meaningful variant | 10+5 | eban | River Split Islands |
| 111 | 6 | Intermediate | proposal_twin_bridge_open_34 | twin-bridge | open | 66 | 33 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Golden Fortress |
| 112 | 6 | Intermediate | proposal_split_islands_wide_35 | split-islands | wide | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Ancestral Twin Towers |
| 113 | 6 | Intermediate | proposal_split_islands_hollow_centre_36 | split-islands | hollow-centre | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Royal Cross |
| 114 | 6 | Intermediate | proposal_fortress_layered_37 | fortress | layered | 70 | 35 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Memory River Path |
| 115 | 6 | Intermediate | proposal_fortress_mirrored_38 | fortress | mirrored | 72 | 36 | 4 | 2 safe pairs; constrained | reused meaningful variant | 5 | akofena | Wisdom Mask |
| 116 | 6 | Intermediate | proposal_twin_towers_compact_39 | twin-towers | compact | 74 | 37 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Unity Royal Stool |
| 117 | 6 | Intermediate | proposal_twin_towers_expanded_base_40 | twin-towers | expanded-base | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Courage Open Diamond |
| 118 | 6 | Intermediate | proposal_cross_dense_41 | cross | dense | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Journey Bridge |
| 119 | 6 | Intermediate | proposal_cross_tall_42 | cross | tall | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal | akoko_nan | Heritage Shrine |
| 120 | 6 | Intermediate | proposal_river_path_asymmetric_43 | river-path | asymmetric | 80 | 40 | 4 | 2 safe pairs; constrained | new template proposal | chapter+10+5 |  | River Layered Diamond |
| 121 | 7 | Intermediate | proposal_river_path_stepped_44 | river-path | stepped | 48 | 24 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Ancestral Courtyard |
| 122 | 7 | Intermediate | proposal_mask_twin_crown_45 | mask | twin-crown | 50 | 25 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Royal Temple Gate |
| 123 | 7 | Intermediate | proposal_mask_open_46 | mask | open | 52 | 26 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Memory Turtle |
| 124 | 7 | Intermediate | proposal_royal_stool_wide_47 | royal-stool | wide | 54 | 27 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal | funtumfunefu_denkyemfunefu | Wisdom Wings |
| 125 | 7 | Intermediate | proposal_royal_stool_hollow_centre_48 | royal-stool | hollow-centre | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | 5 |  | Unity Crown |
| 126 | 7 | Intermediate | proposal_open_diamond_layered_49 | open-diamond | layered | 56 | 28 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Courage Staircase |
| 127 | 7 | Intermediate | proposal_open_diamond_mirrored_50 | open-diamond | mirrored | 58 | 29 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Journey Ring |
| 128 | 7 | Intermediate | proposal_bridge_compact_51 | bridge | compact | 60 | 30 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal | sankofa2 | Heritage Butterfly |
| 129 | 7 | Intermediate | proposal_bridge_expanded_base_52 | bridge | expanded-base | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Twin Bridge |
| 130 | 7 | Intermediate | proposal_shrine_dense_53 | shrine | dense | 64 | 32 | 3 | 2 safe pairs; constrained | reused meaningful variant | 10+5 |  | Golden Split Islands |
| 131 | 7 | Intermediate | proposal_shrine_tall_54 | shrine | tall | 66 | 33 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Ancestral Fortress |
| 132 | 7 | Intermediate | proposal_layered_diamond_asymmetric_55 | layered-diamond | asymmetric | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Royal Twin Towers |
| 133 | 7 | Intermediate | proposal_layered_diamond_more_bridges_56 | layered-diamond | more-bridges | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal | fawohodie | Memory Cross |
| 134 | 7 | Intermediate | proposal_courtyard_stepped_57 | courtyard | stepped | 70 | 35 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Wisdom River Path |
| 135 | 7 | Intermediate | proposal_courtyard_twin_crown_58 | courtyard | twin-crown | 72 | 36 | 4 | 2 safe pairs; constrained | reused meaningful variant | 5 |  | Unity Mask |
| 136 | 7 | Intermediate | proposal_temple_gate_open_59 | temple-gate | open | 74 | 37 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Courage Royal Stool |
| 137 | 7 | Intermediate | proposal_temple_gate_wide_60 | temple-gate | wide | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Journey Open Diamond |
| 138 | 7 | Intermediate | proposal_turtle_hollow_centre_61 | turtle | hollow-centre | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal | fafanto | Heritage Bridge |
| 139 | 7 | Intermediate | proposal_turtle_layered_62 | turtle | layered | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Shrine |
| 140 | 7 | Intermediate | proposal_wings_mirrored_63 | wings | mirrored | 80 | 40 | 4 | 2 safe pairs; constrained | new template proposal | chapter+10+5 |  | Golden Layered Diamond |
| 141 | 8 | Intermediate | proposal_wings_expanded_base_64 | wings | expanded-base | 48 | 24 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Royal Courtyard |
| 142 | 8 | Intermediate | proposal_crown_dense_65 | crown | dense | 50 | 25 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal | fihankra | Memory Temple Gate |
| 143 | 8 | Intermediate | proposal_crown_tall_66 | crown | tall | 52 | 26 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Wisdom Turtle |
| 144 | 8 | Intermediate | proposal_staircase_asymmetric_67 | staircase | asymmetric | 54 | 27 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Unity Wings |
| 145 | 8 | Intermediate | proposal_staircase_more_bridges_68 | staircase | more-bridges | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | 5 |  | Courage Crown |
| 146 | 8 | Intermediate | proposal_ring_stepped_69 | ring | stepped | 56 | 28 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Journey Staircase |
| 147 | 8 | Intermediate | proposal_ring_twin_crown_70 | ring | twin-crown | 58 | 29 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal | fofo | Heritage Ring |
| 148 | 8 | Intermediate | proposal_butterfly_open_71 | butterfly | open | 60 | 30 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Butterfly |
| 149 | 8 | Intermediate | proposal_butterfly_wide_72 | butterfly | wide | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Golden Twin Bridge |
| 150 | 8 | Intermediate | proposal_twin_bridge_hollow_centre_01 | twin-bridge | hollow-centre | 64 | 32 | 3 | 2 safe pairs; constrained | reused meaningful variant | 10+5 |  | Ancestral Split Islands |
| 151 | 8 | Intermediate | proposal_twin_bridge_layered_02 | twin-bridge | layered | 66 | 33 | 4 | 2 safe pairs; constrained | new template proposal | normal | epa | Royal Fortress |
| 152 | 8 | Intermediate | proposal_split_islands_mirrored_03 | split-islands | mirrored | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Memory Twin Towers |
| 153 | 8 | Intermediate | proposal_split_islands_compact_04 | split-islands | compact | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Wisdom Cross |
| 154 | 8 | Intermediate | proposal_fortress_expanded_base_05 | fortress | expanded-base | 70 | 35 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Unity River Path |
| 155 | 8 | Intermediate | proposal_fortress_dense_06 | fortress | dense | 72 | 36 | 4 | 2 safe pairs; constrained | reused meaningful variant | 5 |  | Courage Mask |
| 156 | 8 | Intermediate | proposal_twin_towers_tall_07 | twin-towers | tall | 74 | 37 | 4 | 2 safe pairs; constrained | new template proposal | normal | ese_ne_tekrema | Journey Royal Stool |
| 157 | 8 | Intermediate | proposal_twin_towers_asymmetric_08 | twin-towers | asymmetric | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Heritage Open Diamond |
| 158 | 8 | Intermediate | proposal_cross_more_bridges_09 | cross | more-bridges | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Bridge |
| 159 | 8 | Intermediate | proposal_cross_stepped_10 | cross | stepped | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Golden Shrine |
| 160 | 8 | Intermediate | proposal_river_path_twin_crown_11 | river-path | twin-crown | 80 | 40 | 4 | 2 safe pairs; constrained | new template proposal | chapter+10+5 |  | Ancestral Layered Diamond |
| 161 | 9 | Intermediate | proposal_river_path_wide_12 | river-path | wide | 48 | 24 | 3 | 2 safe pairs; constrained | new template proposal | normal | esono_anatam | Memory Courtyard |
| 162 | 9 | Intermediate | proposal_mask_hollow_centre_13 | mask | hollow-centre | 50 | 25 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Wisdom Temple Gate |
| 163 | 9 | Intermediate | proposal_mask_layered_14 | mask | layered | 52 | 26 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Unity Turtle |
| 164 | 9 | Intermediate | proposal_royal_stool_mirrored_15 | royal-stool | mirrored | 54 | 27 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Courage Wings |
| 165 | 9 | Intermediate | proposal_royal_stool_compact_16 | royal-stool | compact | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | 5 | gyamu_atiko | Journey Crown |
| 166 | 9 | Intermediate | proposal_open_diamond_expanded_base_17 | open-diamond | expanded-base | 56 | 28 | 3 | 2 safe pairs; constrained | new template proposal | normal |  | Heritage Staircase |
| 167 | 9 | Intermediate | proposal_open_diamond_dense_18 | open-diamond | dense | 58 | 29 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Ring |
| 168 | 9 | Intermediate | proposal_bridge_tall_19 | bridge | tall | 60 | 30 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Golden Butterfly |
| 169 | 9 | Intermediate | proposal_bridge_asymmetric_20 | bridge | asymmetric | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Ancestral Twin Bridge |
| 170 | 9 | Intermediate | proposal_shrine_more_bridges_21 | shrine | more-bridges | 64 | 32 | 3 | 2 safe pairs; constrained | reused meaningful variant | 10+5 | hwehwemudua | Royal Split Islands |
| 171 | 9 | Intermediate | proposal_shrine_stepped_22 | shrine | stepped | 66 | 33 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Memory Fortress |
| 172 | 9 | Intermediate | proposal_layered_diamond_twin_crown_23 | layered-diamond | twin-crown | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Wisdom Twin Towers |
| 173 | 9 | Intermediate | proposal_layered_diamond_open_24 | layered-diamond | open | 68 | 34 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Unity Cross |
| 174 | 9 | Intermediate | proposal_courtyard_wide_25 | courtyard | wide | 70 | 35 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal | hye_wo_nhye | Courage River Path |
| 175 | 9 | Intermediate | proposal_courtyard_hollow_centre_26 | courtyard | hollow-centre | 72 | 36 | 4 | 2 safe pairs; constrained | reused meaningful variant | 5 |  | Journey Mask |
| 176 | 9 | Intermediate | proposal_temple_gate_layered_27 | temple-gate | layered | 74 | 37 | 4 | 2 safe pairs; constrained | new template proposal | normal |  | Heritage Royal Stool |
| 177 | 9 | Intermediate | proposal_temple_gate_mirrored_28 | temple-gate | mirrored | 56 | 28 | 3 | 2 safe pairs; constrained | reused meaningful variant | normal |  | River Open Diamond |
| 178 | 9 | Intermediate | proposal_turtle_compact_29 | turtle | compact | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal |  | Golden Bridge |
| 179 | 9 | Intermediate | proposal_turtle_expanded_base_30 | turtle | expanded-base | 78 | 39 | 4 | 2 safe pairs; constrained | reused meaningful variant | normal | kete_pa | Ancestral Shrine |
| 180 | 9 | Intermediate | proposal_wings_dense_31 | wings | dense | 80 | 40 | 4 | 2 safe pairs; constrained | new template proposal | chapter+10+5 |  | Royal Layered Diamond |
| 181 | 10 | Advanced | proposal_wings_asymmetric_32 | wings | asymmetric | 64 | 32 | 3 | 1-2 safe lines; readable | new template proposal | normal |  | Wisdom Courtyard |
| 182 | 10 | Advanced | proposal_crown_more_bridges_33 | crown | more-bridges | 66 | 33 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Unity Temple Gate |
| 183 | 10 | Advanced | proposal_crown_stepped_34 | crown | stepped | 68 | 34 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Courage Turtle |
| 184 | 10 | Advanced | proposal_staircase_twin_crown_35 | staircase | twin-crown | 70 | 35 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal | kokuromotie | Journey Wings |
| 185 | 10 | Advanced | proposal_staircase_open_36 | staircase | open | 72 | 36 | 3 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | Heritage Crown |
| 186 | 10 | Advanced | proposal_ring_wide_37 | ring | wide | 72 | 36 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | River Staircase |
| 187 | 10 | Advanced | proposal_ring_hollow_centre_38 | ring | hollow-centre | 74 | 37 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Golden Ring |
| 188 | 10 | Advanced | proposal_butterfly_layered_39 | butterfly | layered | 76 | 38 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | kramo_bone_amma_yeanhu_kramo_pa | Ancestral Butterfly |
| 189 | 10 | Advanced | proposal_butterfly_mirrored_40 | butterfly | mirrored | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Twin Bridge |
| 190 | 10 | Advanced | proposal_twin_bridge_compact_41 | twin-bridge | compact | 80 | 40 | 4 | 1-2 safe lines; readable | reused meaningful variant | 10+5 |  | Memory Split Islands |
| 191 | 10 | Advanced | proposal_twin_bridge_expanded_base_42 | twin-bridge | expanded-base | 82 | 41 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Wisdom Fortress |
| 192 | 10 | Advanced | proposal_split_islands_dense_43 | split-islands | dense | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Unity Twin Towers |
| 193 | 10 | Advanced | proposal_split_islands_tall_44 | split-islands | tall | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | krapa | Courage Cross |
| 194 | 10 | Advanced | proposal_fortress_asymmetric_45 | fortress | asymmetric | 86 | 43 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Journey River Path |
| 195 | 10 | Advanced | proposal_fortress_more_bridges_46 | fortress | more-bridges | 88 | 44 | 4 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | Heritage Mask |
| 196 | 10 | Advanced | proposal_twin_towers_stepped_47 | twin-towers | stepped | 90 | 45 | 5 | 1-2 safe lines; readable | new template proposal | normal |  | River Royal Stool |
| 197 | 10 | Advanced | proposal_twin_towers_twin_crown_48 | twin-towers | twin-crown | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | kuronti_ne_akwamu | Golden Open Diamond |
| 198 | 10 | Advanced | proposal_cross_open_49 | cross | open | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Ancestral Bridge |
| 199 | 10 | Advanced | proposal_cross_wide_50 | cross | wide | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Shrine |
| 200 | 10 | Advanced | proposal_river_path_hollow_centre_51 | river-path | hollow-centre | 96 | 48 | 5 | 1-2 safe lines; readable | new template proposal | major+chapter+10+5 |  | Memory Layered Diamond |
| 201 | 11 | Advanced | proposal_river_path_mirrored_52 | river-path | mirrored | 64 | 32 | 3 | 1-2 safe lines; readable | new template proposal | normal |  | Unity Courtyard |
| 202 | 11 | Advanced | proposal_mask_compact_53 | mask | compact | 66 | 33 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal | kyemfere | Courage Temple Gate |
| 203 | 11 | Advanced | proposal_mask_expanded_base_54 | mask | expanded-base | 68 | 34 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Journey Turtle |
| 204 | 11 | Advanced | proposal_royal_stool_dense_55 | royal-stool | dense | 70 | 35 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage Wings |
| 205 | 11 | Advanced | proposal_royal_stool_tall_56 | royal-stool | tall | 72 | 36 | 3 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | River Crown |
| 206 | 11 | Advanced | proposal_open_diamond_asymmetric_57 | open-diamond | asymmetric | 72 | 36 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Golden Staircase |
| 207 | 11 | Advanced | proposal_open_diamond_more_bridges_58 | open-diamond | more-bridges | 74 | 37 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | mako | Ancestral Ring |
| 208 | 11 | Advanced | proposal_bridge_stepped_59 | bridge | stepped | 76 | 38 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Butterfly |
| 209 | 11 | Advanced | proposal_bridge_twin_crown_60 | bridge | twin-crown | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Memory Twin Bridge |
| 210 | 11 | Advanced | proposal_shrine_open_61 | shrine | open | 80 | 40 | 4 | 1-2 safe lines; readable | reused meaningful variant | 10+5 |  | Wisdom Split Islands |
| 211 | 11 | Advanced | proposal_shrine_wide_62 | shrine | wide | 82 | 41 | 4 | 1-2 safe lines; readable | new template proposal | normal | mate_masie | Unity Fortress |
| 212 | 11 | Advanced | proposal_layered_diamond_hollow_centre_63 | layered-diamond | hollow-centre | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Courage Twin Towers |
| 213 | 11 | Advanced | proposal_layered_diamond_layered_64 | layered-diamond | layered | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Journey Cross |
| 214 | 11 | Advanced | proposal_courtyard_mirrored_65 | courtyard | mirrored | 86 | 43 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage River Path |
| 215 | 11 | Advanced | proposal_courtyard_compact_66 | courtyard | compact | 88 | 44 | 4 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | River Mask |
| 216 | 11 | Advanced | proposal_temple_gate_expanded_base_67 | temple-gate | expanded-base | 90 | 45 | 5 | 1-2 safe lines; readable | new template proposal | normal | mekyea_wo | Golden Royal Stool |
| 217 | 11 | Advanced | proposal_temple_gate_dense_68 | temple-gate | dense | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Ancestral Open Diamond |
| 218 | 11 | Advanced | proposal_turtle_tall_69 | turtle | tall | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Bridge |
| 219 | 11 | Advanced | proposal_turtle_asymmetric_70 | turtle | asymmetric | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Memory Shrine |
| 220 | 11 | Advanced | proposal_wings_more_bridges_71 | wings | more-bridges | 96 | 48 | 5 | 1-2 safe lines; readable | new template proposal | chapter+10+5 | menso_wo_kenten | Wisdom Layered Diamond |
| 221 | 12 | Advanced | proposal_wings_twin_crown_72 | wings | twin-crown | 64 | 32 | 3 | 1-2 safe lines; readable | new template proposal | normal |  | Courage Courtyard |
| 222 | 12 | Advanced | proposal_crown_open_01 | crown | open | 66 | 33 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Journey Temple Gate |
| 223 | 12 | Advanced | proposal_crown_wide_02 | crown | wide | 68 | 34 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage Turtle |
| 224 | 12 | Advanced | proposal_staircase_hollow_centre_03 | staircase | hollow-centre | 70 | 35 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | River Wings |
| 225 | 12 | Advanced | proposal_staircase_layered_04 | staircase | layered | 72 | 36 | 3 | 1-2 safe lines; readable | reused meaningful variant | 5 | mframadan | Golden Crown |
| 226 | 12 | Advanced | proposal_ring_mirrored_05 | ring | mirrored | 72 | 36 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Ancestral Staircase |
| 227 | 12 | Advanced | proposal_ring_compact_06 | ring | compact | 74 | 37 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Ring |
| 228 | 12 | Advanced | proposal_butterfly_expanded_base_07 | butterfly | expanded-base | 76 | 38 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Memory Butterfly |
| 229 | 12 | Advanced | proposal_butterfly_dense_08 | butterfly | dense | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Wisdom Twin Bridge |
| 230 | 12 | Advanced | proposal_twin_bridge_tall_09 | twin-bridge | tall | 80 | 40 | 4 | 1-2 safe lines; readable | reused meaningful variant | 10+5 | mmeramubere | Unity Split Islands |
| 231 | 12 | Advanced | proposal_twin_bridge_asymmetric_10 | twin-bridge | asymmetric | 82 | 41 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Courage Fortress |
| 232 | 12 | Advanced | proposal_split_islands_more_bridges_11 | split-islands | more-bridges | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Journey Twin Towers |
| 233 | 12 | Advanced | proposal_split_islands_stepped_12 | split-islands | stepped | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage Cross |
| 234 | 12 | Advanced | proposal_fortress_twin_crown_13 | fortress | twin-crown | 86 | 43 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | mmeramutene | River River Path |
| 235 | 12 | Advanced | proposal_fortress_open_14 | fortress | open | 88 | 44 | 4 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | Golden Mask |
| 236 | 12 | Advanced | proposal_twin_towers_wide_15 | twin-towers | wide | 90 | 45 | 5 | 1-2 safe lines; readable | new template proposal | normal |  | Ancestral Royal Stool |
| 237 | 12 | Advanced | proposal_twin_towers_hollow_centre_16 | twin-towers | hollow-centre | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Royal Open Diamond |
| 238 | 12 | Advanced | proposal_cross_layered_17 | cross | layered | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Memory Bridge |
| 239 | 12 | Advanced | proposal_cross_mirrored_18 | cross | mirrored | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal | mmere_dane | Wisdom Shrine |
| 240 | 12 | Advanced | proposal_river_path_compact_19 | river-path | compact | 96 | 48 | 5 | 1-2 safe lines; readable | new template proposal | chapter+10+5 |  | Unity Layered Diamond |
| 241 | 13 | Advanced | proposal_river_path_dense_20 | river-path | dense | 64 | 32 | 3 | 1-2 safe lines; readable | new template proposal | normal |  | Journey Courtyard |
| 242 | 13 | Advanced | proposal_mask_tall_21 | mask | tall | 66 | 33 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage Temple Gate |
| 243 | 13 | Advanced | proposal_mask_asymmetric_22 | mask | asymmetric | 68 | 34 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal | mpatapo | River Turtle |
| 244 | 13 | Advanced | proposal_royal_stool_more_bridges_23 | royal-stool | more-bridges | 70 | 35 | 3 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Golden Wings |
| 245 | 13 | Advanced | proposal_royal_stool_stepped_24 | royal-stool | stepped | 72 | 36 | 3 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | Ancestral Crown |
| 246 | 13 | Advanced | proposal_open_diamond_twin_crown_25 | open-diamond | twin-crown | 72 | 36 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Royal Staircase |
| 247 | 13 | Advanced | proposal_open_diamond_open_26 | open-diamond | open | 74 | 37 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Memory Ring |
| 248 | 13 | Advanced | proposal_bridge_wide_27 | bridge | wide | 76 | 38 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | mpuannum | Wisdom Butterfly |
| 249 | 13 | Advanced | proposal_bridge_hollow_centre_28 | bridge | hollow-centre | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Unity Twin Bridge |
| 250 | 13 | Advanced | proposal_shrine_layered_29 | shrine | layered | 80 | 40 | 4 | 1-2 safe lines; readable | reused meaningful variant | 10+5 |  | Courage Split Islands |
| 251 | 13 | Advanced | proposal_shrine_mirrored_30 | shrine | mirrored | 82 | 41 | 4 | 1-2 safe lines; readable | new template proposal | normal |  | Journey Fortress |
| 252 | 13 | Advanced | proposal_layered_diamond_compact_31 | layered-diamond | compact | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Heritage Twin Towers |
| 253 | 13 | Advanced | proposal_layered_diamond_expanded_base_32 | layered-diamond | expanded-base | 84 | 42 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | nea_oretwa_sa | River Cross |
| 254 | 13 | Advanced | proposal_courtyard_dense_33 | courtyard | dense | 86 | 43 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Golden River Path |
| 255 | 13 | Advanced | proposal_courtyard_tall_34 | courtyard | tall | 88 | 44 | 4 | 1-2 safe lines; readable | reused meaningful variant | 5 |  | Ancestral Mask |
| 256 | 13 | Advanced | proposal_temple_gate_asymmetric_35 | temple-gate | asymmetric | 90 | 45 | 5 | 1-2 safe lines; readable | new template proposal | normal |  | Royal Royal Stool |
| 257 | 13 | Advanced | proposal_temple_gate_more_bridges_36 | temple-gate | more-bridges | 72 | 36 | 4 | 1-2 safe lines; readable | reused meaningful variant | normal | neo_ope_se_obedi_hene | Memory Open Diamond |
| 258 | 13 | Advanced | proposal_turtle_stepped_37 | turtle | stepped | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Wisdom Bridge |
| 259 | 13 | Advanced | proposal_turtle_twin_crown_38 | turtle | twin-crown | 94 | 47 | 5 | 1-2 safe lines; readable | reused meaningful variant | normal |  | Unity Shrine |
| 260 | 13 | Advanced | proposal_wings_open_39 | wings | open | 96 | 48 | 5 | 1-2 safe lines; readable | new template proposal | chapter+10+5 |  | Courage Layered Diamond |
| 261 | 14 | Expert | proposal_wings_hollow_centre_40 | wings | hollow-centre | 78 | 39 | 4 | controlled/occasionally forced | new template proposal | normal |  | Heritage Courtyard |
| 262 | 14 | Expert | proposal_crown_layered_41 | crown | layered | 80 | 40 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nkonsonkonson | River Temple Gate |
| 263 | 14 | Expert | proposal_crown_mirrored_42 | crown | mirrored | 82 | 41 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Golden Turtle |
| 264 | 14 | Expert | proposal_staircase_compact_43 | staircase | compact | 84 | 42 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral Wings |
| 265 | 14 | Expert | proposal_staircase_expanded_base_44 | staircase | expanded-base | 86 | 43 | 4 | controlled/occasionally forced | reused meaningful variant | 5 |  | Royal Crown |
| 266 | 14 | Expert | proposal_ring_dense_45 | ring | dense | 88 | 44 | 4 | controlled/occasionally forced | new template proposal | normal | nkotimsefo_mpua | Memory Staircase |
| 267 | 14 | Expert | proposal_ring_tall_46 | ring | tall | 90 | 45 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Wisdom Ring |
| 268 | 14 | Expert | proposal_butterfly_asymmetric_47 | butterfly | asymmetric | 92 | 46 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Unity Butterfly |
| 269 | 14 | Expert | proposal_butterfly_more_bridges_48 | butterfly | more-bridges | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Courage Twin Bridge |
| 270 | 14 | Expert | proposal_twin_bridge_stepped_49 | twin-bridge | stepped | 94 | 47 | 4 | controlled/occasionally forced | reused meaningful variant | 10+5 |  | Journey Split Islands |
| 271 | 14 | Expert | proposal_twin_bridge_twin_crown_50 | twin-bridge | twin-crown | 96 | 48 | 5 | controlled/occasionally forced | new template proposal | normal | nkrabea | Heritage Fortress |
| 272 | 14 | Expert | proposal_split_islands_open_51 | split-islands | open | 98 | 49 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | River Twin Towers |
| 273 | 14 | Expert | proposal_split_islands_wide_52 | split-islands | wide | 100 | 50 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Golden Cross |
| 274 | 14 | Expert | proposal_fortress_hollow_centre_53 | fortress | hollow-centre | 102 | 51 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral River Path |
| 275 | 14 | Expert | proposal_fortress_layered_54 | fortress | layered | 104 | 52 | 5 | controlled/occasionally forced | reused meaningful variant | 5 |  | Royal Mask |
| 276 | 14 | Expert | proposal_twin_towers_mirrored_55 | twin-towers | mirrored | 106 | 53 | 5 | controlled/occasionally forced | new template proposal | normal | nkyemu | Memory Royal Stool |
| 277 | 14 | Expert | proposal_twin_towers_compact_56 | twin-towers | compact | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Wisdom Open Diamond |
| 278 | 14 | Expert | proposal_cross_expanded_base_57 | cross | expanded-base | 108 | 54 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Unity Bridge |
| 279 | 14 | Expert | proposal_cross_dense_58 | cross | dense | 110 | 55 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Courage Shrine |
| 280 | 14 | Expert | proposal_river_path_tall_59 | river-path | tall | 112 | 56 | 5 | controlled/occasionally forced | new template proposal | chapter+10+5 | nnamfo_pa_baanu | Journey Layered Diamond |
| 281 | 15 | Expert | proposal_river_path_more_bridges_60 | river-path | more-bridges | 78 | 39 | 4 | controlled/occasionally forced | new template proposal | normal |  | River Courtyard |
| 282 | 15 | Expert | proposal_mask_stepped_61 | mask | stepped | 80 | 40 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Golden Temple Gate |
| 283 | 15 | Expert | proposal_mask_twin_crown_62 | mask | twin-crown | 82 | 41 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral Turtle |
| 284 | 15 | Expert | proposal_royal_stool_open_63 | royal-stool | open | 84 | 42 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Royal Wings |
| 285 | 15 | Expert | proposal_royal_stool_wide_64 | royal-stool | wide | 86 | 43 | 4 | controlled/occasionally forced | reused meaningful variant | 5 | nsaa | Memory Crown |
| 286 | 15 | Expert | proposal_open_diamond_hollow_centre_65 | open-diamond | hollow-centre | 88 | 44 | 4 | controlled/occasionally forced | new template proposal | normal |  | Wisdom Staircase |
| 287 | 15 | Expert | proposal_open_diamond_layered_66 | open-diamond | layered | 90 | 45 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Unity Ring |
| 288 | 15 | Expert | proposal_bridge_mirrored_67 | bridge | mirrored | 92 | 46 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Courage Butterfly |
| 289 | 15 | Expert | proposal_bridge_compact_68 | bridge | compact | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nserewa | Journey Twin Bridge |
| 290 | 15 | Expert | proposal_shrine_expanded_base_69 | shrine | expanded-base | 94 | 47 | 4 | controlled/occasionally forced | reused meaningful variant | 10+5 |  | Heritage Split Islands |
| 291 | 15 | Expert | proposal_shrine_dense_70 | shrine | dense | 96 | 48 | 5 | controlled/occasionally forced | new template proposal | normal |  | River Fortress |
| 292 | 15 | Expert | proposal_layered_diamond_tall_71 | layered-diamond | tall | 98 | 49 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Golden Twin Towers |
| 293 | 15 | Expert | proposal_layered_diamond_asymmetric_72 | layered-diamond | asymmetric | 100 | 50 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral Cross |
| 294 | 15 | Expert | proposal_courtyard_more_bridges_01 | courtyard | more-bridges | 102 | 51 | 5 | controlled/occasionally forced | reused meaningful variant | normal | nteasee | Royal River Path |
| 295 | 15 | Expert | proposal_courtyard_stepped_02 | courtyard | stepped | 104 | 52 | 5 | controlled/occasionally forced | reused meaningful variant | 5 |  | Memory Mask |
| 296 | 15 | Expert | proposal_temple_gate_twin_crown_03 | temple-gate | twin-crown | 106 | 53 | 5 | controlled/occasionally forced | new template proposal | normal |  | Wisdom Royal Stool |
| 297 | 15 | Expert | proposal_temple_gate_open_04 | temple-gate | open | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Unity Open Diamond |
| 298 | 15 | Expert | proposal_turtle_wide_05 | turtle | wide | 108 | 54 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Courage Bridge |
| 299 | 15 | Expert | proposal_turtle_hollow_centre_06 | turtle | hollow-centre | 110 | 55 | 5 | controlled/occasionally forced | reused meaningful variant | normal | nyame_baatanpa | Journey Shrine |
| 300 | 15 | Expert | proposal_wings_layered_07 | wings | layered | 112 | 56 | 5 | controlled/occasionally forced | new template proposal | major+chapter+10+5 |  | Heritage Layered Diamond |
| 301 | 16 | Expert | proposal_wings_compact_08 | wings | compact | 78 | 39 | 4 | controlled/occasionally forced | new template proposal | normal |  | Golden Courtyard |
| 302 | 16 | Expert | proposal_crown_expanded_base_09 | crown | expanded-base | 80 | 40 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral Temple Gate |
| 303 | 16 | Expert | proposal_crown_dense_10 | crown | dense | 82 | 41 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nyame_biribi_wo_soro | Royal Turtle |
| 304 | 16 | Expert | proposal_staircase_tall_11 | staircase | tall | 84 | 42 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Memory Wings |
| 305 | 16 | Expert | proposal_staircase_asymmetric_12 | staircase | asymmetric | 86 | 43 | 4 | controlled/occasionally forced | reused meaningful variant | 5 |  | Wisdom Crown |
| 306 | 16 | Expert | proposal_ring_more_bridges_13 | ring | more-bridges | 88 | 44 | 4 | controlled/occasionally forced | new template proposal | normal |  | Unity Staircase |
| 307 | 16 | Expert | proposal_ring_stepped_14 | ring | stepped | 90 | 45 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Courage Ring |
| 308 | 16 | Expert | proposal_butterfly_twin_crown_15 | butterfly | twin-crown | 92 | 46 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nyame_dua | Journey Butterfly |
| 309 | 16 | Expert | proposal_butterfly_open_16 | butterfly | open | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Heritage Twin Bridge |
| 310 | 16 | Expert | proposal_twin_bridge_wide_17 | twin-bridge | wide | 94 | 47 | 4 | controlled/occasionally forced | reused meaningful variant | 10+5 |  | River Split Islands |
| 311 | 16 | Expert | proposal_twin_bridge_hollow_centre_18 | twin-bridge | hollow-centre | 96 | 48 | 5 | controlled/occasionally forced | new template proposal | normal |  | Golden Fortress |
| 312 | 16 | Expert | proposal_split_islands_layered_19 | split-islands | layered | 98 | 49 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Ancestral Twin Towers |
| 313 | 16 | Expert | proposal_split_islands_mirrored_20 | split-islands | mirrored | 100 | 50 | 5 | controlled/occasionally forced | reused meaningful variant | normal | nyame_nti | Royal Cross |
| 314 | 16 | Expert | proposal_fortress_compact_21 | fortress | compact | 102 | 51 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Memory River Path |
| 315 | 16 | Expert | proposal_fortress_expanded_base_22 | fortress | expanded-base | 104 | 52 | 5 | controlled/occasionally forced | reused meaningful variant | 5 |  | Wisdom Mask |
| 316 | 16 | Expert | proposal_twin_towers_dense_23 | twin-towers | dense | 106 | 53 | 5 | controlled/occasionally forced | new template proposal | normal |  | Unity Royal Stool |
| 317 | 16 | Expert | proposal_twin_towers_tall_24 | twin-towers | tall | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nyame_nwa_na_mawu | Courage Open Diamond |
| 318 | 16 | Expert | proposal_cross_asymmetric_25 | cross | asymmetric | 108 | 54 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Journey Bridge |
| 319 | 16 | Expert | proposal_cross_more_bridges_26 | cross | more-bridges | 110 | 55 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Heritage Shrine |
| 320 | 16 | Expert | proposal_river_path_stepped_27 | river-path | stepped | 112 | 56 | 5 | controlled/occasionally forced | new template proposal | chapter+10+5 |  | River Layered Diamond |
| 321 | 17 | Expert | proposal_river_path_open_28 | river-path | open | 78 | 39 | 4 | controlled/occasionally forced | new template proposal | normal |  | Ancestral Courtyard |
| 322 | 17 | Expert | proposal_mask_wide_29 | mask | wide | 80 | 40 | 4 | controlled/occasionally forced | reused meaningful variant | normal | nyansapo | Royal Temple Gate |
| 323 | 17 | Expert | proposal_mask_hollow_centre_30 | mask | hollow-centre | 82 | 41 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Memory Turtle |
| 324 | 17 | Expert | proposal_royal_stool_layered_31 | royal-stool | layered | 84 | 42 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Wisdom Wings |
| 325 | 17 | Expert | proposal_royal_stool_mirrored_32 | royal-stool | mirrored | 86 | 43 | 4 | controlled/occasionally forced | reused meaningful variant | 5 |  | Unity Crown |
| 326 | 17 | Expert | proposal_open_diamond_compact_33 | open-diamond | compact | 88 | 44 | 4 | controlled/occasionally forced | new template proposal | normal | obohemaa | Courage Staircase |
| 327 | 17 | Expert | proposal_open_diamond_expanded_base_34 | open-diamond | expanded-base | 90 | 45 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Journey Ring |
| 328 | 17 | Expert | proposal_bridge_dense_35 | bridge | dense | 92 | 46 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Heritage Butterfly |
| 329 | 17 | Expert | proposal_bridge_tall_36 | bridge | tall | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | River Twin Bridge |
| 330 | 17 | Expert | proposal_shrine_asymmetric_37 | shrine | asymmetric | 94 | 47 | 4 | controlled/occasionally forced | reused meaningful variant | 10+5 |  | Golden Split Islands |
| 331 | 17 | Expert | proposal_shrine_more_bridges_38 | shrine | more-bridges | 96 | 48 | 5 | controlled/occasionally forced | new template proposal | normal | okodee_mmowere | Ancestral Fortress |
| 332 | 17 | Expert | proposal_layered_diamond_stepped_39 | layered-diamond | stepped | 98 | 49 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Royal Twin Towers |
| 333 | 17 | Expert | proposal_layered_diamond_twin_crown_40 | layered-diamond | twin-crown | 100 | 50 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Memory Cross |
| 334 | 17 | Expert | proposal_courtyard_open_41 | courtyard | open | 102 | 51 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Wisdom River Path |
| 335 | 17 | Expert | proposal_courtyard_wide_42 | courtyard | wide | 104 | 52 | 5 | controlled/occasionally forced | reused meaningful variant | 5 |  | Unity Mask |
| 336 | 17 | Expert | proposal_temple_gate_hollow_centre_43 | temple-gate | hollow-centre | 106 | 53 | 5 | controlled/occasionally forced | new template proposal | normal | okuafo_pa | Courage Royal Stool |
| 337 | 17 | Expert | proposal_temple_gate_layered_44 | temple-gate | layered | 88 | 44 | 4 | controlled/occasionally forced | reused meaningful variant | normal |  | Journey Open Diamond |
| 338 | 17 | Expert | proposal_turtle_mirrored_45 | turtle | mirrored | 108 | 54 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | Heritage Bridge |
| 339 | 17 | Expert | proposal_turtle_compact_46 | turtle | compact | 110 | 55 | 5 | controlled/occasionally forced | reused meaningful variant | normal |  | River Shrine |
| 340 | 17 | Expert | proposal_wings_expanded_base_47 | wings | expanded-base | 112 | 56 | 5 | controlled/occasionally forced | new template proposal | chapter+10+5 | osram_ne_nsoromma | Golden Layered Diamond |
| 341 | 18 | Master | proposal_wings_tall_48 | wings | tall | 90 | 45 | 4 | deliberate, finale-grade | new template proposal | normal |  | Royal Courtyard |
| 342 | 18 | Master | proposal_crown_asymmetric_49 | crown | asymmetric | 92 | 46 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Memory Temple Gate |
| 343 | 18 | Master | proposal_crown_more_bridges_50 | crown | more-bridges | 94 | 47 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Wisdom Turtle |
| 344 | 18 | Master | proposal_staircase_stepped_51 | staircase | stepped | 96 | 48 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Unity Wings |
| 345 | 18 | Master | proposal_staircase_twin_crown_52 | staircase | twin-crown | 98 | 49 | 4 | deliberate, finale-grade | reused meaningful variant | 5 | owo_foro_adobe | Courage Crown |
| 346 | 18 | Master | proposal_ring_open_53 | ring | open | 102 | 51 | 5 | deliberate, finale-grade | new template proposal | normal |  | Journey Staircase |
| 347 | 18 | Master | proposal_ring_wide_54 | ring | wide | 104 | 52 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Heritage Ring |
| 348 | 18 | Master | proposal_butterfly_hollow_centre_55 | butterfly | hollow-centre | 106 | 53 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | River Butterfly |
| 349 | 18 | Master | proposal_butterfly_layered_56 | butterfly | layered | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal | owuo_atwedee | Golden Twin Bridge |
| 350 | 18 | Master | proposal_twin_bridge_mirrored_57 | twin-bridge | mirrored | 110 | 55 | 5 | deliberate, finale-grade | reused meaningful variant | 10+5 |  | Ancestral Split Islands |
| 351 | 18 | Master | proposal_twin_bridge_compact_58 | twin-bridge | compact | 112 | 56 | 5 | deliberate, finale-grade | new template proposal | normal |  | Royal Fortress |
| 352 | 18 | Master | proposal_split_islands_expanded_base_59 | split-islands | expanded-base | 114 | 57 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Memory Twin Towers |
| 353 | 18 | Master | proposal_split_islands_dense_60 | split-islands | dense | 116 | 58 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Wisdom Cross |
| 354 | 18 | Master | proposal_fortress_tall_61 | fortress | tall | 118 | 59 | 5 | deliberate, finale-grade | reused meaningful variant | normal | pempamsie | Unity River Path |
| 355 | 18 | Master | proposal_fortress_asymmetric_62 | fortress | asymmetric | 120 | 60 | 5 | deliberate, finale-grade | reused meaningful variant | 5 |  | Courage Mask |
| 356 | 18 | Master | proposal_twin_towers_more_bridges_63 | twin-towers | more-bridges | 122 | 61 | 6 | deliberate, finale-grade | new template proposal | normal |  | Journey Royal Stool |
| 357 | 18 | Master | proposal_twin_towers_stepped_64 | twin-towers | stepped | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Heritage Open Diamond |
| 358 | 18 | Master | proposal_cross_twin_crown_65 | cross | twin-crown | 126 | 63 | 6 | deliberate, finale-grade | reused meaningful variant | normal |  | River Bridge |
| 359 | 18 | Master | proposal_cross_open_66 | cross | open | 128 | 64 | 6 | deliberate, finale-grade | reused meaningful variant | normal | sepow | Golden Shrine |
| 360 | 18 | Master | proposal_river_path_wide_67 | river-path | wide | 130 | 65 | 6 | deliberate, finale-grade | new template proposal | chapter+10+5 |  | Ancestral Layered Diamond |
| 361 | 19 | Master | proposal_river_path_layered_68 | river-path | layered | 90 | 45 | 4 | deliberate, finale-grade | new template proposal | normal |  | Memory Courtyard |
| 362 | 19 | Master | proposal_mask_mirrored_69 | mask | mirrored | 92 | 46 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Wisdom Temple Gate |
| 363 | 19 | Master | proposal_mask_compact_70 | mask | compact | 94 | 47 | 4 | deliberate, finale-grade | reused meaningful variant | normal | sesa_wo_suban | Unity Turtle |
| 364 | 19 | Master | proposal_royal_stool_expanded_base_71 | royal-stool | expanded-base | 96 | 48 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Courage Wings |
| 365 | 19 | Master | proposal_royal_stool_dense_72 | royal-stool | dense | 98 | 49 | 4 | deliberate, finale-grade | reused meaningful variant | 5 |  | Journey Crown |
| 366 | 19 | Master | proposal_open_diamond_tall_01 | open-diamond | tall | 102 | 51 | 5 | deliberate, finale-grade | new template proposal | normal |  | Heritage Staircase |
| 367 | 19 | Master | proposal_open_diamond_asymmetric_02 | open-diamond | asymmetric | 104 | 52 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | River Ring |
| 368 | 19 | Master | proposal_bridge_more_bridges_03 | bridge | more-bridges | 106 | 53 | 5 | deliberate, finale-grade | reused meaningful variant | normal | som_onyankopon | Golden Butterfly |
| 369 | 19 | Master | proposal_bridge_stepped_04 | bridge | stepped | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Ancestral Twin Bridge |
| 370 | 19 | Master | proposal_shrine_twin_crown_05 | shrine | twin-crown | 110 | 55 | 5 | deliberate, finale-grade | reused meaningful variant | 10+5 |  | Royal Split Islands |
| 371 | 19 | Master | proposal_shrine_open_06 | shrine | open | 112 | 56 | 5 | deliberate, finale-grade | new template proposal | normal |  | Memory Fortress |
| 372 | 19 | Master | proposal_layered_diamond_wide_07 | layered-diamond | wide | 114 | 57 | 5 | deliberate, finale-grade | reused meaningful variant | normal | sunsum | Wisdom Twin Towers |
| 373 | 19 | Master | proposal_layered_diamond_hollow_centre_08 | layered-diamond | hollow-centre | 116 | 58 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Unity Cross |
| 374 | 19 | Master | proposal_courtyard_layered_09 | courtyard | layered | 118 | 59 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Courage River Path |
| 375 | 19 | Master | proposal_courtyard_mirrored_10 | courtyard | mirrored | 120 | 60 | 5 | deliberate, finale-grade | reused meaningful variant | 5 |  | Journey Mask |
| 376 | 19 | Master | proposal_temple_gate_compact_11 | temple-gate | compact | 122 | 61 | 6 | deliberate, finale-grade | new template proposal | normal |  | Heritage Royal Stool |
| 377 | 19 | Master | proposal_temple_gate_expanded_base_12 | temple-gate | expanded-base | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal | tabono | River Open Diamond |
| 378 | 19 | Master | proposal_turtle_dense_13 | turtle | dense | 126 | 63 | 6 | deliberate, finale-grade | reused meaningful variant | normal |  | Golden Bridge |
| 379 | 19 | Master | proposal_turtle_tall_14 | turtle | tall | 128 | 64 | 6 | deliberate, finale-grade | reused meaningful variant | normal |  | Ancestral Shrine |
| 380 | 19 | Master | proposal_wings_asymmetric_15 | wings | asymmetric | 130 | 65 | 6 | deliberate, finale-grade | new template proposal | chapter+10+5 |  | Royal Layered Diamond |
| 381 | 20 | Master | proposal_wings_stepped_16 | wings | stepped | 90 | 45 | 4 | deliberate, finale-grade | new template proposal | normal |  | Wisdom Courtyard |
| 382 | 20 | Master | proposal_crown_twin_crown_17 | crown | twin-crown | 92 | 46 | 4 | deliberate, finale-grade | reused meaningful variant | normal | tamfo_bebre | Unity Temple Gate |
| 383 | 20 | Master | proposal_crown_open_18 | crown | open | 94 | 47 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Courage Turtle |
| 384 | 20 | Master | proposal_staircase_wide_19 | staircase | wide | 96 | 48 | 4 | deliberate, finale-grade | reused meaningful variant | normal |  | Journey Wings |
| 385 | 20 | Master | proposal_staircase_hollow_centre_20 | staircase | hollow-centre | 98 | 49 | 4 | deliberate, finale-grade | reused meaningful variant | 5 |  | Heritage Crown |
| 386 | 20 | Master | proposal_ring_layered_21 | ring | layered | 102 | 51 | 5 | deliberate, finale-grade | new template proposal | normal | uac_nkanea | River Staircase |
| 387 | 20 | Master | proposal_ring_mirrored_22 | ring | mirrored | 104 | 52 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Golden Ring |
| 388 | 20 | Master | proposal_butterfly_compact_23 | butterfly | compact | 106 | 53 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Ancestral Butterfly |
| 389 | 20 | Master | proposal_butterfly_expanded_base_24 | butterfly | expanded-base | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Royal Twin Bridge |
| 390 | 20 | Master | proposal_twin_bridge_dense_25 | twin-bridge | dense | 110 | 55 | 5 | deliberate, finale-grade | reused meaningful variant | 10+5 |  | Memory Split Islands |
| 391 | 20 | Master | proposal_twin_bridge_tall_26 | twin-bridge | tall | 112 | 56 | 5 | deliberate, finale-grade | new template proposal | normal | wawa_aba | Wisdom Fortress |
| 392 | 20 | Master | proposal_split_islands_asymmetric_27 | split-islands | asymmetric | 114 | 57 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Unity Twin Towers |
| 393 | 20 | Master | proposal_split_islands_more_bridges_28 | split-islands | more-bridges | 116 | 58 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Courage Cross |
| 394 | 20 | Master | proposal_fortress_stepped_29 | fortress | stepped | 118 | 59 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Journey River Path |
| 395 | 20 | Master | proposal_fortress_twin_crown_30 | fortress | twin-crown | 120 | 60 | 5 | deliberate, finale-grade | reused meaningful variant | 5 | wo_nsa_da_mu_a | Heritage Mask |
| 396 | 20 | Master | proposal_twin_towers_open_31 | twin-towers | open | 122 | 61 | 6 | deliberate, finale-grade | new template proposal | normal |  | River Royal Stool |
| 397 | 20 | Master | proposal_twin_towers_wide_32 | twin-towers | wide | 100 | 50 | 5 | deliberate, finale-grade | reused meaningful variant | normal |  | Golden Open Diamond |
| 398 | 20 | Master | proposal_cross_hollow_centre_33 | cross | hollow-centre | 126 | 63 | 6 | deliberate, finale-grade | reused meaningful variant | normal |  | Ancestral Bridge |
| 399 | 20 | Master | proposal_cross_layered_34 | cross | layered | 128 | 64 | 6 | deliberate, finale-grade | reused meaningful variant | normal |  | Royal Shrine |
| 400 | 20 | Master | proposal_river_path_mirrored_35 | river-path | mirrored | 130 | 65 | 6 | deliberate, finale-grade | new template proposal | major+chapter+10+5 | woforo_dua_pa_a | Memory Layered Diamond |

## 9. Reward pacing

Keep the existing first-clear 40 cowries and star-improvement 12 cowries as the baseline until economy simulation says otherwise. Add rewards through a versioned milestone table, with transaction IDs for every grant:

| Trigger | Recommended additive reward |
|---|---|
| Normal first clear | Existing 40 cowries; scheduled face only when a milestone matches. |
| Every 5th | +40 cowries or rotating one Hint/Shuffle; never require payment. |
| Every 10th | Small chest: +75 cowries plus one rotating booster/cosmetic shard. |
| Every 20th | Chapter chest: existing 120 cowries, one Hint, one Shuffle, chapter cosmetic progress; include at most the single scheduled face. |
| 100 | 250 cowries, cosmetic badge/back, two mixed boosters. |
| 200 | 300 cowries, legacy-campaign commemorative cosmetic, two mixed boosters; **not** campaign completion. |
| 300 | 350 cowries, expert cosmetic, three mixed boosters. |
| 400 | 500 cowries, unique finale tile-back/theme cosmetic, finale badge, three mixed boosters, Grand Archivist achievement. |

Avoid stacking all numeric rewards blindly: the milestone table should specify a resolved bundle for levels divisible by 5/10/20/100. Cosmetics and boosters diversify motivation without pay-to-win pressure. Theme/cosmetic ownership needs an explicit additive persisted entitlement model; no such tile-theme progression exists today.

## 10. UI, performance, developer tools, and validation impact

- Journey: replace the eager chapter-card loop and nested shrink-wrap grids with a selected chapter page, expansion list that builds one grid at a time, or `CustomScrollView` slivers. Derive `$completed/${chapter.levels.length}`. Twenty chapters is manageable; rendering all 400 cards simultaneously is avoidable.
- Home/result/chapter completion: totals already derive from `kLevels`; fix the campaign achievement constant and add tests ensuring Level 200 is an ordinary milestone and Level 400 is final.
- Memory/save size: 200 additional boolean/int keys are tiny. SharedPreferences remains acceptable at this scale, though a future structured store would improve migrations.
- Startup: normal startup does not generate every board. Campaign lists and collection backfill are linear over 400/97 items and negligible.
- Validation/tests: structural validation doubles linearly. The present full suite, including 200-board generation, passed in ~9 seconds; 400 should remain practical but seed matrices and render previews can dominate. Split fast PR checks (one deterministic seed/board) from nightly/release exhaustive seeds.
- Developer catalogue: its `SliverGrid.builder` is already lazy; add chapter/family filters, search/jump-to-ID, coordinate-hash duplication warnings, and cached validation badges.
- Analytics: client event schemas support any integer ID. Audit external dashboards, funnels, Remote Config audiences, and BigQuery queries for `<=200` or “final=200”. Add `chapter_id`, `campaign_version`, `layout_family`, and `template_id` where useful.
- Progress: percentage already divides by `kCampaignLevelCount`; preserve earned absolute progress. Product should approve whether a former 100% player sees 50% after expansion; technically no levels are lost, but the percentage falls. Consider “Legacy Journey complete” messaging.

## 11. Testing strategy

Fast unit tests: constants separated; 400 unique contiguous IDs; 20×20 chapters; predecessor unlocking; milestone ordering/uniqueness/range; ten Level-0 starters; no duplicate tile IDs; reward bundle resolution; Level 200 not final; Level 400 final.

Campaign-structure tests: IDs 1–200 snapshot unchanged; approved Levels 1–5 layout IDs unchanged; all chapter/name/layout/symbol-plan references valid; symbol copy totals equal layout tiles; coordinate hashes respect distance 40; viewport and support validation pass.

Exhaustive solvability tests: every production board generates and solves for a deterministic seed set, with per-board time/node budgets and artifacts for failures. Run a one-seed set on PRs, 25–100 seeds nightly by risk band, and the full release matrix before each layout batch ships.

Preview-render tests: all new/changed templates at 360×640, 390×844, and 430×932; visual approval contact sheets per batch; goldens for the five approved levels; accessibility/text-scale checks for Journey and finale.

Migration tests: union semantics, explicit legacy flags, legacy derived entitlements, sparse completion, currency/boosters/purchases/themes unchanged, idempotent rerun, interrupted marker-last retry, Level 200→201 unlock, and rollback compatibility.

UI/analytics tests: lazy chapter rendering, 400-card navigation/filtering, percentages denominator 400, campaign complete only at 400, analytics accepts IDs 201/400, and external dashboard acceptance verified outside code.

## 12. Controlled implementation batches

| Batch | Scope | New templates / variants target | Required checkpoint |
|---|---|---:|---|
| Foundation | Constants, 20×20 chapter model, milestone/reward models, migration v4, UI virtualization, tests; no new production levels | 0 / 0 | Migration fixtures, 400 placeholder architecture validation, product approval |
| A | Approved Levels 1–5 | 0 / 0 | Preserve current multi-viewport previews and 100-seed opening checks |
| B | Levels 6–20 | 5 / 10 | Preview every layout, 100 seeds for changed/new layouts, visual approval before assignment |
| C | 21–40 | 6 / 14 | Same plus coordinate-distance report |
| D | 41–80 | 8 / 24 | Contact sheets by chapter; PR one-seed + nightly 50 seeds |
| E | 81–120 | 8 / 24 | Density/layer performance benchmark and visual approval |
| F | 121–160 | 8 / 24 | Support/bridge audit and seed matrix |
| G | 161–200 | 8 / 24 | Preserve IDs/rewards; legacy-player regression gate |
| H | 201–250 | 9 / 30 | Expansion save/analytics/UI checkpoint |
| I | 251–300 | 8 / 30 | Expert opening-quality and device performance gate |
| J | 301–350 | 8 / 30 | Large-board memory/frame benchmark; nightly exhaustive seeds |
| K | 351–400 | 12 including one-offs / 24 | Every-level preview, finale approval, full release solvability matrix |

Numbers are planning caps and total about 72 reusable templates plus 12 showcase/finale templates when overlaps and existing approved assets are reconciled. Every batch must: validate coordinates/support/fit/copy totals; generate deterministic boards; run seed tests; produce multi-viewport contact sheets; receive visual approval; and only then change production assignments.

## 13. Exact files eventually requiring modification

Core: `lib/core/constants/level_data.dart`, `chapter_data.dart`, `tile_unlock_data.dart`, `layout_data.dart`; add dedicated campaign/reward milestone data if preferred. Storage/economy: `lib/core/utils/storage_service.dart`, `lib/core/economy/economy_service.dart`, `economy_config.dart`, and possibly `economy_models.dart`. Providers/UI: `lib/providers/progress_provider.dart`, `lib/screens/journey/journey_screen.dart`, `home/home_screen.dart`, `result/result_screen.dart`, `chapter/chapter_complete_screen.dart`, `preview/tile_preview_screen.dart`, and developer tester filters. Validation/tooling: `lib/core/utils/campaign_validator.dart`, `tool/campaign_report.dart`, benchmark/preview tools. Tests: `game_provider_startup_test.dart`, `board_layout_geometry_test.dart`, `tile_unlock_rules_test.dart`, `economy_service_test.dart`, `progression_flow_test.dart`, `phase2_flow_test.dart`, plus new chapter, roadmap, reward, migration, UI-performance, and exhaustive campaign suites.

`analytics_service.dart` needs changes only if adding campaign/chapter/layout metadata; no current numeric cap exists. Monetization code does not require campaign expansion changes and must remain out of the foundation scope.

## 14. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Earned faces relock after schedule replacement | Additive union migration; never delete/false-write; frozen legacy entitlement table. |
| Old Chapter 10/20 transaction collisions | Version reward transaction IDs; preserve old keys and grants. |
| 100% players appear to regress to 50% | Preserve completion, message legacy completion, product-approve percentage presentation. |
| Level 200 still fires finale achievement | Separate campaign end (400) from collection schedule end and test both. |
| Repetitive 400-level feel | Coordinate hash distance 40, family/variant metadata, six families/chapter, breathers/showcases. |
| Large boards fit poorly or solve slowly | Device viewport gates, per-board node/time budgets, progressive seed suites, 130-tile cap subject to benchmark. |
| Journey jank | Render selected/expanded chapter only; derive counts; retain sliver-based developer list. |
| Placeholder roadmap mistaken for implementation | Keep CSV/document status fields and require visual/production assignment checkpoints. |
| Out-of-range chapter silently maps to Accra | Make lookup fail fast/nullable before adding content. |

## 15. Questions requiring approval

1. Approve 20 chapters × 20 levels while retaining current chapter indices/titles?
2. Should a player who completed old Level 200 receive immediate access to Level 201 (recommended), and how should legacy 100% completion be messaged?
3. Approve ten true Level-0 starter faces and the exact starter IDs currently occupying the first ten catalogue positions?
4. Approve collection completion at Level 400 with an average 4.60-level cadence, rather than reserving faces beyond the campaign?
5. Should chapter cosmetics be tile backs, board frames, badges, theme shards, or a mix? Theme ownership needs a new additive model.
6. Approve coordinate repetition distance 40 and showcase distance 100?
7. Approve the 72 reusable + 12 showcase template production target and per-batch visual gates?
8. Decide treatment of old ten-level chapter rewards after ranges become twenty levels: grandfather only (recommended) or grant retroactive v2 chests.

## Final recommendations

1. **Can the campaign safely expand?** Yes, by appending stable IDs 201–400, separating campaign and collection end constants, virtualizing Journey chapters, and shipping an additive migration first.
2. **What assumes 200?** Chapter ranges, generated level count, collection-final constant and campaign achievement coupling, four principal tests plus related fixtures; external analytics dashboards remain to be audited. Runtime totals mostly derive from `kLevels`.
3. **Best unlock interval?** Mixed/data-driven milestones averaging **4.60 levels** (one face roughly every 4–5 levels), with non-face chapter bonuses.
4. **Starting faces?** **10**, available before Level 1 rather than awarded as a ten-face Level 1 batch.
5. **Existing unlock protection?** Persist the explicit set forever and take the union with frozen legacy entitlements and new earned milestones; schema/version marker last and idempotent.
6. **Layouts needed?** About **72 reusable templates**, **3–5 meaningful variants where useful**, and **12 one-off showcases**, producing roughly 220–260 coordinate-distinct layouts across 400 assignments.
7. **Implement first?** Foundation only: constants/model separation, chapter/reward/unlock data models, migration v4, Journey virtualization, validators, and tests—without production Levels 201–400 or layout changes.
8. **When resume Levels 6–20?** Only after the foundation design and eight approval questions above are resolved, migration/structure tests pass, and the batch-B preview/seed/visual-approval gate is ready.
