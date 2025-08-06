import 'package:flutter/material.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/connection_request_model.dart';
import '../../../data/repositories/connection_repository.dart';

class SentRequestsProvider with ChangeNotifier {
  final ConnectionsRepository _repository;
  SentRequestsProvider(this._repository);

  List<ConnectionRequestModel> sentRequests = [];
  bool isLoading = false;
  Failure? failure;

  Future<void> fetchSentRequests() async {
    isLoading = true;
    notifyListeners();

    final result = await _repository.getSentRequests();
    result.fold(
      (f) => failure = f,
      (list) => sentRequests = list,
    );

    isLoading = false;
    notifyListeners();
  }
}
