import 'package:flutter/material.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/space_account_model.dart';
import '../../../data/repositories/connection_repository.dart';

class ConnectionProvider with ChangeNotifier {
  final ConnectionsRepository _repository;
  ConnectionProvider(this._repository);

  List<SpaceAccountModel> following = [];
  List<SpaceAccountModel> followers = [];

  int totalFollowing = 0;
  int totalFollowers = 0;

  bool isLoadingFollowing = false;
  bool isLoadingFollowers = false;
  Failure? followingFailure;
  Failure? followersfailure;

  Future<void> fetchFollowing() async {
    isLoadingFollowing = true;
    followingFailure = null;
    notifyListeners();

    final result = await _repository.getMyFollowing();
    result.fold((f) => followingFailure = f, (list) {
      following = list;
      totalFollowing = list.length;
    });

    isLoadingFollowing = false;
    notifyListeners();
  }

  Future<void> fetchFollowers() async {
    isLoadingFollowers = true;
    followersfailure = null;
    notifyListeners();

    final result = await _repository.getMyFollowers();
    result.fold((f) => followersfailure = f, (list) {
      followers = list;
      totalFollowers = list.length;
    });

    isLoadingFollowers = false;
    notifyListeners();
  }
}
