import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/developer_tools_config.dart';
import '../../models/game_state.dart';
import '../../models/game_launch_config.dart';
import '../constants/level_data.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/developer/developer_level_tester_screen.dart';
import '../../screens/game/game_screen.dart';
import '../../screens/result/result_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/preview/tile_preview_screen.dart';
import '../../widgets/sankofa_background.dart';
import '../theme/sankofa_game_theme.dart';
import '../utils/analytics_service.dart';
import '../utils/storage_service.dart';

GoRouter createAppRouter(StorageService storage) {
  return GoRouter(
    initialLocation: '/',
    observers: [_AnalyticsNavigatorObserver()],
    redirect: (context, state) {
      // First launch → onboarding
      if (state.matchedLocation == '/' && !storage.isOnboardingComplete()) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: 'game',
        path: '/game/:levelId',
        builder: (context, state) {
          final suppliedConfig = state.extra is GameLaunchConfig
              ? state.extra as GameLaunchConfig
              : null;
          final nextIndex =
              storage.getHighestCompletedLevel().clamp(0, kLevels.length);
          final progressionLevelId = nextIndex < kLevels.length
              ? kLevels[nextIndex].id
              : kLevels.last.id;
          final launchConfig = suppliedConfig ??
              GameLaunchConfig(
                levelId: progressionLevelId,
                launchMode: GameLaunchMode.normalProgression,
              );
          if (launchConfig.isDeveloperTest && !developerToolsEnabled) {
            return const HomeScreen();
          }
          return GameScreen(
            launchConfig: launchConfig,
          );
        },
      ),
      GoRoute(
        name: 'result',
        path: '/result',
        builder: (context, state) {
          final result = state.extra;
          if (result is GameResultConfig) {
            if (result.launchConfig.isDeveloperTest && !developerToolsEnabled) {
              return const HomeScreen();
            }
            return ResultScreen(
              gameState: result.gameState,
              launchConfig: result.launchConfig,
            );
          }
          final gameState = result as GameState;
          return ResultScreen(
            gameState: gameState,
            launchConfig: GameLaunchConfig(
              levelId: gameState.levelId,
              launchMode: GameLaunchMode.normalProgression,
            ),
          );
        },
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: 'tile_preview',
        path: '/tile-preview',
        builder: (context, state) => const TilePreviewScreen(),
      ),
      if (developerToolsEnabled)
        GoRoute(
          name: 'developer_level_tester',
          path: '/developer/levels',
          builder: (context, state) => const DeveloperLevelTesterScreen(),
        ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: SankofaGameTheme.backgroundTop,
      body: SankofaBackground(
        child: Center(
          child: Text(
            'Page not found: ${state.error}',
            style: const TextStyle(
              color: SankofaGameTheme.parchmentLight,
            ),
          ),
        ),
      ),
    ),
  );
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  void _logRoute(Route<dynamic>? route) {
    final screenName = route?.settings.name;
    if (screenName != null) {
      AnalyticsService.logScreenView(screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRoute(previousRoute);
  }
}
