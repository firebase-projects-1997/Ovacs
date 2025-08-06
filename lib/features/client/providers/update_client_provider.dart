// lib/pages/clients/providers/update_client_provider.dart
import 'package:flutter/material.dart';

import '../../../data/repositories/client_dashboard.dart';

enum UpdateClientStatus { idle, loading, success, error }

class UpdateClientProvider extends ChangeNotifier {
  final ClientRepository repository;

  UpdateClientProvider(this.repository);

  UpdateClientStatus _status = UpdateClientStatus.idle;
  UpdateClientStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> deleteClient(int id) async {
    _status = UpdateClientStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.deleteClient(id);

    result.fold(
      (failure) {
        _status = UpdateClientStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        _status = UpdateClientStatus.success;
      },
    );

    notifyListeners();

    // Reset to idle after short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _status = UpdateClientStatus.idle;
    notifyListeners();
  }

  Future<void> updateClient({
    required int id,
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    _status = UpdateClientStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.updateClient(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      countryId: countryId,
    );

    result.fold(
      (failure) {
        _status = UpdateClientStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        _status = UpdateClientStatus.success;
      },
    );

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _status = UpdateClientStatus.idle;
    notifyListeners();
  }
}
