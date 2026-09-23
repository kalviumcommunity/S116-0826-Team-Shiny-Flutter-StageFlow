import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/audition.dart';
import '../../models/production.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_provider.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import 'create_audition_dialog.dart';

class AuditionsScreen extends StatefulWidget {
  const AuditionsScreen({super.key});

  @override
  State<AuditionsScreen> createState() => _AuditionsScreenState();
}

class _AuditionsScreenState extends State<AuditionsScreen> {
  String? _selectedProdId; // null = all productions

  void _openCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CreateAuditionDialog(initialProductionId: _selectedProdId),
    );
  }

  void _showApplicantsSheet(BuildContext context, Audition audition, ProductionProvider prodProv) {
    final applicants = audition.castIds
        .map((uid) => prodProv.usersMap[uid])
        .where((u) => u != null)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${audition.productionTitle ?? "Audition"} Applicants',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '${audition.castIds.length} Performer${audition.castIds.length == 1 ? '' : 's'} signed up',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              if (applicants.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No cast members have signed up yet.'),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: applicants.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final actor = applicants[i]!;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.burgundy.withOpacity(0.12),
                          child: Text(
                            actor.name.isNotEmpty ? actor.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppTheme.burgundy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(actor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(actor.email, style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final prodProv = context.watch<ProductionProvider>();

    final isDirector = auth.isDirector;
    final currentUserId = auth.currentUser?.id ?? '';

    final allAuditions = prodProv.allAuditions;
    final displayedAuditions = _selectedProdId == null
        ? allAuditions
        : allAuditions.where((a) => a.productionId == _selectedProdId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audition Sessions'),
        actions: [
          if (isDirector)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () => _openCreateDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Post Audition'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Production Filter Chips
          if (prodProv.productions.isNotEmpty)
            Container(
              color: theme.colorScheme.surface,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Productions'),
                      selected: _selectedProdId == null,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedProdId = null);
                      },
                      selectedColor: theme.colorScheme.primary.withOpacity(0.12),
                      side: BorderSide(
                        color: _selectedProdId == null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...prodProv.productions.map((p) {
                      final isSelected = _selectedProdId == p.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.title),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedProdId = selected ? p.id : null);
                          },
                          selectedColor: theme.colorScheme.primary.withOpacity(0.12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          const Divider(height: 1),

          // Audition list
          Expanded(
            child: displayedAuditions.isEmpty
                ? EmptyState(
                    icon: Icons.how_to_reg_outlined,
                    title: 'No audition sessions found',
                    subtitle: isDirector
                        ? 'Post open audition dates for actors to sign up for roles.'
                        : 'There are no active audition calls for this selection.',
                    actionLabel: isDirector ? 'Post Audition' : null,
                    onAction: isDirector ? () => _openCreateDialog(context) : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: displayedAuditions.length,
                    itemBuilder: (context, index) {
                      final audition = displayedAuditions[index];
                      final isSignedUp = audition.isUserSignedUp(currentUserId);
                      final displayProdTitle = audition.productionTitle ??
                          prodProv.productions
                              .firstWhere(
                                (p) => p.id == audition.productionId,
                                orElse: () => Production(
                                  id: '',
                                  title: 'Production',
                                  description: '',
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now(),
                                  directorId: '',
                                ),
                              )
                              .title;

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
                                      'AUDITION CALL',
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
                                        await prodProv.deleteAudition(audition.id, audition.productionId);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Audition deleted')),
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
                              Text(
                                displayProdTitle,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppDateUtils.formatDate(audition.date),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.access_time, size: 14, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    audition.time,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    audition.venue,
                                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${audition.castIds.length} Applicant${audition.castIds.length == 1 ? '' : 's'}',
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
                                      onPressed: () => _showApplicantsSheet(context, audition, prodProv),
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
                                        if (currentUserId.isEmpty) return;
                                        try {
                                          await prodProv.signUpForAudition(
                                            audition.id,
                                            currentUserId,
                                            audition.productionId,
                                          );
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
                  ),
          ),
        ],
      ),
      floatingActionButton: isDirector && displayedAuditions.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _openCreateDialog(context),
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              tooltip: 'Post Audition',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
