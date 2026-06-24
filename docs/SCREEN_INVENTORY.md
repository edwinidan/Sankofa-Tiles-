# Screen Inventory

## App Shell

| Screen or surface | File | Notes |
|---|---|---|
| App root | `lib/app.dart` | Builds `MaterialApp.router` with `AppTheme.darkTheme` and router from `createAppRouter(storage)`. |
| Router error page | `lib/core/router/app_router.dart` | Dark background, simple page-not-found text. |

## Main Screens

| Screen | File | Route | Current role |
|---|---|---|---|
| Home | `lib/screens/home/home_screen.dart` | `/` | Logo, Continue, Journey, wallet/booster summary, Daily Reward, Adinkra Collection, Settings, How to Play, version label. |
| Onboarding | `lib/screens/onboarding/onboarding_screen.dart` | `/onboarding` | Concise cultural introduction before tutorial. |
| Tutorial | `lib/screens/tutorial/tutorial_screen.dart` | `/tutorial` | Controlled interactive tutorial with matching, blocked tile, hint, and completion persistence. |
| Journey | `lib/screens/journey/journey_screen.dart` | `/journey` | Five-chapter Grand Archive map for all 50 levels. |
| Pre-Level | `lib/screens/pre_level/pre_level_screen.dart` | `/level/:levelId` | Level summary and normal launch gate. |
| Game | `lib/screens/game/game_screen.dart` | `/game/:levelId` | Starts board, displays HUD, board, control dock, pause/load-failed overlays. |
| Result | `lib/screens/result/result_screen.dart` | `/result` | Win/loss summary, grants Phase 3 rewards for normal wins, saves normal wins, offers next/retry/home actions. |
| Chapter Complete | `lib/screens/chapter/chapter_complete_screen.dart` | `/chapter-complete/:levelId` | Chapter milestone and campaign-complete surface. |
| Daily Reward | `lib/screens/daily/daily_reward_screen.dart` | `/daily-reward` | Seven-day local reward cycle with Cowrie/booster claim state. |
| Settings | `lib/screens/settings/settings_screen.dart` | `/settings` | Audio, music volume, haptics, tile names, privacy, developer tools. |
| Adinkra Collection | `lib/screens/preview/tile_preview_screen.dart` | `/tile-preview` | Progression-based collection browser with locked symbols, unlock source hints, and existing verified tile content for unlocked items. |
| Developer Level Tester | `lib/screens/developer/developer_level_tester_screen.dart` | `/developer/levels` | Developer-only level grid and test launch controls. |

## Dialogs, Sheets, and Overlays

| Surface | File | Trigger | Behavior |
|---|---|---|---|
| Quit dialog | `lib/screens/game/game_screen.dart` | Back/header back during game | Pauses, then Resume or Quit. |
| Paused overlay | `lib/screens/game/game_screen.dart` | `GameStatus.paused` | Resume or Quit over the board area. |
| Load failed overlay | `lib/screens/game/game_screen.dart` | `GameStatus.loadFailed` | Retry board generation or leave. |
| Combo overlay | `lib/screens/game/game_screen.dart` | Streak >= 2 | Temporary animated streak feedback. |
| Game settings sheet | `lib/screens/game/game_screen.dart` | Header settings button | Bottom sheet for audio/music/tile names/haptics. Uses some legacy `AppColors`. |
| Reset progress dialog | `lib/screens/settings/settings_screen.dart` | Developer reset action | Confirms and clears level progress keys. |
| SnackBars | Home, Settings, Developer Tester | Completion, reset, privacy failure, test reset | Short status feedback. |

## Reusable UI

| Component | File | Notes |
|---|---|---|
| `SankofaBackground` | `lib/widgets/sankofa_background.dart` | Shared dark/green background image treatment. |
| `KenteButton` | `lib/widgets/kente_button.dart` | Primary app button used across home/result/settings/dev flows. |
| `AdinkraDivider` | `lib/widgets/adinkra_divider.dart` | Decorative divider. |
| `ParchmentBackground` | `lib/screens/game/widgets/parchment_background.dart` | Game screen parchment surface. |
| `GameHeader` | `lib/screens/game/widgets/game_header.dart` | Level header, back, settings. |
| `GameControlDock` | `lib/screens/game/widgets/game_control_dock.dart` | Hint, Shuffle, Open Path inventory controls and game stats. |
| `BoardWidget` | `lib/screens/game/widgets/board_widget.dart` | Rendered tile board. |
| `TileWidget` | `lib/screens/game/widgets/tile_widget.dart` | Individual tile presentation. |

## Missing Planned Screens

These are not implemented after Phase 3: shop, rewarded ads, interstitial ads, banner ads, in-app purchase flows, restore purchases, and remove-ads flows.
