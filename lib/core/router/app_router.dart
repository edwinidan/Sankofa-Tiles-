import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_state.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/level_select/level_select_screen.dart';
import '../../screens/game/game_screen.dart';
import '../../screens/result/result_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../utils/storage_service.dart';

GoRouter createAppRouter(StorageService storage) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // First launch → onboarding
      if (state.matchedLocation == '/' && !storage.isOnboardingComplete()) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/level-select',
        builder: (context, state) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: '/game/:levelId',
        builder: (context, state) {
          final levelId = int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          final difficulty = state.extra is DifficultyMode
              ? state.extra as DifficultyMode
              : DifficultyMode.normal;
          return GameScreen(levelId: levelId, difficulty: difficulty);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final gameState = state.extra as GameState;
          return ResultScreen(gameState: gameState);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A2240),
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
