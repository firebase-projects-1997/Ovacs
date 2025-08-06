import 'package:flutter/material.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/connection_request_model.dart';
import '../../../data/repositories/connection_repository.dart';

enum RequestType { accept, reject }

class ReceivedRequestsProvider with ChangeNotifier {
  final ConnectionsRepository _repository;
  ReceivedRequestsProvider(this._repository);

  List<ConnectionRequestModel> receivedRequests = [];
  bool isLoading = false;
  Failure? failure;
  Set<int> loadingIds = {};
  Failure? sendRequestfailure;
  Future<void> fetchReceivedRequests() async {
    isLoading = true;
    notifyListeners();

    final result = await _repository.getReceivedRequests();
    result.fold((f) => failure = f, (list) => receivedRequests = list);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> respondRequest(int index, RequestType type) async {
    final user = receivedRequests[index];
    final userId = user.id;

    loadingIds.add(userId);
    notifyListeners();

    final result = await _repository.respondToConnectionRequest(
      senderAccountId: user.senderAccount,
      status: type == RequestType.accept ? 'accepted' : 'rejected',
      requestId: user.id,
      action: type == RequestType.accept ? 'accept' : 'reject',
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
