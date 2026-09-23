import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    final name = user?.name.isNotEmpty == true ? user!.name : 'User';
    final email = user?.email.isNotEmpty == true ? user!.email : 'No email';
    final role = user?.role == 'director' ? 'Director' : 'Cast Member';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // User Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.spotlightAmberGlow,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.spotlightAmberDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryCharcoal,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Non-editable Role Chip
              Chip(
                label: Text(
                  role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryCharcoalDark,
                  ),
                ),
                backgroundColor: AppColors.spotlightAmberGlow,
                side: BorderSide.none,
                avatar: Icon(
                  user?.role == 'director'
                      ? Icons.movie_creation_outlined
                      : Icons.theater_comedy_outlined,
                  size: 18,
                  color: AppColors.spotlightAmberDark,
                ),
              ),

              const Spacer(),

              // Log Out Button
              PrimaryButton(
                label: 'Log Out',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.conflictRedContainer,
                foregroundColor: AppColors.conflictRedText,
                isLoading: authViewModel.isLoading,
                onPressed: () async {
                  await authViewModel.signOut();
                  // No manual navigation! GoRouter redirect handles redirect to /login
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
