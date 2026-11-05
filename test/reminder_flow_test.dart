import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/constants/tile_data.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/features/reminders/reminder_lifecycle.dart';
import 'package:sankofa_tiles/models/game_launch_config.dart';
import 'package:sankofa_tiles/models/game_state.dart';
import 'package:sankofa_tiles/models/tile_model.dart';
import 'package:sankofa_tiles/providers/reminder_provider.dart';
import 'package:sankofa_tiles/providers/settings_provider.dart';
import 'package:sankofa_tiles/screens/game/widgets/tile_widget.dart';
import 'package:sankofa_tiles/screens/settings/settings_screen.dart';
import 'support/fake_reminder_gateway.dart';

Future<StorageService> _storage(
    {bool enabled = false, int completed = 8}) async {
  SharedPreferences.setMockInitialValues({
    'campaign_progress_schema_version': 4,
    'highest_completed_level': completed,
    'completed_$completed': true,
    'gentle_reminders_enabled': enabled,
    'sound_enabled': false,
    'music_enabled': false,
  });
  final storage = StorageService();
  await storage.init();
  return storage;
}

Future<GoRouter> _mount(
    WidgetTester tester, StorageService storage, FakeReminderGateway gateway,
    {String route = '/', ValueChanged<GameLaunchConfig>? launched}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = GoRouter(initialLocation: route, routes: [
    GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(
        path: '/journey',
        builder: (_, __) => const Scaffold(body: Text('Journey'))),
    GoRoute(
        path: '/game/:levelId',
        builder: (_, state) {
          launched?.call(state.extra as GameLaunchConfig);
          return Scaffold(
              body: Text('Board ${state.pathParameters['levelId']}'));
        }),
  ]);
  final container = ProviderContainer(overrides: [
    storageServiceProvider.overrideWithValue(storage),
    reminderGatewayProvider.overrideWithValue(gateway),
  ]);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      builder: (_, child) => ReminderLifecycle(router: router, child: child!),
    ),
  ));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
  });
  return router;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  kRunningTests = true;

  testWidgets('Settings offers one opt-in switch with no time or day picker',
      (tester) async {
    final storage = await _storage();
    final gateway = FakeReminderGateway();
    await _mount(tester, storage, gateway, route: '/settings');
    final toggle = find.widgetWithText(SwitchListTile, 'Gentle reminders');
    await tester.scrollUntilVisible(toggle, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(find.text('Choose days'), findsNothing);
    expect(find.byType(TimePickerDialog), findsNothing);
    expect(gateway.permissionRequests, 0);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(storage.areGentleRemindersEnabled(), isTrue);
    expect(gateway.permissionRequests, 1);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(storage.areGentleRemindersEnabled(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the reminder switch remains readable with larger text',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _mount(tester, await _storage(), FakeReminderGateway(),
        route: '/settings');
    final toggle = find.widgetWithText(SwitchListTile, 'Gentle reminders');
    await tester.scrollUntilVisible(toggle, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(toggle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'denial leaves the switch off and explains where permission is controlled',
      (tester) async {
    final gateway = FakeReminderGateway()..permission = false;
    await _mount(tester, await _storage(), gateway, route: '/settings');
    final toggle = find.widgetWithText(SwitchListTile, 'Gentle reminders');
    await tester.scrollUntilVisible(toggle, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(find.textContaining('phone’s settings'), findsOneWidget);
  });

  testWidgets(
      'background creates the finite plan and returning cancels it with no prompts',
      (tester) async {
    final gateway = FakeReminderGateway();
    await _mount(tester, await _storage(enabled: true), gateway);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(gateway.scheduled, hasLength(8));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(gateway.scheduled, isEmpty);
    expect(gateway.permissionRequests, 0);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('cold reminder tap opens the next actual level', (tester) async {
    final gateway = FakeReminderGateway()..coldStartTap = true;
    GameLaunchConfig? launch;
    final router = await _mount(tester, await _storage(enabled: true), gateway,
        launched: (config) => launch = config);
    expect(router.routeInformationProvider.value.uri.path, '/game/9');
    expect(launch?.resumeSavedGame, isFalse);
    expect(launch?.difficulty, DifficultyMode.relaxed);
  });

  testWidgets(
      'a previous campaign finisher opens new Level 361 from a reminder',
      (tester) async {
    final gateway = FakeReminderGateway()..coldStartTap = true;
    final router = await _mount(
        tester, await _storage(enabled: true, completed: 360), gateway);
    expect(router.routeInformationProvider.value.uri.path, '/game/361');
  });

  testWidgets('warm reminder tap resumes the saved board', (tester) async {
    final storage = await _storage(enabled: true);
    await storage.saveActiveGame(GameState.initial().copyWith(
      levelId: 2,
      status: GameStatus.playing,
      difficulty: DifficultyMode.normal,
      tiles: [
        TileModel(uid: 'a', def: kAllTiles.first, row: 0, col: 0),
        TileModel(uid: 'b', def: kAllTiles.first, row: 0, col: 2),
      ],
    ));
    final gateway = FakeReminderGateway();
    GameLaunchConfig? launch;
    final router = await _mount(tester, storage, gateway,
        launched: (config) => launch = config);
    gateway.tap!();
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/game/2');
    expect(launch?.resumeSavedGame, isTrue);
    expect(storage.getActiveGame()!.difficulty, DifficultyMode.normal);
  });

  testWidgets(
      'finished journey notification opens Journey instead of a nonexistent level',
      (tester) async {
    final gateway = FakeReminderGateway()..coldStartTap = true;
    final router = await _mount(
        tester, await _storage(enabled: true, completed: 380), gateway);
    expect(router.routeInformationProvider.value.uri.path, '/journey');
    expect(find.text('Journey'), findsOneWidget);
  });
}
