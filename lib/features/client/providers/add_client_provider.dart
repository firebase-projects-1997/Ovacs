import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/client_model.dart';
import '../../../data/repositories/client_dashboard.dart';

enum AddClientStatus { idle, loading, success, error }

class AddClientProvider extends ChangeNotifier {
  final ClientRepository clientRepository;

  AddClientProvider(this.clientRepository);

  AddClientStatus _status = AddClientStatus.idle;
  AddClientStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> addClient({
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    _status = AddClientStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final Either<Failure, ClientModel> result = await clientRepository
        .createClient(
          name: name,
          email: email,
          mobile: mobile,
          countryId: countryId,
        );

    result.fold(
      (failure) {
        _status = AddClientStatus.error;
        _errorMessage = failure.message;
      },
      (client) {
        _status = AddClientStatus.success;
      },
    );

    notifyListeners();
  }

  void resetStatus() {
    _status = AddClientStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
