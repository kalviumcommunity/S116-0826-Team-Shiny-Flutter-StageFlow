import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/cast_member.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class CastRolesScreen extends StatefulWidget {
  final String productionId;

  const CastRolesScreen({
    super.key,
    required this.productionId,
  });

  @override
  State<CastRolesScreen> createState() => _CastRolesScreenState();
}

class _CastRolesScreenState extends State<CastRolesScreen> {
  final _repository = MockStageFlowRepository();
  List<CastMember> _castMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCast();
  }

  Future<void> _loadCast() async {
    final cast = await _repository.getCastMembers(widget.productionId);
    if (mounted) {
      setState(() {
        _castMembers = cast;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCast = _castMembers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.role.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast & Roles: Hamlet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Cast Member form opened.')),
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
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search character or actor name...',
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

                  // Cast List
                  Expanded(
                    child: filteredCast.isEmpty
                        ? const Center(child: Text('No cast members match your search.'))
                        : ListView.separated(
                            itemCount: filteredCast.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final member = filteredCast[index];
                              return StageFlowCard(
                                child: Row(
                                  children: [
                                    AvatarBadge(
                                      imageUrl: member.avatarUrl,
                                      name: member.name,
                                      radius: 24,
                                      isOnline: member.isAvailable,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                member.role,
                                                style: AppTypography.headlineMd.copyWith(fontSize: 16),
                                              ),
                                              StatusChip.fromStatusString(member.status),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            member.name,
                                            style: AppTypography.bodyLg.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.deepNavy,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${member.email} • ${member.phone}',
                                            style: AppTypography.metadata,
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
                    label: '+ Add Character Role',
                    variant: ButtonVariant.darkNavy,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New role creation sheet opened.')),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
