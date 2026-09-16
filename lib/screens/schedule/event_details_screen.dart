import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/event.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _repository = MockStageFlowRepository();
  ScheduleEvent? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final evt = await _repository.getEventById(widget.eventId);
    if (mounted) {
      setState(() {
        _event = evt;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: Text('Event not found.')),
      );
    }

    final event = _event!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Call Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit event form opened.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header Card
            StageFlowCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(label: event.type, type: ChipType.info),
                      StatusChip.fromStatusString(event.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(event.title, style: AppTypography.display.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.theater_comedy, size: 16, color: AppColors.stageRed),
                      const SizedBox(width: 6),
                      Text(
                        event.productionTitle,
                        style: AppTypography.headlineMd.copyWith(fontSize: 16, color: AppColors.deepNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, size: 20, color: AppColors.deepNavy),
                      const SizedBox(width: 10),
                      Text(event.timeSlotString, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: AppColors.deepNavy),
                      const SizedBox(width: 10),
                      Text(event.venueName, style: AppTypography.bodyLg),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Required Cast & Roles
            const SectionHeader(title: 'Required Cast & Crew'),
            const SizedBox(height: 12),
            StageFlowCard(
              child: Column(
                children: event.requiredCast.map((name) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        AvatarBadge(imageUrl: '', name: name, radius: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.bodyLg.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const StatusChip(label: 'CHECKED IN', type: ChipType.success),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Technical Notes & Script References
            const SectionHeader(title: 'Stage & Technical Notes'),
            const SizedBox(height: 12),
            StageFlowCard(
              child: Text(
                event.notes.isNotEmpty ? event.notes : 'No specific technical notes for this call.',
                style: AppTypography.bodyMd,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            StageFlowButton(
              label: 'Check In Cast Members',
              variant: ButtonVariant.primary,
              icon: Icons.check_circle,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cast check-in confirmed!')),
                );
              },
            ),
            const SizedBox(height: 10),
            StageFlowButton(
              label: 'Cancel Call',
              variant: ButtonVariant.secondary,
              icon: Icons.cancel_outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
