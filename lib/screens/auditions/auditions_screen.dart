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
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

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
    final theme = Theme.of(context);
    final filtered = _candidates.where((c) {
      return _selectedFilter == 'All' || c.status == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Auditions & Recruitment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_outlined),
            tooltip: 'Copy Application Link',
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips Row
                Container(
                  color: theme.colorScheme.surface,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'All', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Called Back', 'Called Back', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Under Review', 'Under Review', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Cast', 'Cast', theme),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.recent_actors_outlined,
                          title: 'No candidates found',
                          subtitle: 'There are no candidates matching the current filter.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final candidate = filtered[index];
                            return _buildCandidateCard(candidate, theme);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audition slot registration form opened.')),
          );
        },
        backgroundColor: AppTheme.burgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Register Candidate', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue, ThemeData theme) {
    final isSelected = _selectedFilter == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = filterValue),
      selectedColor: theme.colorScheme.primary.withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Widget _buildCandidateCard(AuditionCandidate candidate, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarBadge(
                  imageUrl: candidate.headshotUrl,
                  name: candidate.candidateName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              candidate.candidateName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          StatusChip.fromStatusString(candidate.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applying for: ${candidate.roleApplied}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            candidate.timeSlot,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (candidate.directorNotes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        candidate.directorNotes,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: AppTheme.gold),
                          const SizedBox(width: 4),
                          Text(
                            '${candidate.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
