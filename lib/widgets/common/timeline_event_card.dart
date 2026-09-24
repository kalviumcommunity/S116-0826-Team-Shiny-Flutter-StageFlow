import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../theme/app_colors.dart';

class TimelineEventCard extends StatelessWidget {
  final EventModel event;
  final String? productionTitle;
  final VoidCallback? onTap;

  const TimelineEventCard({
    super.key,
    required this.event,
    this.productionTitle,
    this.onTap,
  });

  Color _getCategoryColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('rehearsal')) return AppColors.primaryContainer;
    if (lower.contains('audition')) return AppColors.secondaryAmber;
    if (lower.contains('performance')) return const Color(0xFF15803D);
    if (lower.contains('meeting')) return AppColors.tertiarySlate;
    return AppColors.tertiarySlateLight;
  }

  Color _getCategoryBg(String type, bool isDark) {
    final lower = type.toLowerCase();
    if (isDark) return const Color(0xFF223042);
    if (lower.contains('rehearsal')) return const Color(0xFFFFD9DD);
    if (lower.contains('audition')) return AppColors.warningContainer;
    if (lower.contains('performance')) return AppColors.successContainer;
    return AppColors.surfaceLow;
  }

  Color _getCategoryFg(String type, bool isDark) {
    final lower = type.toLowerCase();
    if (isDark) return const Color(0xFFFF93A6);
    if (lower.contains('rehearsal')) return AppColors.primaryCrimson;
    if (lower.contains('audition')) return AppColors.warningText;
    if (lower.contains('performance')) return AppColors.successText;
    return AppColors.tertiarySlate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161F36) : Colors.white;
    final borderCol = isDark ? const Color(0xFF283044) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final indicatorColor = _getCategoryColor(event.type);
    final badgeBg = _getCategoryBg(event.type, isDark);
    final badgeFg = _getCategoryFg(event.type, isDark);

    final timeFormatter = DateFormat('h:mm a');
    final timeStr = '${timeFormatter.format(event.start)} – ${timeFormatter.format(event.end)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Category Indicator Strip
              Container(
                width: 4,
                color: indicatorColor,
              ),
              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time & Category Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 15, color: indicatorColor),
                              const SizedBox(width: 4),
                              Text(
                                timeStr,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textCol,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              event.type,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        productionTitle != null && productionTitle!.isNotEmpty
                            ? '$productionTitle — ${event.notes.isNotEmpty ? event.notes : "${event.type} Call"}'
                            : (event.notes.isNotEmpty ? event.notes : "${event.type} Call"),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textCol,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Venue & Cast details
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: subTextCol),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              event.venue,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: subTextCol,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.castIds.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.group, size: 14, color: subTextCol),
                            const SizedBox(width: 3),
                            Text(
                              '${event.castIds.length} called',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subTextCol,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
