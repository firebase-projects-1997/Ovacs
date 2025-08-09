import 'dart:developer' as developer;
import '../enums/permission_action.dart';
import '../enums/permission_resource.dart';
import '../enums/user_role.dart';
import '../enums/document_security_level.dart';
import '../services/permission_service.dart';
import '../../data/models/permission_model.dart';

/// Debug utilities for the permission system
class PermissionDebug {
  
  /// Print permission matrix for a specific role
  static void printRolePermissions(UserRole role) {
    developer.log('=== Permission Matrix for ${role.displayName} ===');
    
    final permissions = PermissionService.getDefaultPermissionsForRole(role);
    
    for (final permission in permissions) {
      developer.log('${permission.resource.displayName}:');
      for (final action in permission.actions) {
        developer.log('  - ${action.displayName}');
      }
    }
    
    developer.log('=== Document Security Access ===');
    for (final level in DocumentSecurityLevel.values) {
      final canAccess = PermissionService.canAccessDocument(
        null,
        level,
        fallbackRole: role,
      );
      developer.log('${level.displayName}: ${canAccess ? "✓" : "✗"}');
    }
  }
  
  /// Print all role permissions
  static void printAllRolePermissions() {
    for (final role in UserRole.values) {
      printRolePermissions(role);
      developer.log('');
    }
  }
  
  /// Check specific permission for a role
  static bool checkRolePermission(
    UserRole role,
    PermissionResource resource,
    PermissionAction action,
  ) {
    final hasPermission = PermissionService.hasPermission(
      null,
      resource,
      action,
      fallbackRole: role,
    );
    
    developer.log(
      '${role.displayName} ${hasPermission ? "CAN" : "CANNOT"} '
      '${action.displayName.toLowerCase()} ${resource.displayName.toLowerCase()}',
    );
    
    return hasPermission;
  }
  
  /// Test document security access for all roles
  static void testDocumentSecurityAccess() {
    developer.log('=== Document Security Access Matrix ===');
    
    for (final level in DocumentSecurityLevel.values) {
      developer.log('\n${level.displayName}:');
      for (final role in UserRole.values) {
        final canAccess = PermissionService.canAccessDocument(
          null,
          level,
          fallbackRole: role,
        );
        developer.log('  ${role.displayName}: ${canAccess ? "✓" : "✗"}');
      }
    }
  }
  
  /// Validate permission consistency
  static void validatePermissionConsistency() {
    developer.log('=== Permission Consistency Check ===');
    
    final issues = <String>[];
    
    // Check that higher roles have at least the same permissions as lower roles
    for (final resource in PermissionResource.values) {
      for (final action in PermissionAction.values) {
        final silverCan = PermissionService.hasPermission(
          null, resource, action, fallbackRole: UserRole.silver,
        );
        final goldCan = PermissionService.hasPermission(
          null, resource, action, fallbackRole: UserRole.gold,
        );
        final diamondCan = PermissionService.hasPermission(
          null, resource, action, fallbackRole: UserRole.diamond,
        );
        final adminCan = PermissionService.hasPermission(
          null, resource, action, fallbackRole: UserRole.admin,
        );
        final ownerCan = PermissionService.hasPermission(
          null, resource, action, fallbackRole: UserRole.owner,
        );
        
        // Silver can do something but Gold cannot (inconsistency)
        if (silverCan && !goldCan) {
          issues.add('Silver can ${action.value} ${resource.value} but Gold cannot');
        }
        
        // Gold can do something but Diamond cannot (inconsistency)
        if (goldCan && !diamondCan) {
          issues.add('Gold can ${action.value} ${resource.value} but Diamond cannot');
        }
        
        // Diamond can do something but Admin cannot (inconsistency)
        if (diamondCan && !adminCan) {
          issues.add('Diamond can ${action.value} ${resource.value} but Admin cannot');
        }
        
        // Admin can do something but Owner cannot (inconsistency)
        if (adminCan && !ownerCan) {
          issues.add('Admin can ${action.value} ${resource.value} but Owner cannot');
        }
      }
    }
    
    if (issues.isEmpty) {
      developer.log('✓ No permission consistency issues found');
    } else {
      developer.log('✗ Found ${issues.length} permission consistency issues:');
      for (final issue in issues) {
        developer.log('  - $issue');
      }
    }
  }
  
  /// Print permission summary for debugging
  static void printPermissionSummary(UserPermissionsModel? permissions) {
    if (permissions == null) {
      developer.log('No permissions loaded');
      return;
    }
    
    developer.log('=== Current User Permissions ===');
    developer.log('Role: ${permissions.userRole.displayName}');
    if (permissions.spaceId != null) {
      developer.log('Space ID: ${permissions.spaceId}');
    }
    if (permissions.caseId != null) {
      developer.log('Case ID: ${permissions.caseId}');
    }
    
    developer.log('\nPermissions:');
    for (final permission in permissions.permissions) {
      developer.log('${permission.resource.displayName}:');
      for (final action in permission.actions) {
        developer.log('  - ${action.displayName}');
      }
    }
  }
  
  /// Test all CRUD operations for a resource
  static void testResourceCRUD(PermissionResource resource, UserRole role) {
    developer.log('=== CRUD Test for ${resource.displayName} (${role.displayName}) ===');
    
    final crudActions = [
      PermissionAction.create,
      PermissionAction.read,
      PermissionAction.update,
      PermissionAction.delete,
      PermissionAction.list,
    ];
    
    for (final action in crudActions) {
      checkRolePermission(role, resource, action);
    }
  }
}
