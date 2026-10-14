# Sankofa Tiles: retention and solitaire experience review

Review date: 14 October 2026  
Status: review retained as the planning baseline; selected recommendations implemented on 14 October 2026 (see progress below).

## Implementation progress - 14 October 2026

- [x] R06 implemented: persistent Next Level includes a next-board preview, retains the current play style, and bypasses chapter briefings. Chapter recaps remain optional. Unlock celebrations can be skipped after rewards are saved; reopening does not grant them twice.
- [x] R07 implemented: Undo and other dock controls have visible labels; unavailable Undo explains its conditions. Automatic board recovery announces its action and lack of booster/score cost. Existing mastery rules are preserved.
- [x] R14 feature portion: home, results and Collection preview the next earnable symbol and its actual level requirement. Collection retains unlocked meanings, including after skipped celebrations.
- [ ] R14 remaining: a separate cultural review of names and meanings; existing content was reused unchanged.
- [x] R10 Undo portion: visible labels and explanations for unavailable Undo; next-level continuation also retains the current play style.
- [ ] R10 remaining: remember the mode across relaunches and clarify mode descriptions.
- [ ] R01 home-screen redesign: visual concept shown only; not implemented.
- Verification: focused Flutter regression tests cover continuation, reward persistence, collection availability, mode preservation, recovery and small-screen layouts. Physical-device visual review remains a follow-up. The PDF mirrors this updated checklist. Full recommendations R06 and R07 are complete; R10 and R14 remain partial.

## 1. Main finding

Make the board the hero, make continuing effortless, and give each completed board a clear reason to play another. Start with presentation and flow before adding more currencies, menus, or levels.

The game has a strong identity: Adinkra symbols, Ghanaian visual references, layered Mahjong solitaire boards, and a collection with meanings. Preserve those strengths. Interpret "actual solitaire" as a polished single-player Mahjong solitaire experience; converting to card solitaire would be a separate product decision.

The current home screen reads as a decorated menu: a large image, divider, wallet, campaign summary, a panel of similarly styled buttons, reward shortcuts, and version text. That hierarchy can obscure the central promise: a satisfying board ready to play. This is a code-based design finding, not a measured explanation of player churn.

## 2. Scope and evidence

Reviewed current Flutter source for home, entry flow, routing, pre-level, gameplay state, results, daily rewards, scoring, analytics, and monetization configuration. This review did not launch the app or inspect a live rendered build. Small-screen crowding, perceived animation quality, readability, and performance therefore require device validation. No player analytics export or interviews were available; retention effects below are hypotheses.

Important correction to older documentation: `docs/GAME_FLOW.md` explicitly describes a historical version. Current code already includes saved-game resume, journey navigation, interactive entry/tutorial routes, daily rewards, collection unlocks, chapter rewards, Classic/Relaxed selection, elapsed-time scoring, an undo implementation, and lifecycle handling. Improve these systems rather than rebuilding them.

Primary evidence:

- `lib/screens/home/home_screen.dart`: vertically stacked home, saved-game CTA, whole-campaign progress, wallet and reward shortcuts.
- `lib/features/entry_flow/entry_flow_director.dart`: optional returning-player opening, 2.4-second timer, tap-to-exit behavior.
- `lib/app.dart`, `lib/core/router/app_router.dart` and `lib/features/entry_flow/entry_game.dart`: current entry and navigation paths; app initialization selects the tutorial for first discovery, while a legacy onboarding route remains available.
- `lib/screens/pre_level/pre_level_screen.dart`: level details and Classic/Relaxed selection.
- `lib/providers/game_provider.dart`: matching, one-use undo snapshot, automatic stuck-board shuffle, recovery state, elapsed-time ticks.
- `lib/screens/game/game_screen.dart`: gameplay orchestration, recovery choices and lifecycle pause/resume handling.
- `lib/core/scoring/level_scoring.dart`: score and star conditions, including Classic par-time criteria.
- `lib/screens/result/result_screen.dart`: stars, rewards, collection ceremonies, chapter progress and next-level navigation.
- `lib/screens/daily/daily_reward_screen.dart`: claimable reward screen; a reward claim is different from a daily puzzle.
- `lib/core/utils/analytics_service.dart`: existing funnel, tutorial, level, reward and advertising events.
- `lib/core/monetization/monetization_config.dart`: interstitial thresholds and caps.

## 3. Home-screen redesign specification

### Recommended visual direction

