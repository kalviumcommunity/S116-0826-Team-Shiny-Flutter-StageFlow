import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/audition_model.dart';
import '../../models/production_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auditions_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';

class AuditionsScreen extends StatefulWidget {
  final String? initialProductionId;

  const AuditionsScreen({
    super.key,
    this.initialProductionId,
  });

  @override
  State<AuditionsScreen> createState() => _AuditionsScreenState();
}

class _AuditionsScreenState extends State<AuditionsScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: My Signups
  String? _selectedProductionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final prodVm = context.read<ProductionsViewModel>();
      final uid = authVm.currentUser?.uid;

      if (prodVm.productions.isEmpty && uid != null && uid.isNotEmpty) {
        prodVm.startWatching(uid);
      }

      final initialId = widget.initialProductionId ??
          (prodVm.productions.isNotEmpty ? prodVm.productions.first.id : null);

      if (initialId != null) {
        setState(() => _selectedProductionId = initialId);
        context.read<AuditionsViewModel>().startWatching(initialId);
      }
    });
  }

  void _onProductionChanged(String? newId) {
    if (newId != null && newId != _selectedProductionId) {
      setState(() => _selectedProductionId = newId);
      context.read<AuditionsViewModel>().startWatching(newId);
    }
  }

  Future<void> _handleSignUp(AuditionModel audition, String userId) async {
    if (_selectedProductionId == null || audition.id == null) return;

    final auditionsVm = context.read<AuditionsViewModel>();
    final success = await auditionsVm.signUp(_selectedProductionId!, audition.id!, userId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully reserved audition slot: ${audition.time}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else if (auditionsVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auditionsVm.errorMessage!),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _handleWithdraw(AuditionModel audition, String userId) async {
    if (_selectedProductionId == null || audition.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Withdraw from Audition?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to release your reserved slot for ${audition.time}?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Slot'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final auditionsVm = context.read<AuditionsViewModel>();
    final success = await auditionsVm.withdraw(_selectedProductionId!, audition.id!, userId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been withdrawn from the audition slot.'),
          backgroundColor: AppColors.warningRust,
        ),
      );
    } else if (auditionsVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auditionsVm.errorMessage!),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showCreateSlotDialog(BuildContext context) {
    if (_selectedProductionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a production first.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final venueController = TextEditingController(text: 'Room 201 · Rehearsal Wing B');
    final timeController = TextEditingController(text: '3:00 PM Call');
    final capacityController = TextEditingController(text: '10');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'New Audition Slot',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderHairline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Call Time',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(hintText: 'e.g. 3:00 PM Call'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Venue',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(hintText: 'e.g. Room 201'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Capacity Limit (optional)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 10'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final venue = venueController.text.trim();
                final time = timeController.text.trim();
                final cap = int.tryParse(capacityController.text.trim());

                if (venue.isEmpty || time.isEmpty) return;

                final newAudition = AuditionModel(
                  date: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                  time: time,
                  venue: venue,
                  venueKey: AuditionModel.normalizeVenue(venue),
                  castIds: const <String>[],
                  capacity: cap,
                  status: 'open',
                );

                final audVm = context.read<AuditionsViewModel>();
                final prodId = _selectedProductionId!;
                final messenger = ScaffoldMessenger.of(context);

                Navigator.of(ctx).pop();

                final success = await audVm.createAudition(prodId, newAudition);

                if (mounted && success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Audition slot opened on company callboard.'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              },
              child: const Text('Publish Slot'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final authVm = context.watch<AuthViewModel>();
    final prodVm = context.watch<ProductionsViewModel>();
    final auditionsVm = context.watch<AuditionsViewModel>();

    final currentUser = authVm.currentUser;
    final currentUserId = currentUser?.uid;
    final isDirector = currentUser?.role.toLowerCase() == 'director' ||
        currentUser?.role.toLowerCase() == 'stage_manager';

    // Default selected production fallback
    final effectiveProdId = _selectedProductionId ??
        (prodVm.productions.isNotEmpty ? prodVm.productions.first.id : null);
    if (_selectedProductionId == null && effectiveProdId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedProductionId == null) {
          setState(() => _selectedProductionId = effectiveProdId);
          context.read<AuditionsViewModel>().startWatching(effectiveProdId);
        }
      });
    }

    ProductionModel? currentProd;
    try {
      currentProd = prodVm.productions.firstWhere((p) => p.id == _selectedProductionId);
    } catch (_) {
      currentProd = prodVm.productions.isNotEmpty ? prodVm.productions.first : null;
    }

    final allAuditions = auditionsVm.auditions;
    final mySignupsCount = currentUserId != null
        ? allAuditions.where((a) => a.castIds.contains(currentUserId)).length
        : 0;

    final displayedAuditions = _selectedTabIndex == 1
        ? allAuditions
            .where((a) => currentUserId != null && a.castIds.contains(currentUserId))
            .toList()
        : allAuditions;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.theater_comedy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StageSync',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Productions & Casting',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: subTextCol,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (isDirector)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'New Audition Slot',
              onPressed: () => _showCreateSlotDialog(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedProductionId != null) {
            auditionsVm.startWatching(_selectedProductionId!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header & Context
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auditions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Casting calls & active sign-up rosters',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: subTextCol,
                        ),
                      ),
                    ],
                  ),
                  if (prodVm.productions.length > 1)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProductionId,
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        items: prodVm.productions.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(
                              p.title,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: _onProductionChanged,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Filter Switch: Upcoming vs My Signups
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Upcoming',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: _selectedTabIndex == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedTabIndex == 0 ? textCol : subTextCol,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'My Signups',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == 1 ? textCol : subTextCol,
                                ),
                              ),
                              if (mySignupsCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$mySignupsCount',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Quick Callout Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryWarmAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.secondaryAmber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sides & cold readings released 24h before call time.',
                        style: GoogleFonts.inter(fontSize: 12, color: textCol),
                      ),
                    ),
                    Text(
                      'Rules',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Auditions List
              if (auditionsVm.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (displayedAuditions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.how_to_reg, size: 48, color: subTextCol.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      Text(
                        _selectedTabIndex == 1
                            ? 'No Auditions Reserved'
                            : 'No Audition Slots Open',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedTabIndex == 1
                            ? 'You have not signed up for any audition calls in this production yet.'
                            : 'Check back later or contact stage management for casting calls.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                      ),
                      if (isDirector && _selectedTabIndex == 0) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateSlotDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Audition Slot'),
                        ),
                      ],
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedAuditions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final audition = displayedAuditions[index];
                    final isUserSignedUp =
                        currentUserId != null && audition.castIds.contains(currentUserId);
                    final isFull = audition.isFull;

                    return Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left color indicator and top meta row
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Block
                                Container(
                                  width: 48,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderCol),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('MMM').format(audition.date).toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryCrimson,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd').format(audition.date),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: textCol,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              currentProd?.title ?? 'Audition Call',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: textCol,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDirector
                                                  ? AppColors.secondaryAmber.withValues(alpha: 0.12)
                                                  : (isUserSignedUp
                                                      ? AppColors.successContainer
                                                      : (isDark
                                                          ? const Color(0xFF334155)
                                                          : const Color(0xFFF1F5F9))),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              isDirector
                                                  ? 'Director View'
                                                  : (isUserSignedUp
                                                      ? 'Reserved'
                                                      : (isFull ? 'Full' : 'Open')),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: isDirector
                                                    ? AppColors.secondaryAmber
                                                    : (isUserSignedUp
                                                        ? AppColors.successGreen
                                                        : subTextCol),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            size: 13,
                                            color: AppColors.primaryCrimson,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            audition.time,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: subTextCol,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.meeting_room,
                                            size: 13,
                                            color: AppColors.secondaryAmber,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              audition.venue,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: subTextCol,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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

                          // Specs Grid
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Applicants',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: subTextCol,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        audition.capacity != null
                                            ? '${audition.castIds.length} / ${audition.capacity} signed up'
                                            : '${audition.castIds.length} registered',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: textCol,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: subTextCol,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        audition.isOpen ? 'Accepting Signups' : 'Slot Closed',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: audition.isOpen
                                              ? AppColors.successGreen
                                              : AppColors.errorRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Action CTA
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: isDirector
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${audition.castIds.length} applicant(s) registered for this slot.',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.group, size: 16),
                                          label: Text(
                                            'View Roster (${audition.castIds.length})',
                                            style: GoogleFonts.inter(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : isUserSignedUp
                                    ? SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.successGreen,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            _handleWithdraw(audition, currentUserId);
                                          },
                                          icon: const Icon(Icons.check_circle, size: 18),
                                          label: Text(
                                            '✓ Signed Up (Tap to withdraw)',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          onPressed: (!audition.isOpen || currentUserId == null)
                                              ? null
                                              : () => _handleSignUp(audition, currentUserId),
                                          icon: const Icon(Icons.how_to_reg, size: 18),
                                          label: Text(
                                            isFull ? 'Slot Full' : 'Sign Up for Audition',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // General Audition Guidelines Section Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment,
                              size: 18,
                              color: AppColors.tertiarySlate,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'General Audition Guidelines',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textCol,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Equity & Non-Eq',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please arrive at least 15 minutes ahead of your reserved time slot. Bring two physical headshots with updated resumes stapled back-to-back. Accompanist provided for vocal auditions.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subTextCol,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
