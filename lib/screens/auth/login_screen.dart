import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../utils/constants.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'stage.manager@stageflow.org');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _isLoading = false;
  String _selectedRole = 'Stage Manager';

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authViewModel = context.read<AuthViewModel?>();
        if (authViewModel != null) {
          await authViewModel.signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            context.go('/home');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Error: ')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _quickFillRole(String role, String email) {
    setState(() {
      _selectedRole = role;
      _emailController.text = email;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header Logo
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.theater_comedy, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: AppTypography.headlineLg.copyWith(color: AppColors.deepNavy),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  'Command Center Login',
                  style: AppTypography.display.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to manage active productions, schedules, and technical calls.',
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: 28),

                // Form Fields
                StageFlowTextField(
                  label: 'Work Email',
                  hint: 'name@stageflow.org',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your work email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                StageFlowTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset link sent to registered email.')),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.stageRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                StageFlowButton(
                  label: 'Sign In to StageFlow',
                  variant: ButtonVariant.primary,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 32),
                Divider(height: 1, color: Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle),
                const SizedBox(height: 24),

                // Quick Demo Role Switcher
                Text(
                  'DEMO QUICK LOGIN (SELECT ROLE)',
                  style: AppTypography.metadata.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _selectedRole == 'Stage Manager' ? AppColors.stageRed : Theme.of(context).colorScheme.outlineVariant,
                          ),
                          backgroundColor: _selectedRole == 'Stage Manager' ? AppColors.stageRed.withAlpha(20) : Colors.transparent,
                        ),
                        onPressed: () => _quickFillRole('Stage Manager', 'stage.manager@stageflow.org'),
                        child: const Text('Stage Mgr', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _selectedRole == 'Director' ? AppColors.stageRed : Theme.of(context).colorScheme.outlineVariant,
                          ),
                          backgroundColor: _selectedRole == 'Director' ? AppColors.stageRed.withAlpha(20) : Colors.transparent,
                        ),
                        onPressed: () => _quickFillRole('Director', 'director.eleanor@stageflow.org'),
                        child: const Text('Director', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _selectedRole == 'Producer' ? AppColors.stageRed : Theme.of(context).colorScheme.outlineVariant,
                          ),
                          backgroundColor: _selectedRole == 'Producer' ? AppColors.stageRed.withAlpha(20) : Colors.transparent,
                        ),
                        onPressed: () => _quickFillRole('Producer', 'producer.croft@stageflow.org'),
                        child: const Text('Producer', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
