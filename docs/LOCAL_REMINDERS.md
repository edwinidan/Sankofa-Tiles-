# Gentle local reminders

Reminders are opt-in through the single **Gentle reminders** switch in Settings.
There are no day/time pickers, automatic permission requests, gameplay prompts,
or prompts to resume reminders. Enabling the switch requests the OS alert
permission; sound and badge permissions are not requested on iOS. A denial
leaves the switch off and explains that permission is controlled in phone Settings.

## Schedule

The phone schedules eight one-shot requests. No messaging server, account,
periodic worker, or exact-alarm permission is required.

- The first request is at 7 PM in the device timezone, at least 24 hours after
  the player's last app session ends.
- The first four requests are spaced two calendar days apart, covering a
  seven-day window.
- There is then a five-day (at least 120-hour) cooldown after request four.
- The final four requests are spaced two calendar days apart over another
  seven-day window. After request eight there is no repeating schedule.
- Returning to the app cancels pending requests, clears these notifications,
  and quietly resets the cycle. It never re-enables a switch the player turned off.
- Leaving the foreground records the latest activity and installs a fresh plan.
  This also counts collection browsing and other in-app time as recent activity.
  Nothing is scheduled while the app is in the foreground.

For example, leaving on November 5 at 10 AM in Accra produces 7 PM invitations
on November 6, 8, 10, 12, then November 17, 19, 21, 23. There is no further
notification unless the player returns. Reopening cancels this old plan rather
than catching up its elapsed dates.

Timezone-aware calendar dates preserve 7 PM across daylight-saving changes.
The full IANA database includes device aliases such as `Africa/Accra`. A spring
clock change during the cooldown can add a calendar day to preserve at least
120 quiet hours. The timezone is refreshed when scheduling after a return;
travelling without opening the app does not immediately recalculate existing
requests. Android uses inexact scheduling, so 7 PM is approximate and OS battery
policies can delay or suppress delivery. As with other local notifications,
platform reboot/offline delivery behavior must be checked on supported devices.

## Copy and tapping

All reminders are titled **Adinkra Tiles**. Their messages rotate:

- Saved board: “Pick up where you left off, one pair at a time.”
- Next board: “Level 42 is ready whenever you are.”
- Completed journey: “Return to a favourite board and enjoy another quiet moment.”
- “A quiet moment? Your next board is waiting.” (or a favourite-board invitation
  after finishing the campaign)
- “Settle in for a little matching, at your own pace.”
- “Your tiles are here whenever you’re ready.”

Tapping resumes a saved board under its existing rules, otherwise starts the next
Relaxed board, or opens Journey if all current levels are complete. The route
uses current saved progress at tap time rather than trusting an old level ID in
the notification. These notifications have no default sound, vibration, numbered
badge, or high-priority interruption.

## Implementation

- `reminder_plan.dart` contains the finite schedule and copy.
- `reminder_gateway.dart` adapts native permissions, timezone lookup, scheduling,
  and notification callbacks. Android receivers restore pending requests after
  reboot or an app update. The notification icon is explicitly kept in release builds.
- `local_reminder_service.dart` serializes lifecycle/permission operations so
  returning or opting out cannot be overwritten by an older scheduling pass.
- `ReminderLifecycle` handles foreground/background transitions and warm/cold taps.
- `reminderSettingsProvider` exposes enabled/busy state for Settings.
- Preferences are stored in `gentle_reminders_enabled` (default false) and
  `gentle_reminders_last_activity`. Existing progress and purchases are unaffected.

Flutter 3.38.1 / Dart 3.10 or newer is required by the notification dependency.

## Validation

```sh
flutter test --no-pub test/local_reminders_test.dart test/reminder_gateway_test.dart test/reminder_flow_test.dart
flutter analyze --no-pub
flutter build apk --debug --no-pub
flutter build ios --simulator --debug --no-codesign --no-pub
```

Before release, use real Android and iOS devices to verify permission denial and
revocation, quiet delivery while terminated, warm/cold taps, reboot behavior,
and OS battery restrictions. Automated tests validate the schedule, DST, aliases,
permission timing, finite native payloads, cancellation races, Settings, and routing;
builds alone do not prove notification delivery on a physical phone.
