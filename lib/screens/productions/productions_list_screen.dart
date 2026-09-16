import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/production.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class ProductionsListScreen extends StatefulWidget {
  const ProductionsListScreen({super.key});

  @override
  State<ProductionsListScreen> createState() => _ProductionsListScreenState();
}

class _ProductionsListScreenState extends State<ProductionsListScreen> {
  final _repository = MockStageFlowRepository();
  List<Production> _allProductions = [];
  List<Production> _filteredProductions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchProductions();
  }

  Future<void> _fetchProductions() async {
    final prods = await _repository.getProductions();
    if (mounted) {
      setState(() {
        _allProductions = prods;
        _filteredProductions = prods;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredProductions = _allProductions.where((p) {
        final matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.director.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _selectedFilter == 'All' || p.status == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New Production wizard opened.')),
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
                  // Search Input
                  TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search production or director...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'In Rehearsal', 'Tech Week', 'Pre-Production', 'Auditions Open'].map((filter) {
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
                                _applyFilter();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionHeader(title: 'Active Season Roster'),
                  const SizedBox(height: 12),

                  // List of Productions
                  Expanded(
                    child: _filteredProductions.isEmpty
                        ? const Center(child: Text('No matching productions found.'))
                        : ListView.separated(
                            itemCount: _filteredProductions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final prod = _filteredProductions[index];
                              return StageFlowCard(
                                onTap: () => context.go('/productions/${prod.id}'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            prod.imageUrl,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 70,
                                              height: 70,
                                              color: AppColors.deepNavy,
                                              child: const Icon(Icons.theater_comedy, color: Colors.white),
                                            ),
                                          ),
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
                                                    prod.title,
                                                    style: AppTypography.headlineMd,
                                                  ),
                                                  StatusChip.fromStatusString(prod.status),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Director: ${prod.director}',
                                                style: AppTypography.bodyMd,
                                              ),
                                              Text(
                                                'Venue: ${prod.venue} • Opens ${prod.openingDate}',
                                                style: AppTypography.metadata,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${prod.totalCast} Cast Members • ${prod.totalCues} Technical Cues',
                                          style: AppTypography.metadata.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        ),
                                        Text(
                                          '${(prod.progress * 100).toInt()}% Progress',
                                          style: AppTypography.metadata.copyWith(
                                            color: AppColors.stageRed,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: prod.progress,
                                      backgroundColor: Theme.of(context).extension<StageFlowThemeExtension>()!.surfaceContainerLow,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.stageRed),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
