import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sankofa_tiles/core/utils/storage_service.dart';
import 'package:sankofa_tiles/features/entry_flow/entry_game.dart';

Future<StorageService> storageWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  await storage.init();
  return storage;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeded discovery contains exactly three deterministic pairs', () {
    final first = EntryPairGame.seeded(seed: 42);
    final second = EntryPairGame.seeded(seed: 42);
    expect(first.tiles.map((tile) => tile.definition.id),
        second.tiles.map((tile) => tile.definition.id));
    expect(first.tiles, hasLength(6));
    final counts = <String, int>{};
    for (final tile in first.tiles) {
      counts.update(tile.definition.id, (value) => value + 1,
          ifAbsent: () => 1);
    }
    expect(counts.length, 3);
    expect(counts.values, everyElement(2));
  });

  test('a tile cannot match itself', () {
    final game = EntryPairGame.seeded();
    expect(game.isPair(game.tiles.first, game.tiles.first), isFalse);
  });

  test('legacy completion and progress protect existing users', () async {
    expect(
        (await storageWith({'onboarding_complete': true}))
            .hasCompletedEntryDiscovery(),
        isTrue);
    expect(
        (await storageWith({'tutorial_complete': true}))
            .hasCompletedEntryDiscovery(),
        isTrue);
    expect(
        (await storageWith({'highest_completed_level': 2}))
            .hasCompletedEntryDiscovery(),
        isTrue);
    expect((await storageWith({})).hasCompletedEntryDiscovery(), isFalse);
  });

  test('entry completion does not complete tutorial', () async {
    final storage = await storageWith({});
    await storage.setEntryDiscoveryComplete();
    expect(storage.hasCompletedEntryDiscovery(), isTrue);
    expect(storage.isOnboardingComplete(), isTrue);
    expect(storage.isTutorialComplete(), isFalse);
  });

  test('three immediate skips disable opening and normal play resets count',
      () async {
    final storage = await storageWith({});
    expect(await storage.recordReturningSplashCompletion(immediate: true),
        isFalse);
    expect(await storage.recordReturningSplashCompletion(immediate: true),
        isFalse);
    expect(
        await storage.recordReturningSplashCompletion(immediate: true), isTrue);
    expect(storage.isAnimatedOpeningEnabled(), isFalse);

    await storage.setAnimatedOpeningEnabled(true);
    await storage.recordReturningSplashCompletion(immediate: false);
    expect(storage.getReturningSplashImmediateSkipCount(), 0);
    expect(storage.isAnimatedOpeningEnabled(), isTrue);
  });
}
