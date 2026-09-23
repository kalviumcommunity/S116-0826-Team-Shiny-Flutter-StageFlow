import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final isDirector = auth.isDirector;
    final userName = user?.name ?? 'StageSync User';
    final userEmail = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // User Avatar & Identity Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppTheme.burgundy,
                    backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                        ? Text(
                            _getInitials(userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDirector
                          ? AppTheme.burgundy.withOpacity(0.12)
                          : AppTheme.emerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDirector
                            ? AppTheme.burgundy.withOpacity(0.3)
                            : AppTheme.emerald.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isDirector ? 'DIRECTOR' : 'CAST MEMBER',
                      style: TextStyle(
                        color: isDirector ? AppTheme.burgundy : AppTheme.emerald,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Theme Settings Section
            const Text(
              'Appearance & Theme',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Preference',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose how StageSync appears on your device.',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_suggest_outlined, size: 16),
                        ),
                      ],
                      selected: {themeProv.themeMode},
                      onSelectionChanged: (newSelection) {
                        themeProv.setThemeMode(newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppTheme.burgundy.withOpacity(0.15),
                        selectedForegroundColor: AppTheme.burgundy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Production & Engine Safeguards
            const Text(
              'Theatre System Safeguards',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppTheme.emerald),
                    title: const Text('RBAC Security Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Strict Firestore rules enforce Director and Cast boundaries', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.check_circle, color: AppTheme.emerald, size: 18),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined, color: AppTheme.emerald),
                    title: const Text('Conflict Detection Engine', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Active cross-production venue & cast overlap verification', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.check_circle, color: AppTheme.emerald, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context, auth),
              icon: const Icon(Icons.logout, size: 18, color: Color(0xFFBA1A1A)),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBA1A1A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of StageSync?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
