import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'director'; // 'director' or 'cast'
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _passwordStrength = 0; // 0 to 3

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String value) {
    int strength = 0;
    if (value.length >= 6) strength++;
    if (value.length >= 8 && RegExp(r'[0-9]').hasMatch(value)) strength++;
    if (value.length >= 10 && RegExp(r'[!@#\$&*~A-Z]').hasMatch(value)) strength++;
    setState(() => _passwordStrength = strength);
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final success = await auth.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.conflictRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthViewModel>();

    final cardBg = isDark ? const Color(0xFF161F36) : Colors.white;
    final borderCol = isDark ? const Color(0xFF283044) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back navigation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: textCol,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                  ),

                  // Theatrical Hero Banner
                  Container(
                    height: 110,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF283044) : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.theater_comedy, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(
                                    'PRODUCTION CALLBOARD',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '2024 Season Active',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Join StageSync',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Header Block
                  Text(
                    'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join StageSync to manage or participate in theatre productions',
                    style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                  ),
                  const SizedBox(height: 20),

                  // Role Selection Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELECT PRIMARY ROLE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: subTextCol,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.tune, size: 13, color: AppColors.primaryContainer),
                          const SizedBox(width: 3),
                          Text(
                            'Switchable later',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Role Option 1: Director
                  _buildRoleCard(
                    title: 'Director / Stage Manager',
                    badge: 'Lead',
                    description: 'Manage productions, schedules, auditions, and casting calls.',
                    icon: Icons.chair,
                    isSelected: _selectedRole == 'director',
                    onTap: () => setState(() => _selectedRole = 'director'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),

                  // Role Option 2: Cast Member
                  _buildRoleCard(
                    title: 'Cast Member / Performer',
                    badge: 'Artist',
                    description: 'View personal schedule, rehearsal times, and assigned roles.',
                    icon: Icons.theater_comedy,
                    isSelected: _selectedRole == 'cast',
                    onTap: () => setState(() => _selectedRole = 'cast'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),

                  // Core Inputs Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Full Name',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: subTextCol),
                            ),
                            Text(
                              'Stage billing',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.inter(fontSize: 14, color: textCol),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Sarah Jenkins',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (v) => Validators.required(v, 'Please enter your full name'),
                        ),
                        const SizedBox(height: 14),

                        // Email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Email Address',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: subTextCol),
                            ),
                            Text(
                              'Call notifications',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.inter(fontSize: 14, color: textCol),
                          decoration: const InputDecoration(
                            hintText: 'sarah.j@actor.org',
                            prefixIcon: Icon(Icons.mail_outline, size: 20),
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 14),

                        // Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: subTextCol),
                            ),
                            Text(
                              'Min. 8 characters',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onChanged: _checkPasswordStrength,
                          style: GoogleFonts.inter(fontSize: 14, color: textCol),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                                color: subTextCol,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 6),

                        // Password Strength Visualization
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _passwordStrength >= 1
                                      ? (_passwordStrength == 1 ? Colors.orange : AppColors.primaryContainer)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _passwordStrength >= 2
                                      ? (_passwordStrength == 2 ? Colors.amber : AppColors.primaryContainer)
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _passwordStrength >= 3
                                      ? AppColors.successGreen
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Confirm Password',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: subTextCol),
                            ),
                            Text(
                              'Must match',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignUp(),
                          style: GoogleFonts.inter(fontSize: 14, color: textCol),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.verified_user_outlined, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                                color: subTextCol,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Trust & Protocol Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified, size: 16, color: AppColors.tertiarySlateLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'By registering, you confirm backstage communications via encrypted StageSync production protocols.',
                            style: GoogleFonts.inter(fontSize: 12, color: subTextCol, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Create Account Button
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                  ),
                  const SizedBox(height: 18),

                  // Sign In link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String badge,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderCol = isSelected
        ? AppColors.primaryContainer
        : (isDark ? const Color(0xFF283044) : AppColors.borderHairline);
    final bgCol = isSelected
        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
        : (isDark ? const Color(0xFF131B2E) : const Color(0xFFF8F9FA));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 13, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF283044) : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
