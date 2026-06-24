import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/developer_tools_config.dart';
import '../../models/game_state.dart';
import '../../models/game_launch_config.dart';
import '../constants/level_data.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/tutorial/tutorial_screen.dart';
import '../../screens/journey/journey_screen.dart';
import '../../screens/pre_level/pre_level_screen.dart';
import '../../screens/chapter/chapter_complete_screen.dart';
import '../../screens/daily/daily_reward_screen.dart';
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
        pageBuilder: (context, state) => _fadePage(
          context,
          state,
          const HomeScreen(),
        ),
      ),
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        name: 'tutorial',
        path: '/tutorial',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          TutorialScreen(replay: state.uri.queryParameters['replay'] == '1'),
        ),
      ),
      GoRoute(
        name: 'journey',
        path: '/journey',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          const JourneyScreen(),
        ),
      ),
      GoRoute(
        name: 'daily_reward',
        path: '/daily-reward',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          const DailyRewardScreen(),
        ),
      ),
      GoRoute(
        name: 'pre_level',
        path: '/level/:levelId',
        pageBuilder: (context, state) {
          final levelId = int.tryParse(state.pathParameters['levelId'] ?? '');
          return _slideFadePage(
            context,
            state,
            PreLevelScreen(levelId: levelId ?? -1),
          );
        },
      ),
      GoRoute(
        name: 'game',
        path: '/game/:levelId',
        pageBuilder: (context, state) {
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
            return _fadePage(context, state, const HomeScreen());
          }
          return _slideFadePage(
            context,
            state,
            GameScreen(
              launchConfig: launchConfig,
            ),
          );
        },
      ),
      GoRoute(
        name: 'result',
        path: '/result',
        pageBuilder: (context, state) {
          final result = state.extra;
          if (result is GameResultConfig) {
            if (result.launchConfig.isDeveloperTest && !developerToolsEnabled) {
              return _fadePage(context, state, const HomeScreen());
            }
            return _fadePage(
              context,
              state,
              ResultScreen(
                gameState: result.gameState,
                launchConfig: result.launchConfig,
              ),
            );
          }
          final gameState = result as GameState;
          return _fadePage(
            context,
            state,
            ResultScreen(
              gameState: gameState,
              launchConfig: GameLaunchConfig(
                levelId: gameState.levelId,
                launchMode: GameLaunchMode.normalProgression,
              ),
            ),
          );
        },
      ),
      GoRoute(
        name: 'chapter_complete',
        path: '/chapter-complete/:levelId',
        pageBuilder: (context, state) {
          final levelId = int.tryParse(state.pathParameters['levelId'] ?? '');
          return _fadePage(
            context,
            state,
            ChapterCompleteScreen(completedLevelId: levelId ?? 1),
          );
        },
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        name: 'tile_preview',
        path: '/tile-preview',
        pageBuilder: (context, state) => _slideFadePage(
          context,
          state,
          const TilePreviewScreen(),
        ),
      ),
      if (developerToolsEnabled)
        GoRoute(
          name: 'developer_level_tester',
          path: '/developer/levels',
          pageBuilder: (context, state) => _slideFadePage(
            context,
            state,
            const DeveloperLevelTesterScreen(),
          ),
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

CustomTransitionPage<void> _fadePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration:
        reducedMotion ? Duration.zero : const Duration(milliseconds: 180),
    reverseTransitionDuration:
        reducedMotion ? Duration.zero : const Duration(milliseconds: 140),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideFadePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration:
        reducedMotion ? Duration.zero : const Duration(milliseconds: 220),
    reverseTransitionDuration:
        reducedMotion ? Duration.zero : const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.035, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offset, child: child),
      );
    },
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
