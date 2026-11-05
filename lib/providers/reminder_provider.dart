import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/reminders/local_reminder_service.dart';
import '../core/reminders/reminder_gateway.dart';
import 'settings_provider.dart';

final reminderGatewayProvider =
    Provider<ReminderGateway>((ref) => DeviceReminderGateway());
final localReminderServiceProvider = Provider<LocalReminderService>((ref) =>
    LocalReminderService(
        ref.watch(storageServiceProvider), ref.watch(reminderGatewayProvider)));

class ReminderSettingsState {
  const ReminderSettingsState({required this.enabled, this.busy = false});
  final bool enabled;
  final bool busy;
}

class ReminderSettingsNotifier extends StateNotifier<ReminderSettingsState> {
  ReminderSettingsNotifier(this.service)
      : super(ReminderSettingsState(enabled: service.enabled));

  final LocalReminderService service;

  Future<ReminderSettingResult?> setEnabled(bool value) async {
    if (state.busy) return null;
    state = ReminderSettingsState(enabled: state.enabled, busy: true);
    try {
      return await service.setEnabled(value);
    } finally {
      if (mounted) state = ReminderSettingsState(enabled: service.enabled);
    }
  }
}

final reminderSettingsProvider =
    StateNotifierProvider<ReminderSettingsNotifier, ReminderSettingsState>(
        (ref) =>
            ReminderSettingsNotifier(ref.watch(localReminderServiceProvider)));
