import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/production/production_card.dart';

class ProductionsListScreen extends StatelessWidget {
  const ProductionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final productionsViewModel = context.watch<ProductionsViewModel>();

    final user = authViewModel.currentUser;
    final isDirector = user?.role == 'director';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user?.uid != null) {
              productionsViewModel.startWatching(user!.uid!);
            }
          },
          child: _buildContent(context, productionsViewModel, isDirector),
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

  Widget _buildContent(
    BuildContext context,
    ProductionsViewModel viewModel,
    bool isDirector,
  ) {
    if (viewModel.isLoading && viewModel.productions.isEmpty) {
      return const Center(
        child: LoadingIndicator(message: 'Loading productions...'),
      );
    }

    if (viewModel.errorMessage != null && viewModel.productions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ErrorBanner(
            message: viewModel.errorMessage!,
            isDismissible: false,
          ),
        ),
      );
    }

    if (viewModel.productions.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.theater_comedy_rounded,
                  size: 44,
                  color: AppColors.textSubtle,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Productions Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isDirector
                    ? 'Start managing your play or musical by creating your first production.'
                    : "You haven't been assigned to any productions yet.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              if (isDirector) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/production/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Production'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.productions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final prod = viewModel.productions[index];
        return SizedBox(
          width: double.infinity,
          child: ProductionCard(
            production: prod,
            onTap: () {
              if (prod.id != null) {
                context.push('/production/${prod.id}');
              }
            },
          ),
        );
      },
    );
  }
}
