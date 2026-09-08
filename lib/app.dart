import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/user_service.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(
            child: Text(
              'StageSync',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    ),
  ],
);

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
      child: MaterialApp.router(
        title: 'StageSync',
        debugShowCheckedModeBanner: false,
        theme: StageSyncTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
