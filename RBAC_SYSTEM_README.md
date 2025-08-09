# Role-Based Access Control (RBAC) System

## Overview

This Django backend implements a comprehensive **Role-Based Access Control (RBAC) system** for space switching and collaborative access. The system allows users to access resources across different accounts based on their assigned roles in specific cases.

## Key Features

✅ **Flexible Permission Matrix** - Easily configurable role-based permissions  
✅ **Space Switching Support** - Cross-account access with proper authorization  
✅ **Case-Level Granularity** - Permissions tied to specific case assignments  
✅ **Document Security Levels** - Red/Yellow/Green classification with role-based access  
✅ **Audit Logging** - Comprehensive access tracking  
✅ **Easy Configuration** - Modify permissions without code changes

## Role Hierarchy

| Role        | Description                                  | Typical Use Case             |
| ----------- | -------------------------------------------- | ---------------------------- |
| **Owner**   | Full control over their account              | Account owner/primary lawyer |
| **Admin**   | High-level access, can't create/delete cases | Senior partner/case manager  |
| **Diamond** | Full access to sessions and documents        | Senior associate             |
| **Gold**    | Can update sessions, read-only for most      | Junior associate             |
| **Silver**  | Read-only access                             | Paralegal/intern             |

## Permission Matrix

### Current Default Permissions

| Resource           | Owner            | Admin   | Diamond | Gold  | Silver |
| ------------------ | ---------------- | ------- | ------- | ----- | ------ |
| **Case**           | ✅ CRUD + Assign | ✅ RU   | ✅ R    | ✅ R  | ✅ R   |
| **Client**         | ✅ CRUD          | ✅ R    | ✅ R    | ✅ R  | ✅ R   |
| **Session**        | ✅ CRUD          | ✅ CRUD | ✅ CRUD | ✅ RU | ✅ R   |
| **Document**       | ✅ CRUD          | ✅ CRUD | ✅ CRUD | ✅ R  | ✅ R   |
| **Document Group** | ✅ CRUD          | ✅ CRUD | ✅ CRUD | ✅ R  | ✅ R   |
| **Message**        | ✅ CRUD          | ✅ CRUD | ✅ CRUD | ✅ CR | ✅ R   |

**Legend:** C=Create, R=Read, U=Update, D=Delete, Assign=Manage Assignments

## How It Works

### 1. Space Switching Flow

```
User Request with space_id → Connection Verification → Case Assignment Check → Role Determination → Permission Enforcement
```

### 2. Permission Checking Process

1. **User Authentication** - JWT token validation
2. **Space Access Verification** - Check if user follows target account
3. **Case Assignment Lookup** - Find user's role in specific cases
4. **Permission Matrix Lookup** - Check if role allows the action
5. **Resource Access** - Grant or deny access based on permissions

### 3. API Usage Examples

```bash
# Check user permissions in a space
GET /api/check-permissions/?space_id=123&case_id=456

# Access case details in another account
GET /api/cases/789/?space_id=123

# Update session in another account (if role allows)
PUT /api/sessions/456/?space_id=123

# List documents with space switching
GET /api/documents/?space_id=123
```

## Configuration

### Easy Permission Modification

Edit `api/permission_config.py` to modify permissions:

```python
ROLE_PERMISSIONS = {
    'gold': {
        'session': ['read', 'update', 'list'],  # Added 'update'
        'document': ['create', 'read', 'list'], # Added 'create'
        # ... other resources
    }
}
```

### Management Commands

```bash
# View current permission matrix
python manage.py show_permissions

# View permissions for specific role
python manage.py show_permissions --role=gold

# View permissions for specific resource
python manage.py show_permissions --resource=document

# Export permissions as JSON
python manage.py show_permissions --format=json
```

## Implementation Details

### Key Components

1. **`api/permissions.py`** - Core RBAC system
2. **`api/permission_config.py`** - Easy configuration file
3. **`api/views.py`** - Updated views with permission checks
4. **`SpaceSwitchingMixin`** - Unified space switching logic
5. **Permission Classes** - DRF permission integration

### Security Features

- **Multi-layer validation** - Connection + Assignment + Role checks
- **Case-specific permissions** - Different roles per case
- **Document security levels** - Additional red/yellow/green classification
- **Real-time validation** - Permissions checked on every request
- **Audit logging** - All access attempts logged

### Document Security Integration

The RBAC system works with the existing document security levels:

| Security Level | Owner | Admin | Diamond | Gold | Silver |
| -------------- | ----- | ----- | ------- | ---- | ------ |
| **Red**        | ✅    | ✅    | ❌      | ❌   | ❌     |
| **Yellow**     | ✅    | ✅    | ✅      | ❌   | ❌     |
| **Green**      | ✅    | ✅    | ✅      | ✅   | ✅     |

## Testing

### Permission Check Endpoint

Use the debug endpoint to verify permissions:

```bash
curl -H "Authorization: Bearer <token>" \
     "http://localhost:8000/api/check-permissions/?space_id=123&case_id=456"
```

Response:

```json
{
  "type": "success",
  "data": {
    "user_role": "gold",
    "permissions": {
      "case": ["read", "list"],
      "session": ["read", "update", "list"],
      "document": ["read", "list"]
    }
  }
}
```

### Test Scenarios

1. **Cross-account access** - Verify space switching works
2. **Role enforcement** - Test different roles have appropriate access
3. **Permission denial** - Ensure unauthorized actions are blocked
4. **Document security** - Verify security levels are enforced
5. **Audit logging** - Check access attempts are logged

## Extending the System

### Adding New Roles

1. Add role to `Role` enum in `permissions.py`
2. Define permissions in `permission_config.py`
3. Update database choices in `models.py`
4. Run migrations

### Adding New Resources

1. Add resource to `Resource` enum
2. Define permissions for each role
3. Create permission class for the resource
4. Update views to use the permission class

### Adding New Actions

1. Add action to `Action` enum
2. Update permission configurations
3. Implement action-specific checks in views

## Best Practices

1. **Principle of Least Privilege** - Grant minimum necessary permissions
2. **Regular Audits** - Review permission assignments periodically
3. **Test Thoroughly** - Verify permissions work as expected
4. **Document Changes** - Keep track of permission modifications
5. **Monitor Access** - Review audit logs for suspicious activity

## Troubleshooting

### Common Issues

1. **Permission Denied** - Check user is assigned to case with appropriate role
2. **Space Access Denied** - Verify connection exists between accounts
3. **Document Access Denied** - Check both role permissions and security level
4. **Configuration Not Loading** - Restart Django after config changes

### Debug Tools

- Use `check-permissions` endpoint for debugging
- Check audit logs for access attempts
- Use management commands to verify configuration
- Enable Django debug mode for detailed error messages

This RBAC system provides a robust, flexible foundation for managing access control in collaborative legal document management scenarios.
