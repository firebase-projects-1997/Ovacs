// lib/pages/clients/providers/clients_provider.dart
import 'package:flutter/material.dart';

import '../../../core/mixins/optimistic_update_mixin.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/country_model.dart';
import '../../../data/repositories/client_dashboard.dart';

class ClientsProvider extends ChangeNotifier
    with OptimisticUpdateMixin<ClientModel> {
  final ClientRepository repository;

  ClientsProvider(this.repository);

  List<ClientModel> _clients = [];

  @override
  List<ClientModel> get items => _clients;

  @override
  set items(List<ClientModel> value) {
    _clients = value;
  }

  List<ClientModel> get clients => _clients;

  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  set isLoading(bool value) {
    _isLoading = value;
  }

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _errorMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

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

  /// Optimistically adds a new client
  Future<bool> addClientOptimistic({
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    // Create a temporary country object for optimistic update
    final tempCountry = CountryModel(
      id: countryId,
      name: 'Loading...', // Temporary name
    );

    // Create a temporary client with a negative ID for optimistic update
    final tempClient = ClientModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
      account: 0, // Temporary account ID
      name: name,
      email: email,
      mobile: mobile,
      country: tempCountry,
      createdAt: DateTime.now(),
    );

    return await optimisticAdd<ClientModel>(
      item: tempClient,
      operation: () => repository.createClient(
        name: name,
        email: email,
        mobile: mobile,
        countryId: countryId,
      ),
      getId: (client) => client.id,
      mapResult: (response) =>
          response, // The response is already a ClientModel
    );
  }

  /// Optimistically updates a client
  Future<bool> updateClientOptimistic({
    required int id,
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    // Find the existing client to preserve other fields
    final existingClient = _clients.firstWhere((c) => c.id == id);

    // Create updated country if countryId changed, otherwise keep existing
    final updatedCountry = existingClient.country.id == countryId
        ? existingClient.country
        : CountryModel(
            id: countryId,
            name: 'Loading...', // Temporary name until server response
          );

    final updatedClient = ClientModel(
      id: id,
      account: existingClient.account, // Preserve existing account
      name: name,
      email: email,
      mobile: mobile,
      country: updatedCountry,
      createdAt: existingClient.createdAt,
    );

    return await optimisticUpdate<ClientModel>(
      updatedItem: updatedClient,
      operation: () => repository.updateClient(
        id: id,
        name: name,
        email: email,
        mobile: mobile,
        countryId: countryId,
      ),
      getId: (client) => client.id,
      mapResult: (response) =>
          response, // The response is already a ClientModel
    );
  }

  /// Optimistically deletes a client
  Future<bool> deleteClientOptimistic(int clientId) async {
    return await optimisticDelete<bool>(
      itemId: clientId,
      operation: () => repository.deleteClient(clientId),
      getId: (client) => client.id,
    );
  }
}