Build an intimate tabletop: deep green felt, warm ivory tile faces, restrained antique gold, consistent tile shadows, and a subtle kente border. Use existing theme tokens and real tile assets. Keep the play surface visually quiet so the symbols remain easy to scan. Decorative texture should disappear behind the board rather than compete with it.

Use one display font for the title and clear body text for controls. Reserve the strongest gold treatment for the primary action. Secondary navigation should use smaller, quieter controls. Use the same tile geometry, shadow direction, surfaces, and typography on home, gameplay and results.

### Proposed phone layout, top to bottom

1. Compact title: Adinkra Tiles, with subtitle "Mahjong Solitaire" and a settings icon. Keep one consistent public name across icon, opening, home and store listing; the repository is named Sankofa Tiles while several assets and screens say Adinkra Tiles.
2. A real layered-board preview as the central image. Prefer the actual saved board when available; otherwise use a representative opening layout. The preview should be decorative and excluded from tap navigation unless its action is clearly labeled.
3. One dominant button: "Play Level 1" for a new player, "Play Level N" for progression, or "Resume Level N" for a saved board. Show tiles remaining and play style beneath the saved-game action. Current generic CONTINUE copy can be more explicit.
4. A short chapter milestone: "Chapter progress: 6 of 10" as an illustrative format, populated from real chapter bounds. Follow with the next actual symbol or reward. Keep overall campaign totals in Journey.
5. One secondary daily-puzzle card once that feature exists. Until then label the current shortcut "Daily Reward" so it accurately describes the action.
6. Quiet navigation: Journey, Collection, Shop. Put version information in Settings. Help must remain reachable through Settings even when the conditional home prompt disappears.

For a completed campaign, replace the dead-end Continue/snackbar interaction with "Replay a Board", Journey, and the daily puzzle when available.

### Home acceptance criteria

- Primary play action is visible without scrolling at 360 x 640 and 390 x 844 logical pixels, including safe areas and a realistic long chapter name. These are proposed test sizes, not current observed failures.
- Text at 200% scaling remains readable; scrolling may be necessary at enlarged text sizes.
- A new player sees Play; a returning player with a save sees Resume; campaign completion has a useful playable destination.
- Secondary buttons never visually compete with the main action. Maintain at least 48 logical-pixel touch targets.
- In a five-person formative test, at least four participants identify how to start or resume within five seconds. This is a proposed usability gate, not a retention benchmark.

## 4. First session: earn attention through play

The entry flow and tutorial already exist. Audit the full first-install path for duplicated explanations or repeated matching exercises. Teach through the first meaningful board: match a free pair, explain a blocked tile in context, then let the player continue independently. Offer short optional symbol meanings after success.

Keep cultural storytelling, preferences, and help available without making every explanation a mandatory stop. Measure time from first interactive frame to first successful match, not just tutorial completion. A completed tutorial with no campaign board played is not activation.

For returning players, test shortening or suppressing the optional opening. The current opening has a 2.4-second timer and can be tapped away. Prefer immediate access to Resume; preserve animation preferences and reduced-motion support. Do not introduce a recurring ready countdown.

## 5. Gameplay: make the tiles feel physical and the rules fair

Prioritize scanability over extra effects. Audit tile size and symbol contrast on dense boards, distinguish free/selected/blocked states using shape or outlines as well as color, and keep particles away from the next likely tap. Match feedback should be brief, responsive and consistent. Expose sound, music and motion preferences clearly.

Keep Classic and Relaxed, but explain the difference in plain language: Classic uses time in mastery scoring; Relaxed removes the time criterion. The code currently has elapsed time and a Classic speed bonus; this is not evidence of a countdown loss timer. Remember the player's preferred mode rather than asking unnecessarily before each board.

Undo already exists with a limited snapshot and allowance. Improve discoverability and explain when it is unavailable. Evaluate a more generous Relaxed undo policy separately; do not rebuild Undo as if it were absent.

Automatic stuck-board recovery currently reshuffles without a score penalty and without incrementing manual shuffle usage. Show a brief "No pairs left - board refreshed" explanation so the change is understandable. Decide explicitly whether auto-recovered clears qualify for mastery. Either preserve the assist with disclosure or revise scoring consistently; players should understand what earned their stars.

Audit the first ten campaign levels for changing silhouettes, readable symbols, and a gentle rhythm: teach, reinforce, vary, then offer a short success. Use observed completion time, help use and exits to locate difficulty spikes. Existing level-analysis tools are useful inputs; layout variety alone does not demonstrate enjoyable difficulty.

## 6. Same-session retention: make the next board inviting

