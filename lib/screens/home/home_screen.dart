import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/production.dart';
import '../../models/event_model.dart';
import '../../models/audition.dart';
import '../../widgets/event_card.dart';
import '../../widgets/production_card.dart';
import '../../widgets/empty_state.dart';

import '../../utils/date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<ProductionProvider>().fetchInitialData(
              auth.currentUser!.id,
              auth.isDirector,
            );
      }
    });
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    String prefix = 'Good morning';
    if (hour >= 12 && hour < 17) {
      prefix = 'Good afternoon';
    } else if (hour >= 17) {
      prefix = 'Good evening';
    }
    return '$prefix, $name';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final prodProv = context.watch<ProductionProvider>();
    final schedProv = context.watch<ScheduleProvider>();

    final user = auth.currentUser;
    final isDirector = auth.isDirector;
    final productions = prodProv.productions;
    final filteredEvents = schedProv.getFilteredEvents(
      castUserId: isDirector ? null : user?.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null ? _getGreeting(user.name.split(' ').first) : 'StageSync',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
            ),
            const SizedBox(height: 2),
            Text(
              isDirector ? 'Director Dashboard' : 'Cast Member Dashboard',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (isDirector)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'New Production',
                onPressed: () => context.push('/productions/new'),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            prodProv.fetchInitialData(user.id, isDirector);
          }
        },
        child: isDirector
            ? _buildDirectorView(theme, productions, filteredEvents, prodProv)
            : _buildCastView(theme, user?.id, productions, filteredEvents, prodProv),
      ),
    );
  }

  // ==========================================
  // DIRECTOR DASHBOARD VIEW
  // ==========================================
  Widget _buildDirectorView(
    ThemeData theme,
    List<Production> productions,
    List<EventModel> filteredEvents,
    ProductionProvider prodProv,
  ) {
    final castMembersCount = prodProv.allUsers.where((u) => u.isCast).length;
    final nextEvent = filteredEvents.isNotEmpty ? filteredEvents.first : null;

    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        // Quick Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.add,
                  label: 'New Show',
                  onTap: () => context.push('/productions/new'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.calendar_today_outlined,
                  label: 'Schedule Call',
                  onTap: () {
                    if (productions.isNotEmpty) {
                      context.push('/schedule/new', extra: productions.first);
                    } else {
                      context.push('/productions/new');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.how_to_reg_outlined,
                  label: 'Auditions',
                  onTap: () => context.push('/auditions'),
                ),
              ),
            ],
          ),
        ),

        // Stat Cards Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.theater_comedy,
                  label: 'Active Shows',
                  value: '${productions.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.calendar_today_outlined,
                  label: 'Upcoming Calls',
                  value: '${filteredEvents.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.people_outline,
                  label: 'Cast Members',
                  value: '$castMembersCount',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Spotlight: Next Upcoming Call
        if (nextEvent != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Upcoming Call',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/schedule'),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          EventCard(
            event: nextEvent,
            isDirector: true,
            onEdit: () => context.push('/schedule/edit', extra: nextEvent),
          ),
          const SizedBox(height: 12),
        ],

        // Upcoming Events List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/schedule'),
                child: const Text('Full Schedule'),
              ),
            ],
          ),
        ),
        if (filteredEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Center(
                child: Text(
                  'No upcoming rehearsals or performances scheduled',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ),
          )
        else
          ...filteredEvents.take(3).map(
                (e) => EventCard(
                  event: e,
                  isDirector: true,
                  onEdit: () => context.push('/schedule/edit', extra: e),
                ),
              ),

        const SizedBox(height: 16),

        // Active Productions List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Productions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/productions'),
                child: const Text('All Shows'),
              ),
            ],
          ),
        ),
        if (productions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: EmptyState(
              icon: Icons.theater_comedy,
              title: 'No Active Productions',
              subtitle: 'Create a new theatrical production to begin scheduling rehearsals and assigning roles.',
              actionLabel: 'New Production',
              onAction: () => context.push('/productions/new'),
            ),
          )
        else
          ...productions.take(3).map(
                (p) => ProductionCard(
                  production: p,
                  isDirector: true,
                  directorName: prodProv.usersMap[p.directorId]?.name,
                  onTap: () => context.push('/productions/details', extra: p),
                  onEdit: () => context.push('/productions/edit', extra: p),
                ),
              ),
      ],
    );
  }

  // ==========================================
  // CAST MEMBER DASHBOARD VIEW
  // ==========================================
  Widget _buildCastView(
    ThemeData theme,
    String? userId,
    List<Production> productions,
    List<EventModel> filteredEvents,
    ProductionProvider prodProv,
  ) {
    final nextEvent = filteredEvents.isNotEmpty ? filteredEvents.first : null;
    final availableAuditions = prodProv.allAuditions;

    return ListView(
      padding: const EdgeInsets.only(bottom: 36),
      children: [
        // Quick Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.calendar_month_outlined,
                  label: 'My Schedule',
                  onTap: () => context.go('/schedule'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.how_to_reg_outlined,
                  label: 'Auditions',
                  onTap: () => context.push('/auditions'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  theme: theme,
                  icon: Icons.theater_comedy,
                  label: 'Shows',
                  onTap: () => context.go('/productions'),
                ),
              ),
            ],
          ),
        ),

        // Stat Cards Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.calendar_today_outlined,
                  label: 'Your Calls',
                  value: '${filteredEvents.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.theater_comedy,
                  label: 'Your Shows',
                  value: '${productions.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  icon: Icons.how_to_reg_outlined,
                  label: 'Open Auditions',
                  value: '${availableAuditions.length}',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Spotlight: Next Upcoming Call
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Text(
            'Your Next Call',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (nextEvent != null)
          EventCard(event: nextEvent, isDirector: false)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No calls scheduled for you right now. You are clear!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Assigned Shows & Roles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Productions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/productions'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        if (productions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Text(
                'You have not been assigned to any productions yet.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          )
        else
          ...productions.take(2).map(
                (p) => ProductionCard(
                  production: p,
                  isDirector: false,
                  directorName: prodProv.usersMap[p.directorId]?.name,
                  onTap: () => context.push('/productions/details', extra: p),
                ),
              ),

        const SizedBox(height: 16),

        // Upcoming Personal Schedule
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/schedule'),
                child: const Text('Full Schedule'),
              ),
            ],
          ),
        ),
        if (filteredEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Text(
                'No upcoming events on your calendar.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          )
        else
          ...filteredEvents.take(3).map((e) => EventCard(event: e, isDirector: false)),

        const SizedBox(height: 16),

        // Available Auditions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Auditions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/auditions'),
                child: const Text('Audition Board'),
              ),
            ],
          ),
        ),
        if (availableAuditions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: const Text(
                'No open auditions currently posted.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          )
        else
          ...availableAuditions.take(2).map(
                (aud) => _buildAuditionCard(theme, aud, userId, prodProv),
              ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditionCard(
    ThemeData theme,
    Audition audition,
    String? userId,
    ProductionProvider prodProv,
  ) {
    final isSignedUp = userId != null && audition.castIds.contains(userId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.how_to_reg_outlined,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audition.productionTitle ?? 'General Audition',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppDateUtils.formatDate(audition.date)} • ${audition.venue}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isSignedUp)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'Signed Up',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  if (userId == null) return;
                  try {
                    await prodProv.signUpForAudition(audition.id, userId, audition.productionId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully signed up for audition!'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
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
      ),
    );
  }
}
