import 'package:flutter/material.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/data/models/document_group_model.dart';
import 'package:new_ovacs/data/repositories/document_repository.dart';
import 'package:new_ovacs/common/providers/workspace_provider.dart';

enum GroupsStatus { initial, loading, loaded, error }

class GroupsProvider extends ChangeNotifier {
  final DocumentRepository _documentRepository;
  final WorkspaceProvider _workspaceProvider;

  GroupsProvider(this._documentRepository, this._workspaceProvider);

  GroupsStatus status = GroupsStatus.initial;
  List<DocumentGroupModel> groups = [];
  String? errorMessage;

  // Fetch groups by session_id
  Future<void> fetchGroupsBySession(int sessionId) async {
    status = GroupsStatus.loading;
    notifyListeners();

    // Include workspace parameters
    final workspaceParams = _workspaceProvider.getWorkspaceQueryParams();
    final allParams = <String, dynamic>{
      'session_id': sessionId,
      ...workspaceParams,
    };

    final result = await _documentRepository.listDocumentGroups(
      params: allParams,
    );

    result.fold(
      (failure) {
        status = GroupsStatus.error;
        errorMessage = _mapFailureToMessage(failure);
      },
      (fetchedGroups) {
        groups = fetchedGroups;
        status = GroupsStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Create group
  Future<bool> createGroup({
    required int sessionId,
    required String name,
    required String description,
  }) async {
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _documentRepository.createGroup({
      'session_id': sessionId,
      'name': name,
      'description': description,
    }, queryParams: queryParams);

    return result.fold((failure) {
      errorMessage = _mapFailureToMessage(failure);
      return false;
    }, (_) => true);
  }

  // Update group
  Future<bool> updateGroup({
    required int groupId,
    required int sessionId,
    required String name,
    required String description,
  }) async {
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _documentRepository.updateGroup(groupId, {
      'name': name,
      'description': description,
      'session_id': sessionId,
    }, queryParams: queryParams);

    return result.fold((failure) {
      errorMessage = _mapFailureToMessage(failure);
      return false;
    }, (_) => true);
  }

  // Delete group
  Future<bool> deleteGroup(int groupId) async {
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _documentRepository.deleteGroup(
      groupId,
      queryParams: queryParams,
    );

    return result.fold(
      (failure) {
        errorMessage = _mapFailureToMessage(failure);
        return false;
      },
      (_) {
        groups.removeWhere((group) => group.id == groupId);
        notifyListeners();
        return true;
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
