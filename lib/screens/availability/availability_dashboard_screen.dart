import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/cast_member.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class AvailabilityDashboardScreen extends StatefulWidget {
  const AvailabilityDashboardScreen({super.key});

  @override
  State<AvailabilityDashboardScreen> createState() => _AvailabilityDashboardScreenState();
}

class _AvailabilityDashboardScreenState extends State<AvailabilityDashboardScreen> {
  final _repository = MockStageFlowRepository();
  List<CastMember> _members = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAvailabilityData();
  }

  Future<void> _loadAvailabilityData() async {
    final members = await _repository.getCastMembers('hamlet-1');
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = _members.where((m) {
      return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.role.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blackout dates submission tool opened.')),
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
                  // Overview Summary Banner
                  StageFlowCard(
                    backgroundColor: AppColors.deepNavy,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOverviewStat('Active Roster', '${_members.length}', Colors.white),
                        _buildOverviewStat('Available', '${_members.where((m) => m.isAvailable).length}', AppColors.successGreenBg),
                        _buildOverviewStat('Blackouts', '${_members.where((m) => !m.isAvailable).length}', AppColors.conflictRedBg),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Filter member availability...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Cast & Crew Availability Roster'),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];

                        return StageFlowCard(
                          child: Row(
                            children: [
                              AvatarBadge(
                                imageUrl: member.avatarUrl,
                                name: member.name,
                                radius: 22,
                                isOnline: member.isAvailable,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: AppTypography.headlineMd.copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      member.role,
                                      style: AppTypography.bodyMd,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildDayDot('M', true),
                                        _buildDayDot('T', true),
                                        _buildDayDot('W', member.isAvailable),
                                        _buildDayDot('T', true),
                                        _buildDayDot('F', member.isAvailable),
                                        _buildDayDot('S', false),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label: member.isAvailable ? 'AVAILABLE' : 'BLACKOUT',
                                type: member.isAvailable ? ChipType.success : ChipType.conflict,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  StageFlowButton(
                    label: '+ Submit Personal Blackout Dates',
                    variant: ButtonVariant.darkNavy,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Blackout request submitted for review.')),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDayDot(String day, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.successGreenBg : AppColors.conflictRedBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isAvailable ? AppColors.successGreenText : AppColors.conflictRedText,
          ),
        ),
      ),
    );
  }
}
