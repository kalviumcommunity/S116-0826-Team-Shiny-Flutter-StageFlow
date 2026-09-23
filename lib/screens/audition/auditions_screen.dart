import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auditions_viewmodel.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class AuditionsScreen extends StatelessWidget {
  final String prodId;

  const AuditionsScreen({super.key, required this.prodId});

  void _showCreateAuditionDialog(
    BuildContext context,
    AuditionsViewModel auditionsVm,
  ) {
    DateTime auditionDate = DateTime.now();
    TimeOfDay auditionTime = const TimeOfDay(hour: 14, minute: 0);
    final venueController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Schedule Audition Slot',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: auditionDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setSheetState(() => auditionDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          suffixIcon:
                              Icon(Icons.calendar_today_rounded, size: 20),
                        ),
                        child: Text(
                          dateFormat.format(auditionDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: auditionTime,
                        );
                        if (picked != null) {
                          setSheetState(() => auditionTime = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time *',
                          suffixIcon: Icon(Icons.access_time_rounded, size: 20),
                        ),
                        child: Text(
                          auditionTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: venueController,
                      decoration: const InputDecoration(
                        labelText: 'Venue *',
                        hintText: 'e.g. Green Room, Studio 3',
                      ),
                      validator: (val) {
                        if ((val ?? '').trim().isEmpty) {
                          return 'Venue is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Create Slot',
                      onPressed: () async {
                        if (formKey.currentState?.validate() == true) {
                          final audition = AuditionModel(
                            date: DateTime.utc(
                              auditionDate.year,
                              auditionDate.month,
                              auditionDate.day,
                            ),
                            time: auditionTime.format(context),
                            venue: venueController.text.trim(),
                            venueKey: AuditionModel.normalizeVenue(
                              venueController.text,
                            ),
                            castIds: const [],
                          );
                          final success = await auditionsVm.createAudition(
                            prodId,
                            audition,
                          );
                          if (success && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auditionsVm = context.watch<AuditionsViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;
    final isDirector = user?.role == 'director';
    final currentUserId = user?.uid;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    if (auditionsVm.isLoading && auditionsVm.auditions.isEmpty) {
      return const Center(
        child: LoadingIndicator(message: 'Loading auditions...'),
      );
    }

    return Column(
      children: [
        if (auditionsVm.errorMessage != null) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ErrorBanner(
              message: auditionsVm.errorMessage!,
              isDismissible: true,
              onDismiss: () => auditionsVm.errorMessage = null,
            ),
          ),
        ],
        if (isDirector)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${auditionsVm.auditions.length} Audition Slots',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showCreateAuditionDialog(context, auditionsVm),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Slot'),
                ),
              ],
            ),
          ),
        Expanded(
          child: auditionsVm.auditions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.how_to_reg_outlined,
                          size: 48,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No auditions scheduled',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDirector
                              ? 'Tap "+ Add Slot" to open audition time slots for actors.'
                              : 'Open audition slots will appear here for you to sign up.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: auditionsVm.auditions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final audition = auditionsVm.auditions[index];
                    final isSignedUp = currentUserId != null &&
                        audition.castIds.contains(currentUserId);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormat.format(audition.date),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.spotlightAmberGlow,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    audition.time,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.spotlightAmberDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    audition.venue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (isDirector) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.group_outlined,
                                    size: 16,
                                    color: AppColors.spotlightAmberDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${audition.castIds.length} auditionee(s) signed up',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Cast Action
                              if (isSignedUp)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreenContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 18,
                                        color: AppColors.successGreen,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "You're signed up",
                                        style: TextStyle(
                                          color: AppColors.successGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                PrimaryButton(
                                  label: 'Sign Up for Slot',
                                  height: 42,
                                  isLoading: auditionsVm.isLoading,
                                  onPressed: () async {
                                    if (currentUserId != null &&
                                        audition.id != null) {
                                      await auditionsVm.signUp(
                                        prodId,
                                        audition.id!,
                                        currentUserId,
                                      );
                                    }
                                  },
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
