import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme/theme_notifier.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';
import '../../viewmodels/schedule_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _autoDim = true;

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showEditNameDialog(BuildContext context, AuthViewModel authVm, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Profile Details',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Name',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your legal stage name',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success = await authVm.updateProfile(name: nameController.text.trim());
              if (mounted && success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Change Password',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'A password reset link will be sent to your registered work email: $email',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final authVm = context.read<AuthViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              final success = await authVm.sendPasswordResetEmail(email);
              if (mounted) {
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Password reset instructions dispatched to $email.'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } else if (authVm.errorMessage != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(authVm.errorMessage!),
                      backgroundColor: AppColors.conflictRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.theater_comedy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'About StageSync',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StageSync Theatre Production & Operations Suite',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Version 1.0.0 (Production Release)\n'
              'Architecture: UI → ViewModel → Service → Firebase\n'
              'Design System: Velvet Crimson & Slate Blue Stitch Aesthetic\n'
              'Engine: Real-time Callboard Sync & Conflict Detection Engine',
              style: GoogleFonts.inter(fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthViewModel auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Log Out of StageSync?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to end your backstage session? You will be redirected to the sign-in portal.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final authVm = context.watch<AuthViewModel>();
    final prodVm = context.watch<ProductionsViewModel>();
    final scheduleVm = context.watch<ScheduleViewModel>();
    final themeNotifier = context.watch<ThemeNotifier>();

    final user = authVm.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Production Member';
    final userEmail = user?.email ?? 'member@stagesync.app';
    final isDirector = user?.role.toLowerCase() == 'director' ||
        user?.role.toLowerCase() == 'stage_manager';
    final roleLabel = isDirector ? 'DIRECTOR' : 'CAST MEMBER';

    final activeProd = prodVm.productions.isNotEmpty ? prodVm.productions.first : null;
    final nextItem =
        scheduleVm.scheduledItems.isNotEmpty ? scheduleVm.scheduledItems.first : null;

    final currentThemeMode = themeNotifier.themeMode;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.theater_comedy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StageSync',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Profile & Settings',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: subTextCol,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with Active dot
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryCrimson,
                        backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                            ? Text(
                                _getInitials(userName),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successGreen,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textCol,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDirector
                                    ? AppColors.primaryContainer.withValues(alpha: 0.12)
                                    : AppColors.successContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                roleLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDirector
                                      ? AppColors.primaryCrimson
                                      : AppColors.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subTextCol,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (activeProd != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.theater_comedy,
                                size: 13,
                                color: AppColors.secondaryAmber,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  activeProd.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: subTextCol,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (user != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: subTextCol,
                      tooltip: 'Edit Profile Details',
                      onPressed: () => _showEditNameDialog(context, authVm, user),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Rehearsal Readiness / Next Call Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: AppColors.primaryCrimson,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextItem != null
                              ? 'Next Call: ${nextItem.event.notes.isNotEmpty ? nextItem.event.notes : nextItem.event.type}'
                              : 'No Immediate Call Scheduled',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextItem != null
                              ? '${nextItem.event.venue} • ${DateFormat('h:mm a').format(nextItem.event.start)} ${DateFormat('MMM d').format(nextItem.event.start)}'
                              : 'Company ledger clear • Stage ready',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: subTextCol,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Callboard',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Appearance / Theme Selector Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.palette,
                            size: 18,
                            color: AppColors.primaryCrimson,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Appearance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textCol,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Stage Optimized',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: subTextCol,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adjust brightness for high-contrast backstage navigation or daylit production meetings.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subTextCol,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3-Way Segmented Theme Selector
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildThemeButton(
                          label: 'Light',
                          icon: Icons.light_mode,
                          isSelected: currentThemeMode == ThemeMode.light,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                          cardBg: cardBg,
                          textCol: textCol,
                          subTextCol: subTextCol,
                        ),
                        _buildThemeButton(
                          label: 'Dark',
                          icon: Icons.dark_mode,
                          isSelected: currentThemeMode == ThemeMode.dark,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                          cardBg: cardBg,
                          textCol: textCol,
                          subTextCol: subTextCol,
                        ),
                        _buildThemeButton(
                          label: 'System',
                          icon: Icons.devices,
                          isSelected: currentThemeMode == ThemeMode.system,
                          onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                          cardBg: cardBg,
                          textCol: textCol,
                          subTextCol: subTextCol,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Auto-dim during cues switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Auto-dim during active cues',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                      Switch(
                        value: _autoDim,
                        activeThumbColor: AppColors.primaryCrimson,
                        onChanged: (val) {
                          setState(() => _autoDim = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Production Settings Navigation Group
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      'PRODUCTION SETTINGS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: subTextCol,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notifications_active_outlined, size: 18),
                    ),
                    title: Text(
                      'Notifications',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Rehearsal notices, callboard updates',
                      style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Callboard notifications enabled on device.'),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: borderCol),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_reset, size: 18),
                    ),
                    title: Text(
                      'Change Password',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Security, 2FA & keycard authorization',
                      style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showPasswordResetDialog(context, userEmail),
                  ),
                  Divider(height: 1, color: borderCol),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline, size: 18),
                    ),
                    title: Text(
                      'About StageSync',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'v1.0 Production Release',
                      style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v1.0',
                            style: GoogleFonts.inter(fontSize: 11, color: subTextCol),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Active Company Credentials Card (Real RBAC Safeguards)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF640023),
                    Color(0xFF881337),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE REPERTORY CREDENTIALS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeProd?.title ?? 'StageSync Repertory',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDirector
                        ? 'Director & Stage Manager Access • Full Callboard & Conflict Validation'
                        : 'Company Cast Member Access • Rehearsal Ledger & Auditions Roster',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Destructive Log Out Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.errorRed),
                  foregroundColor: AppColors.errorRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _confirmSignOut(context, authVm),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(
                  'Log Out',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'StageSync Production Suite • Signed in as ${user?.role ?? "member"}',
                style: GoogleFonts.inter(fontSize: 11, color: subTextCol),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color textCol,
    required Color subTextCol,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : icon,
                size: 16,
                color: isSelected ? AppColors.primaryCrimson : subTextCol,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? textCol : subTextCol,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
