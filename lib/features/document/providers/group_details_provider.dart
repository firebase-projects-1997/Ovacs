import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../data/models/document_group_model.dart';
import '../../../../data/repositories/document_repository.dart';

enum GroupDetailsStatus { initial, loading, loaded, error }

class GroupDetailsProvider extends ChangeNotifier {
  final DocumentRepository repository;

  GroupDetailsProvider(this.repository);

  GroupDetailsStatus _status = GroupDetailsStatus.initial;
  GroupDetailsStatus get status => _status;

  DocumentGroupModel? _group;
  DocumentGroupModel? get group => _group;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchGroupDetail(int id) async {
    _status = GroupDetailsStatus.loading;
    notifyListeners();

    final result = await repository.getGroupDetail(id);

    result.fold(
      (f) {
        _failure = f;
        _status = GroupDetailsStatus.error;
      },
      (data) {
        _group = data;
        _status = GroupDetailsStatus.loaded;
      },
    );

    notifyListeners();
  }
}
