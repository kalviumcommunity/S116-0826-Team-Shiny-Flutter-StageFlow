import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/production.dart';
import '../../repositories/stageflow_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/status_chip.dart';

class ProductionDetailsScreen extends StatefulWidget {
  final String productionId;

  const ProductionDetailsScreen({
    super.key,
    required this.productionId,
  });

  @override
  State<ProductionDetailsScreen> createState() => _ProductionDetailsScreenState();
}

class _ProductionDetailsScreenState extends State<ProductionDetailsScreen> {
  final _repository = MockStageFlowRepository();
  Production? _production;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduction();
  }

  Future<void> _loadProduction() async {
    final prod = await _repository.getProductionById(widget.productionId);
    if (mounted) {
      setState(() {
        _production = prod;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: const Text('Production Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_production == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: const Text('Production Details')),
        body: const Center(child: Text('Production not found.')),
      );
    }

    final prod = _production!;
    final auth = context.watch<AuthViewModel>();
    final isDirector = auth.currentUser?.role.toLowerCase() == 'director';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.burgundy,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Export Schedule',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Production schedule exported.')),
                  );
                },
              ),
              if (isDirector)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Production',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit production not implemented in mock.')),
                    );
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (prod.imageUrl.isNotEmpty)
                    Image.network(
                      prod.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPosterPlaceholder(),
                    )
                  else
                    _buildPosterPlaceholder(),
                  
                  // Dark gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),

                  // Production Header Info
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                prod.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusChip.fromStatusString(prod.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              'Dir. ${prod.director}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today_outlined, size: 15, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              'Opens ${prod.openingDate}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              prod.venue,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Synopsis / Description
                  Text(
                    'Synopsis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prod.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Navigation Shortcuts Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          theme: theme,
                          title: 'Cast & Roles',
                          subtitle: 'Manage company',
                          icon: Icons.people_alt_outlined,
                          color: AppColors.deepNavy,
                          onTap: () => context.go('/productions/${prod.id}/cast'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          context: context,
                          theme: theme,
                          title: 'Schedule',
                          subtitle: 'View calls',
                          icon: Icons.calendar_today_outlined,
                          color: AppColors.stageRed,
                          onTap: () => context.go('/schedule'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Production Metrics Overview
                  Text(
                    'Production Metrics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(theme, 'Total Cast', '${prod.totalCast}', Icons.groups),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(theme, 'Tech Cues', '${prod.totalCues}', Icons.equalizer),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(theme, 'Progress', '${(prod.progress * 100).toInt()}%', Icons.check_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Key Leadership & Team
                  Text(
                    'Key Leadership',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        _buildContactTile(theme, 'Eleanor Vance', 'Director / Lead', 'eleanor@stageflow.org', true),
                        Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
                        _buildContactTile(theme, 'Julian Croft', 'Stage Manager', 'julian@stageflow.org', true),
                        Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
                        _buildContactTile(theme, 'Arjun Patel', 'Technical Director', 'arjun@stageflow.org', true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: const Color(0xFF281E24),
      child: const Center(
        child: Icon(Icons.theater_comedy, size: 64, color: Colors.white24),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppTheme.burgundy),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(ThemeData theme, String name, String role, String email, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarBadge(imageUrl: '', name: name, radius: 20, isOnline: isOnline),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$role • $email',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline, size: 20),
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
