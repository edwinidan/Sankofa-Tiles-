import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/app_bootstrapper.dart';
import 'package:sankofa_tiles/core/startup/app_startup.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';

Future<StorageService> _storageWithPrefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startup controller reaches ready when storage loads', () async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await controller.start();

    expect(controller.state.status, AppStartupStatus.ready);
    expect(controller.state.storage, isNotNull);
  });

  test('startup controller exposes recoverable failure and retries', () async {
    var attempts = 0;
    final controller = AppStartupController(
      loadStorage: () async {
        attempts++;
        if (attempts == 1) {
          throw StateError('storage unavailable');
        }
        return _storageWithPrefs({'onboarding_complete': true});
      },
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await controller.start();
    expect(controller.state.status, AppStartupStatus.recoverableError);
    expect(controller.state.canRetry, isTrue);

    await controller.retry();
    expect(controller.state.status, AppStartupStatus.ready);
    expect(attempts, 2);
  });

  testWidgets('first-time users land on onboarding after startup',
      (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome to'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);
  });

  testWidgets('returning users land on home after startup', (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({'onboarding_complete': true}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.textContaining('Welcome to'), findsNothing);
  });
}
