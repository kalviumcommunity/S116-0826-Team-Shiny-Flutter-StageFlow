import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/production_model.dart';
import '../../models/role_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auditions_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/events_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';
import '../../viewmodels/roles_viewmodel.dart';
import '../../widgets/common/timeline_event_card.dart';

class ProductionDetailsScreen extends StatefulWidget {
  final String productionId;

  const ProductionDetailsScreen({
    super.key,
    required this.productionId,
  });

  @override
  State<ProductionDetailsScreen> createState() => _ProductionDetailsScreenState();
}

class _ProductionDetailsScreenState extends State<ProductionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProductionModel? _cachedProduction;
  bool _isLoadingProd = true;
  String? _loadedProdId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedProdId != widget.productionId) {
      _loadedProdId = widget.productionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _initStreams();
      });
    }
  }

  Future<void> _initStreams() async {
    setState(() => _isLoadingProd = true);
    try {
      final prodVm = context.read<ProductionsViewModel?>();
      final rolesVm = context.read<RolesViewModel?>();
      final eventsVm = context.read<EventsViewModel?>();
      final audVm = context.read<AuditionsViewModel?>();

      rolesVm?.startWatching(widget.productionId);
      eventsVm?.startWatching(widget.productionId);
      audVm?.startWatching(widget.productionId);

      if (prodVm != null) {
        _cachedProduction = await prodVm.getProduction(widget.productionId);
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingProd = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRoleDialog() {
    final roleNameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add Character Role',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the character name for the cast roster.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: roleNameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Role Name',
                hintText: 'e.g. Hamlet, Ophelia, Horatio',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = roleNameCtrl.text.trim();
              if (name.isEmpty) return;
              final rolesVm = context.read<RolesViewModel?>();
              final success = await rolesVm?.addRole(widget.productionId, name) ?? false;
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Role "$name" added.'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            child: const Text('Add Role'),
          ),
        ],
      ),
    );
  }

  void _showAssignRoleDialog(RoleModel role) {
    final rolesVm = context.read<RolesViewModel?>();
    final castUsers = rolesVm?.castUsers ?? <UserModel>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF131B2E) : Colors.white;
        final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Assign Role: ${role.name}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 12),
                if (role.assignedUserId != null) ...[
                  ListTile(
                    leading: const Icon(Icons.person_remove, color: AppColors.conflictRed),
                    title: const Text('Unassign Current Performer'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (role.id != null) {
                        await rolesVm?.unassignRole(widget.productionId, role.id!);
                      }
                    },
                  ),
                  const Divider(),
                ],
                if (castUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No cast members registered yet.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: castUsers.length,
                      itemBuilder: (context, idx) {
                        final u = castUsers[idx];
                        final isAssigned = u.uid == role.assignedUserId;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          title: Text(u.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text(u.email, style: GoogleFonts.inter(fontSize: 12)),
                          trailing: isAssigned
                              ? const Icon(Icons.check_circle, color: AppColors.successGreen)
                              : null,
                          onTap: () async {
                            Navigator.pop(ctx);
                            if (role.id != null && u.uid != null) {
                              await rolesVm?.assignRole(widget.productionId, role.id!, u.uid!);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthViewModel>();
    final rolesVm = context.watch<RolesViewModel?>();
    final eventsVm = context.watch<EventsViewModel?>();
    final audVm = context.watch<AuditionsViewModel?>();

    final roles = rolesVm?.roles ?? <RoleModel>[];
    final events = eventsVm?.events ?? [];
    final auditions = audVm?.auditions ?? [];

    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (_isLoadingProd) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
        appBar: AppBar(title: const Text('Production Details')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer)),
      );
    }

    final prod = _cachedProduction;
    final startFmt = prod != null ? DateFormat('MMM d').format(prod.startDate) : 'TBD';
    final endFmt = prod != null ? DateFormat('MMM d, y').format(prod.endDate) : 'TBD';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/productions');
            }
          },
        ),
        title: Text(
          'Production Details',
          style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                auth.currentUser?.name.isNotEmpty ?? false ? auth.currentUser!.name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Production Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F36) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ACTIVE PRODUCTION',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryContainer,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF283044) : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${prod?.memberIds.length ?? 0} Members',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subTextCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prod?.title ?? 'Production Ledger',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (prod?.description.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      prod!.description,
                      style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Metadata Grid
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryContainer),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RUN DATES', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: subTextCol)),
                                Text('$startFmt – $endFmt', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textCol)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.theater_comedy, size: 16, color: AppColors.secondaryAmber),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DIRECTOR', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: subTextCol)),
                                Text('Production Lead', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textCol)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Navigation Tabs (Roles, Schedule, Auditions)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F36) : const Color(0xFFEAEDFF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF283044) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: AppColors.primaryContainer,
                unselectedLabelColor: subTextCol,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Roles'),
                        if (roles.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              roles.length.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Schedule'),
                        if (events.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              events.length.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Auditions'),
                        if (auditions.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              auditions.length.toString(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryAmber),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Roles Roster
                  _buildRolesTab(roles, rolesVm, isDark, textCol, subTextCol),

                  // Tab 2: Production Schedule
                  _buildScheduleTab(events, isDark, textCol, subTextCol),

                  // Tab 3: Production Auditions
                  _buildAuditionsTab(auditions, isDark, textCol, subTextCol),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesTab(
    List<RoleModel> roles,
    RolesViewModel? rolesVm,
    bool isDark,
    Color textCol,
    Color subTextCol,
  ) {
    return Column(
      children: [
        // Sub-header Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Character Roster (${roles.length} Roles)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddRoleDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text('Add Role', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        // List or Empty
        Expanded(
          child: rolesVm?.isLoading ?? false
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
              : roles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_outlined, size: 40, color: subTextCol.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text(
                              'No roles created yet',
                              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: textCol),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add characters to the roster to assign performers.',
                              style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _showAddRoleDialog,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Role'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: roles.length,
                      itemBuilder: (context, idx) {
                        final role = roles[idx];
                        final isAssigned = role.assignedUserId != null && role.assignedUserId!.isNotEmpty;
                        final assignedUser = rolesVm?.castUsers.where((u) => u.uid == role.assignedUserId).firstOrNull;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF161F36) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: isAssigned
                                  ? AppColors.primaryContainer
                                  : (isDark ? const Color(0xFF283044) : AppColors.surfaceHigh),
                              child: Text(
                                role.name.isNotEmpty ? role.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: isAssigned ? Colors.white : subTextCol,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  role.name,
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF283044) : AppColors.surfaceLow,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    idx == 0 ? 'Lead' : (idx < 3 ? 'Supporting' : 'Ensemble'),
                                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: subTextCol),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              isAssigned
                                  ? (assignedUser?.name ?? 'Assigned Performer')
                                  : 'Unassigned • Open Role',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isAssigned ? textCol : AppColors.secondaryAmber,
                                fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
                              ),
                            ),
                            trailing: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () => _showAssignRoleDialog(role),
                              child: Text(
                                isAssigned ? 'Reassign' : 'Assign',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(
    List dynamicEvents,
    bool isDark,
    Color textCol,
    Color subTextCol,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Production Events (${dynamicEvents.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/schedule/create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text('New Event', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: dynamicEvents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 40, color: subTextCol.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'No events scheduled',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Log rehearsal calls and production meetings for this show.',
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/schedule/create'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Event'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: dynamicEvents.length,
                  itemBuilder: (context, idx) {
                    final e = dynamicEvents[idx];
                    return TimelineEventCard(
                      event: e,
                      productionTitle: _cachedProduction?.title,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAuditionsTab(
    List dynamicAuditions,
    bool isDark,
    Color textCol,
    Color subTextCol,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Casting Calls (${dynamicAuditions.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/auditions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryAmber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.how_to_reg, size: 15),
                label: Text('Auditions Portal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: dynamicAuditions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg_outlined, size: 40, color: subTextCol.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'No auditions active',
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: textCol),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create audition calls for this production to receive signups.',
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: dynamicAuditions.length,
                  itemBuilder: (context, idx) {
                    final aud = dynamicAuditions[idx];
                    final dateFmt = DateFormat('MMM d, h:mm a').format(aud.date);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161F36) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                aud.venue,
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textCol),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warningContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  '${aud.castIds.length} Applicants',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warningText),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFmt,
                            style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
