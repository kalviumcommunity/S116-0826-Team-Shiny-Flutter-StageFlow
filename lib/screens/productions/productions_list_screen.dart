import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/production_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';

class ProductionsListScreen extends StatefulWidget {
  const ProductionsListScreen({super.key});

  @override
  State<ProductionsListScreen> createState() => _ProductionsListScreenState();
}

class _ProductionsListScreenState extends State<ProductionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'active'; // 'active', 'upcoming', 'archived'
  String _searchQuery = '';
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
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewProductionDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
          final sheetBg = isDark ? const Color(0xFF131B2E) : Colors.white;
          final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
          final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
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
                      'New Production',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textCol,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a production ledger for rehearsals and cast rosters.',
                      style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Production Title',
                        hintText: 'e.g. Hamlet',
                        prefixIcon: Icon(Icons.theater_comedy, size: 20),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Playwright',
                        hintText: 'e.g. William Shakespeare · Fall Repertory',
                        prefixIcon: Icon(Icons.description_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date pickers
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate: startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() => startDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              child: Text(
                                DateFormat('MMM d, y').format(startDate),
                                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate: endDate.isBefore(startDate) ? startDate : endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() => endDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                prefixIcon: Icon(Icons.event, size: 18),
                              ),
                              child: Text(
                                DateFormat('MMM d, y').format(endDate),
                                style: GoogleFonts.inter(fontSize: 13, color: textCol),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final auth = context.read<AuthViewModel>();
                              final prodVm = context.read<ProductionsViewModel?>();
                              final uid = auth.currentUser?.uid;

                              if (uid == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User not authenticated.')),
                                );
                                return;
                              }

                              final success = await prodVm?.createProduction(
                                    title: titleCtrl.text.trim(),
                                    description: descCtrl.text.trim(),
                                    startDate: startDate,
                                    endDate: endDate,
                                    directorId: uid,
                                  ) ??
                                  false;

                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }

                              if (mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Production created successfully!'),
                                      backgroundColor: AppColors.successGreen,
                                    ),
                                  );
                                } else if (prodVm?.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(prodVm!.errorMessage!),
                                      backgroundColor: AppColors.conflictRed,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Create'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ProductionsViewModel? prodVm;
    try {
      prodVm = context.watch<ProductionsViewModel?>();
    } catch (_) {}

    final allProductions = prodVm?.productions ?? <ProductionModel>[];
    final now = DateTime.now();

    // Counts for filter pills
    final activeCount = allProductions.where((p) => !p.startDate.isAfter(now) && !p.endDate.isBefore(now)).length;
    final upcomingCount = allProductions.where((p) => p.startDate.isAfter(now)).length;
    final archivedCount = allProductions.where((p) => p.endDate.isBefore(now)).length;

    // Filter productions
    List<ProductionModel> filtered = allProductions.where((p) {
      if (_selectedFilter == 'active') {
        return !p.startDate.isAfter(now) && !p.endDate.isBefore(now);
      } else if (_selectedFilter == 'upcoming') {
        return p.startDate.isAfter(now);
      } else if (_selectedFilter == 'archived') {
        return p.endDate.isBefore(now);
      }
      return true;
    }).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
      }).toList();
    }

    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
      appBar: AppBar(
        title: Text(
          'Productions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24, color: AppColors.primaryContainer),
            tooltip: 'New Production',
            onPressed: _showNewProductionDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F36) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: GoogleFonts.inter(fontSize: 13, color: textCol),
                      decoration: InputDecoration(
                        hintText: 'Search productions, plays, directors...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                        prefixIcon: Icon(Icons.search, size: 20, color: subTextCol),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: 'Active ($activeCount)',
                          filterKey: 'active',
                          isSelected: _selectedFilter == 'active',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: 'Upcoming ($upcomingCount)',
                          filterKey: 'upcoming',
                          isSelected: _selectedFilter == 'upcoming',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          label: 'Archived ($archivedCount)',
                          filterKey: 'archived',
                          isSelected: _selectedFilter == 'archived',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Section Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _selectedFilter == 'active'
                            ? 'All Active Productions'
                            : (_selectedFilter == 'upcoming' ? 'Upcoming Productions' : 'Archived Productions'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF283044) : AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          filtered.length.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subTextCol,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _showNewProductionDialog,
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryContainer),
                    label: Text(
                      'New Production',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Productions List Area
            Expanded(
              child: prodVm?.isLoading ?? false
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.theater_comedy, size: 48, color: subTextCol.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  'No productions found',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textCol,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No productions matching "$_searchQuery".'
                                      : 'Tap "New Production" to create your first production.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _showNewProductionDialog,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('New Production'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryContainer,
                          onRefresh: () async {
                            if (_lastWatchedUid != null) {
                              prodVm?.startWatching(_lastWatchedUid!);
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildProductionCard(filtered[index], isDark);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required String filterKey,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : (isDark ? const Color(0xFF1E293B) : AppColors.surfaceHigh),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildProductionCard(ProductionModel prod, bool isDark) {
    final cardBg = isDark ? const Color(0xFF161F36) : Colors.white;
    final borderCol = isDark ? const Color(0xFF283044) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final startFmt = DateFormat('MMM d').format(prod.startDate);
    final endFmt = DateFormat('MMM d, y').format(prod.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (prod.id != null) {
              context.push('/productions/${prod.id}');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Area
          Container(
            height: 100,
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
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Active Repertory',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LEDGER',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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
                Text(
                  prod.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (prod.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
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
                const SizedBox(height: 12),

                // Metrics / Chips row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF223042) : AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.groups, size: 13, color: AppColors.primaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            '${prod.memberIds.length} Cast/Crew',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF223042) : AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_outlined, size: 13, color: AppColors.secondaryAmber),
                          const SizedBox(width: 4),
                          Text(
                            'Production Active',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Footer with Manage button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cast avatar initials stack
                    Row(
                      children: [
                        for (int i = 0; i < prod.memberIds.take(3).length; i++)
                          Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: i == 0
                                  ? AppColors.primaryContainer
                                  : (i == 1 ? AppColors.tertiarySlate : AppColors.secondaryAmber),
                              child: Text(
                                'M${i + 1}',
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (prod.memberIds.length > 3)
                          Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              child: Text(
                                '+${prod.memberIds.length - 3}',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isDark ? Colors.white : AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        if (prod.id != null) {
                          context.push('/productions/${prod.id}');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        child: Row(
                          children: [
                            Text(
                              'Manage Production',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryContainer),
                          ],
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
    ),
  ),
);
  }
}
