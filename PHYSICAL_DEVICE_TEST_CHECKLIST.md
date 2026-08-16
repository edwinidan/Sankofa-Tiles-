# Physical Device Test Checklist

Manual testing checklist for **Adinkra Tiles** AdMob integration.
Run these tests on a physical Android device before each milestone.

## Setup

1. Install a debug build: `flutter run --dart-define=ENABLE_DEVELOPER_TOOLS=true`
2. For UMP debug geography, no additional setup is needed (debug builds auto-enable EEA geography).
3. For Ad Inspector, open the app, then use the developer tools or call `MobileAds.instance.openAdInspector()`.

---

## Test Matrix

| # | Scenario | Steps | Expected Result | Pass/Fail |
|---|---|---|---|---|
| 1 | **Fresh install** | Uninstall the app. Reinstall from debug build. Launch. | Onboarding → Tutorial → Level 1 appears. No crashes. | ☐ |
| 2 | **Returning user** | Quit and reopen the app with existing progress. | Home screen shows correct progress. No duplicate consent forms. | ☐ |
| 3 | **Consent form — EEA debug** | Fresh install in debug mode. | UMP consent form appears automatically on first launch. | ☐ |
| 4 | **Consent accepted** | Accept consent when the form appears. | Ads begin loading. Privacy choices appears in Settings. | ☐ |
| 5 | **Consent declined** | Decline consent when the form appears. | Game continues normally. No ads are shown. No crashes. | ☐ |
| 6 | **Privacy choices from Settings** | Go to Settings → Privacy choices. | Official UMP privacy-options form opens. After closing, Settings updates visibility correctly. | ☐ |
| 7 | **Rewarded Hint earned** | Play a level. Run out of Hints. Tap Hint → "Watch ad" → Watch the full test ad. | Hint booster count increases by 1 after the ad completes. | ☐ |
| 8 | **Rewarded Hint closed early** | Tap Hint → Close the test ad before it finishes. | No Hint granted. Snackbar shows "Ad was not completed." Player can try again. | ☐ |
| 9 | **Retry assistance earned** | Lose a level (no more moves). Tap "WATCH AD & RETRY". Watch the full test ad. | Level restarts with 1 free Shuffle granted. Wording says "Retry with help" and "retry this level with one free Shuffle." | ☐ |
| 10 | **Retry assistance closed early** | Lose a level. Tap "WATCH AD & RETRY". Close the test ad early. | No Shuffle granted. Button becomes tappable again. Snackbar shows failure message. | ☐ |
| 11 | **Rapid repeated taps** | Lose a level. Tap "WATCH AD & RETRY" rapidly multiple times. | Only one ad loads. Button shows "LOADING…" and is disabled. No duplicate ads or retries. | ☐ |
| 12 | **Interstitial threshold** | Complete 3+ levels (past the minimum completed level threshold). | Interstitial test ad appears after a completed level. | ☐ |
| 13 | **Interstitial cooldown** | After seeing an interstitial, immediately complete another level. | No interstitial appears (8-minute cooldown). | ☐ |
| 14 | **No interstitial during tutorial** | Complete the tutorial for the first time. | No interstitial appears during or after tutorial. | ☐ |
| 15 | **No interstitial during first session** | Fresh install → complete the first level. | No interstitial appears for the first completed level. | ☐ |
| 16 | **No interstitial after rewarded** | Watch a rewarded ad. Then complete a level within 2 minutes. | No interstitial appears (rewarded-ad cooldown). | ☐ |
| 17 | **Offline mode** | Enable airplane mode. Complete a level. | Game functions normally. No ad-related crashes. Interstitial is skipped gracefully. | ☐ |
| 18 | **Slow network** | Throttle network (e.g., developer options or network conditioner). Complete a level. | Interstitial may fail to load but navigation continues normally. No freezes. | ☐ |
| 19 | **App backgrounding during ad** | While a test ad is showing, press Home then return to the app. | Ad resumes or dismisses cleanly. Game continues. No stuck state. | ☐ |
| 20 | **Audio before and after ads** | Play with music/SFX enabled. Trigger a full-screen ad. Return to game. | Audio resumes at the correct volume after the ad closes. | ☐ |
| 21 | **Progression persistence** | Complete several levels, see rewards. Force-quit the app. Reopen. | All level scores, stars, cowries, and boosters are preserved. | ☐ |
| 22 | **Ad Inspector** | Open Ad Inspector from developer tools. | Ad Inspector opens showing ad activity, recent requests, and configuration. No errors. | ☐ |

---

## Notes

- **Test ad units**: Debug builds automatically use Google's official test ad-unit IDs (`ca-app-pub-3940256099942544/*`). These show test banners/content, not real ads.
- **EEA debug geography**: Debug builds automatically configure UMP with `DebugGeography.debugGeographyEea` so the consent form always appears.
- **Production ads**: Every release build automatically selects the configured
  platform-specific production IDs. TestFlight/release testing must use an
  AdMob-registered test device. Verify the **Test Ad** or **Test mode** indicator
  before interacting, and never click your own live production ads.

## Sign-off

| Role | Name | Date | Notes |
|---|---|---|---|
| Developer | | | |
| QA / Edwin | | | |
