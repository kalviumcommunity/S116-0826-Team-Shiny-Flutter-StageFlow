import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class AvatarBadge extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool isOnline;

  const AvatarBadge({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 20.0,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.deepNavy,
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).extension<StageFlowThemeExtension>()!.surfaceContainerLow,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: radius * 0.8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  )
                : null,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
