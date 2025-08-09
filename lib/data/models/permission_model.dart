import 'package:equatable/equatable.dart';
import '../../core/enums/permission_action.dart';
import '../../core/enums/permission_resource.dart';
import '../../core/enums/user_role.dart';

class PermissionModel extends Equatable {
  final PermissionResource resource;
  final List<PermissionAction> actions;

  const PermissionModel({required this.resource, required this.actions});

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      resource: PermissionResource.fromString(json['resource']),
      actions: (json['actions'] as List<dynamic>)
          .map((action) => PermissionAction.fromString(action.toString()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource': resource.value,
      'actions': actions.map((action) => action.value).toList(),
    };
  }

  bool hasAction(PermissionAction action) {
    return actions.contains(action);
  }

  @override
  List<Object?> get props => [resource, actions];
}

class UserPermissionsModel extends Equatable {
  final UserRole userRole;
  final List<PermissionModel> permissions;
  final int? spaceId;
  final int? caseId;

  const UserPermissionsModel({
    required this.userRole,
    required this.permissions,
    this.spaceId,
    this.caseId,
  });

  factory UserPermissionsModel.fromJson(Map<String, dynamic> json) {
    return UserPermissionsModel(
      userRole: UserRole.fromString(json['user_role']),
      permissions: (json['permissions'] as Map<String, dynamic>).entries
          .map(
            (entry) => PermissionModel(
              resource: PermissionResource.fromString(entry.key),
              actions: (entry.value as List<dynamic>)
                  .map(
                    (action) => PermissionAction.fromString(action.toString()),
                  )
                  .toList(),
            ),
          )
          .toList(),
      spaceId: json['space_id'] != null
          ? int.tryParse(json['space_id'].toString())
          : null,
      caseId: json['case_id'] != null
          ? int.tryParse(json['case_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final permissionsMap = <String, List<String>>{};
    for (final permission in permissions) {
      permissionsMap[permission.resource.value] = permission.actions
          .map((action) => action.value)
          .toList();
    }

    return {
      'user_role': userRole.value,
      'permissions': permissionsMap,
      if (spaceId != null) 'space_id': spaceId,
      if (caseId != null) 'case_id': caseId,
    };
  }

  bool hasPermission(PermissionResource resource, PermissionAction action) {
    final permission = permissions.firstWhere(
      (p) => p.resource == resource,
      orElse: () => const PermissionModel(
        resource: PermissionResource.case_,
        actions: [],
      ),
    );
    return permission.hasAction(action);
  }

  PermissionModel? getPermissionForResource(PermissionResource resource) {
    try {
      return permissions.firstWhere((p) => p.resource == resource);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [userRole, permissions, spaceId, caseId];
}
