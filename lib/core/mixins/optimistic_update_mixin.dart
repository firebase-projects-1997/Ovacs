import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../error/failure.dart';

/// A mixin that provides optimistic update functionality for providers.
/// This allows immediate UI updates with rollback capabilities on failure.
mixin OptimisticUpdateMixin<T> on ChangeNotifier {
  /// The main list of items managed by this provider
  List<T> get items;
  set items(List<T> value);

  /// Error message for the last operation
  String? get errorMessage;
  set errorMessage(String? value);

  /// Loading state for operations
  bool get isLoading;
  set isLoading(bool value);

  /// Performs an optimistic add operation
  ///
  /// [item] - The item to add locally
  /// [operation] - The async operation that performs the actual add
  /// [getId] - Function to extract ID from the item
  /// [onSuccess] - Optional callback when operation succeeds
  /// [onFailure] - Optional callback when operation fails
  Future<bool> optimisticAdd<R>({
    required T item,
    required Future<Either<Failure, R>> Function() operation,
    required dynamic Function(T) getId,
    T Function(R)? mapResult,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    // Optimistically add the item to the list
    final originalList = List<T>.from(items);
    items = [item, ...items];
    notifyListeners();

    try {
      final result = await operation();

      return result.fold(
        (failure) {
          // Rollback on failure
          items = originalList;
          errorMessage = failure.message;
          notifyListeners();
          onFailure?.call();
          return false;
        },
        (response) {
          // Update with the actual response if mapper is provided
          if (mapResult != null) {
            final actualItem = mapResult(response);
            final index = items.indexWhere((i) => getId(i) == getId(item));
            if (index != -1) {
              items[index] = actualItem;
              notifyListeners();
            }
          }
          errorMessage = null;
          onSuccess?.call();
          return true;
        },
      );
    } catch (e) {
      // Rollback on exception
      items = originalList;
      errorMessage = e.toString();
      notifyListeners();
      onFailure?.call();
      return false;
    }
  }

  /// Performs an optimistic update operation
  ///
  /// [updatedItem] - The updated item
  /// [operation] - The async operation that performs the actual update
  /// [getId] - Function to extract ID from the item
  /// [onSuccess] - Optional callback when operation succeeds
  /// [onFailure] - Optional callback when operation fails
  Future<bool> optimisticUpdate<R>({
    required T updatedItem,
    required Future<Either<Failure, R>> Function() operation,
    required dynamic Function(T) getId,
    T Function(R)? mapResult,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    // Find the item to update
    final itemId = getId(updatedItem);
    final index = items.indexWhere((item) => getId(item) == itemId);

    if (index == -1) {
      errorMessage = 'Item not found for update';
      onFailure?.call();
      return false;
    }

    // Store original item for rollback
    final originalItem = items[index];

    // Optimistically update the item
    items[index] = updatedItem;
    notifyListeners();

    try {
      final result = await operation();

      return result.fold(
        (failure) {
          // Rollback on failure
          items[index] = originalItem;
          errorMessage = failure.message;
          notifyListeners();
          onFailure?.call();
          return false;
        },
        (response) {
          // Update with the actual response if mapper is provided
          if (mapResult != null) {
            items[index] = mapResult(response);
            notifyListeners();
          }
          errorMessage = null;
          onSuccess?.call();
          return true;
        },
      );
    } catch (e) {
      // Rollback on exception
      items[index] = originalItem;
      errorMessage = e.toString();
      notifyListeners();
      onFailure?.call();
      return false;
    }
  }

  /// Performs an optimistic delete operation
  ///
  /// [itemId] - The ID of the item to delete
  /// [operation] - The async operation that performs the actual delete
  /// [getId] - Function to extract ID from the item
  /// [onSuccess] - Optional callback when operation succeeds
  /// [onFailure] - Optional callback when operation fails
  Future<bool> optimisticDelete<R>({
    required dynamic itemId,
    required Future<Either<Failure, R>> Function() operation,
    required dynamic Function(T) getId,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    // Find the item to delete
    final index = items.indexWhere((item) => getId(item) == itemId);

    if (index == -1) {
      errorMessage = 'Item not found for deletion';
      onFailure?.call();
      return false;
    }

    // Store original item and its position for rollback
    final originalItem = items[index];

    // Optimistically remove the item
    items.removeAt(index);
    notifyListeners();

    try {
      final result = await operation();

      return result.fold(
        (failure) {
          // Rollback on failure - restore item at original position
          items.insert(index, originalItem);
          errorMessage = failure.message;
          notifyListeners();
          onFailure?.call();
          return false;
        },
        (response) {
          errorMessage = null;
          onSuccess?.call();
          return true;
        },
      );
    } catch (e) {
      // Rollback on exception
      items.insert(index, originalItem);
      errorMessage = e.toString();
      notifyListeners();
      onFailure?.call();
      return false;
    }
  }

  /// Performs an optimistic batch operation (multiple items)
  ///
  /// [operation] - The async operation that performs the actual batch operation
  /// [optimisticUpdate] - Function to apply optimistic changes
  /// [rollback] - Function to rollback changes on failure
  /// [onSuccess] - Optional callback when operation succeeds
  /// [onFailure] - Optional callback when operation fails
  Future<bool> optimisticBatch<R>({
    required Future<Either<Failure, R>> Function() operation,
    required VoidCallback optimisticUpdate,
    required VoidCallback rollback,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    // Apply optimistic changes
    optimisticUpdate();
    notifyListeners();

    try {
      final result = await operation();

      return result.fold(
        (failure) {
          // Rollback on failure
          rollback();
          errorMessage = failure.message;
          notifyListeners();
          onFailure?.call();
          return false;
        },
        (response) {
          errorMessage = null;
          onSuccess?.call();
          return true;
        },
      );
    } catch (e) {
      // Rollback on exception
      rollback();
      errorMessage = e.toString();
      notifyListeners();
      onFailure?.call();
      return false;
    }
  }
}
