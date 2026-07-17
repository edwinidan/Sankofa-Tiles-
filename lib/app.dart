import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'features/entry_flow/entry_flow_director.dart';

class SankofaTilesApp extends ConsumerWidget {
  const SankofaTilesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final router = createAppRouter(
      storage,
      initialLocation: storage.hasCompletedEntryDiscovery() ? '/' : '/tutorial',
    );

    return MaterialApp.router(
      title: 'Adinkra Tiles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) => EntryFlowDirector(
        storage: storage,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
