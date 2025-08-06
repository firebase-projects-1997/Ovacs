import 'package:flutter/material.dart';
import '../../../data/models/client_model.dart';
import '../../../data/repositories/client_dashboard.dart';

class ClientsSearchProvider extends ChangeNotifier {
  final ClientRepository repository;

  ClientsSearchProvider(this.repository);

  List<ClientModel> _clients = [];
  List<ClientModel> get clients => _clients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _search = '';
  String _ordering = '-created_at';
  String _country = '';

  // Getters for filters
  String get search => _search;
  String get ordering => _ordering;
  String get country => _country;

  /// Fetch initial results with optional filters
  Future<void> fetchClientsBySearch({
    String? search,
    String? ordering,
    String? country,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;

    _search = search ?? '';
    _ordering = ordering ?? '-created_at';
    _country = country ?? '';

    notifyListeners();

    final result = await repository.getClientsBySearch(
      page: _currentPage,
      search: _search,
      ordering: _ordering,
      country: _country,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _clients = [];
      },
      (response) {
        _clients = response.clients;
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Load more results for pagination
  Future<void> fetchMoreClientsBySearch() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;

    final result = await repository.getClientsBySearch(
      page: _currentPage,
      search: _search,
      ordering: _ordering,
      country: _country,
    );

    result.fold((failure) => _errorMessage = failure.message, (response) {
      _clients.addAll(response.clients);
      _hasMore = response.pagination.hasNext;
    });

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Reset search state
  void clearFilters() {
    _search = '';
    _ordering = '-created_at';
    _country = '';
    _clients = [];
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }
}
