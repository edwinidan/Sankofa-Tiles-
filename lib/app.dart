import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/reminders/reminder_lifecycle.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'features/entry_flow/entry_flow_director.dart';

class SankofaTilesApp extends ConsumerStatefulWidget {
  const SankofaTilesApp({super.key});

  @override
  ConsumerState<SankofaTilesApp> createState() => _SankofaTilesAppState();
}

class _SankofaTilesAppState extends ConsumerState<SankofaTilesApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _router = createAppRouter(
      storage,
      initialLocation: storage.hasCompletedEntryDiscovery() ? '/' : '/tutorial',
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    return MaterialApp.router(
      title: 'Adinkra Tiles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      builder: (context, child) => ReminderLifecycle(
        router: _router,
        child: EntryFlowDirector(
          storage: storage,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
