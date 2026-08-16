# ACTION REQUIRED — Edwin

Actions only Edwin can personally perform. Grouped by urgency.

---

## Required Now

- [ ] **Physical-device testing (debug build)**
  Run `flutter run --dart-define=ENABLE_DEVELOPER_TOOLS=true` on a physical Android device.
  Complete the full [PHYSICAL_DEVICE_TEST_CHECKLIST.md](PHYSICAL_DEVICE_TEST_CHECKLIST.md).
  Focus on: consent form appearance, rewarded hint, retry assistance wording, interstitial timing, and audio behavior.

- [ ] **Review retry-assistance UX wording**
  The loss screen now shows:
  - Title: "Retry with help"
  - Description: "Watch an ad to retry this level with one free Shuffle."
  - Button: "WATCH AD & RETRY"
  Confirm this wording matches your intended player experience.

---

## Required Before Internal Testing

- [ ] **Upload internal-test AAB to Google Play**
  Build: `flutter build appbundle --release`
  (This uses test ad IDs — safe for internal testers.)
  Upload to the internal testing track in Google Play Console.

- [ ] **Google Play: "Contains ads" declaration**
  In Google Play Console → App content → Ads, declare: **Yes, the app contains ads.**

- [ ] **Google Play: Data Safety review**
  Review the Data Safety section in Google Play Console.
  Since AD_ID permissions are removed, you should NOT declare advertising ID collection.
  Declare: Crashlytics crash logs, analytics data, shared preferences (local only).
  If using personalized ads in the future, update accordingly.

- [ ] **Privacy policy update**
  Update your privacy policy at `https://adinkra-tiles-privacy-policy.vercel.app/` to include:
  - Google AdMob usage for serving ads
  - UMP consent framework for GDPR/EEA users
  - Types of data collected by ad SDKs (if applicable)
  - Link to Google's privacy policy for ads

- [ ] **Physical-device testing (internal-test build)**
  Install the internal-test AAB via Play Store internal testing.
  Repeat the [PHYSICAL_DEVICE_TEST_CHECKLIST.md](PHYSICAL_DEVICE_TEST_CHECKLIST.md) on the release build.
  Because release builds select production IDs automatically, use only an
  AdMob-registered test device and verify the **Test Ad** or **Test mode**
  indicator before interacting with an ad.

---

## Required Before Production

- [ ] **Final production AAB build**
  Release builds automatically use production IDs: `flutter build appbundle --release`.
  Test release builds only on an AdMob-registered test device and verify the
  **Test Ad** or **Test mode** indicator before interacting with an ad. Never
  click your own live production ads.
  Debug builds use Google test IDs by default; release builds serve from the
  configured production IDs automatically.

- [ ] **Upload production AAB to Google Play**
  Upload to the production track in Google Play Console.
  Do NOT upload until all internal testing is complete.

- [ ] **Link Play Store listing in AdMob**
  In the AdMob console → Apps → Adinkra Tiles → App settings → Link to app stores.
  Link the public Google Play listing.
  This enables AdMob to verify app ownership and is required for ad serving.

- [ ] **app-ads.txt setup and verification**
  1. Create or update `app-ads.txt` on your developer website.
  2. Content: `google.com, pub-5484820744037011, DIRECT, f08c47fec0942fa0`
  3. The file must be accessible at: `https://yourdomain.com/app-ads.txt`
  4. In Google Play Console → Store listing → Website, ensure the website URL is set.
  5. In AdMob console → Apps → Adinkra Tiles → App settings → Verify `app-ads.txt` status.
  6. Allow 24-48 hours for verification.

- [ ] **Publish production release**
  After uploading the production AAB, complete the Google Play review and release.

- [ ] **Monitor AdMob dashboard**
  After launch, check the AdMob dashboard for:
  - Ad requests and fill rate
  - Revenue reporting
  - Policy violations or warnings
  - app-ads.txt verification status
