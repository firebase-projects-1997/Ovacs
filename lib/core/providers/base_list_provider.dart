import 'package:dartz/dartz.dart';
import 'base_provider.dart';
import '../error/failure.dart';
import '../mixins/optimistic_update_mixin.dart';

/// Base provider for managing lists of items with pagination support
/// Includes optimistic updates and consistent state management
abstract class BaseListProvider<T> extends BaseProvider with OptimisticUpdateMixin<T> {
  List<T> _items = [];
  int _currentPage = 1;
  bool _hasMore = true;
  int _totalCount = 0;

  /// The list of items
  @override
  List<T> get items => _items;

  @override
  set items(List<T> value) {
    _items = value;
  }

  /// Current page for pagination
  int get currentPage => _currentPage;

  /// Whether there are more items to load
  bool get hasMore => _hasMore;

  /// Total count of items
  int get totalCount => _totalCount;

  /// Whether the list is empty
  bool get isEmpty => _items.isEmpty;

  /// Whether the list has items
  bool get isNotEmpty => _items.isNotEmpty;

  /// Error message for optimistic updates
  @override
  String? get errorMessage => super.errorMessage;

  @override
  set errorMessage(String? value) {
    setError(value ?? 'An error occurred');
  }

  /// Loading state for optimistic updates
  @override
  bool get isLoading => super.isLoading;

  @override
  set isLoading(bool value) {
    if (value) {
      setLoading();
    }
  }

  /// Fetch initial data
  Future<bool> fetchData({
    Map<String, dynamic>? params,
    String? successMessage,
  }) async {
    _currentPage = 1;
    _hasMore = true;
    
    return await executeOperationWithData<List<T>>(
      operation: () => performFetch(page: _currentPage, params: params),
      successMessage: successMessage,
      onSuccess: (data) {
        _items = data;
        _updatePaginationInfo();
      },
    ) != null;
  }

  /// Load more data (pagination)
  Future<bool> loadMore({
    Map<String, dynamic>? params,
  }) async {
    if (!_hasMore || isLoadingMore) return false;

    _currentPage++;
    
    return await executeOperationWithData<List<T>>(
      operation: () => performFetch(page: _currentPage, params: params),
      useLoadingMore: true,
      onSuccess: (data) {
        _items.addAll(data);
        _updatePaginationInfo();
      },
      onError: () {
        _currentPage--; // Rollback page increment on error
      },
    ) != null;
  }

  /// Refresh data
  Future<bool> refresh({
    Map<String, dynamic>? params,
    String? successMessage,
  }) async {
    _currentPage = 1;
    _hasMore = true;
    
    return await executeOperationWithData<List<T>>(
      operation: () => performFetch(page: _currentPage, params: params),
      useRefreshing: true,
      successMessage: successMessage,
      onSuccess: (data) {
        _items = data;
        _updatePaginationInfo();
      },
    ) != null;
  }

  /// Add item optimistically
  Future<bool> addItem({
    required T item,
    required Future<Either<Failure, T>> Function() operation,
    required dynamic Function(T) getId,
    String? successMessage,
  }) async {
    return await optimisticAdd<T>(
      item: item,
      operation: operation,
      getId: getId,
      mapResult: (response) => response,
      onSuccess: () {
        if (successMessage != null) setSuccess(successMessage);
      },
    );
  }

  /// Update item optimistically
  Future<bool> updateItem({
    required T updatedItem,
    required Future<Either<Failure, T>> Function() operation,
    required dynamic Function(T) getId,
    String? successMessage,
  }) async {
    return await optimisticUpdate<T>(
      updatedItem: updatedItem,
      operation: operation,
      getId: getId,
      mapResult: (response) => response,
      onSuccess: () {
        if (successMessage != null) setSuccess(successMessage);
      },
    );
  }

  /// Delete item optimistically
  Future<bool> deleteItem({
    required dynamic itemId,
    required Future<Either<Failure, dynamic>> Function() operation,
    required dynamic Function(T) getId,
    String? successMessage,
  }) async {
    return await optimisticDelete<dynamic>(
      itemId: itemId,
      operation: operation,
      getId: getId,
      onSuccess: () {
        if (successMessage != null) setSuccess(successMessage);
        _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
      },
    );
  }

  /// Clear all items
  void clearItems() {
    _items.clear();
    _currentPage = 1;
    _hasMore = true;
    _totalCount = 0;
    reset();
  }

  /// Find item by ID
  T? findItemById(dynamic id, dynamic Function(T) getId) {
    try {
      return _items.firstWhere((item) => getId(item) == id);
    } catch (e) {
      return null;
    }
  }

  /// Update pagination info after fetch operations
  void _updatePaginationInfo() {
    // This should be overridden by subclasses to handle their specific pagination response
    // Default implementation assumes no more pages if less than expected items
  }

  /// Abstract method that subclasses must implement to perform the actual fetch
  Future<Either<Failure, List<T>>> performFetch({
    required int page,
    Map<String, dynamic>? params,
  });

  /// Set pagination info (to be called by subclasses)
  void setPaginationInfo({
    required bool hasMore,
    required int totalCount,
  }) {
    _hasMore = hasMore;
    _totalCount = totalCount;
  }
}
