# Firebase Tracking Notes

Firebase Analytics and Firebase Crashlytics are included for Play Store MVP
quality monitoring.

## Analytics events

- App open and screen views
- Level started, completed, and failed
- Hint, shuffle, and pause usage
- Settings opened
- Tile preview opened
- Onboarding completed
- Progress reset

Event parameters are limited to gameplay context such as level number,
difficulty, score, stars, elapsed time, event source, and failure reason.

No personal user input is logged. No individual tile taps, tile selections, or
tile-level personal data are logged.

## Crash reporting

Crashlytics records uncaught Flutter and platform errors. It also receives
selected non-fatal reports for board generation, game startup, audio playback,
and local persistence failures.

This data is used only for crash reporting and gameplay quality improvement.

The Play Console Data Safety form and the published privacy policy must disclose
the use of Firebase Analytics and Firebase Crashlytics before release.
