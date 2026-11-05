import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_plan.dart';

abstract interface class ReminderGateway {
  bool get isSupported;
  Future<void> initialize(VoidCallback onTap);
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<tz.Location> localTimezone();
  Future<void> cancelReminders();
  Future<void> schedule(PlannedReminder reminder);
}

class DeviceReminderGateway implements ReminderGateway {
  DeviceReminderGateway({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize(VoidCallback onTap) async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_reminder'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentAlert: false,
          defaultPresentBadge: false,
          defaultPresentSound: false,
          defaultPresentBanner: false,
          defaultPresentList: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == reminderPayload) onTap();
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true &&
        launch?.notificationResponse?.payload == reminderPayload) {
      onTap();
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(
            alert: true, badge: false, sound: false) ??
        false;
  }

  @override
  Future<bool> hasPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    return (await _ios?.checkPermissions())?.isEnabled ?? false;
  }

  @override
  Future<tz.Location> localTimezone() async {
    final zone = await FlutterTimezone.getLocalTimezone();
    return tz.getLocation(zone.identifier);
  }

  @override
  Future<void> cancelReminders() async {
    await Future.wait([for (final id in reminderIds) _plugin.cancel(id: id)]);
  }

  @override
  Future<void> schedule(PlannedReminder reminder) => _plugin.zonedSchedule(
        id: reminder.id,
        title: 'Adinkra Tiles',
        body: reminder.body,
        scheduledDate: reminder.at,
        payload: reminderPayload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'gentle_reminders_v1',
            'Gentle reminders',
            channelDescription: 'Quiet invitations to return to your tiles',
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
            channelShowBadge: false,
            onlyAlertOnce: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentSound: false,
            presentBadge: false,
            presentBanner: false,
            presentList: false,
            interruptionLevel: InterruptionLevel.passive,
            threadIdentifier: 'gentle_reminders',
          ),
        ),
      );
}
