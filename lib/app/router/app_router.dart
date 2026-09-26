import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../screens/auditions/auditions_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_dashboard_screen.dart';
import '../../screens/productions/production_details_screen.dart';
import '../../screens/productions/productions_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/schedule/create_event_screen.dart';
import '../../screens/schedule/master_schedule_screen.dart';
import '../../screens/splash/logo_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../widgets/navigation/main_bottom_nav.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter createRouter(AuthViewModel? authViewModel) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/logo',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        if (authViewModel == null) return null;

        final isLoading = authViewModel.isLoading;
        final isAuthenticated = authViewModel.currentUser != null;
        final currentPath = state.uri.path;
        final isAuthRoute = currentPath == '/login' ||
            currentPath == '/signup' ||
            currentPath == '/logo' ||
            currentPath == '/splash';

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
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),

        // Legacy conflict routes - superseded by VenueConflictDialog bottom sheet
        GoRoute(
          path: '/conflicts/resolve',
          redirect: (context, state) => '/schedule',
        ),
        GoRoute(
          path: '/conflicts/success',
          redirect: (context, state) => '/schedule',
        ),

        // Secondary Detail Routes
        GoRoute(
          path: '/productions/:id',
          redirect: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null || id.trim().isEmpty) {
              return '/productions';
            }
            return null;
          },
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductionDetailsScreen(productionId: id);
          },
        ),
        // Legacy cast roles route - superseded by Roles tab in ProductionDetailsScreen
        GoRoute(
          path: '/productions/:id/cast',
          redirect: (context, state) {
            final id = state.pathParameters['id'];
            if (id != null && id.trim().isNotEmpty) {
              return '/productions/$id';
            }
            return '/productions';
          },
        ),
        GoRoute(
          path: '/schedule/create',
          builder: (context, state) => const CreateEventScreen(),
        ),
        // Legacy event details route - superseded by Master Schedule timeline
        GoRoute(
          path: '/schedule/events/:id',
          redirect: (context, state) => '/schedule',
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
              path: '/schedule',
              builder: (context, state) => const MasterScheduleScreen(),
            ),
            GoRoute(
              path: '/productions',
              builder: (context, state) => const ProductionsListScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            // Legacy venues route - superseded by inline venue conflict detection
            GoRoute(
              path: '/venues',
              redirect: (context, state) => '/schedule',
            ),
            // Legacy availability route - superseded by cast roster management
            GoRoute(
              path: '/availability',
              redirect: (context, state) => '/schedule',
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
