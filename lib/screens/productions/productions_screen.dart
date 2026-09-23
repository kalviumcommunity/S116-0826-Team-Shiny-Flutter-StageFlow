import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/production.dart';
import '../../widgets/production_card.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_theme.dart';

class ProductionsScreen extends StatefulWidget {
  const ProductionsScreen({super.key});

  @override
  State<ProductionsScreen> createState() => _ProductionsScreenState();
}

class _ProductionsScreenState extends State<ProductionsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'upcoming'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Production> _filterProductions(List<Production> productions) {
    final now = DateTime.now();
    return productions.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_statusFilter == 'active') {
        // Active: currently running or ending in future
        return p.endDate.isAfter(now);
      } else if (_statusFilter == 'upcoming') {
        // Upcoming: starts in future
        return p.startDate.isAfter(now);
      } else if (_statusFilter == 'archived') {
        // Archived: ended in past
        return p.endDate.isBefore(now);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final prodProv = context.watch<ProductionProvider>();
    final schedProv = context.watch<ScheduleProvider>();

    final isDirector = auth.isDirector;
    final allProductions = prodProv.productions;
    final filtered = _filterProductions(allProductions);

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
                onPressed: () => context.push('/productions/new'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Production'),
              ),
            ),
        ],
      ),
      body: Column(
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
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search productions by title...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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
                    children: [
                      _buildFilterChip('All Shows', 'all', theme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active', theme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Upcoming', 'upcoming', theme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Archived', 'archived', theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List of Productions
          Expanded(
            child: allProductions.isEmpty
                ? EmptyState(
                    icon: Icons.theater_comedy,
                    title: 'No productions found',
                    subtitle: isDirector
                        ? 'Create your first theatrical production to start managing cast calls, roles, and dates.'
                        : 'You are not currently enrolled in any productions.',
                    actionLabel: isDirector ? 'New Production' : null,
                    onAction: isDirector ? () => context.push('/productions/new') : null,
                  )
                : filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No matches found',
                        subtitle: 'Try adjusting your search query or status filter.',
                        actionLabel: 'Clear Search',
                        onAction: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _statusFilter = 'all';
                          });
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final production = filtered[index];
                          final directorName = prodProv.usersMap[production.directorId]?.name;
                          final prodEvents = schedProv.allEvents
                              .where((e) => e.productionId == production.id)
                              .toList();
                          final upcomingEventCount = prodEvents
                              .where((e) => e.start.isAfter(DateTime.now()))
                              .length;

                          return ProductionCard(
                            production: production,
                            isDirector: isDirector,
                            directorName: directorName,
                            upcomingEventCount: upcomingEventCount,
                            onTap: () {
                              prodProv.selectProduction(production);
                              context.push('/productions/details', extra: production);
                            },
                            onEdit: () => context.push('/productions/edit', extra: production),
                            onDelete: () => _confirmDelete(context, production.id, production.title),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: isDirector && allProductions.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push('/productions/new'),
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              tooltip: 'New Production',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
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
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ProductionProvider>().deleteProduction(productionId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Production deleted' : 'Failed to delete production'),
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
