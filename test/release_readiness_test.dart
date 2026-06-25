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

  test('banner ads and live ad SDK are not present in this sandbox build', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final monetization = File('lib/core/monetization/monetization_config.dart')
        .readAsStringSync();

    expect(pubspec, isNot(contains('google_mobile_ads')));
    expect(monetization, isNot(contains('banner')));
  });
}
