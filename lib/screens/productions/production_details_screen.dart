import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/production.dart';
import '../../models/role_model.dart';
import '../../models/event_model.dart';
import '../../models/audition.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/role_card.dart';
import '../../widgets/event_card.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import 'role_management_dialog.dart';

class ProductionDetailsScreen extends StatefulWidget {
  final Production production;

  const ProductionDetailsScreen({super.key, required this.production});

  @override
  State<ProductionDetailsScreen> createState() => _ProductionDetailsScreenState();
}

class _ProductionDetailsScreenState extends State<ProductionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionProvider>().selectProduction(widget.production);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddRoleDialog([RoleModel? role]) {
    showDialog(
      context: context,
      builder: (ctx) => RoleManagementDialog(role: role),
    );
  }

  void _openCreateAuditionDialog(BuildContext context) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final venueController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 18, minute: 0);

    dateController.text = AppDateUtils.formatDate(selectedDate);
    timeController.text = selectedTime.format(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Audition Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Audition Date'),
                  subtitle: Text(dateController.text),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                        dateController.text = AppDateUtils.formatDate(picked);
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Time Slot'),
                  subtitle: Text(timeController.text),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedTime = picked;
                        timeController.text = picked.format(ctx);
                      });
                    }
                  },
                ),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue / Room',
                    hintText: 'e.g. Studio B or Main Stage',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 42),
              ),
              onPressed: () async {
                final venue = venueController.text.trim();
                if (venue.isEmpty) return;

                final prodProv = context.read<ProductionProvider>();
                await prodProv.createAudition(
                  date: selectedDate,
                  time: timeController.text,
                  venue: venue,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audition posted successfully!')),
                  );
                }
              },
              child: const Text('Post Audition'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicantsDialog(BuildContext context, Audition audition, ProductionProvider prodProv) {
    final applicants = audition.castIds
        .map((uid) => prodProv.usersMap[uid])
        .where((u) => u != null)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${audition.productionTitle ?? "Audition"} Applicants'),
        content: SizedBox(
          width: double.maxFinite,
          child: applicants.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No cast members have signed up yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: applicants.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final appUser = applicants[i]!;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.burgundy.withOpacity(0.12),
                        child: Text(
                          appUser.name.isNotEmpty ? appUser.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        appUser.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(appUser.email, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final auth = context.watch<AuthProvider>();
    final prodProv = context.watch<ProductionProvider>();

    final isDirector = auth.isDirector;
    final currentUserId = auth.currentUser?.id;
    final currentProd = prodProv.selectedProduction ?? widget.production;
    final roles = prodProv.currentRoles;
    final events = prodProv.currentEvents;
    final auditions = prodProv.currentAuditions;

    final directorName = prodProv.usersMap[currentProd.directorId]?.name ?? 'Director';
    final venue = events.isNotEmpty ? events.first.venue : 'Main Stage';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 230,
              pinned: true,
              title: Text(currentProd.title),
              actions: [
                if (isDirector)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Production',
                    onPressed: () => context.push('/productions/edit', extra: currentProd),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (currentProd.imageURL != null && currentProd.imageURL!.isNotEmpty)
                      Image.network(
                        currentProd.imageURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPosterPlaceholder(),
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
                      bottom: 58,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentProd.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                AppDateUtils.formatDateRange(currentProd.startDate, currentProd.endDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                'Dir. $directorName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                venue,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.burgundy,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Roles'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Auditions'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Roles
            _buildRolesTab(roles, isDirector, currentProd.id),

            // Tab 2: Schedule
            _buildScheduleTab(events, isDirector, currentProd),

            // Tab 3: Auditions
            _buildAuditionsTab(auditions, isDirector, currentUserId, currentProd, prodProv),
          ],
        ),
      ),
      floatingActionButton: isDirector
          ? FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  _openAddRoleDialog();
                } else if (_tabController.index == 1) {
                  context.push('/schedule/new', extra: currentProd);
                } else {
                  _openCreateAuditionDialog(context);
                }
              },
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              tooltip: _tabController.index == 0
                  ? 'Add Role'
                  : _tabController.index == 1
                      ? 'Schedule Call'
                      : 'Post Audition',
              child: const Icon(Icons.add),
            )
          : null,
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

  Widget _buildRolesTab(List<RoleModel> roles, bool isDirector, String prodId) {
    if (roles.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No roles defined yet',
        subtitle: isDirector
            ? 'Add character roles (e.g. Hamlet, Ophelia) and assign performers.'
            : 'No roles have been assigned yet for this production.',
        actionLabel: isDirector ? 'Add Role' : null,
        onAction: isDirector ? () => _openAddRoleDialog() : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return RoleCard(
          role: role,
          isDirector: isDirector,
          onEdit: isDirector ? () => _openAddRoleDialog(role) : null,
          onDelete: isDirector
              ? () => context.read<ProductionProvider>().deleteRole(role.id)
              : null,
        );
      },
    );
  }

  Widget _buildScheduleTab(List<EventModel> events, bool isDirector, Production prod) {
    if (events.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No scheduled calls',
        subtitle: isDirector
            ? 'Schedule rehearsals, run-throughs, or performances.'
            : 'No calls scheduled for this production yet.',
        actionLabel: isDirector ? 'Schedule Call' : null,
        onAction: isDirector ? () => context.push('/schedule/new', extra: prod) : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          isDirector: isDirector,
          onEdit: isDirector
              ? () => context.push('/schedule/edit', extra: event)
              : null,
          onDelete: isDirector
              ? () => context.read<ScheduleProvider>().deleteEvent(prod.id, event.id)
              : null,
        );
      },
    );
  }

  Widget _buildAuditionsTab(
    List<Audition> auditions,
    bool isDirector,
    String? currentUserId,
    Production prod,
    ProductionProvider prodProv,
  ) {
    final theme = Theme.of(context);

    if (auditions.isEmpty) {
      return EmptyState(
        icon: Icons.how_to_reg_outlined,
        title: 'No audition sessions',
        subtitle: isDirector
            ? 'Post audition dates and times for cast members to sign up.'
            : 'No auditions posted for this production currently.',
        actionLabel: isDirector ? 'Post Audition' : null,
        onAction: isDirector ? () => _openCreateAuditionDialog(context) : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: auditions.length,
      itemBuilder: (context, index) {
        final aud = auditions[index];
        final isSignedUp = currentUserId != null && aud.castIds.contains(currentUserId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.emerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AUDITION SESSION',
                        style: TextStyle(
                          color: AppTheme.emerald,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isDirector)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                        onPressed: () async {
                          await prodProv.deleteAudition(aud.id, prod.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Audition removed')),
                            );
                          }
                        },
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${AppDateUtils.formatDate(aud.date)} at ${aud.time}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      aud.venue,
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${aud.castIds.length} Applicant${aud.castIds.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isDirector)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(130, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 15),
                        label: const Text('View Applicants'),
                        onPressed: () => _showApplicantsDialog(context, aud, prodProv),
                      )
                    else if (isSignedUp)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 14, color: AppTheme.emerald),
                            SizedBox(width: 6),
                            Text(
                              'Signed Up',
                              style: TextStyle(
                                color: AppTheme.emerald,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (currentUserId == null) return;
                          try {
                            await prodProv.signUpForAudition(aud.id, currentUserId, prod.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully signed up for audition!'),
                                  backgroundColor: AppTheme.emerald,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: ${e.toString()}'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Sign Up'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
