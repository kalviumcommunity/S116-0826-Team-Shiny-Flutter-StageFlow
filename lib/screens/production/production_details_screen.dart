import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/screens/audition/auditions_screen.dart';
import 'package:stagesync/screens/production/schedule_tab.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auditions_viewmodel.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/production/roles_tab.dart';

class ProductionDetailsScreen extends StatefulWidget {
  final String prodId;

  const ProductionDetailsScreen({super.key, required this.prodId});

  @override
  State<ProductionDetailsScreen> createState() =>
      _ProductionDetailsScreenState();
}

class _ProductionDetailsScreenState extends State<ProductionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProductionModel? _production;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProductionData();
  }

  void _loadProductionData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prodVm = context.read<ProductionsViewModel>();
      final existing = prodVm.productions.where((p) => p.id == widget.prodId);

      if (existing.isNotEmpty) {
        setState(() {
          _production = existing.first;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
        final fetched = await prodVm.getProduction(widget.prodId);
        if (mounted) {
          setState(() {
            _production = fetched;
            _isLoading = false;
          });
        }
      }

      // Initialize feature viewmodels for this production
      if (mounted) {
        context.read<RolesViewModel>().startWatching(widget.prodId);
        context.read<EventsViewModel>().startWatching(widget.prodId);
        context.read<AuditionsViewModel>().startWatching(widget.prodId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Production?'),
          content: const Text(
            'This will permanently delete this production, its roles, scheduled events, and auditions. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.conflictRed,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;
    final prodVm = context.read<ProductionsViewModel>();
    final success = await prodVm.deleteProduction(widget.prodId);
    if (!mounted) return;
    if (success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVm = context.watch<AuthViewModel>();
    final isDirector = authVm.currentUser?.role == 'director' &&
        _production?.directorId == authVm.currentUser?.uid;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Production')),
        body: const Center(
          child: LoadingIndicator(message: 'Loading production details...'),
        ),
      );
    }

    if (_production == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Production Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Production not found.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDateRange =
        '${dateFormat.format(_production!.startDate)} – ${dateFormat.format(_production!.endDate)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _production!.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isDirector) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Production',
              onPressed: () async {
                await context.push('/production/edit/${widget.prodId}');
                _loadProductionData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.conflictRed),
              tooltip: 'Delete Production',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster image thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 88,
                            height: 118,
                            color: AppColors.primaryCharcoalLight,
                            child: _production!.imageURL != null &&
                                    _production!.imageURL!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _production!.imageURL!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child: Icon(
                                        Icons.theater_comedy_rounded,
                                        size: 36,
                                        color: AppColors.spotlightAmber,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.theater_comedy_rounded,
                                      size: 36,
                                      color: AppColors.spotlightAmber,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _production!.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      formattedDateRange,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.group_outlined,
                                    size: 15,
                                    color: AppColors.spotlightAmberDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${_production!.memberIds.length} members involved',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_production!.description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        _production!.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.spotlightAmber,
                  labelColor: AppColors.primaryCharcoalDark,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Roles'),
                    Tab(text: 'Schedule'),
                    Tab(text: 'Auditions'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            RolesTab(prodId: widget.prodId),
            ScheduleTab(prodId: widget.prodId),
            AuditionsScreen(prodId: widget.prodId),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surfaceWhite,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
