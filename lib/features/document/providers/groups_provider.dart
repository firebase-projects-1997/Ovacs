import 'package:flutter/material.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/data/models/document_group_model.dart';
import 'package:new_ovacs/data/repositories/document_repository.dart';

enum GroupsStatus { initial, loading, loaded, error }

class GroupsProvider extends ChangeNotifier {
  final DocumentRepository _documentRepository;

  GroupsProvider(this._documentRepository);

  GroupsStatus status = GroupsStatus.initial;
  List<DocumentGroupModel> groups = [];
  String? errorMessage;

  // Fetch groups by session_id
  Future<void> fetchGroupsBySession(int sessionId) async {
    status = GroupsStatus.loading;
    notifyListeners();

    final result = await _documentRepository.listDocumentGroups(
      params: {'session_id': sessionId},
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
    final result = await _documentRepository.createGroup({
      'session_id': sessionId,
      'name': name,
      'description': description,
    });

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
    final result = await _documentRepository.updateGroup(groupId, {
      'name': name,
      'description': description,
      'session_id': sessionId,
    });

    return result.fold((failure) {
      errorMessage = _mapFailureToMessage(failure);
      return false;
    }, (_) => true);
  }

  // Delete group
  Future<bool> deleteGroup(int groupId) async {
    final result = await _documentRepository.deleteGroup(groupId);

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
