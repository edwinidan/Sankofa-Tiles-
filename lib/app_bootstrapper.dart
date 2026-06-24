import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/startup/app_startup.dart';
import 'providers/settings_provider.dart';

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({
    super.key,
    this.controller,
  });

  final AppStartupController? controller;

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  late final AppStartupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AppStartupController();
    _controller.addListener(_onStartupChanged);
    _controller.start();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStartupChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onStartupChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final storage = state.storage;

    if (state.status == AppStartupStatus.ready && storage != null) {
      return ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: const SankofaTilesApp(),
      );
    }

    return AppStartupScreen(
      state: state,
      onRetry: _controller.retry,
    );
  }
}
