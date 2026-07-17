import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/app_bootstrapper.dart';
import 'package:sankofa_tiles/core/startup/app_startup.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/features/entry_flow/entry_flow_director.dart';

Future<StorageService> _storageWithPrefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 4),
  Duration step = const Duration(milliseconds: 50),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
    elapsed += step;
  }
  fail('Timed out after $timeout waiting for $finder.');
}

Future<void> _pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 4),
  Duration step = const Duration(milliseconds: 50),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < timeout) {
    await tester.pump(step);
    if (finder.evaluate().isEmpty) return;
    elapsed += step;
  }
  fail('Timed out after $timeout waiting for $finder to leave.');
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

  testWidgets('first-time users go directly to the gameplay tutorial',
      (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await _pumpUntilFound(
      tester,
      find.text('Match two identical free tiles.'),
    );

    expect(find.text('Match two identical free tiles.'), findsOneWidget);
    expect(find.byKey(const ValueKey('entry-flow-overlay')), findsNothing);
    expect(find.text('Discover three Adinkra pairs'), findsNothing);
    expect(find.text('Before your journey begins'), findsNothing);
  });

  testWidgets('returning users land on home after startup', (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({'onboarding_complete': true}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await _pumpUntilFound(tester, find.text('CONTINUE'));

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('Tap the glowing tile'), findsNothing);
  });

  testWidgets('returning splash exits after its configured duration',
      (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({'onboarding_complete': true}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await _pumpUntilFound(tester, find.text('Tap to continue'));
    final destination = tester.widget<TickerMode>(
      find.byKey(const ValueKey('entry-flow-destination')),
    );
    expect(destination.enabled, isFalse);

    await _pumpUntilGone(
      tester,
      find.byKey(const ValueKey('entry-flow-overlay')),
    );
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('tapping returning splash exits immediately and does not restart',
      (tester) async {
    final controller = AppStartupController(
      loadStorage: () => _storageWithPrefs({'tutorial_complete': true}),
      reportError: (_, __, {reason}) {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(AppBootstrapper(controller: controller));
    await _pumpUntilFound(tester, find.text('Tap to continue'));
    await tester.tap(find.text('Tap to continue'));
    await _pumpUntilGone(
      tester,
      find.byKey(const ValueKey('entry-flow-overlay')),
    );
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byKey(const ValueKey('entry-flow-overlay')), findsNothing);
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('reduced-motion returning startup settles and reveals content',
      (tester) async {
    final storage = await _storageWithPrefs({'tutorial_complete': true});
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: EntryFlowDirector(
            storage: storage,
            child: const Scaffold(body: Text('Ready destination')),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('entry-flow-overlay')), findsOneWidget);
    await _pumpUntilGone(
      tester,
      find.byKey(const ValueKey('entry-flow-overlay')),
    );
    expect(find.byKey(const ValueKey('entry-flow-overlay')), findsNothing);
    expect(find.text('Ready destination'), findsOneWidget);
  });

  testWidgets('disposing an active returning splash cancels its timer safely',
      (tester) async {
    final storage = await _storageWithPrefs({'onboarding_complete': true});
    await tester.pumpWidget(
      MaterialApp(
        home: EntryFlowDirector(
          storage: storage,
          child: const Scaffold(body: Text('Destination')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('entry-flow-overlay')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
