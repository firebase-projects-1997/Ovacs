import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/permission_action.dart';
import '../../core/enums/permission_resource.dart';
import '../../core/enums/user_role.dart';
import '../providers/permission_provider.dart';
import '../providers/workspace_provider.dart';

/// An app bar that shows different actions based on user permissions
class PermissionAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<PermissionAwareAction> actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const PermissionAwareAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PermissionProvider, WorkspaceProvider>(
      builder: (context, permissionProvider, workspaceProvider, _) {
        final filteredActions = actions
            .where((action) => action.shouldShow(permissionProvider))
            .map((action) => action.build(context, permissionProvider))
            .toList();

        return AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (workspaceProvider.isConnectionMode)
                Text(
                  workspaceProvider.workspaceDisplayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
            ],
          ),
          actions: filteredActions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Represents an action that can be shown in the app bar based on permissions
abstract class PermissionAwareAction {
  final PermissionResource resource;
  final PermissionAction action;
  final UserRole? fallbackRole;

  const PermissionAwareAction({
    required this.resource,
    required this.action,
    this.fallbackRole,
  });

  bool shouldShow(PermissionProvider permissionProvider) {
    return permissionProvider.hasPermission(
      resource,
      action,
      fallbackRole: fallbackRole,
    );
  }

  Widget build(BuildContext context, PermissionProvider permissionProvider);
}

/// An icon button action for the app bar
class PermissionAwareIconAction extends PermissionAwareAction {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const PermissionAwareIconAction({
    required super.resource,
    required super.action,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.fallbackRole,
  });

  @override
  Widget build(BuildContext context, PermissionProvider permissionProvider) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// A popup menu button action for the app bar
class PermissionAwarePopupMenuAction extends PermissionAwareAction {
  final List<PermissionAwarePopupMenuItem> items;
  final Widget? icon;
  final String? tooltip;

  const PermissionAwarePopupMenuAction({
    required super.resource,
    required super.action,
    required this.items,
    this.icon,
    this.tooltip,
    super.fallbackRole,
  });

  @override
  Widget build(BuildContext context, PermissionProvider permissionProvider) {
    final filteredItems = items
        .where((item) => item.shouldShow(permissionProvider))
        .toList();

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: icon,
      tooltip: tooltip,
      itemBuilder: (context) => filteredItems
          .map((item) => item.build(context, permissionProvider))
          .toList(),
    );
  }
}

/// A popup menu item that can be shown based on permissions
class PermissionAwarePopupMenuItem {
  final PermissionResource resource;
  final PermissionAction action;
  final String value;
  final Widget child;
  final VoidCallback? onTap;
  final UserRole? fallbackRole;

  const PermissionAwarePopupMenuItem({
    required this.resource,
    required this.action,
    required this.value,
    required this.child,
    this.onTap,
    this.fallbackRole,
  });

  bool shouldShow(PermissionProvider permissionProvider) {
    return permissionProvider.hasPermission(
      resource,
      action,
      fallbackRole: fallbackRole,
    );
  }

  PopupMenuItem<String> build(BuildContext context, PermissionProvider permissionProvider) {
    return PopupMenuItem<String>(
      value: value,
      onTap: onTap,
      child: child,
    );
  }
}

/// A text button action for the app bar
class PermissionAwareTextAction extends PermissionAwareAction {
  final String text;
  final VoidCallback? onPressed;

  const PermissionAwareTextAction({
    required super.resource,
    required super.action,
    required this.text,
    required this.onPressed,
    super.fallbackRole,
  });

  @override
  Widget build(BuildContext context, PermissionProvider permissionProvider) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
