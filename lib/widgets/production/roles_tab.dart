import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class RolesTab extends StatelessWidget {
  final String prodId;

  const RolesTab({super.key, required this.prodId});

  void _showAddRoleDialog(BuildContext context, RolesViewModel rolesVm) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Role',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Role / Character Name *',
                    hintText: 'e.g. Juliet, Stage Manager, Lighting Tech',
                  ),
                  validator: (val) {
                    if ((val ?? '').trim().isEmpty) {
                      return 'Role name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Add Role',
                  onPressed: () async {
                    if (formKey.currentState?.validate() == true) {
                      final success = await rolesVm.addRole(
                        prodId,
                        nameController.text.trim(),
                      );
                      if (success && bottomSheetContext.mounted) {
                        Navigator.of(bottomSheetContext).pop();
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
  }

  void _showAssignRoleDialog(
    BuildContext context,
    RolesViewModel rolesVm,
    RoleModel role,
  ) {
    String? selectedUserId = role.assignedUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Assign "${role.name}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (rolesVm.castUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No cast accounts found in StageSync. Actors can register with the Cast Member role.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: rolesVm.castUsers
                              .any((u) => u.uid == selectedUserId)
                          ? selectedUserId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Cast Member',
                      ),
                      items: [
                        ...rolesVm.castUsers.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.uid,
                            child: Text(
                                user.name.isNotEmpty ? user.name : user.email),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedUserId = val;
                        });
                      },
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (role.assignedUserId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.conflictRed,
                              side: const BorderSide(
                                  color: AppColors.conflictRed),
                            ),
                            onPressed: () async {
                              if (role.id != null) {
                                await rolesVm.unassignRole(prodId, role.id!);
                              }
                              if (bottomSheetContext.mounted) {
                                Navigator.of(bottomSheetContext).pop();
                              }
                            },
                            child: const Text('Unassign'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: PrimaryButton(
                          label: 'Save',
                          onPressed: selectedUserId == null || role.id == null
                              ? null
                              : () async {
                                  await rolesVm.assignRole(
                                    prodId,
                                    role.id!,
                                    selectedUserId!,
                                  );
                                  if (bottomSheetContext.mounted) {
                                    Navigator.of(bottomSheetContext).pop();
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
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
    final rolesVm = context.watch<RolesViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final isDirector = authVm.currentUser?.role == 'director';

    if (rolesVm.isLoading && rolesVm.roles.isEmpty) {
      return const Center(
        child: LoadingIndicator(message: 'Loading production roles...'),
      );
    }

    return Column(
      children: [
        if (rolesVm.errorMessage != null) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ErrorBanner(
              message: rolesVm.errorMessage!,
              isDismissible: true,
              onDismiss: () => rolesVm.errorMessage = null,
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
                  '${rolesVm.roles.length} Roles Defined',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddRoleDialog(context, rolesVm),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Role'),
                ),
              ],
            ),
          ),
        Expanded(
          child: rolesVm.roles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_ind_outlined,
                          size: 48,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No roles added yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDirector
                              ? 'Tap "+ Add Role" to create characters and crew assignments.'
                              : 'Roles will appear here once added by the director.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rolesVm.roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final role = rolesVm.roles[index];
                    final assignedUser =
                        rolesVm.castUsers.cast<UserModel?>().firstWhere(
                              (u) => u?.uid == role.assignedUserId,
                              orElse: () => null,
                            );

                    final isAssigned = role.assignedUserId != null;
                    final assignedName = assignedUser != null
                        ? assignedUser.name
                        : (isAssigned ? 'Assigned' : 'Unassigned');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAssigned
                              ? AppColors.spotlightAmberGlow
                              : AppColors.surfaceCard,
                          child: Icon(
                            isAssigned
                                ? Icons.person
                                : Icons.person_outline_rounded,
                            color: isAssigned
                                ? AppColors.spotlightAmberDark
                                : AppColors.textSubtle,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          role.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          assignedName,
                          style: TextStyle(
                            color: isAssigned
                                ? AppColors.textDark
                                : AppColors.textSubtle,
                            fontStyle: isAssigned
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                        trailing: isDirector
                            ? IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Assign or edit role',
                                onPressed: () => _showAssignRoleDialog(
                                  context,
                                  rolesVm,
                                  role,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
