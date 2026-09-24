import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/production_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import '../../widgets/common/stage_kpi_card.dart';
import '../../widgets/common/timeline_event_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String? _lastWatchedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthViewModel>();
    final uid = auth.currentUser?.uid;

    if (uid != null && uid != _lastWatchedUid) {
      _lastWatchedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final prodVm = context.read<ProductionsViewModel?>();
          prodVm?.startWatching(uid);
          final schedVm = context.read<ScheduleViewModel?>();
          schedVm?.startWatching(uid);
        } catch (_) {
          // Safe when running in isolated test widget tree
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthViewModel>();
    ProductionsViewModel? prodVm;
    ScheduleViewModel? schedVm;

    try {
      prodVm = context.watch<ProductionsViewModel?>();
      schedVm = context.watch<ScheduleViewModel?>();
    } catch (_) {}

    final user = auth.currentUser;
    final userName = user?.name.split(' ').first ?? 'Director';

    final productions = prodVm?.productions ?? <ProductionModel>[];
    final scheduledItems = schedVm?.scheduledItems ?? <GlobalScheduleItem>[];

    // Filter today's events
    final now = DateTime.now();
    final todayItems = scheduledItems.where((item) {
      final d = item.event.date;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    // Calculate unique roster members across active productions
    final allMemberIds = <String>{};
    for (final prod in productions) {
      allMemberIds.addAll(prod.memberIds);
    }
    final rosterCount = allMemberIds.isNotEmpty ? allMemberIds.length : (user != null ? 1 : 0);

    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.theater_comedy, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StageSync',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Text(
                  'Home',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: subTextCol,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All production calls are up to date.')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                    ? Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryContainer,
          onRefresh: () async {
            if (_lastWatchedUid != null) {
              prodVm?.startWatching(_lastWatchedUid!);
              schedVm?.startWatching(_lastWatchedUid!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Ambient Greeting Banner
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE PRODUCTION DECK',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: subTextCol,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Good day, $userName',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Here's what's happening across your productions today.",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subTextCol,
                  ),
                ),
                const SizedBox(height: 16),

                // KPI Metrics Grid (3 Cards)
                Row(
                  children: [
                    Expanded(
                      child: StageKpiCard(
                        icon: Icons.theater_comedy,
                        tag: 'ACTIVE',
                        tagColor: AppColors.primaryContainer,
                        value: productions.length.toString(),
                        label: 'Productions',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StageKpiCard(
                        icon: Icons.event_note,
                        tag: 'TODAY',
                        tagColor: AppColors.secondaryAmber,
                        value: todayItems.length.toString(),
                        label: 'Calls Today',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StageKpiCard(
                        icon: Icons.groups,
                        tag: 'ROSTER',
                        tagColor: AppColors.tertiarySlateLight,
                        value: rosterCount.toString(),
                        label: 'Cast Roster',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upcoming Events Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Upcoming Events',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF283044) : AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Today',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subTextCol,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go('/schedule'),
                      child: Row(
                        children: [
                          Text(
                            'View Schedule',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Events List or Empty State
                if (schedVm?.isLoading ?? false)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryContainer),
                    ),
                  )
                else if (todayItems.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F36) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.event_available, size: 36, color: subTextCol.withValues(alpha: 0.6)),
                        const SizedBox(height: 8),
                        Text(
                          'No calls scheduled for today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Company calls and rehearsals will appear here automatically.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                      ],
                    ),
                  )
                else
                  ...todayItems.map(
                    (item) => TimelineEventCard(
                      event: item.event,
                      productionTitle: item.productionTitle,
                      onTap: () => context.go('/schedule'),
                    ),
                  ),

                const SizedBox(height: 26),

                // Your Productions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Productions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textCol,
                          ),
                        ),
                        Text(
                          'Current active repertory & stage schedules',
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/productions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'New',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Productions List or Empty State
                if (prodVm?.isLoading ?? false)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryContainer),
                    ),
                  )
                else if (productions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F36) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.theater_comedy, size: 40, color: subTextCol.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No productions found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create or join a production to start scheduling rehearsals and calls.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () => context.go('/productions'),
                          child: const Text('Go to Productions'),
                        ),
                      ],
                    ),
                  )
                else
                  ...productions.map((prod) => _buildProductionHomeCard(prod, context, isDark)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductionHomeCard(ProductionModel prod, BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF161F36) : Colors.white;
    final borderCol = isDark ? const Color(0xFF283044) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final startFmt = DateFormat('MMM d').format(prod.startDate);
    final endFmt = DateFormat('MMM d, y').format(prod.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Header Area
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF223042) : AppColors.surfaceHigh,
              image: prod.imageURL != null && prod.imageURL!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(prod.imageURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.secondaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        '$startFmt – $endFmt',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Active',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        prod.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (prod.id != null) {
                          context.push('/productions/${prod.id}');
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            'Manage',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryContainer),
                        ],
                      ),
                    ),
                  ],
                ),
                if (prod.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    prod.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subTextCol,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF223042) : AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups, size: 13, color: AppColors.primaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            '${prod.memberIds.length} Members',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
