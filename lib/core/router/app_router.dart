import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/core/router/scaffold_with_nav.dart';
import 'package:planzy/features/home/view/home_screen.dart';
import 'package:planzy/features/timeline/view/timeline_screen.dart';
import 'package:planzy/features/insights/view/insights_screen.dart';
import 'package:planzy/features/profile/view/profile_screen.dart';
import 'package:planzy/features/commitments/view/add_commitment_screen.dart';
import 'package:planzy/features/goals/view/add_goal_screen.dart';
import 'package:planzy/features/onboarding/view/splash_screen.dart';
import 'package:planzy/features/onboarding/view/onboarding_screen.dart';
import 'package:planzy/features/auth/view/auth_choice_screen.dart';
import 'package:planzy/features/auth/view/login_screen_new.dart';
import 'package:planzy/features/auth/view/signup_screen.dart';
import 'package:planzy/features/transactions/presentation/view/add_transaction_screen.dart';
import 'package:planzy/features/transactions/presentation/view/transaction_history_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isAuthCheckComplete = authState.when(
        data: (_) => true,
        loading: () => false,
        error: (_, __) => true,
      );

      final isOnAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/auth-choice' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      // If still checking auth, stay on splash
      if (!isAuthCheckComplete) {
        return '/splash';
      }

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isOnAuthRoute) {
        return '/auth-choice';
      }

      // If authenticated and trying to access auth routes
      if (isAuthenticated && isOnAuthRoute && state.matchedLocation != '/splash') {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth-choice',
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          // Empty branch for Add button space
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add_placeholder',
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/add-commitment',
        builder: (context, state) => const AddCommitmentScreen(),
      ),
      GoRoute(
        path: '/add-goal',
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transaction-history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
    ],
  );
});

class AppRouter {
  // Use this inside a ProviderScope widget
  static GoRouter routerOf(WidgetRef ref) => ref.watch(routerProvider);
}
