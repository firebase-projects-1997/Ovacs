/// Base state enum for consistent state management across all providers
enum BaseState {
  /// Initial state when provider is first created
  initial,
  
  /// Loading state when an operation is in progress
  loading,
  
  /// Success state when operation completed successfully
  success,
  
  /// Error state when operation failed
  error,
  
  /// Loading more data (for pagination)
  loadingMore,
  
  /// Refreshing existing data
  refreshing,
}

/// Extension to provide convenient state checking methods
extension BaseStateExtension on BaseState {
  /// Check if the state is loading (any loading variant)
  bool get isLoading => this == BaseState.loading || 
                       this == BaseState.loadingMore || 
                       this == BaseState.refreshing;
  
  /// Check if the state is initial
  bool get isInitial => this == BaseState.initial;
  
  /// Check if the state is success
  bool get isSuccess => this == BaseState.success;
  
  /// Check if the state is error
  bool get isError => this == BaseState.error;
  
  /// Check if the state is loading more
  bool get isLoadingMore => this == BaseState.loadingMore;
  
  /// Check if the state is refreshing
  bool get isRefreshing => this == BaseState.refreshing;
  
  /// Check if the state allows user interaction
  bool get canInteract => !isLoading;
  
  /// Get user-friendly state description
  String get description {
    switch (this) {
      case BaseState.initial:
        return 'Ready';
      case BaseState.loading:
        return 'Loading...';
      case BaseState.success:
        return 'Success';
      case BaseState.error:
        return 'Error occurred';
      case BaseState.loadingMore:
        return 'Loading more...';
      case BaseState.refreshing:
        return 'Refreshing...';
    }
  }
}
