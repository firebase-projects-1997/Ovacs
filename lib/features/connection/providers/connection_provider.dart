import 'package:flutter/material.dart';
import 'package:new_ovacs/data/models/account_model.dart';
import '../../../core/error/failure.dart';
import '../../../data/repositories/connection_repository.dart';

class ConnectionProvider with ChangeNotifier {
  final ConnectionsRepository _repository;
  ConnectionProvider(this._repository);

  List<AccountModel> following = [];
  int totalFollowing = 0;
  List<AccountModel> followers = [];
  int totalFollowers = 0;
  bool isLoading = false;
  Failure? failure;

  Future<void> fetchConnections() async {
    isLoading = true;
    notifyListeners();

    final result = await _repository.getAllConnections();
    result.fold((f) => failure = f, (list) {
      following.addAll(list.following);
      followers.addAll(list.followers);
      totalFollowing = list.totalFollowing;
      totalFollowers = list.totalFollowers;
    });

    isLoading = false;
    notifyListeners();
  }
}
