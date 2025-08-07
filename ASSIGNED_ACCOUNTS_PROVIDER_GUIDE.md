# Assigned Accounts Provider Implementation Guide

## Overview

The `AssignedAccountsProvider` is a comprehensive state management solution for handling assigned accounts in cases. It provides full CRUD operations (Create, Read, Update, Delete) for managing account assignments with optimistic updates and detailed loading states.

## What's Been Implemented

### 1. Provider (`lib/features/case/providers/assigned_accounts_provider.dart`)

#### **Core Features:**
- **Fetch Assigned Accounts**: Get all accounts assigned to a specific case
- **Assign Account**: Assign a new account to a case with a specific role
- **Update Role**: Change the role of an assigned account
- **Deassign Account**: Remove an account from a case
- **Optimistic Updates**: Immediate UI feedback with rollback on failure
- **Action-Specific Loading States**: Track loading for each operation separately

#### **State Management:**
```dart
enum AssignedAccountsStatus { idle, loading, success, error }
enum AssignedAccountAction { assign, updateRole, deassign }
```

#### **Key Properties:**
- `assignedAccounts`: List of currently assigned accounts
- `status`: Overall provider status
- `isAssigning/isUpdatingRole/isDeassigning`: Action-specific loading states
- `actionTargetAccountId`: ID of account being acted upon
- `availableRoles`: ['admin', 'diamond', 'gold', 'silver']

### 2. UI Widget (`lib/features/case/widgets/assigned_accounts_widget.dart`)

#### **Features:**
- **Responsive Design**: Adapts to different screen sizes
- **Real-time Updates**: Shows loading states for each action
- **Role Management**: Visual role indicators with colors
- **Error Handling**: Comprehensive error states with retry options
- **Interactive Dialogs**: Update role and deassign confirmation dialogs

#### **Visual Elements:**
- **Role Colors**: 
  - Admin: Red
  - Diamond: Blue  
  - Gold: Amber
  - Silver: Grey
- **Loading Indicators**: Per-action spinners
- **Empty States**: Helpful messages when no accounts assigned

### 3. API Integration

#### **Endpoints Used:**
```
GET    /api/cases/{caseId}/assigned-accounts/     # Fetch assigned accounts
POST   /api/cases/assign-user/                    # Assign account to case
PUT    /api/cases/{caseId}/assigned-accounts/{accountId}/  # Update role
DELETE /api/cases/{caseId}/assigned-accounts/{accountId}/  # Deassign account
```

#### **Request/Response Formats:**

**Assign Account:**
```json
POST /api/cases/assign-user/
{
  "case": 47,
  "account": 39,
  "role": "gold"
}
```

**Update Role:**
```json
PUT /api/cases/47/assigned-accounts/39/
{
  "role": "admin"
}
```

**Response Format:**
```json
{
  "data": [
    {
      "account": {
        "id": 39,
        "name": "Account Name",
        "owner": {
          "id": 1,
          "name": "Owner Name",
          "email": "owner@example.com"
        }
      },
      "role": "gold",
      "assigned_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

## Usage Examples

### 1. Basic Widget Usage

```dart
// In a case details page
AssignedAccountsWidget(
  caseId: caseId,
  showAddButton: true,
  onAddPressed: () {
    // Custom assign logic
    _showCustomAssignDialog();
  },
)
```

### 2. Provider Usage in Custom Widgets

```dart
class CustomAssignedAccountsPage extends StatelessWidget {
  final int caseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignedAccountsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Assigned Accounts'),
            actions: [
              IconButton(
                onPressed: provider.isLoading ? null : () {
                  provider.fetchAssignedAccounts(caseId);
                },
                icon: provider.isLoading 
                  ? CircularProgressIndicator()
                  : Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              // Custom UI using provider data
              if (provider.status == AssignedAccountsStatus.loading)
                LinearProgressIndicator(),
              
              Expanded(
                child: ListView.builder(
                  itemCount: provider.assignedAccounts.length,
                  itemBuilder: (context, index) {
                    final account = provider.assignedAccounts[index];
                    return ListTile(
                      title: Text(account.account.name ?? 'Unknown'),
                      subtitle: Text('Role: ${account.role}'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Update Role'),
                            onTap: () => _updateRole(account),
                          ),
                          PopupMenuItem(
                            child: Text('Remove'),
                            onTap: () => _deassign(account),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _assignNewAccount(),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _updateRole(AssignedAccountModel account) async {
    final provider = context.read<AssignedAccountsProvider>();
    final success = await provider.updateAccountRole(
      accountId: account.account.id,
      newRole: 'admin',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated successfully')),
      );
    }
  }

  void _deassign(AssignedAccountModel account) async {
    final provider = context.read<AssignedAccountsProvider>();
    final success = await provider.deassignAccount(account.account.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account removed successfully')),
      );
    }
  }

  void _assignNewAccount() async {
    final provider = context.read<AssignedAccountsProvider>();
    final success = await provider.assignAccountToCase(
      accountId: 123,
      role: 'gold',
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account assigned successfully')),
      );
    }
  }
}
```

### 3. Advanced Usage with Loading States

```dart
Consumer<AssignedAccountsProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.assignedAccounts.length,
      itemBuilder: (context, index) {
        final account = provider.assignedAccounts[index];
        final isUpdating = provider.isAccountLoading(
          account.account.id, 
          AssignedAccountAction.updateRole
        );
        final isDeassigning = provider.isAccountLoading(
          account.account.id, 
          AssignedAccountAction.deassign
        );

        return Card(
          child: ListTile(
            title: Text(account.account.name ?? 'Unknown'),
            subtitle: Text('Role: ${account.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isUpdating || isDeassigning ? null : () {
                    // Update role logic
                  },
                  icon: isUpdating 
                    ? SizedBox(
                        width: 16, 
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: isUpdating || isDeassigning ? null : () {
                    // Deassign logic
                  },
                  icon: isDeassigning 
                    ? SizedBox(
                        width: 16, 
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
)
```

## Key Features

### ✅ **Optimistic Updates**
- Immediate UI feedback for better UX
- Automatic rollback on API failure
- Maintains data consistency

### ✅ **Action-Specific Loading States**
- Track loading for each operation separately
- Prevent multiple simultaneous actions on same account
- Visual feedback for each action

### ✅ **Comprehensive Error Handling**
- Network error handling
- Server error responses
- User-friendly error messages
- Retry mechanisms

### ✅ **Role Management**
- Predefined roles: admin, diamond, gold, silver
- Visual role indicators with colors
- Easy role updates with validation

### ✅ **Dependency Injection Ready**
- Registered in GetIt service locator
- Available throughout the app
- Proper lifecycle management

## Integration Steps

1. **Use the Widget**: Add `AssignedAccountsWidget` to case details pages
2. **Custom Implementation**: Use the provider directly for custom UIs
3. **Handle Callbacks**: Implement custom assign/update/delete logic
4. **Error Handling**: Show appropriate feedback to users
5. **Loading States**: Use action-specific loading indicators

The provider is now fully integrated and ready to use for managing assigned accounts in cases with a complete, user-friendly interface.
