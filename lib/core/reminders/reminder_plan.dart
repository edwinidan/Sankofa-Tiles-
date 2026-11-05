import 'package:timezone/timezone.dart' as tz;

const reminderPayload = 'gentle_reminder';
const reminderIds = [7100, 7101, 7102, 7103, 7104, 7105, 7106, 7107];

class PlannedReminder {
  const PlannedReminder(
      {required this.id, required this.at, required this.body});

  final int id;
  final tz.TZDateTime at;
  final String body;
}

/// Four invitations over seven days, five days quiet, then four final ones.
/// These are one-shot requests: nothing repeats after the eighth invitation.
List<PlannedReminder> buildReminderPlan({
  required DateTime lastActivity,
  required tz.Location location,
  bool hasSavedBoard = false,
  int? nextLevelId,
}) {
  final earliest = lastActivity.add(const Duration(hours: 24));
  final local = tz.TZDateTime.from(earliest, location);
  var first = tz.TZDateTime(location, local.year, local.month, local.day, 19);
  if (first.isBefore(earliest)) {
    first = tz.TZDateTime(location, local.year, local.month, local.day + 1, 19);
  }

  // Calendar constructors keep 7 PM stable when daylight saving changes.
  // The second window starts no earlier than 120 hours after reminder four.
  var second =
      tz.TZDateTime(location, first.year, first.month, first.day + 11, 19);
  final fourth =
      tz.TZDateTime(location, first.year, first.month, first.day + 6, 19);
  if (second.difference(fourth) < const Duration(days: 5)) {
    second =
        tz.TZDateTime(location, second.year, second.month, second.day + 1, 19);
  }

  final contextual = hasSavedBoard
      ? 'Pick up where you left off, one pair at a time.'
      : nextLevelId != null
          ? 'Level $nextLevelId is ready whenever you are.'
          : 'Return to a favourite board and enjoy another quiet moment.';
  final messages = [
    contextual,
    nextLevelId == null && !hasSavedBoard
        ? 'A quiet moment? Revisit a favourite board.'
        : 'A quiet moment? Your next board is waiting.',
    'Settle in for a little matching, at your own pace.',
    'Your tiles are here whenever you’re ready.',
  ];
  return List.unmodifiable([
    for (var index = 0; index < reminderIds.length; index++)
      PlannedReminder(
        id: reminderIds[index],
        at: index < 4
            ? tz.TZDateTime(
                location, first.year, first.month, first.day + index * 2, 19)
            : tz.TZDateTime(location, second.year, second.month,
                second.day + (index - 4) * 2, 19),
        body: messages[index % messages.length],
      ),
  ]);
}
