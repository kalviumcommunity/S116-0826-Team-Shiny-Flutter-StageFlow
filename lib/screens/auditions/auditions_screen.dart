import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/audition.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class AuditionsScreen extends StatefulWidget {
  const AuditionsScreen({super.key});

  @override
  State<AuditionsScreen> createState() => _AuditionsScreenState();
}

class _AuditionsScreenState extends State<AuditionsScreen> {
  final _repository = MockStageFlowRepository();
  List<AuditionCandidate> _candidates = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAuditions();
  }

  Future<void> _loadAuditions() async {
    final list = await _repository.getAuditions();
    if (mounted) {
      setState(() {
        _candidates = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _candidates.where((c) {
      return _selectedFilter == 'All' || c.status == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auditions & Recruitment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audition application portal link copied.')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audition Call Summary Card
                  StageFlowCard(
                    backgroundColor: AppColors.deepNavy,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            StatusChip(label: 'AUDITION CALL OPEN', type: ChipType.warning),
                            Text('ROMEO & JULIET', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Main Stage Audition Session', style: AppTypography.headlineMd.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Slot Booking: 9:00 AM - 5:00 PM • Studio Theatre', style: AppTypography.bodyMd.copyWith(color: const Color(0xFFC4C7CA))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Called Back', 'Under Review', 'Cast'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: AppColors.deepNavy,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Candidate Roster & Notes'),
                  const SizedBox(height: 12),

                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No audition candidates found.'))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final candidate = filtered[index];

                              return StageFlowCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AvatarBadge(
                                          imageUrl: candidate.headshotUrl,
                                          name: candidate.candidateName,
                                          radius: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    candidate.candidateName,
                                                    style: AppTypography.headlineMd.copyWith(fontSize: 16),
                                                  ),
                                                  StatusChip.fromStatusString(candidate.status),
                                                ],
                                              ),
                                              Text(
                                                'Applying for: ${candidate.roleApplied}',
                                                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Time: ${candidate.timeSlot}',
                                                style: AppTypography.metadata,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).extension<StageFlowThemeExtension>()!.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.rate_review_outlined, size: 16, color: AppColors.deepNavy),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '"${candidate.directorNotes}"',
                                              style: AppTypography.bodyMd.copyWith(fontSize: 13, fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 14, color: AppColors.warningAmber),
                                              Text(
                                                '${candidate.rating}',
                                                style: AppTypography.metadata.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),

                  StageFlowButton(
                    label: '+ Register New Audition Slot',
                    variant: ButtonVariant.darkNavy,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audition slot registration form opened.')),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
