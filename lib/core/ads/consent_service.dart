import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/crash_reporting_service.dart';
import 'ad_ids.dart';

class ConsentService {
  static final ConsentService shared = ConsentService();

  ConsentService({
    ConsentInformation? consentInformation,
  }) : _consentInformation = consentInformation ?? ConsentInformation.instance;

  final ConsentInformation _consentInformation;
  Future<bool>? _startupConsentFuture;
  bool _privacyOptionsRequired = false;

  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<bool> gatherConsent() {
    if (_startupConsentFuture != null) return _startupConsentFuture!;
    _startupConsentFuture = _gatherConsent();
    return _startupConsentFuture!;
  }

  Future<bool> _gatherConsent() async {
    if (!AdIds.isSupportedPlatform) return false;

    final updateCompleted = Completer<void>();
    try {
      _consentInformation.requestConsentInfoUpdate(
        _requestParameters(),
        updateCompleted.complete,
        (error) {
          CrashReportingService.recordNonFatal(
            Exception('Consent info update failed: ${error.errorCode}'),
            StackTrace.current,
            reason: 'AdMob consent information update failed',
          );
          updateCompleted.complete();
        },
      );
      await updateCompleted.future;
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'AdMob consent information update failed',
      );
    }

    final formCompleted = Completer<void>();
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          CrashReportingService.recordNonFatal(
            Exception('Consent form failed: ${error.errorCode}'),
            StackTrace.current,
            reason: 'AdMob consent form failed',
          );
        }
        formCompleted.complete();
      });
      await formCompleted.future;
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'AdMob consent form failed',
      );
    }

    await refreshPrivacyOptionsRequirement();
    return _canRequestAds();
  }

  Future<bool> canRequestAds() async {
    if (!AdIds.isSupportedPlatform) return false;
    return _canRequestAds();
  }

  Future<bool> _canRequestAds() async {
    try {
      return _consentInformation.canRequestAds();
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'AdMob canRequestAds check failed',
      );
      return false;
    }
  }

  Future<void> refreshPrivacyOptionsRequirement() async {
    if (!AdIds.isSupportedPlatform) {
      _privacyOptionsRequired = false;
      return;
    }
    try {
      final status =
          await _consentInformation.getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'AdMob privacy options status check failed',
      );
      _privacyOptionsRequired = false;
    }
  }

  Future<bool> showPrivacyOptionsForm() async {
    if (!AdIds.isSupportedPlatform) return false;
    final completed = Completer<bool>();
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          CrashReportingService.recordNonFatal(
            Exception('Privacy options form failed: ${error.errorCode}'),
            StackTrace.current,
            reason: 'AdMob privacy options form failed',
          );
          completed.complete(false);
          return;
        }
        completed.complete(true);
      });
    } catch (error, stackTrace) {
      CrashReportingService.recordNonFatal(
        error,
        stackTrace,
        reason: 'AdMob privacy options form failed',
      );
      completed.complete(false);
    }
    return completed.future;
  }

  ConsentRequestParameters _requestParameters() {
    if (!kDebugMode) {
      return ConsentRequestParameters(tagForUnderAgeOfConsent: false);
    }
    return ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
      ),
    );
  }
}
