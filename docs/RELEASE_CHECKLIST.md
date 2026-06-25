# Release Checklist

## Automated Validation

| Check | Status | Notes |
|---|---|---|
| `dart format` | Passed | Phase 5 touched files formatted. |
| `flutter analyze` | Passed | No analyzer issues. |
| `flutter test` | Passed | Full suite passed. |
| Release-readiness regression test | Passed | App identity, ad-id removal, signing config, portrait lock, developer default, and no live ad SDK are checked. |

## Android

| Item | Status | Notes |
|---|---|---|
| App label | Passed | `android:label="Adinkra Tiles"`. |
| Package id | Passed | `com.sankofatiles.sankofa_tiles`. |
| Advertising ID permissions | Passed | AD_ID and AdServices AD_ID are removed in manifest. |
| Firebase Analytics ad id collection | Passed | Disabled in manifest metadata. |
| Release signing config | Present | Uses `upload` signing config and `android/key.properties`; actual key validity must be protected outside repo. |
| Build Android release AAB | Passed | `build/app/outputs/bundle/release/app-release.aab` built successfully. |
| Play Data Safety | Blocker | Must be completed in Play Console after final SDK choices. |
| AdMob app/products | Blocker for live monetized release | Live SDK not integrated yet. |
| Billing products | Blocker for live monetized release | Live billing SDK not integrated yet. |

## iOS

| Item | Status | Notes |
|---|---|---|
| Display name | Passed | `Adinkra Tiles`. |
| Portrait orientation | Passed | Portrait only in `Info.plist`. |
| Restore Purchases UI | Passed | Shop Restore section exists. |
| Release build config | Passed no-codesign build | `flutter build ios --release --no-codesign` built `build/ios/iphoneos/Runner.app`. |
| Release signing | Manual | Requires Xcode team/profile validation and manual codesigning before device/App Store deployment. |
| App Privacy labels | Blocker | Must be completed after final ad/billing SDK choices. |
| In-app purchase products | Blocker for live monetized release | Live billing SDK not integrated yet. |

## Privacy and Legal

| Item | Status | Notes |
|---|---|---|
| Privacy findings | Updated | Sandbox monetization status documented. |
| Published privacy policy | Blocker | Must be updated to match final production SDK behavior. |
| Terms / purchase disclosure | Blocker for live purchases | Needed before paid products. |
| Consent UI | Blocker for live ads | Not implemented because no live ad SDK initializes. |
| Children’s privacy decision | Manual | Decide whether the app is directed to children before store submission. |

## Product Readiness

| Item | Status | Notes |
|---|---|---|
| Full 50-level campaign generation | Passed | Existing tests cover all campaign levels. |
| Economy duplication protection | Passed | Economy and monetization idempotency tests pass. |
| Offline gameplay | Passed by architecture | Core game uses local state; monetization offline states do not block play. |
| Accessibility | Manual follow-up | See `docs/ACCESSIBILITY_REPORT.md`. |
| Store screenshots | Manual | Not generated in this phase. |

## Final Status

The app is validated as a sandbox monetization build, not yet a production monetized store build. Production release is blocked by live billing/ad SDK integration, receipt validation, consent/legal updates, and store-console configuration.
