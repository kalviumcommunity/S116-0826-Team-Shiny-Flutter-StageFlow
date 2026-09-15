import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/user_service.dart';
import 'package:stagesync/screens/splash/splash_screen.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';

class StageSyncApp extends StatelessWidget {
  const StageSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            authService: AuthService(),
            userService: UserService(),
          ),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final authViewModel = context.read<AuthViewModel>();

          return MaterialApp.router(
            title: 'StageSync',
            debugShowCheckedModeBanner: false,
            theme: StageSyncTheme.light,
            routerConfig: _buildRouter(authViewModel),
          );
        },
      ),
    );
  }
}

GoRouter _buildRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authViewModel,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.uri.path;
      final bool isLoading = authViewModel.isLoading;
      final bool isAuthenticated = authViewModel.currentUser != null;
      final bool isAuthRoute = location == '/login' ||
          location == '/signup' ||
          location == '/splash';

      if (isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      if (!isAuthenticated) {
        if (location == '/login' || location == '/signup') {
          return null;
        }
        return '/login';
      }

      if (isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderRouteScreen(
            title: 'Login',
            subtitle: 'Login UI comes in the next prompt.',
          );
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderRouteScreen(
            title: 'Sign Up',
            subtitle: 'Sign up UI comes in the next prompt.',
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const _PlaceholderRouteScreen(
            title: 'Home',
            subtitle: 'Home UI comes in Prompt 10.',
          );
        },
      ),
    ],
  );
}

class _PlaceholderRouteScreen extends StatelessWidget {
  const _PlaceholderRouteScreen({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
