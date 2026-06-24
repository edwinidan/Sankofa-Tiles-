import 'package:flutter/material.dart';
import '../../widgets/kente_button.dart';
import '../../widgets/sankofa_background.dart';
import '../theme/app_text_styles.dart';
import '../theme/sankofa_game_theme.dart';
import '../utils/crash_reporting_service.dart';
import '../utils/storage_service.dart';

enum AppStartupStatus {
  loading,
  ready,
  recoverableError,
  fatalError,
}

typedef StartupStorageLoader = Future<StorageService> Function();
typedef StartupErrorReporter = void Function(
  Object error,
  StackTrace stackTrace, {
  String? reason,
});

class AppStartupState {
  const AppStartupState._({
    required this.status,
    this.storage,
    this.message,
    this.canRetry = false,
  });

  const AppStartupState.loading()
      : this._(
          status: AppStartupStatus.loading,
          message: 'Preparing the Grand Archive...',
        );

  const AppStartupState.ready(StorageService storage)
      : this._(
          status: AppStartupStatus.ready,
          storage: storage,
        );

  const AppStartupState.recoverableError(String message)
      : this._(
          status: AppStartupStatus.recoverableError,
          message: message,
          canRetry: true,
        );

  const AppStartupState.fatalError(String message)
      : this._(
          status: AppStartupStatus.fatalError,
          message: message,
        );

  final AppStartupStatus status;
  final StorageService? storage;
  final String? message;
  final bool canRetry;
}

class AppStartupController extends ChangeNotifier {
  AppStartupController({
    StartupStorageLoader? loadStorage,
    StartupErrorReporter? reportError,
  })  : _loadStorage = loadStorage ?? defaultStartupStorageLoader,
        _reportError = reportError ?? CrashReportingService.recordNonFatal;

  final StartupStorageLoader _loadStorage;
  final StartupErrorReporter _reportError;

  AppStartupState _state = const AppStartupState.loading();
  AppStartupState get state => _state;

  Future<void> start() => _run();

  Future<void> retry() => _run();

  Future<void> _run() async {
    _setState(const AppStartupState.loading());
    try {
      final storage = await _loadStorage();
      _setState(AppStartupState.ready(storage));
    } catch (error, stackTrace) {
      _reportError(
        error,
        stackTrace,
        reason: 'App startup initialization failed',
      );
      _setState(
        const AppStartupState.recoverableError(
          'We could not restore your journey. Please try again.',
        ),
      );
    }
  }

  void _setState(AppStartupState next) {
    _state = next;
    notifyListeners();
  }
}

Future<StorageService> defaultStartupStorageLoader() async {
  final storage = StorageService();
  await storage.init();
  return storage;
}

class AppStartupScreen extends StatelessWidget {
  const AppStartupScreen({
    super.key,
    required this.state,
    this.onRetry,
  });

  final AppStartupState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isError = state.status == AppStartupStatus.recoverableError ||
        state.status == AppStartupStatus.fatalError;

    return MaterialApp(
      title: 'Adinkra Tiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SankofaGameTheme.backgroundTop,
      ),
      home: Scaffold(
        backgroundColor: SankofaGameTheme.backgroundTop,
        body: SankofaBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Semantics(
                    liveRegion: true,
                    label: isError
                        ? 'Startup error'
                        : 'Adinkra Tiles is preparing your journey',
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: SankofaGameTheme.appParchmentPanelDecoration,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/adinkra_tiles_homescreen_show-removebg-preview.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isError ? 'Journey Interrupted' : 'Adinkra Tiles',
                            style: AppTextStyles.archiveDisplayMedium.copyWith(
                              color: SankofaGameTheme.darkText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message ?? 'Arranging the tiles...',
                            style: AppTextStyles.archiveBodyMedium.copyWith(
                              color: SankofaGameTheme.mutedGold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (isError) ...[
                            KenteButton(
                              label: 'TRY AGAIN',
                              icon: Icons.refresh,
                              width: double.infinity,
                              onTap: state.canRetry ? onRetry : null,
                            ),
                          ] else
                            reduceMotion
                                ? const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: SankofaGameTheme.antiqueGold,
                                    ),
                                  )
                                : const _StartupMark(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupMark extends StatefulWidget {
  const _StartupMark();

  @override
  State<_StartupMark> createState() => _StartupMarkState();
}

class _StartupMarkState extends State<_StartupMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.48, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: SankofaGameTheme.antiqueGold,
        size: 34,
      ),
    );
  }
}
