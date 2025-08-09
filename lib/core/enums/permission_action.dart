enum PermissionAction {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  list('list'),
  assign('assign'),
  unassign('unassign'),
  manageRoles('manage_roles');

  const PermissionAction(this.value);
  final String value;

  static PermissionAction fromString(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return PermissionAction.create;
      case 'read':
        return PermissionAction.read;
      case 'update':
        return PermissionAction.update;
      case 'delete':
        return PermissionAction.delete;
      case 'list':
        return PermissionAction.list;
      case 'assign':
        return PermissionAction.assign;
      case 'unassign':
        return PermissionAction.unassign;
      case 'manage_roles':
        return PermissionAction.manageRoles;
      default:
        throw ArgumentError('Unknown permission action: $action');
    }
  }

  String get displayName {
    switch (this) {
      case PermissionAction.create:
        return 'Create';
      case PermissionAction.read:
        return 'Read';
      case PermissionAction.update:
        return 'Update';
      case PermissionAction.delete:
        return 'Delete';
      case PermissionAction.list:
        return 'List';
      case PermissionAction.assign:
        return 'Assign';
      case PermissionAction.unassign:
        return 'Unassign';
      case PermissionAction.manageRoles:
        return 'Manage Roles';
    }
  }
}
