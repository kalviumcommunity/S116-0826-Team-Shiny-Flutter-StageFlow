import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/theme/app_colors.dart';

class ProductionCard extends StatelessWidget {
  final ProductionModel production;
  final VoidCallback? onTap;

  const ProductionCard({
    super.key,
    required this.production,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateRangeFormat = DateFormat('MMM d');
    final formattedDates =
        '${dateRangeFormat.format(production.startDate)} - ${dateRangeFormat.format(production.endDate)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poster Image or Fallback
              Container(
                height: 105,
                width: double.infinity,
                color: AppColors.primaryCharcoalLight,
                child: production.imageURL != null &&
                        production.imageURL!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: production.imageURL!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.spotlightAmber,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.theater_comedy_rounded,
                            size: 36,
                            color: AppColors.spotlightAmber,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.theater_comedy_rounded,
                          size: 36,
                          color: AppColors.spotlightAmber,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      production.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDates,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 15,
                          color: AppColors.spotlightAmberDark,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${production.memberIds.length} members',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
