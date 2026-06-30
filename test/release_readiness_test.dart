import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile app identity is release-facing', () {
    final androidManifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(androidManifest, contains('android:label="Adinkra Tiles"'));
    expect(iosInfo, contains('<string>Adinkra Tiles</string>'));
  });

  test('privacy-sensitive ad identifiers are disabled in Android manifest', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('com.google.android.gms.permission.AD_ID'));
    expect(manifest, contains('android.permission.ACCESS_ADSERVICES_AD_ID'));
    expect(manifest, contains('tools:node="remove"'));
    expect(
      manifest,
      contains('google_analytics_adid_collection_enabled'),
    );
    expect(manifest, contains('android:value="false"'));
  });

  test('release build is not configured to use debug signing', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('create("upload")'));
    expect(
        gradle, contains('signingConfig = signingConfigs.getByName("upload")'));
    expect(
      gradle,
      isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
    );
  });

  test('developer tools are disabled by default outside debug builds', () {
    final config =
        File('lib/core/config/developer_tools_config.dart').readAsStringSync();

    expect(config, contains('defaultValue: false'));
    expect(config, contains('kDebugMode || enableDeveloperTools'));
  });

  test('app is portrait-only on Android and iOS', () {
    final main = File('lib/main.dart').readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(main, contains('DeviceOrientation.portraitUp'));
    expect(iosInfo, contains('UIInterfaceOrientationPortrait'));
    expect(iosInfo, isNot(contains('UIInterfaceOrientationLandscape')));
  });

  test('AdMob app and unit IDs are centrally configured and guarded', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final adIds = File('lib/core/ads/ad_ids.dart').readAsStringSync();
    final gameDock = File('lib/screens/game/widgets/game_control_dock.dart')
        .readAsStringSync();
    final resultScreen =
        File('lib/screens/result/result_screen.dart').readAsStringSync();

    expect(pubspec, contains('google_mobile_ads'));
    expect(
      manifest,
      contains('com.google.android.gms.ads.APPLICATION_ID'),
    );
    expect(manifest, contains('ca-app-pub-5484820744037011~7670775878'));
    expect(adIds, contains('USE_PRODUCTION_ADS'));
    expect(adIds, contains('kReleaseMode && useProductionAds'));
    expect(adIds, contains('_testAndroidRewarded'));
    expect(adIds, contains('_testAndroidInterstitial'));
    expect(adIds, contains("androidAppId.contains('~')"));
    expect(adIds, contains("id != null && id.contains('/')"));
    expect(gameDock, isNot(contains('ca-app-pub-')));
    expect(resultScreen, isNot(contains('ca-app-pub-')));
  });

  test('interstitial call site passes real tutorial and first-session state',
      () {
    final resultScreen =
        File('lib/screens/result/result_screen.dart').readAsStringSync();

    // The call site must pass explicit tutorialActive and isFirstSession
    // based on real storage state, not defaults.
    expect(
      resultScreen,
      contains('tutorialActive:'),
      reason: 'tutorialActive must be explicitly passed',
    );
    expect(
      resultScreen,
      contains('isFirstSession:'),
      reason: 'isFirstSession must be explicitly passed',
    );
    expect(
      resultScreen,
      contains('isTutorialComplete()'),
      reason: 'Tutorial state must be read from storage',
    );
    expect(
      resultScreen,
      contains('isFirstSessionCompleted()'),
      reason: 'First-session state must be read from storage',
    );
  });

  test('first-session storage key exists', () {
    final storage =
        File('lib/core/utils/storage_service.dart').readAsStringSync();

    expect(storage, contains('first_session_completed'));
    expect(storage, contains('isFirstSessionCompleted'));
    expect(storage, contains('setFirstSessionCompleted'));
  });

  test('retry assistance UX wording is clear about restart', () {
    final resultScreen =
        File('lib/screens/result/result_screen.dart').readAsStringSync();

    // Must not claim the player continues the same board
    expect(resultScreen, isNot(contains('Continue playing')));
    expect(resultScreen, isNot(contains('Resume game')));

    // Must communicate retry with assistance
    expect(resultScreen, contains('Retry with help'));
    expect(resultScreen, contains('retry this level'));
    expect(resultScreen, contains('WATCH AD & RETRY'));
  });
}
