import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../screens/auditions/auditions_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/availability/availability_dashboard_screen.dart';
import '../../screens/conflicts/conflict_success_screen.dart';
import '../../screens/conflicts/resolve_conflict_screen.dart';
import '../../screens/home/home_dashboard_screen.dart';
import '../../screens/productions/cast_roles_screen.dart';
import '../../screens/productions/production_details_screen.dart';
import '../../screens/productions/productions_list_screen.dart';
import '../../screens/schedule/create_event_screen.dart';
import '../../screens/schedule/event_details_screen.dart';
import '../../screens/schedule/master_schedule_screen.dart';
import '../../screens/splash/logo_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/venues/venues_screen.dart';
import '../../widgets/navigation/main_bottom_nav.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter createRouter(AuthViewModel? authViewModel) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/logo',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        // If Firebase is not active, allow all routes for UI testing
        if (authViewModel == null) return null;

        final isLoading = authViewModel.isLoading;
        final isAuthenticated = authViewModel.currentUser != null;
        final isAuthRoute = state.uri.path == '/login' ||
            state.uri.path == '/logo' ||
            state.uri.path == '/splash';

        if (isLoading) {
          // Stay on splash/logo while loading
          return isAuthRoute ? null : '/splash';
        }

        if (!isAuthenticated) {
          if (isAuthRoute) return null;
          return '/login';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Top Level Non-Shell Routes
      GoRoute(
        path: '/logo',
        builder: (context, state) => const LogoScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/conflicts/resolve',
        builder: (context, state) => const ResolveConflictScreen(),
      ),
      GoRoute(
        path: '/conflicts/success',
        builder: (context, state) => const ConflictSuccessScreen(),
      ),

      // Secondary Detail Routes
      GoRoute(
        path: '/productions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'hamlet-1';
          return ProductionDetailsScreen(productionId: id);
        },
      ),
      GoRoute(
        path: '/productions/:id/cast',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'hamlet-1';
          return CastRolesScreen(productionId: id);
        },
      ),
      GoRoute(
        path: '/schedule/create',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/schedule/events/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'evt-1';
          return EventDetailsScreen(eventId: id);
        },
      ),

      // Shell Route for Bottom Navigation Tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainBottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: '/productions',
            builder: (context, state) => const ProductionsListScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const MasterScheduleScreen(),
          ),
          GoRoute(
            path: '/venues',
            builder: (context, state) => const VenuesScreen(),
          ),
          GoRoute(
            path: '/availability',
            builder: (context, state) => const AvailabilityDashboardScreen(),
          ),
          GoRoute(
            path: '/auditions',
            builder: (context, state) => const AuditionsScreen(),
          ),
        ],
      ),
    ],
  );
  }
}
