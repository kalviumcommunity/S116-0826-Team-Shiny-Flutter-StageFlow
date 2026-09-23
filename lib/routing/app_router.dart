import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/production.dart';
import '../models/event_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/productions/productions_screen.dart';
import '../screens/productions/create_edit_production_screen.dart';
import '../screens/productions/production_details_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/create_edit_event_screen.dart';
import '../screens/auditions/auditions_screen.dart';
import '../screens/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationScreen(navigationShell: navigationShell);
      },
      branches: [
        // 1. Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // 2. Schedule
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const ScheduleScreen(),
            ),
          ],
        ),

        // 3. Productions
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/productions',
              builder: (context, state) => const ProductionsScreen(),
            ),
          ],
        ),

        // 4. Profile
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

    // Top-level modal/push routes
    GoRoute(
      path: '/productions/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateEditProductionScreen(),
    ),
    GoRoute(
      path: '/productions/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final prod = state.extra as Production?;
        return CreateEditProductionScreen(production: prod);
      },
    ),
    GoRoute(
      path: '/productions/details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final prod = state.extra as Production;
        return ProductionDetailsScreen(production: prod);
      },
    ),
    GoRoute(
      path: '/schedule/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final prod = state.extra as Production?;
        return CreateEditEventScreen(defaultProduction: prod);
      },
    ),
    GoRoute(
      path: '/schedule/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final event = state.extra as EventModel;
        return CreateEditEventScreen(event: event);
      },
    ),
    GoRoute(
      path: '/auditions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuditionsScreen(),
    ),
  ],
);
