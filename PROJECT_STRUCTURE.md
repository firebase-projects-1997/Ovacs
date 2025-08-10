# 🏗️ OVACS Project Structure & Architecture Guide

## 📁 Project Structure

```
lib/
├── common/                    # Shared components across features
│   ├── pages/                # Common pages (splash, error, etc.)
│   ├── providers/            # Global providers (theme, locale, workspace, permissions)
│   └── widgets/              # Reusable UI components
├── core/                     # Core architecture and utilities
│   ├── config/               # App configuration
│   ├── constants/            # App constants (colors, routes, storage keys)
│   ├── di/                   # Dependency injection setup
│   ├── enums/                # App-wide enums
│   ├── error/                # Error handling
│   ├── functions/            # Utility functions
│   ├── mixins/               # Reusable mixins
│   ├── network/              # Network configuration
│   ├── providers/            # Base provider classes
│   ├── services/             # Core services
│   ├── utils/                # Utility classes
│   └── widgets/              # Core UI components
├── data/                     # Data layer
│   ├── models/               # Data models
│   └── repositories/         # Data repositories
├── features/                 # Feature modules
│   ├── auth/                 # Authentication feature
│   │   ├── providers/        # Auth-specific providers
│   │   ├── views/            # Auth screens
│   │   └── widgets/          # Auth-specific widgets
│   ├── case/                 # Case management feature
│   │   ├── providers/        # Case-specific providers
│   │   ├── views/            # Case screens
│   │   └── widgets/          # Case-specific widgets
│   └── [other features]/     # Other feature modules
├── generated/                # Generated files (localization)
├── l10n/                     # Localization files
├── services/                 # App-level services
└── main.dart                 # App entry point
```

## 🏛️ Architecture Patterns

### 1. **Provider Pattern with Base Classes**

All providers should extend from standardized base classes:

- **BaseProvider**: For simple state management
- **BaseListProvider<T>**: For list management with pagination
- **BaseFormProvider<T>**: For form handling and validation

### 2. **Consistent State Management**

All providers use the `BaseState` enum for consistent state handling:

```dart
enum BaseState {
  initial,    // Ready state
  loading,    // Operation in progress
  success,    // Operation completed successfully
  error,      // Operation failed
  loadingMore,// Loading more data (pagination)
  refreshing, // Refreshing existing data
}
```

### 3. **Permission-Aware Architecture**

All features integrate with the unified permissions system:

- Use `ProviderPermissionsMixin` in providers
- Use `PermissionMixin` in widgets
- Follow role-based access control (RBAC) patterns

### 4. **Workspace-Aware Operations**

All data operations consider workspace context:

- Personal workspace: Full control over own data
- Connection workspace: Role-based permissions apply

## 🎭 Role-Based Permissions

### Role Hierarchy (Highest to Lowest)
1. **Owner** 👑 - Full system access
2. **Admin** ⚡ - Administrative access
3. **Diamond** 💎 - Senior user access
4. **Gold** 🥇 - Standard user access
5. **Silver** 🥈 - Limited access

### Permission Matrix

| Resource | Owner | Admin | Diamond | Gold | Silver |
|----------|-------|-------|---------|------|--------|
| Cases    | CRUD+Assign | RU | R | R | R |
| Clients  | CRUD | RU | R | R | R |
| Sessions | CRUD | CRUD | CRUD | RU | R |
| Documents| CRUD | CRUD | CRUD | R | R |
| Messages | CRUD | CRUD | CRUD | CR | R |

**Legend**: C=Create, R=Read, U=Update, D=Delete

### Document Security Levels
- 🔴 **RED**: Owner + Admin only
- 🟡 **YELLOW**: Owner + Admin + Diamond
- 🟢 **GREEN**: All roles

## 📋 Development Guidelines

### 1. **Provider Development**

```dart
// ✅ Good: Extend base classes
class MyProvider extends BaseListProvider<MyModel> {
  @override
  Future<Either<Failure, List<MyModel>>> performFetch({
    required int page,
    Map<String, dynamic>? params,
  }) async {
    // Implementation
  }
}

// ❌ Bad: Custom state management
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  // Custom implementation
}
```

### 2. **Permission Integration**

```dart
// ✅ Good: Use permission mixins
class MyProvider extends BaseProvider with ProviderPermissionsMixin {
  Future<bool> createItem() async {
    if (!hasPermission(PermissionResource.cases, PermissionAction.create)) {
      setError('Permission denied');
      return false;
    }
    // Proceed with operation
  }
}
```

### 3. **Error Handling**

```dart
// ✅ Good: Use standardized error handling
return await executeOperation(
  operation: () => repository.getData(),
  successMessage: 'Data loaded successfully',
);

// ❌ Bad: Custom error handling
try {
  final result = await repository.getData();
  // Custom handling
} catch (e) {
  // Custom error handling
}
```

### 4. **UI State Management**

```dart
// ✅ Good: Use StateBuilder
StateBuilder(
  state: provider.state,
  onInitial: () => Text('Ready'),
  onLoading: () => StandardLoadingIndicator(),
  onSuccess: () => MySuccessWidget(),
  onError: (error) => StandardErrorWidget(message: error),
)

// ❌ Bad: Manual state checking
if (provider.isLoading) {
  return CircularProgressIndicator();
} else if (provider.error != null) {
  return Text('Error: ${provider.error}');
}
```

## 🚀 Performance Optimizations

### 1. **Font Optimization**
- Reduced from 18 font files to 8 (Regular, Medium, SemiBold, Bold for each family)
- Removed unused font weights (100, 200, 800, 900) and italic variants

### 2. **Dependency Optimization**
- Moved `device_preview` to dev dependencies
- Removed unused imports and dependencies

### 3. **Asset Optimization**
- Optimized asset loading
- Implemented lazy loading where appropriate

## 🔧 Message System

### Standardized Messages

```dart
// Success messages
MessageService.showSuccess('Operation completed successfully');

// Error messages
MessageService.showError('Operation failed. Please try again.');

// Confirmation dialogs
final confirmed = await MessageService.showDeleteConfirmation(
  context,
  itemName: 'case',
);
```

### Standard Message Types
- **Success**: Green with checkmark icon
- **Error**: Red with error icon
- **Warning**: Orange with warning icon
- **Info**: Blue with info icon

## 📱 UI Components

### Core Widgets
- `StandardLoadingIndicator`: Consistent loading UI
- `StandardErrorWidget`: Consistent error display
- `StandardEmptyWidget`: Consistent empty state
- `StandardSuccessWidget`: Consistent success display
- `LoadingMoreIndicator`: Pagination loading

### Permission-Aware Components
- `PermissionAwareButton`: Shows/hides based on permissions
- `DocumentSecurityGuard`: Document access control
- `RoleBadge`: Display user roles

## 🧪 Testing Guidelines

1. **Unit Tests**: Test business logic in providers
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows
4. **Permission Tests**: Verify role-based access control

## 📈 Monitoring & Analytics

- Error tracking through standardized error handling
- Performance monitoring through base providers
- User action tracking through permission system

## 🔄 Migration Guide

When updating existing providers:

1. Extend appropriate base class (`BaseProvider`, `BaseListProvider`, or `BaseFormProvider`)
2. Add `ProviderPermissionsMixin` if permissions are needed
3. Replace custom state management with `BaseState` enum
4. Use standardized error handling methods
5. Update UI to use `StateBuilder` and standard widgets

This architecture ensures consistency, maintainability, and scalability across the entire application.
