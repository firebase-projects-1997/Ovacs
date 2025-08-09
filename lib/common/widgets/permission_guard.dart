import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/permission_action.dart';
import '../../core/enums/permission_resource.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/document_security_level.dart';
import '../../core/services/permission_service.dart';
import '../providers/permission_provider.dart';

/// A widget that conditionally shows its child based on user permissions
class PermissionGuard extends StatelessWidget {
  final PermissionResource resource;
  final PermissionAction action;
  final Widget child;
  final Widget? fallback;
  final UserRole? fallbackRole;

  const PermissionGuard({
    super.key,
    required this.resource,
    required this.action,
    required this.child,
    this.fallback,
    this.fallbackRole,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasPermission = permissionProvider.hasPermission(
          resource,
          action,
          fallbackRole: fallbackRole,
        );

        if (hasPermission) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// A widget that shows different content based on user role
class RoleBasedWidget extends StatelessWidget {
  final Map<UserRole, Widget> roleWidgets;
  final Widget? defaultWidget;

  const RoleBasedWidget({
    super.key,
    required this.roleWidgets,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final userRole = permissionProvider.currentUserRole;

        if (roleWidgets.containsKey(userRole)) {
          return roleWidgets[userRole]!;
        }

        return defaultWidget ?? const SizedBox.shrink();
      },
    );
  }
}

/// A button that is only enabled if user has permission
class PermissionAwareButton extends StatelessWidget {
  final PermissionResource resource;
  final PermissionAction action;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final UserRole? fallbackRole;
  final String? disabledTooltip;

  const PermissionAwareButton({
    super.key,
    required this.resource,
    required this.action,
    required this.onPressed,
    required this.child,
    this.style,
    this.fallbackRole,
    this.disabledTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasPermission = permissionProvider.hasPermission(
          resource,
          action,
          fallbackRole: fallbackRole,
        );

        final button = ElevatedButton(
          onPressed: hasPermission ? onPressed : null,
          style: style,
          child: child,
        );

        if (!hasPermission && disabledTooltip != null) {
          return Tooltip(message: disabledTooltip!, child: button);
        }

        return button;
      },
    );
  }
}

/// An icon button that is only enabled if user has permission
class PermissionAwareIconButton extends StatelessWidget {
  final PermissionResource resource;
  final PermissionAction action;
  final VoidCallback? onPressed;
  final Widget icon;
  final UserRole? fallbackRole;
  final String? disabledTooltip;
  final double? iconSize;
  final Color? color;

  const PermissionAwareIconButton({
    super.key,
    required this.resource,
    required this.action,
    required this.onPressed,
    required this.icon,
    this.fallbackRole,
    this.disabledTooltip,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasPermission = permissionProvider.hasPermission(
          resource,
          action,
          fallbackRole: fallbackRole,
        );

        final button = IconButton(
          onPressed: hasPermission ? onPressed : null,
          icon: icon,
          iconSize: iconSize,
          color: hasPermission ? color : Theme.of(context).disabledColor,
        );

        if (!hasPermission && disabledTooltip != null) {
          return Tooltip(message: disabledTooltip!, child: button);
        }

        return button;
      },
    );
  }
}

/// A floating action button that is only shown if user has permission
class PermissionAwareFAB extends StatelessWidget {
  final PermissionResource resource;
  final PermissionAction action;
  final VoidCallback? onPressed;
  final Widget child;
  final UserRole? fallbackRole;

  const PermissionAwareFAB({
    super.key,
    required this.resource,
    required this.action,
    required this.onPressed,
    required this.child,
    this.fallbackRole,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasPermission = permissionProvider.hasPermission(
          resource,
          action,
          fallbackRole: fallbackRole,
        );

        if (!hasPermission) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(onPressed: onPressed, child: child);
      },
    );
  }
}

/// A list tile that is only enabled if user has permission
class PermissionAwareListTile extends StatelessWidget {
  final PermissionResource resource;
  final PermissionAction action;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final UserRole? fallbackRole;

  const PermissionAwareListTile({
    super.key,
    required this.resource,
    required this.action,
    this.onTap,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.fallbackRole,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasPermission = permissionProvider.hasPermission(
          resource,
          action,
          fallbackRole: fallbackRole,
        );

        return ListTile(
          onTap: hasPermission ? onTap : null,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          enabled: hasPermission,
        );
      },
    );
  }
}

/// A widget that conditionally shows its child based on document security level and permissions
class DocumentSecurityGuard extends StatelessWidget {
  final PermissionAction action;
  final DocumentSecurityLevel securityLevel;
  final Widget child;
  final Widget? fallback;
  final UserRole? fallbackRole;

  const DocumentSecurityGuard({
    super.key,
    required this.action,
    required this.securityLevel,
    required this.child,
    this.fallback,
    this.fallbackRole,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        final hasAccess = PermissionService.canAccessDocumentWithPermission(
          permissionProvider.userPermissions,
          action,
          securityLevel,
          fallbackRole: fallbackRole,
        );

        if (hasAccess) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
