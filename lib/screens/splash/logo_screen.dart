import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../utils/constants.dart';
import '../../widgets/stageflow_button.dart';

class LogoScreen extends StatelessWidget {
  const LogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // StageFlow Logo Mark
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.stageRed,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.theater_comedy,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: AppTypography.display.copyWith(
                  color: AppColors.textOnDark,
                  letterSpacing: -1.0,
                  fontSize: 38,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline.toUpperCase(),
                style: AppTypography.metadata.copyWith(
                  color: const Color(0xFF9EA8B0),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              StageFlowButton(
                label: 'Enter Command Center',
                variant: ButtonVariant.primary,
                icon: Icons.arrow_forward,
                onPressed: () => context.go('/splash'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
