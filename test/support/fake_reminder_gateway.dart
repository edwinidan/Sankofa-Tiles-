import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sankofa_tiles/core/reminders/reminder_gateway.dart';
import 'package:sankofa_tiles/core/reminders/reminder_plan.dart';

class FakeReminderGateway implements ReminderGateway {
  bool supported = true;
  bool permission = true;
  bool coldStartTap = false;
  int permissionRequests = 0;
  int initializations = 0;
  int cancellations = 0;
  int? failAfter;
  final scheduled = <PlannedReminder>[];
  VoidCallback? tap;
  Future<tz.Location> Function()? timezoneLoader;
  tz.Location? location;

  @override
  bool get isSupported => supported;
  @override
  Future<void> initialize(VoidCallback onTap) async {
    initializations++;
    tap = onTap;
    if (coldStartTap) onTap();
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<bool> hasPermission() async => permission;
  @override
  Future<tz.Location> localTimezone() =>
      timezoneLoader?.call() ?? Future.value(location ?? tz.UTC);
  @override
  Future<void> cancelReminders() async {
    cancellations++;
    scheduled.clear();
  }

  @override
  Future<void> schedule(PlannedReminder reminder) async {
    if (failAfter == scheduled.length) {
      throw StateError('Native scheduling failed');
    }
    scheduled.add(reminder);
  }
}
