import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/reminders/local_reminder_service.dart';
import '../../core/constants/level_data.dart';
import '../../core/utils/crash_reporting_service.dart';
import '../../models/game_launch_config.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';

class ReminderLifecycle extends ConsumerStatefulWidget {
  const ReminderLifecycle(
      {super.key, required this.router, required this.child});
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<ReminderLifecycle> createState() => _ReminderLifecycleState();
}

class _ReminderLifecycleState extends ConsumerState<ReminderLifecycle>
    with WidgetsBindingObserver {
  late final LocalReminderService _service;
  bool _background = false;

  @override
  void initState() {
    super.initState();
    _service = ref.read(localReminderServiceProvider);
    _service.onTap = _openReminder;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_quietly(_service.onForeground()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _background = false;
      unawaited(_quietly(_service.onForeground()));
    } else if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        !_background) {
      _background = true;
      unawaited(_quietly(_service.onBackground()));
    }
  }

  Future<void> _quietly(Future<void> work) async {
    try {
      await work;
    } catch (error, stack) {
      CrashReportingService.recordNonFatal(error, stack,
          reason: 'Reminder lifecycle failed');
    }
  }

  void _openReminder() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final storage = ref.read(storageServiceProvider);
      final saved = storage.getActiveGameSummary();
      final next = saved?.levelId ?? storage.getHighestCompletedLevel() + 1;
      if (saved == null && next > kImplementedFinalLevelId) {
        widget.router.go('/journey');
      } else {
        widget.router.go('/game/$next',
            extra: GameLaunchConfig(
              levelId: next,
              launchMode: GameLaunchMode.normalProgression,
              resumeSavedGame: saved != null,
            ));
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.onTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
