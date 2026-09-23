import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/production.dart';
import '../../repositories/stageflow_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/production_card.dart';
import '../../widgets/empty_state.dart';

class ProductionsListScreen extends StatefulWidget {
  const ProductionsListScreen({super.key});

  @override
  State<ProductionsListScreen> createState() => _ProductionsListScreenState();
}

class _ProductionsListScreenState extends State<ProductionsListScreen> {
  final _repository = MockStageFlowRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Production> _allProductions = [];
  List<Production> _filteredProductions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'In Rehearsal',
    'Tech Week',
    'Pre-Production',
    'Auditions Open'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProductions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductions() async {
    final prods = await _repository.getProductions();
    if (mounted) {
      setState(() {
        _allProductions = prods;
        _filteredProductions = prods;
        _isLoading = false;
      });
      _applyFilter();
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
    final theme = Theme.of(context);
    final auth = context.watch<AuthViewModel>();
    final isDirector = auth.currentUser?.role.toLowerCase() == 'director';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productions'),
        actions: [
          if (isDirector)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(130, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New Production wizard opened.')),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Production'),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search & Filters Container
                Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      // Search field
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          _searchQuery = val.trim();
                          _applyFilter();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search productions by title or director...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _applyFilter();
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(filter, theme),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // List of Productions
                Expanded(
                  child: _allProductions.isEmpty
                      ? EmptyState(
                          icon: Icons.theater_comedy,
                          title: 'No productions found',
                          subtitle: isDirector
                              ? 'Create your first theatrical production to start managing cast calls, roles, and dates.'
                              : 'You are not currently enrolled in any productions.',
                          actionLabel: isDirector ? 'New Production' : null,
                          onAction: isDirector ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New Production wizard opened.')),
                            );
                          } : null,
                        )
                      : _filteredProductions.isEmpty
                          ? EmptyState(
                              icon: Icons.search_off,
                              title: 'No matches found',
                              subtitle: 'Try adjusting your search query or status filter.',
                              actionLabel: 'Clear Search',
                              onAction: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedFilter = 'All';
                                });
                                _applyFilter();
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _filteredProductions.length,
                              itemBuilder: (context, index) {
                                final production = _filteredProductions[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ProductionCard(
                                    production: production,
                                    isDirector: isDirector,
                                    directorName: production.director,
                                    venue: production.venue,
                                    castCount: production.totalCast,
                                    onTap: () => context.go('/productions/${production.id}'),
                                    onEdit: isDirector ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Edit production screen opened.')),
                                      );
                                    } : null,
                                    onDelete: isDirector ? () => _confirmDelete(context, production.id, production.title) : null,
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: isDirector && _allProductions.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New Production wizard opened.')),
                );
              },
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              tooltip: 'New Production',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, ThemeData theme) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _selectedFilter = label;
        _applyFilter();
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
        width: 1,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productionId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Production'),
        content: Text(
          'Are you sure you want to delete "$title"? This will also remove its associated roles, scheduled calls, and auditions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Not doing actual delete because MockStageFlowRepository does not implement deleteProduction yet!
              // For UI demo purposes we just show a snackbar.
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete functionality not implemented in mock repository.'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