The result screen already has stars, rewards, chapter progress and symbol-unlock ceremonies. Refine their pacing rather than layering on more mandatory screens.

Keep Next Level in a predictable position. Show one next-board preview and one nearby milestone. Collapse secondary score detail by default. Let players advance after a short readable celebration; keep earned rewards even when the animation is skipped. Review mandatory reveal gates and multiple-symbol ceremonies for repeat-session friction. Replay symbol meanings in Collection.

Avoid routing a player through a full pre-level briefing after every win. Use a compact next-level transition with the remembered play style, while keeping level details reachable. Audit current result and pre-level paths before changing navigation.

Measure whether the improvement increases next-board starts and completions. A longer result animation increases session duration without increasing enjoyable play.

## 7. Return retention: give players something worth returning for

### Add a daily playable board after the core flow is improved

Daily rewards already exist; a daily puzzle adds an actual play reason. Offer one solvable, date-seeded board with a clear completion mark, a monthly collection page, and a small reward. Keep campaign progression independent. Save and resume the daily board separately from the campaign save.

Specify daily rollover and seed versioning before implementation. Use a documented day boundary; handle clock changes, offline use, app upgrades and reward idempotency. If competitive comparisons are added later, local device dates and unverified scores are insufficient. Start without a leaderboard.

### Make the collection an achievable goal

Surface the next actual unlock and how many real steps remain. Connect each earned symbol to its meaning after play, with a permanent Collection entry. Seek knowledgeable cultural review for names, meanings and pronunciation before expanding educational content. Offer optional cosmetic goals, such as a tabletop theme, when the theme system supports them.

### Use forgiving goals

Test a small weekly objective, such as clearing three boards, only after the daily-board loop works. Do not stack multiple new goal systems at once. Let players miss a day without losing earned collection progress. Avoid energy gates or forced waiting: the requested outcome is more enjoyable play.

## 8. Advertising and economy

Current configuration already limits interstitials: completed-level frequency 3, minimum completed levels 2, session cap 2, and an eight-minute cooldown. These constants do not alone prove when an ad is shown; runtime service eligibility still applies. Preserve caps while measuring actual exposure.

A result action may pass through an interstitial before navigation. Measure exits around that interruption. Test a protected first session and compare next-level completion with the current policy. Keep rewarded ads optional, clearly labeled, and separate from normal continuation. Make unavailable-ad handling return the player to a useful game action.

Reduce wallet prominence on home. Inventory matters when choosing assistance; it need not be the main visual introduction. Track booster depletion and recovery exits before changing grants or prices. More friction is not a reliable retention strategy.

## 9. Implementation backlog

Effort is relative: S = localized UI/copy change; M = changes across several screens/state paths; L = new persistent game mode. Estimates require developer scoping. Checkboxes track implementation, not approval. R06 and R07 are complete. R10 and R14 are partial: completed portions are ticked in the progress section above; the full items stay unchecked until their remaining work is finished.

- [ ] R01 | P0 | M | Redesign home around a board preview and one Play/Resume action. Accept when small-screen and text-scale checks in section 3 pass.
- [ ] R02 | P0 | S | Make new, returning, saved-board and campaign-complete CTA states explicit. Accept when every state leads to a playable destination and save replacement is clear.
- [ ] R03 | P0 | S | Replace home campaign-wide progress emphasis with chapter-local progress and the next actual milestone. Accept when chapter boundaries and finale states are correct.
- [ ] R04 | P0 | S | Compact wallet; demote Settings, version and Shop. Make help persistently reachable. Accept when the play action retains visual priority.
- [ ] R05 | P0 | M | Instrument entry-to-first-match, resume, recovery and result continuation. Accept when events fire once per action and exclude developer test games.
- [x] R06 | P1 | M | Shorten result-to-next-board flow; keep rewards durable and celebrations skippable. Accept when skipping never loses or duplicates rewards.
- [x] R07 | P1 | S | Explain automatic reshuffles and confirm mastery policy. Accept when assist copy and star outcomes agree.
- [ ] R08 | P1 | M | Audit dense-board readability, free/blocked states, animation interference and reduced motion. Accept after representative low-end Android and small-screen checks.
- [ ] R09 | P1 | M | Audit full first-install entry/tutorial path and returning opening; remove repeated teaching. Accept when first match and campaign-start metrics are available.
- [ ] R10 | P1 | S | PARTIAL - Clarify and remember Classic/Relaxed preference; improve existing Undo affordance. Accept when selected mode survives relaunch and unavailable actions explain why.
- [ ] R11 | P1 | M | Tune first-ten-level pacing using telemetry and playtests. Accept when each change has a stated learning goal and no generation/solvability regression.
- [ ] R12 | P1 | M | Test first-session ad protection and monitor continuation around ads. Accept when exposure, next-board completion and revenue tradeoffs are reported together.
- [ ] R13 | P2 | L | Add a daily seeded board with separate save and idempotent rewards. Depends on R05 and stable save handling. Accept after rollover, offline, upgrade and duplicate-claim checks.
- [ ] R14 | P2 | M | PARTIAL - Surface next collection unlock and review cultural content. Accept when previews match real unlock rules and meanings remain accessible after reveal.
- [ ] R15 | P2 | M | Test one forgiving weekly goal or an earnable visual theme. Depends on validated core/daily loops; select one initially.
- [ ] R16 | P0 | S | Align public game name and update stale flow references. Accept when the store-facing name, home and entry agree and docs distinguish historical from current behavior.

