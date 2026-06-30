import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ads/admob_service.dart';
import '../core/ads/consent_service.dart';

final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService.shared;
});

final adMobServiceProvider = Provider<AdMobService>((ref) {
  return AdMobService.shared;
});

final privacyOptionsRequiredProvider = FutureProvider<bool>((ref) async {
  final consentService = ref.watch(consentServiceProvider);
  await consentService.refreshPrivacyOptionsRequirement();
  return consentService.privacyOptionsRequired;
});
