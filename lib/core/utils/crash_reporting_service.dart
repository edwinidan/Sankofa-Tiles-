import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  CrashReportingService._();

  static FirebaseCrashlytics? _crashlytics;

  static void initialize() {
    _crashlytics = FirebaseCrashlytics.instance;
  }

  static void recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;

    unawaited(
      crashlytics
          .recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      )
          .catchError((Object reportingError) {
        debugPrint('[CrashReportingService] $reportingError');
      }),
    );
  }
}
