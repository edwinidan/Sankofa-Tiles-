import 'package:flutter/foundation.dart';

import '../constants/level_data.dart';
import '../utils/crash_reporting_service.dart';
import '../utils/storage_service.dart';
import 'reminder_gateway.dart';
import 'reminder_plan.dart';

enum ReminderSettingResult { enabled, disabled, denied, unavailable, failed }

class LocalReminderService {
  LocalReminderService(this.storage, this.gateway, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final StorageService storage;
  final ReminderGateway gateway;
  final DateTime Function() _now;
  Future<void> _pending = Future.value();
  bool _initialized = false;
  bool _foreground = true;
  VoidCallback? onTap;

  bool get enabled => storage.areGentleRemindersEnabled();
  bool get isSupported => gateway.isSupported;

  // Permission sheets and lifecycle changes can overlap. Serialize native
  // operations so an older scheduling pass cannot undo a later cancellation.
  Future<T> _enqueue<T>(Future<T> Function() work) {
    final result = _pending.then((_) => work());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    await gateway.initialize(() => onTap?.call());
    _initialized = true;
  }

  Future<void> onForeground() {
    _foreground = true;
    final activity = _now();
    return _enqueue(() async {
      await storage.setReminderLastActivity(activity);
      if (!isSupported || !enabled) return;
      try {
        await _initialize();
        await gateway.cancelReminders();
      } catch (error, stack) {
        _report(error, stack);
      }
    });
  }

  Future<void> onBackground() {
    _foreground = false;
    final activity = _now();
    return _enqueue(() async {
      // Count time spent in the app as recent activity too. Returning to the
      // game silently resets the finite cycle; nothing is shown in gameplay.
      await storage.setReminderLastActivity(activity);
      if (_foreground || !enabled || !isSupported) return;
      try {
        await _initialize();
        await _schedule(activity);
      } catch (error, stack) {
        await _cancelAfterFailure();
        _report(error, stack);
      }
    });
  }

  Future<ReminderSettingResult> setEnabled(bool value) => _enqueue(() async {
        if (!value) {
          await storage.setGentleRemindersEnabled(false);
          if (isSupported) {
            try {
              await _initialize();
              await gateway.cancelReminders();
            } catch (error, stack) {
              _report(error, stack);
              return ReminderSettingResult.failed;
            }
          }
          return ReminderSettingResult.disabled;
        }
        if (!isSupported) return ReminderSettingResult.unavailable;
        try {
          await _initialize();
          if (!await gateway.requestPermission()) {
            await storage.setGentleRemindersEnabled(false);
            await gateway.cancelReminders();
            return ReminderSettingResult.denied;
          }
          final activity = _now();
          await storage.setReminderLastActivity(activity);
          await storage.setGentleRemindersEnabled(true);
          // Foreground notifications stay cancelled. The finite plan is
          // installed when the app leaves the foreground, after saving play.
          await gateway.cancelReminders();
          if (!_foreground) await _schedule(activity);
          return ReminderSettingResult.enabled;
        } catch (error, stack) {
          await storage.setGentleRemindersEnabled(false);
          await _cancelAfterFailure();
          _report(error, stack);
          return ReminderSettingResult.failed;
        }
      });

  Future<void> _schedule(DateTime activity) async {
    await gateway.cancelReminders();
    if (!await gateway.hasPermission()) return;
    final location = await gateway.localTimezone();
    if (_foreground || !enabled) return;
    final next = storage.getHighestCompletedLevel() + 1;
    final plan = buildReminderPlan(
      lastActivity: activity,
      location: location,
      hasSavedBoard: storage.getActiveGameSummary() != null,
      nextLevelId: next <= kImplementedFinalLevelId ? next : null,
    );
    for (final reminder in plan) {
      if (_foreground || !enabled) {
        await gateway.cancelReminders();
        return;
      }
      // Never catch up an elapsed request after a slow permission/timezone call.
      if (reminder.at.isAfter(_now())) await gateway.schedule(reminder);
    }
  }

  Future<void> _cancelAfterFailure() async {
    try {
      await gateway.cancelReminders();
    } catch (_) {
      // The original platform error is reported; the game remains available.
    }
  }

  void _report(Object error, StackTrace stack) =>
      CrashReportingService.recordNonFatal(error, stack,
          reason: 'Local reminder scheduling failed');
}
