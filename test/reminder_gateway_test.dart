import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sankofa_tiles/core/reminders/reminder_gateway.dart';
import 'package:sankofa_tiles/core/reminders/reminder_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const timezoneChannel = MethodChannel('flutter_timezone');
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'initialize' ||
        'requestNotificationsPermission' ||
        'areNotificationsEnabled' ||
        'requestPermissions' =>
          true,
        'getNotificationAppLaunchDetails' => {'notificationLaunchedApp': false},
        'checkPermissions' => {
            'isEnabled': true,
            'isAlertEnabled': true,
            'isBadgeEnabled': false,
            'isSoundEnabled': false
          },
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(
        timezoneChannel, (_) async => 'Africa/Accra');
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(timezoneChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test(
        '$platform sends quiet one-shot requests and asks permission only explicitly',
        () async {
      debugDefaultTargetPlatformOverride = platform;
      if (platform == TargetPlatform.android) {
        AndroidFlutterLocalNotificationsPlugin.registerWith();
      } else {
        IOSFlutterLocalNotificationsPlugin.registerWith();
      }
      final gateway = DeviceReminderGateway();
      await gateway.initialize(() {});
      expect(calls.where((c) => c.method.startsWith('request')), isEmpty);
      if (platform == TargetPlatform.iOS) {
        final settings =
            calls.singleWhere((c) => c.method == 'initialize').arguments as Map;
        expect(settings['requestAlertPermission'], isFalse);
        expect(settings['requestBadgePermission'], isFalse);
        expect(settings['requestSoundPermission'], isFalse);
      }
      expect(await gateway.requestPermission(), isTrue);
      expect(await gateway.hasPermission(), isTrue);
      final zone = await gateway.localTimezone();
      expect(zone.name, 'Africa/Accra');
      final future =
          tz.TZDateTime.from(DateTime.now().add(const Duration(days: 2)), zone);
      await gateway.schedule(PlannedReminder(
          id: reminderIds.first, at: future, body: 'A quiet moment?'));
      final args = calls
          .singleWhere((c) => c.method == 'zonedSchedule')
          .arguments as Map;
      expect(args['title'], 'Adinkra Tiles');
      expect(args['payload'], reminderPayload);
      expect(args.containsKey('matchDateTimeComponents'), isFalse,
          reason: 'The eighth notification must never repeat indefinitely');
      final details = args['platformSpecifics'] as Map;
      if (platform == TargetPlatform.android) {
        expect(details['playSound'], isFalse);
        expect(details['enableVibration'], isFalse);
        expect(details['channelShowBadge'], isFalse);
        expect(details['scheduleMode'],
            AndroidScheduleMode.inexactAllowWhileIdle.name);
      } else {
        expect(details['presentSound'], isFalse);
        expect(details['presentBadge'], isFalse);
        expect(details['interruptionLevel'], InterruptionLevel.passive.index);
      }
      await gateway.cancelReminders();
      expect(
          calls
              .where((c) => c.method == 'cancel')
              .map((c) =>
                  c.arguments is Map ? (c.arguments as Map)['id'] : c.arguments)
              .toList(),
          orderedEquals(reminderIds));
    });
    for (final payload in [reminderPayload, 'unrelated_notification']) {
      test('$platform cold launch handles only reminder taps ($payload)',
          () async {
        debugDefaultTargetPlatformOverride = platform;
        if (platform == TargetPlatform.android) {
          AndroidFlutterLocalNotificationsPlugin.registerWith();
        } else {
          IOSFlutterLocalNotificationsPlugin.registerWith();
        }
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getNotificationAppLaunchDetails') {
            return {
              'notificationLaunchedApp': true,
              'notificationResponse': {
                'notificationId': reminderIds.first,
                'notificationResponseType': 0,
                'payload': payload,
              },
            };
          }
          return true;
        });
        var taps = 0;
        await DeviceReminderGateway().initialize(() => taps++);
        expect(taps, payload == reminderPayload ? 1 : 0);
      });
    }
  }
}
