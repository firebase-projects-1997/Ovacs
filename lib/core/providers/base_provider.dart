import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../enums/base_state.dart';
import '../error/failure.dart';

/// Base provider class that provides consistent state management
/// All feature providers should extend this class
abstract class BaseProvider extends ChangeNotifier {
  BaseState _state = BaseState.initial;
  String? _errorMessage;
  String? _successMessage;

  /// Current state of the provider
  BaseState get state => _state;

  /// Error message if state is error
  String? get errorMessage => _errorMessage;

  /// Success message if state is success
  String? get successMessage => _successMessage;

  /// Convenience getters for state checking
  bool get isInitial => _state.isInitial;
  bool get isLoading => _state.isLoading;
  bool get isSuccess => _state.isSuccess;
  bool get isError => _state.isError;
  bool get isLoadingMore => _state.isLoadingMore;
  bool get isRefreshing => _state.isRefreshing;
  bool get canInteract => _state.canInteract;

  /// Set state to loading
  void setLoading() {
    _state = BaseState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Set state to loading more (for pagination)
  void setLoadingMore() {
    _state = BaseState.loadingMore;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set state to refreshing
  void setRefreshing() {
    _state = BaseState.refreshing;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set state to success with optional message
  void setSuccess([String? message]) {
    _state = BaseState.success;
    _errorMessage = null;
    _successMessage = message;
    notifyListeners();
  }

  /// Set state to error with message
  void setError(String message) {
    _state = BaseState.error;
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _state = BaseState.initial;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Execute an async operation with automatic state management
  /// Returns true if successful, false if failed
  Future<bool> executeOperation<T>({
    required Future<Either<Failure, T>> Function() operation,
    String? successMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool useLoadingMore = false,
    bool useRefreshing = false,
  }) async {
    // Set appropriate loading state
    if (useLoadingMore) {
      setLoadingMore();
    } else if (useRefreshing) {
      setRefreshing();
    } else {
      setLoading();
    }

    try {
      final result = await operation();
      
      return result.fold(
        (failure) {
          setError(failure.message);
          onError?.call();
          return false;
        },
        (data) {
          setSuccess(successMessage);
          onSuccess?.call();
          return true;
        },
      );
    } catch (e) {
      setError(e.toString());
      onError?.call();
      return false;
    }
  }

  /// Execute an operation that returns data with automatic state management
  Future<T?> executeOperationWithData<T>({
    required Future<Either<Failure, T>> Function() operation,
    String? successMessage,
    void Function(T data)? onSuccess,
    VoidCallback? onError,
    bool useLoadingMore = false,
    bool useRefreshing = false,
  }) async {
    // Set appropriate loading state
    if (useLoadingMore) {
      setLoadingMore();
    } else if (useRefreshing) {
      setRefreshing();
    } else {
      setLoading();
    }

    try {
      final result = await operation();
      
      return result.fold(
        (failure) {
          setError(failure.message);
          onError?.call();
          return null;
        },
        (data) {
          setSuccess(successMessage);
          onSuccess?.call(data);
          return data;
        },
      );
    } catch (e) {
      setError(e.toString());
      onError?.call();
      return null;
    }
  }

  /// Clear any messages without changing state
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Get user-friendly state description
  String get stateDescription => _state.description;
}
