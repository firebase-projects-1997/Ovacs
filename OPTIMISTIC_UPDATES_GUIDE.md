# Optimistic Updates Implementation Guide

## Overview

This guide explains how to use the new optimistic update system implemented in your Flutter app. Optimistic updates provide a better user experience by immediately updating the UI when users perform actions (add, edit, delete), and automatically rolling back changes if the network request fails.

## What's Been Implemented

### 1. OptimisticUpdateMixin

A reusable mixin (`lib/core/mixins/optimistic_update_mixin.dart`) that provides:
- `optimisticAdd()` - Immediately adds items to the list
- `optimisticUpdate()` - Immediately updates items in the list  
- `optimisticDelete()` - Immediately removes items from the list
- `optimisticBatch()` - Handles multiple operations at once
- Automatic rollback on network failures

### 2. Updated Providers

All major providers now support optimistic updates:

#### ClientsProvider
- `addClientOptimistic()` - Add new clients
- `updateClientOptimistic()` - Update existing clients
- `deleteClientOptimistic()` - Delete clients

#### CasesProvider  
- `addCaseOptimistic()` - Add new cases
- `updateCaseOptimistic()` - Update existing cases
- `deleteCaseOptimistic()` - Delete cases

#### SessionsProvider
- `addSessionOptimistic()` - Add new sessions
- `updateSessionOptimistic()` - Update existing sessions
- `deleteSessionOptimistic()` - Delete sessions

#### DocumentsProvider
- `updateDocumentOptimistic()` - Update document metadata
- `deleteDocumentOptimistic()` - Delete documents

#### AllMessagesProvider
- `updateMessageOptimistic()` - Edit message content
- `deleteMessageOptimistic()` - Delete messages

## How to Use Optimistic Updates

### Basic Usage Pattern

Instead of the old pattern:
```dart
// OLD WAY - UI waits for server response
await provider.deleteItem(id);
if (provider.status == Success) {
  // Manually refresh the list
  provider.fetchItems();
  showSuccessMessage();
} else {
  showErrorMessage();
}
```

Use the new optimistic pattern:
```dart
// NEW WAY - UI updates immediately
final success = await provider.deleteItemOptimistic(id);
if (success) {
  showSuccessMessage();
} else {
  showErrorMessage(); // Item already rolled back automatically
}
```

### Example: Deleting a Client

```dart
// In your UI component
onPressed: () async {
  // Store context references before async operation
  final navigator = Navigator.of(context);
  final clientsProvider = context.read<ClientsProvider>();
  final localizations = AppLocalizations.of(context)!;
  
  // Optimistic delete - UI updates immediately
  final success = await clientsProvider.deleteClientOptimistic(client.id);
  
  navigator.pop(); // Close dialog
  
  if (success) {
    if (context.mounted) {
      showAppSnackBar(
        context,
        localizations.clientDeletedSuccessfully,
        type: SnackBarType.success,
      );
    }
  } else {
    if (context.mounted) {
      showAppSnackBar(
        context,
        clientsProvider.errorMessage ?? 'Failed to delete client',
      );
    }
  }
}
```

### Example: Adding a New Case

```dart
// In your add case form
onPressed: () async {
  final casesProvider = context.read<CasesProvider>();
  
  final success = await casesProvider.addCaseOptimistic(
    clientId: selectedClientId,
    clientName: selectedClientName,
    title: titleController.text,
    description: descriptionController.text,
    date: selectedDate.toIso8601String(),
  );
  
  if (success) {
    Navigator.pop(context); // Go back to cases list
    showSuccessMessage();
  } else {
    showErrorMessage(casesProvider.errorMessage);
  }
}
```

### Example: Updating a Session

```dart
// In your edit session form
onPressed: () async {
  final sessionsProvider = context.read<SessionsProvider>();
  
  final success = await sessionsProvider.updateSessionOptimistic(
    id: session.id,
    title: titleController.text,
    description: descriptionController.text,
    date: selectedDate.toIso8601String(),
    time: selectedTime,
  );
  
  if (success) {
    Navigator.pop(context);
    showSuccessMessage();
  } else {
    showErrorMessage(sessionsProvider.errorMessage);
  }
}
```

## Benefits

1. **Immediate UI Response**: Users see changes instantly
2. **Better UX**: No waiting for network requests
3. **Automatic Rollback**: Failed operations are automatically reverted
4. **Consistent Error Handling**: Standardized error management
5. **Reduced Code**: Less boilerplate in UI components

## Migration Guide

To migrate existing UI components:

1. Replace `provider.deleteItem()` with `provider.deleteItemOptimistic()`
2. Replace `provider.updateItem()` with `provider.updateItemOptimistic()`  
3. Replace `provider.addItem()` with `provider.addItemOptimistic()`
4. Remove manual list refreshing (`provider.fetchItems()`)
5. Store context references before async operations
6. Use `context.mounted` checks for post-async UI updates

## Error Handling

The optimistic update system automatically:
- Shows loading states during network requests
- Rolls back UI changes if requests fail
- Sets error messages in the provider's `errorMessage` property
- Maintains data consistency

You only need to:
- Check the return value (`true` for success, `false` for failure)
- Display appropriate user feedback
- Handle navigation logic

## Performance Notes

- UI updates are immediate (no network delay)
- Memory usage is minimal (temporary objects are cleaned up)
- Network requests still happen in the background
- Failed operations don't require additional API calls to refresh data
