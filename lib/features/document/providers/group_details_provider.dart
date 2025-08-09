import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../data/models/document_group_model.dart';
import '../../../../data/repositories/document_repository.dart';
import '../../../../common/providers/workspace_provider.dart';

enum GroupDetailsStatus { initial, loading, loaded, error }

class GroupDetailsProvider extends ChangeNotifier {
  final DocumentRepository repository;
  final WorkspaceProvider _workspaceProvider;

  GroupDetailsProvider(this.repository, this._workspaceProvider);

  GroupDetailsStatus _status = GroupDetailsStatus.initial;
  GroupDetailsStatus get status => _status;

  DocumentGroupModel? _group;
  DocumentGroupModel? get group => _group;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchGroupDetail(int id) async {
    _status = GroupDetailsStatus.loading;
    notifyListeners();

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await repository.getGroupDetail(
      id,
      queryParams: queryParams,
    );

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
