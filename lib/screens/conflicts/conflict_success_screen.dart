import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class ConflictSuccessScreen extends StatelessWidget {
  const ConflictSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated / Prominent Success Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.successGreenBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.successGreen, width: 3),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Conflict Resolved!',
                style: AppTypography.display.copyWith(
                  color: AppColors.deepNavy,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule updated successfully. Stage space and cast assignments are now synchronized and conflict-free.',
                style: AppTypography.bodyLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Updated Timetable Card
              StageFlowCard(
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        StatusChip(label: 'MAIN STAGE AUDITORIUM', type: ChipType.success),
                        Text('TODAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResolvedRow('2:00 PM - 4:00 PM', 'Hamlet: Act 1 Scene 2 Rehearsal', 'Main Stage'),
                    const Divider(height: 16),
                    _buildResolvedRow('2:30 PM - 5:00 PM', 'Macbeth: Lighting Focus Call', 'Studio Theatre (Relocated)'),
                  ],
                ),
              ),

              const Spacer(),

              StageFlowButton(
                label: 'Return to Master Schedule',
                variant: ButtonVariant.primary,
                icon: Icons.calendar_today,
                onPressed: () => context.go('/schedule'),
              ),
              const SizedBox(height: 12),
              StageFlowButton(
                label: 'Notify Production Directors',
                variant: ButtonVariant.secondary,
                icon: Icons.send_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications dispatched to Eleanor Vance & Julian Croft.')),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResolvedRow(String time, String title, String room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: AppTypography.metadata.copyWith(color: AppColors.stageRed)),
        const SizedBox(height: 2),
        Text(title, style: AppTypography.headlineMd.copyWith(fontSize: 15)),
        Text(room, style: AppTypography.bodyMd),
      ],
    );
  }
}
