import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/router/scaffold_with_nav.dart';
import 'package:planzy/features/home/view/home_screen.dart';
import 'package:planzy/features/timeline/view/timeline_screen.dart';
import 'package:planzy/features/insights/view/insights_screen.dart';
import 'package:planzy/features/profile/view/profile_screen.dart';
import 'package:planzy/features/commitments/view/add_commitment_screen.dart';
import 'package:planzy/features/goals/view/add_goal_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
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
    ],
  );
}
