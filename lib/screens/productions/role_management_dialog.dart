import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/role_model.dart';
import '../../providers/production_provider.dart';
import '../../utils/validators.dart';

class RoleManagementDialog extends StatefulWidget {
  final RoleModel? role;

  const RoleManagementDialog({super.key, this.role});

  @override
  State<RoleManagementDialog> createState() => _RoleManagementDialogState();
}

class _RoleManagementDialogState extends State<RoleManagementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedUserId;

  bool get isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _selectedUserId = widget.role!.assignedUserId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final prodProv = context.read<ProductionProvider>();
    final roleName = _nameController.text.trim();

    if (isEditing) {
      await prodProv.updateRole(widget.role!.id, roleName, _selectedUserId);
    } else {
      await prodProv.addRole(roleName, _selectedUserId);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductionProvider>();
    final allUsers = prodProv.allUsers;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Role' : 'Add New Role'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Character / Role Name',
                  hintText: 'e.g. Hamlet, Ophelia, Claudius',
                ),
                validator: (v) => Validators.required(v, 'Role name is required'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assign Cast Member',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Unassigned (Open Role)'),
                  ),
                  ...allUsers.map((user) {
                    final roleTag = user.isDirector ? ' (Director)' : '';
                    return DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text('${user.name}$roleTag'),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedUserId = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 42),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
