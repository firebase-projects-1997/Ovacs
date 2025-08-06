// lib/pages/clients/providers/client_detail_provider.dart

import 'package:flutter/material.dart';
import 'package:new_ovacs/data/models/client_model.dart';
import 'package:new_ovacs/data/repositories/client_dashboard.dart';

enum ClientDetailStatus { idle, loading, success, error }

class ClientDetailProvider extends ChangeNotifier {
  final ClientRepository repository;

  ClientDetailProvider(this.repository);

  ClientDetailStatus _status = ClientDetailStatus.idle;
  ClientDetailStatus get status => _status;

  ClientModel? _client;
  ClientModel? get client => _client;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchClientDetail(int id) async {
    _status = ClientDetailStatus.loading;
    notifyListeners();

    final result = await repository.getClientDetail(id);

    result.fold(
      (failure) {
        _status = ClientDetailStatus.error;
        _errorMessage = failure.message;
      },
      (clientModel) {
        _status = ClientDetailStatus.success;
        _client = clientModel;
      },
    );

    notifyListeners();
  }
}