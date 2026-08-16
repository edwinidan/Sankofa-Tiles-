# Ad Placement & UX Analysis — Sankofa Tiles

This report reviews the current placement of AdMob advertisements in **Sankofa Tiles**, details how users interact with them, analyzes potential friction points, and provides recommendations on placements to add, modify, or remove.

---

## 1. Current Ad Placements & User Interactions

The app currently implements two categories of ads: **Rewarded Ads** (where users opt-in to watch an ad in exchange for a reward) and **Interstitial Ads** (full-screen ads shown during natural transitions, subject to strict pacing rules).

### A. Rewarded Ads (User-Initiated)

| Placement | UI Screen / Trigger Point | User Interaction Flow | Reward Granted |
| :--- | :--- | :--- | :--- |
| **Free Hint** (`freeHint`) | **Game Screen** (Control Dock)<br>• Tapped when Hint count is `0`. | Tapping the "Hint" button immediately starts loading and showing the ad. | `1` Hint booster |
| **Free Shuffle** (`freeRescueShuffle`) | **Game Screen** (Control Dock)<br>• Tapped when Shuffle count is `0`. | Tapping the "Shuffle" button immediately starts loading and showing the ad. | `1` Shuffle booster |
| **Daily Bonus** (`bonusDailyChest`) | **Daily Reward Screen**<br>• Tapped via "BONUS CHEST" button. | User taps "BONUS CHEST" button (labeled with a video icon) to watch the ad. | `30` Cowries + `1` Hint booster |
| **Shop Gift** (`smallShopReward`) | **Shop Screen**<br>• Tapped via "WATCH" button in "Free Shop Gift" card. | User scrolls to the gift panel and taps the "WATCH" button (labeled with a video icon). | `25` Cowries |
| **Double Cowries** (`doubleCompletionCowries`) | **Result Screen (Win)**<br>• Tapped via "DOUBLE COWRIES" button. | After level completion, user taps the button (labeled with a video icon) to double their level completion earnings. | `baseCowries` (effectively 2x earnings) |
| **Retry Assist** (`retryAssistance`) | **Result Screen (Loss)**<br>• Tapped via "WATCH AD & RETRY" button. | After losing (no more moves), user taps the button to restart the level with an extra booster. | `1` Shuffle booster + Level Restart |

### B. Interstitial Ads (Forced Transitions)

| Placement | Trigger Point / Location | Pacing and Eligibility Rules |
| :--- | :--- | :--- |
| **Level Win Transition** (`afterCompletedLevels`) | **Result Screen (Win)**<br>• Triggered when entering or displaying the win screen. | **Only shown if all the following conditions are met:**<br>1. User does not own the "Remove Ads" entitlement.<br>2. First session is completed (the very first level won is protected).<br>3. Tutorial is completed.<br>4. At least `2` levels have been completed.<br>5. Every `3` completed levels (`completedLevelFrequency = 3`).<br>6. Minimum `8` minutes since the last Interstitial ad.<br>7. Minimum `2` minutes since the last Rewarded ad.<br>8. Cap of `2` Interstitial ads shown per app session. |

---

## 2. Key Technical & Configuration Findings

### ✅ Production Unit IDs Configured For Enabled Placements
In `lib/core/ads/ad_ids.dart`, every enabled rewarded placement plus the
level-transition interstitial and settings banner has a distinct Android and
iOS production ad-unit ID. The unused `returningHome` and `beforeNewChapter`
interstitial placements intentionally return `null`.

Release builds automatically select production IDs through
`kReleaseMode || useProductionAds`. Debug builds use Google's platform-specific
test IDs by default.

### ✅ iOS Ads Configured
The iOS AdMob App ID is configured in `ios/Runner/Info.plist`, and the resolver
returns iOS-specific test or production ad-unit IDs for supported placements.
It does not return Android IDs on iOS.

### 🔄 Session Cap Resets on Boot
The `sessionInterstitialCap` (set to `2` per session) is stored in `SharedPreferences` but is explicitly reset to `0` in `StorageService.init()` every time the app boots.
* **Impact:** This is a clean, player-friendly implementation that ensures players aren't overwhelmed with ads, while correctly resetting the cap for each new session.

---

## 3. UX & Friction Analysis

### 🔴 High Friction: Instant In-Game Ad Playback (Free Hint / Free Shuffle)
* **Behavior:** When a player runs out of Hint or Shuffle boosters mid-game, tapping the booster button in the dock immediately launches the full-screen rewarded ad.
* **Friction:** In active gameplay, this is highly disruptive. Tapping a gameplay tool should never launch a full-screen video instantly without warning. This violates the core design principle that rewarded ads should be explicitly opted into. Players may trigger this by accident and feel frustrated that the game was abruptly halted.

### 🟡 Confusion: "Retry Assist" vs. "Continue"
* **Behavior:** The ad unit is named `_androidRewardedContinue`, but the screen title shows "Retry with help" and the button says "WATCH AD & RETRY". 
* **Details:** This placement does *not* resume the current board state (which would require complex board reconstruction logic). Instead, it acts as a level restart with a bonus Shuffle. The button text "WATCH AD & RETRY" is clear and avoids misleading the player into thinking their progress is saved, but the underlying variable/configuration naming remains slightly inconsistent.

---

## 4. Recommendations: What to Add, Modify, or Remove

### 💡 Recommendation 1: Add a Confirmation Dialog for In-Game Rewarded Ads
* **Action:** Instead of launching the ad immediately when a player clicks "Hint" or "Shuffle" at `0` count, display a themed modal popup.
* **Suggested Text:** 
  > *"No Hints left! Watch a short video to get 1 Free Hint?"* 
  > **[ WATCH ]**  **[ CANCEL ]**
* **Rationale:** This preserves active gameplay flow, prevents accidental ad triggers, and aligns with Google Mobile Ads policies regarding user consent and expectations.

### 💡 Recommendation 2: Enforce Release-Test Safety
* **Action:** Test TestFlight and other release builds only on devices registered
  as AdMob test devices. Confirm the **Test Ad** or **Test mode** indicator is
  visible before interacting. Publishers must never click their own live ads.
* **Rationale:** Release builds automatically use the configured production IDs,
  including the iOS IDs used by App Store builds.

### 💡 Recommendation 4: Remove Unused Interstitial Placements
* **Action:** Remove `returningHome` and `beforeNewChapter` from the `InterstitialPlacement` enum in [lib/core/monetization/monetization_models.dart](file:///Users/edwinrichardidan/projects/GitHub/Sankofa-Tiles-/lib/core/monetization/monetization_models.dart) and their corresponding lines in `ad_ids.dart`.
* **Rationale:** These placements are defined in the models and ad IDs but are never used anywhere in the UI or game screens. Removing them cleans up dead code. If you want to use them in the future, they can be re-added when the corresponding navigation hook is implemented.

### 💡 Recommendation 5: Avoid Banner Ads (Do NOT Add)
* **Action:** Keep banner ads out of the project.
* **Rationale:** Although banner ads provide passive revenue, they would severely clash with the game's premium Ghanaian "Sankofa" visual aesthetics (gold and parchment styling). Since the game already has plenty of rewarded opt-in points and a well-paced interstitial transition, banner ads would degrade the user experience without providing a substantial revenue increase.
