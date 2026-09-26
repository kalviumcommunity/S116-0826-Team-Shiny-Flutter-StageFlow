import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audition_service.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/production_service.dart';
import '../services/role_service.dart';
import '../services/storage_service.dart';
import '../services/uninitialized_services.dart';
import '../services/user_service.dart';
import '../viewmodels/auditions_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/events_viewmodel.dart';
import '../viewmodels/productions_viewmodel.dart';
import '../viewmodels/roles_viewmodel.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

class StageFlowApp extends StatelessWidget {
  final bool isFirebaseInitialized;

  const StageFlowApp({super.key, this.isFirebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Builder(
        builder: (context) {
          final themeNotifier = context.watch<ThemeNotifier>();

          final AuthService authService = isFirebaseInitialized
              ? AuthService()
              : UninitializedAuthService();
          final UserService userService = isFirebaseInitialized
              ? UserService()
              : UninitializedUserService();
          final ProductionService productionService = isFirebaseInitialized
              ? ProductionService()
              : UninitializedProductionService();
          final StorageService storageService = isFirebaseInitialized
              ? StorageService()
              : UninitializedStorageService();
          final EventService eventService = isFirebaseInitialized
              ? EventService()
              : UninitializedEventService();
          final RoleService roleService = isFirebaseInitialized
              ? RoleService()
              : UninitializedRoleService();
          final AuditionService auditionService = isFirebaseInitialized
              ? AuditionService()
              : UninitializedAuditionService();

          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthViewModel>(
                create: (_) => AuthViewModel(
                  authService: authService,
                  userService: userService,
                ),
              ),
              ChangeNotifierProvider<ProductionsViewModel>(
                create: (_) => ProductionsViewModel(
                  productionService: productionService,
                  storageService: storageService,
                ),
              ),
              ChangeNotifierProvider<ScheduleViewModel>(
                create: (_) => ScheduleViewModel(
                  productionService: productionService,
                  eventService: eventService,
                ),
              ),
              ChangeNotifierProvider<EventsViewModel>(
                create: (_) => EventsViewModel(
                  eventService: eventService,
                ),
              ),
              ChangeNotifierProvider<RolesViewModel>(
                create: (_) => RolesViewModel(
                  roleService: roleService,
                ),
              ),
              ChangeNotifierProvider<AuditionsViewModel>(
                create: (_) => AuditionsViewModel(
                  auditionService: auditionService,
                ),
              ),
            ],
            child: Builder(
              builder: (context) {
                final authViewModel = context.read<AuthViewModel>();

                return MaterialApp.router(
                  title: 'StageSync',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeNotifier.themeMode,
                  routerConfig: AppRouter.createRouter(authViewModel),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
