import 'package:flutter/foundation.dart';

const bool enableDeveloperTools = bool.fromEnvironment(
  'ENABLE_DEVELOPER_TOOLS',
  defaultValue: false,
);

const bool developerToolsEnabled = kDebugMode || enableDeveloperTools;
