import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:sankofa_tiles/core/reminders/local_reminder_service.dart';
import 'package:sankofa_tiles/core/reminders/reminder_plan.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'support/fake_reminder_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  test(
      'eight finite reminders form two seven-day windows with a five-day break',
      () {
    final activity = DateTime.utc(2026, 11, 5, 10);
    final plan = buildReminderPlan(
        lastActivity: activity, location: tz.UTC, nextLevelId: 42);
    expect(plan, hasLength(8));
    expect(plan.map((r) => r.id).toSet(), hasLength(8));
    expect(plan.first.at, DateTime.utc(2026, 11, 6, 19));
    for (final window in [plan.take(4).toList(), plan.skip(4).toList()]) {
      expect(
          window.last.at.difference(window.first.at), const Duration(days: 6));
      for (var i = 1; i < window.length; i++) {
        expect(
            window[i].at.difference(window[i - 1].at), const Duration(days: 2));
      }
    }
    expect(plan[4].at.difference(plan[3].at), const Duration(days: 5));
    expect(plan.every((r) => r.at.hour == 19 && r.at.minute == 0), isTrue);
    expect(plan.first.body, 'Level 42 is ready whenever you are.');
  });

  for (final hour in [0, 18, 19, 20, 23]) {
    test('last activity at $hour never produces a reminder inside 24 hours',
        () {
      final activity = DateTime.utc(2026, 11, 5, hour, 30);
      final plan = buildReminderPlan(lastActivity: activity, location: tz.UTC);
      expect(plan.first.at.difference(activity),
          greaterThanOrEqualTo(const Duration(hours: 24)));
    });
  }

  test('seven PM uses the device zone rather than UTC', () {
    final zone = tz.getLocation('Asia/Kolkata');
    final activity = DateTime.utc(2026, 11, 5, 10);
    final plan = buildReminderPlan(lastActivity: activity, location: zone);
    expect(plan.first.at.hour, 19);
    expect(plan.first.at.toUtc().hour, 13);
    expect(plan.first.at.toUtc().minute, 30);
  });

  for (final activity in [
    DateTime.utc(2026, 3, 1, 10),
    DateTime.utc(2026, 10, 24, 10)
  ]) {
    test('DST at $activity keeps seven PM and at least 120 quiet hours', () {
      final plan = buildReminderPlan(
          lastActivity: activity, location: tz.getLocation('America/New_York'));
      expect(plan.every((r) => r.at.hour == 19), isTrue);
      expect(plan.first.at.difference(activity),
          greaterThanOrEqualTo(const Duration(hours: 24)));
      expect(plan[4].at.difference(plan[3].at),
          greaterThanOrEqualTo(const Duration(days: 5)));
    });
  }

  test('messages reflect a saved board and a finished journey', () {
    final saved = buildReminderPlan(
        lastActivity: DateTime.utc(2026),
        location: tz.UTC,
        hasSavedBoard: true,
        nextLevelId: 9);
    expect(saved.first.body, 'Pick up where you left off, one pair at a time.');
    final complete =
        buildReminderPlan(lastActivity: DateTime.utc(2026), location: tz.UTC);
    expect(complete.first.body, contains('favourite board'));
    expect(
        complete.map((r) => r.body).join(' '), isNot(contains('next board')));
  });

  group('reminder service', () {
    late StorageService storage;
    late FakeReminderGateway gateway;
    late LocalReminderService service;
    late DateTime now;

    setUp(() async {
      SharedPreferences.setMockInitialValues(
          {'campaign_progress_schema_version': 4});
      storage = StorageService();
      await storage.init();
      gateway = FakeReminderGateway();
      now = DateTime.utc(2026, 11, 5, 10);
      service = LocalReminderService(storage, gateway, now: () => now);
    });

    test(
        'default-off startup never initializes or requests notification permission',
        () async {
      await service.onForeground();
      await service.onBackground();
      expect(service.enabled, isFalse);
      expect(gateway.initializations, 0);
      expect(gateway.permissionRequests, 0);
      expect(gateway.scheduled, isEmpty);
    });

    test('enabling requests permission once, schedules only after leaving',
        () async {
      expect(await service.setEnabled(true), ReminderSettingResult.enabled);
      expect(gateway.permissionRequests, 1);
      expect(gateway.scheduled, isEmpty);
      now = now.add(const Duration(hours: 2));
      await service.onBackground();
      expect(gateway.scheduled, hasLength(8));
      expect(gateway.scheduled.first.at.difference(now),
          greaterThanOrEqualTo(const Duration(hours: 24)));
      expect(storage.getReminderLastActivity(), now.toLocal());
    });

    test(
        'return clears pending reminders and silently resets a completed cycle',
        () async {
      await service.setEnabled(true);
      await service.onBackground();
      now = now.add(const Duration(days: 30));
      // Simulate all eight requests having been consumed by the OS.
      gateway.scheduled.clear();
      await service.onForeground();
      expect(gateway.scheduled, isEmpty);
      expect(gateway.permissionRequests, 1);
      expect(service.enabled, isTrue);
      await service.onBackground();
      expect(gateway.scheduled, hasLength(8));
      expect(gateway.scheduled.every((r) => r.at.isAfter(now)), isTrue);
    });

    test('turning off removes every pending reminder and stays off on return',
        () async {
      await service.setEnabled(true);
      await service.onBackground();
      expect(await service.setEnabled(false), ReminderSettingResult.disabled);
      expect(gateway.scheduled, isEmpty);
      await service.onForeground();
      await service.onBackground();
      expect(service.enabled, isFalse);
      expect(gateway.scheduled, isEmpty);
    });

    test('permission denial leaves reminders off without scheduling', () async {
      gateway.permission = false;
      expect(await service.setEnabled(true), ReminderSettingResult.denied);
      expect(service.enabled, isFalse);
      expect(gateway.scheduled, isEmpty);
    });

    test('OS revocation cancels pending requests without prompting again',
        () async {
      await service.setEnabled(true);
      await service.onBackground();
      gateway.permission = false;
      await service.onForeground();
      await service.onBackground();
      expect(gateway.scheduled, isEmpty);
      expect(gateway.permissionRequests, 1);
    });

    test(
        'scheduling error removes partial plans and a later return can recover',
        () async {
      await service.setEnabled(true);
      gateway.failAfter = 3;
      await service.onBackground();
      expect(gateway.scheduled, isEmpty);
      gateway.failAfter = null;
      await service.onForeground();
      await service.onBackground();
      expect(gateway.scheduled, hasLength(8));
    });

    test('return during a slow timezone lookup cannot leave a stale plan',
        () async {
      await service.setEnabled(true);
      final lookup = Completer<tz.Location>();
      final started = Completer<void>();
      gateway.timezoneLoader = () {
        started.complete();
        return lookup.future;
      };
      final scheduling = service.onBackground();
      await started.future;
      final returning = service.onForeground();
      lookup.complete(tz.UTC);
      await Future.wait([scheduling, returning]);
      expect(gateway.scheduled, isEmpty);
    });

    test('preferences survive recreation without a new permission prompt',
        () async {
      await service.setEnabled(true);
      service = LocalReminderService(storage, gateway, now: () => now);
      await service.onForeground();
      await service.onBackground();
      expect(service.enabled, isTrue);
      expect(gateway.permissionRequests, 1);
      expect(gateway.scheduled, hasLength(8));
    });

    test('unsupported platforms do not persist an enabled preference',
        () async {
      gateway.supported = false;
      expect(await service.setEnabled(true), ReminderSettingResult.unavailable);
      expect(service.enabled, isFalse);
      expect(gateway.permissionRequests, 0);
    });
  });
}
