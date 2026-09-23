import 'package:flutter/material.dart';
import '../models/role_model.dart';


class RoleCard extends StatelessWidget {
  final RoleModel role;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDirector;

  const RoleCard({
    super.key,
    required this.role,
    this.onEdit,
    this.onDelete,
    this.isDirector = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAssigned = role.isAssigned;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Character Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isAssigned
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.theater_comedy,
                  size: 22,
                  color: isAssigned
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Character and Performer details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAssigned
                              ? const Color(0xFF059669).withOpacity(0.1)
                              : const Color(0xFFD97706).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAssigned ? 'Assigned' : 'Open Role',
                          style: TextStyle(
                            color: isAssigned
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAssigned
                              ? (role.assignedUserName ?? 'Cast Member')
                              : 'No performer assigned',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isAssigned
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isAssigned ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Director controls
            if (isDirector)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_outlined, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Assign / Edit Role',
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFBA1A1A)),
                      onPressed: onDelete,
                      tooltip: 'Delete Role',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
