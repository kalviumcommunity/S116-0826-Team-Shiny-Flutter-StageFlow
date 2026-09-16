import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/production.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
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
        appBar: AppBar(title: const Text('Production Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_production == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Production Details')),
        body: const Center(child: Text('Production not found.')),
      );
    }

    final prod = _production!;

    return Scaffold(
      appBar: AppBar(
        title: Text(prod.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Production schedule exported.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Production Hero Card
            StageFlowCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        prod.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: AppColors.deepNavy,
                          child: const Icon(Icons.theater_comedy, size: 60, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: StatusChip.fromStatusString(prod.status),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prod.title, style: AppTypography.display.copyWith(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(prod.description, style: AppTypography.bodyMd),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetaDetail('DIRECTOR', prod.director),
                            _buildMetaDetail('VENUE', prod.venue),
                            _buildMetaDetail('OPENING', prod.openingDate),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Shortcuts Grid
            Row(
              children: [
                Expanded(
                  child: StageFlowButton(
                    label: 'Cast & Roles',
                    variant: ButtonVariant.darkNavy,
                    icon: Icons.people_outline,
                    onPressed: () => context.go('/productions/${prod.id}/cast'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StageFlowButton(
                    label: 'Schedule',
                    variant: ButtonVariant.secondary,
                    icon: Icons.calendar_today_outlined,
                    onPressed: () => context.go('/schedule'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Production Metrics Overview
            const SectionHeader(title: 'Production Metrics'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile('Total Cast', '${prod.totalCast}', Icons.groups),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile('Tech Cues', '${prod.totalCues}', Icons.equalizer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile('Progress', '${(prod.progress * 100).toInt()}%', Icons.check_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Key Leadership Contacts
            const SectionHeader(title: 'Key Leadership & Team'),
            const SizedBox(height: 12),
            StageFlowCard(
              child: Column(
                children: [
                  _buildContactTile('Eleanor Vance', 'Director / Lead', 'eleanor@stageflow.org', true),
                  const Divider(height: 12),
                  _buildContactTile('Julian Croft', 'Stage Manager', 'julian@stageflow.org', true),
                  const Divider(height: 12),
                  _buildContactTile('Arjun Patel', 'Technical Director', 'arjun@stageflow.org', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.metadata),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return StageFlowCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.stageRed),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.headlineLg.copyWith(fontSize: 20)),
          Text(label, style: AppTypography.metadata),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String role, String email, bool isOnline) {
    return Row(
      children: [
        AvatarBadge(imageUrl: '', name: name, radius: 18, isOnline: isOnline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.bodyLg.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('$role • $email', style: AppTypography.metadata),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.mail_outline, size: 20, color: AppColors.deepNavy),
          onPressed: () {},
        ),
      ],
    );
  }
}
