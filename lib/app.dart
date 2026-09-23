import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/screens/auth/login_screen.dart';
import 'package:stagesync/screens/auth/signup_screen.dart';
import 'package:stagesync/screens/event/create_edit_event_screen.dart';
import 'package:stagesync/screens/home/home_shell.dart';
import 'package:stagesync/screens/production/create_edit_production_screen.dart';
import 'package:stagesync/screens/production/production_details_screen.dart';
import 'package:stagesync/screens/profile/profile_screen.dart';
import 'package:stagesync/screens/splash/splash_screen.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/event_service.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/services/role_service.dart';
import 'package:stagesync/services/storage_service.dart';
import 'package:stagesync/services/user_service.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/viewmodels/auditions_viewmodel.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';
import 'package:stagesync/viewmodels/schedule_viewmodel.dart';

class StageSyncApp extends StatelessWidget {
  final AuthViewModel? authViewModel;
  final ProductionsViewModel? productionsViewModel;
  final RolesViewModel? rolesViewModel;
  final EventsViewModel? eventsViewModel;
  final AuditionsViewModel? auditionsViewModel;
  final ScheduleViewModel? scheduleViewModel;

  const StageSyncApp({
    super.key,
    this.authViewModel,
    this.productionsViewModel,
    this.rolesViewModel,
    this.eventsViewModel,
    this.auditionsViewModel,
    this.scheduleViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) =>
              authViewModel ??
              AuthViewModel(
                authService: AuthService(),
                userService: UserService(),
              ),
        ),
        ChangeNotifierProvider<ProductionsViewModel>(
          create: (_) =>
              productionsViewModel ??
              ProductionsViewModel(
                productionService: ProductionService(),
                storageService: StorageService(),
              ),
        ),
        ChangeNotifierProvider<RolesViewModel>(
          create: (_) =>
              rolesViewModel ??
              RolesViewModel(
                roleService: RoleService(),
              ),
        ),
        ChangeNotifierProvider<EventsViewModel>(
          create: (_) =>
              eventsViewModel ??
              EventsViewModel(
                eventService: EventService(),
              ),
        ),
        ChangeNotifierProvider<AuditionsViewModel>(
          create: (_) =>
              auditionsViewModel ??
              AuditionsViewModel(
                auditionService: AuditionService(),
              ),
        ),
        ChangeNotifierProvider<ScheduleViewModel>(
          create: (_) =>
              scheduleViewModel ??
              ScheduleViewModel(
                productionService: ProductionService(),
                eventService: EventService(),
              ),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final effectiveAuthVm = context.read<AuthViewModel>();

          return MaterialApp.router(
            title: 'StageSync',
            debugShowCheckedModeBanner: false,
            theme: StageSyncTheme.light,
            routerConfig: _buildRouter(effectiveAuthVm),
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
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/production/create',
        name: 'createProduction',
        builder: (context, state) => const CreateEditProductionScreen(),
      ),
      GoRoute(
        path: '/production/edit/:prodId',
        name: 'editProduction',
        builder: (context, state) {
          final prodId = state.pathParameters['prodId'];
          return CreateEditProductionScreen(prodId: prodId);
        },
      ),
      GoRoute(
        path: '/production/:prodId',
        name: 'productionDetails',
        builder: (context, state) {
          final prodId = state.pathParameters['prodId']!;
          return ProductionDetailsScreen(prodId: prodId);
        },
      ),
      GoRoute(
        path: '/production/:prodId/event/create',
        name: 'createEvent',
        builder: (context, state) {
          final prodId = state.pathParameters['prodId']!;
          return CreateEditEventScreen(prodId: prodId);
        },
      ),
      GoRoute(
        path: '/production/:prodId/event/edit',
        name: 'editEvent',
        builder: (context, state) {
          final prodId = state.pathParameters['prodId']!;
          final initialEvent = state.extra as EventModel?;
          return CreateEditEventScreen(
            prodId: prodId,
            initialEvent: initialEvent,
          );
        },
      ),
    ],
  );
}
