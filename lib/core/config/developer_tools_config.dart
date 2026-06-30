import 'package:flutter/foundation.dart';

const bool enableDeveloperTools = bool.fromEnvironment(
  'ENABLE_DEVELOPER_TOOLS',
  defaultValue: false,
);

/// Developer tools are hidden unless explicitly enabled at build/run time.
///
/// Use:
/// flutter run --dart-define=ENABLE_DEVELOPER_TOOLS=true
const bool developerToolsEnabled = kDebugMode || enableDeveloperTools;
