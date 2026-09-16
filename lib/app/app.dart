import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class StageFlowApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  
  const StageFlowApp({super.key, this.isFirebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    Widget app = Builder(
      builder: (context) {
        final authViewModel = isFirebaseInitialized ? context.read<AuthViewModel>() : null;
        
        return MaterialApp.router(
          title: 'StageFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Enables system-based switching for the initial review
          routerConfig: AppRouter.createRouter(authViewModel),
        );
      },
    );

    // Only inject the Firebase-dependent providers if Firebase actually initialized
    if (isFirebaseInitialized) {
      app = MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(
              authService: AuthService(),
              userService: UserService(),
            ),
          ),
        ],
        child: app,
      );
    }

    return app;
  }
}
