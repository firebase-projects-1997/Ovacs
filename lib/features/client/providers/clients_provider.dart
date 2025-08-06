// lib/pages/clients/providers/clients_provider.dart
import 'package:flutter/material.dart';

import '../../../data/models/client_model.dart';
import '../../../data/repositories/client_dashboard.dart';

class ClientsProvider extends ChangeNotifier {
  final ClientRepository repository;

  ClientsProvider(this.repository);

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

  Future<void> fetchClients() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    final result = await repository.getClients(page: _currentPage);
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

  Future<void> fetchMoreClients() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await repository.getClients(page: _currentPage);
    result.fold((failure) => _errorMessage = failure.message, (response) {
      _clients.addAll(response.clients);
      _hasMore = response.pagination.hasNext;
    });

    _isLoadingMore = false;
    notifyListeners();
  }
}
