import 'package:flutter/material.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/account_model.dart';
import '../../../data/repositories/connection_repository.dart';

class NonConnectionsProvider with ChangeNotifier {
  final ConnectionsRepository _repository;
  NonConnectionsProvider(this._repository);

  List<AccountModel> users = [];
  bool isLoading = false;
  Failure? failure;
  Failure? sendRequestfailure;

  Set<int> loadingIds = {};

  Future<void> fetchSuggestions() async {
    isLoading = true;
    failure = null;
    notifyListeners();

    final result = await _repository.getNonConnections();
    result.fold((f) => failure = f, (list) => users = list);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> sendRequest(int index) async {
    final user = users[index];
    final userId = user.id;

    loadingIds.add(userId);
    notifyListeners();

    final result = await _repository.sendConnectionRequest(
      receiverAccountId: userId,
      receiverAccountName: user.name ?? '',
    );

    bool isSuccess = false;

    result.fold(
      (f) {
        sendRequestfailure = f;
        isSuccess = false;
      },
      (_) {
        isSuccess = true;
      },
    );

    loadingIds.remove(userId);
    notifyListeners();

    return isSuccess;
  }
}