Suggested sequence: baseline and home (R05, R01-R04, R16); continuity and clarity (R06-R12); daily play and collection depth (R13-R15). Reassess priorities after each measured release. Do not bundle all changes into one retention experiment.

## 10. Measurement plan

Primary outcome: completed boards per active player, interpreted together with D1 and D7 return rates. Longer elapsed sessions alone can reflect friction or ads.

Track:

- Activation: new players who complete their first campaign board / new players who reached an interactive entry or home screen.
- Home-to-play conversion: home visits followed by a campaign or daily board start before leaving / home visits. Report resume separately.
- Next-board conversion: successful results followed by another board start in the same foreground session / successful results.
- Continuation quality: next-board completions / next-board starts, split by source and ad exposure.
- Active play minutes: foreground time with a playable board; exclude pause, background, ads and ceremonies. Report median and upper percentiles, not only mean.
- D1/D7: install-cohort players active on the next calendar day / seven calendar days later, using one documented reporting timezone and counting gameplay activity separately from reward-only visits.
- Guardrails: crash-free players, startup and board-load latency, recovery exits, ad-related exits, reward/save errors and early-level abandonment.

Existing analytics include play_pressed, next_game_pressed, level_started/completed/failed, tutorial steps, entry events, daily claims, unlocks and ad events. The saved-game home branch bypasses the existing logPlayPressed call, so do not treat that event alone as all home play attempts.

Add proposed events: home_primary_tapped (new/resume/progression/replay source), first_match (once per attempt), resume_attempt/resume_result, auto_recovery_shown, result_next_tapped (before ad decision), and board_exit with reason and active duration. Add daily start/complete when shipped. Use an attempt identifier to deduplicate retries and resumptions, keep a stable experiment assignment, and avoid personal input. Keep privacy disclosures aligned with any expanded tracking.

Capture a baseline covering weekday and weekend behavior, then compare one change at a time with randomized cohorts when traffic permits. Predefine one main metric and guardrails, choose sample size from baseline and a minimum meaningful effect, and wait for D7 cohorts to mature. With low traffic, use moderated usability tests and descriptive cohorts; do not claim statistical uplift.

## 11. Practical validation checklist

- [ ] Observe five new players without coaching: can they explain the goal, start, match, understand a blocked tile, and choose another board?
- [ ] Observe returning players with and without a save: can they resume immediately and understand the milestone?
- [ ] Review home and gameplay at small portrait sizes, large text, reduced motion, muted audio and color-vision variations.
- [ ] Verify saves through backgrounding, process termination, relaunch and updates; check campaign/daily separation if added.
- [ ] Verify reward persistence after skipping ceremonies, retrying, resuming and interrupted writes.
- [ ] Compare chapter starts, dense boards and final levels for readability and board-generation latency.
- [ ] Confirm ads never occur during a match and Next returns to the intended level when an ad fails or closes.
- [ ] Record owner, release, implementation status and observed metric outcome beside each backlog ID during implementation.

## 12. External reference and limits

Microsoft's Mahjong product page describes daily challenges, monthly badges, hints, Undo, themes and tile sets: https://www.microsoftcasualgames.com/mahjong (accessed 14 October 2026).

This is a useful genre reference for a complete solitaire offering. It does not establish that copying a feature will improve this game's retention. The prioritized recommendations come from the current source review and should be validated with players and measured cohorts.

Start with R01-R05 and R16. The most valuable first release is a clear, board-led home and a measurable path into play; the daily puzzle is the next substantial feature once that path works well.
