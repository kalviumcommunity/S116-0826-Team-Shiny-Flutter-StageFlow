import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoading) {
      void listener() {
        if (!auth.isLoading) {
          auth.removeListener(listener);
          if (mounted) {
            if (auth.isAuthenticated) {
              context.go('/home');
            } else {
              context.go('/login');
            }
          }
        }
      }
      auth.addListener(listener);
      return;
    }

    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.burgundy.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold, width: 1.5),
              ),
              child: const Icon(
                Icons.theater_comedy,
                size: 64,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'StageSync',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Theatre Production & Schedule Management',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
