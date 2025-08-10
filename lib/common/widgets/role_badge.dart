import 'package:flutter/material.dart';
import '../../core/enums/user_role.dart';

/// A badge widget that displays user roles with appropriate styling
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool showIcon;
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getRoleConfig(role);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Text(config.icon, style: TextStyle(fontSize: compact ? 10 : 12)),
            SizedBox(width: compact ? 2 : 4),
          ],
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _RoleConfig _getRoleConfig(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return _RoleConfig(
          color: const Color(0xFF7C3AED), // Purple
          label: 'Owner',
          icon: '👑',
        );
      case UserRole.admin:
        return _RoleConfig(
          color: const Color(0xFFDC2626), // Red
          label: 'Admin',
          icon: '⚡',
        );
      case UserRole.diamond:
        return _RoleConfig(
          color: const Color(0xFF2563EB), // Blue
          label: 'Diamond',
          icon: '💎',
        );
      case UserRole.gold:
        return _RoleConfig(
          color: const Color(0xFFD97706), // Yellow/Orange
          label: 'Gold',
          icon: '🥇',
        );
      case UserRole.silver:
        return _RoleConfig(
          color: const Color(0xFF6B7280), // Gray
          label: 'Silver',
          icon: '🥈',
        );
    }
  }
}

class _RoleConfig {
  final Color color;
  final String label;
  final String icon;

  const _RoleConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}

/// A widget that shows role hierarchy information
class RoleHierarchyIndicator extends StatelessWidget {
  final UserRole currentRole;
  final UserRole? requiredRole;

  const RoleHierarchyIndicator({
    super.key,
    required this.currentRole,
    this.requiredRole,
  });

  @override
  Widget build(BuildContext context) {
    final hasRequiredLevel =
        requiredRole == null || currentRole.hasPermissionLevel(requiredRole!);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoleBadge(role: currentRole, compact: true),
        if (requiredRole != null) ...[
          const SizedBox(width: 4),
          Icon(
            hasRequiredLevel ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: hasRequiredLevel ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            'Required: ${requiredRole!.displayName}',
            style: TextStyle(
              fontSize: 10,
              color: hasRequiredLevel ? Colors.green : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

/// A widget that displays all available roles with their permissions
class RolePermissionMatrix extends StatelessWidget {
  final UserRole currentRole;

  const RolePermissionMatrix({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Hierarchy',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...UserRole.values.map((role) {
          final isCurrent = role == currentRole;
          final hasLevel = currentRole.hasPermissionLevel(role);

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : hasLevel
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isCurrent
                    ? Theme.of(context).primaryColor
                    : hasLevel
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                RoleBadge(role: role, compact: true),
                const SizedBox(width: 8),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'YOU',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  hasLevel ? Icons.check : Icons.close,
                  size: 16,
                  color: hasLevel ? Colors.green : Colors.grey,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
