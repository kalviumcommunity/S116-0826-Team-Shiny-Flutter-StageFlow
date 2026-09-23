import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/production/production_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final uid = authViewModel.currentUser?.uid;
      if (uid != null) {
        context.read<ProductionsViewModel>().startWatching(uid);
      }
    });
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    final timePeriod = hour < 12
        ? 'morning'
        : hour < 17
            ? 'afternoon'
            : 'evening';
    return 'Good $timePeriod, $name';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final productionsViewModel = context.watch<ProductionsViewModel>();

    final user = authViewModel.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Thespian';
    final isDirector = user?.role == 'director';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StageSync',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryCharcoal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () {
              // Can navigate to profile tab or route
              context.go('/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user?.uid != null) {
              productionsViewModel.startWatching(user!.uid!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personalized Greeting
                Text(
                  _getGreeting(userName),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDirector
                      ? 'Manage your productions, calls, and cues.'
                      : 'View your call times, roles, and schedules.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                if (productionsViewModel.errorMessage != null) ...[
                  ErrorBanner(
                    message: productionsViewModel.errorMessage!,
                    isDismissible: true,
                    onDismiss: () => productionsViewModel.errorMessage = null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Productions Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Productions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isDirector)
                      TextButton.icon(
                        onPressed: () => context.push('/production/create'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Productions List
                _buildProductionsSection(productionsViewModel, isDirector),

                const SizedBox(height: 32),

                // Upcoming Events Section Header
                Text(
                  'Upcoming Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Upcoming Events Card Placeholder
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.spotlightAmberGlow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.spotlightAmberDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Call Times',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete cross-production schedule view is available in the Schedule tab.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isDirector
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/production/create'),
              backgroundColor: AppColors.spotlightAmber,
              foregroundColor: AppColors.primaryCharcoalDark,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Production',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildProductionsSection(
    ProductionsViewModel viewModel,
    bool isDirector,
  ) {
    if (viewModel.isLoading && viewModel.productions.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: LoadingIndicator(message: 'Loading productions...'),
        ),
      );
    }

    if (viewModel.productions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.theater_comedy_outlined,
              size: 44,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 12),
            Text(
              isDirector
                  ? 'No productions yet — create your first one!'
                  : "You haven't been added to any productions yet.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            if (isDirector) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => context.push('/production/create'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Production'),
              ),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.productions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final prod = viewModel.productions[index];
          return ProductionCard(
            production: prod,
            onTap: () {
              if (prod.id != null) {
                context.push('/production/${prod.id}');
              }
            },
          );
        },
      ),
    );
  }
}
