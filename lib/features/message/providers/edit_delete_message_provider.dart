import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/message_repository.dart';

enum EditDeleteStatus { initial, loading, success, error }

class EditDeleteMessageProvider with ChangeNotifier {
  final MessageRepository _repository;

  EditDeleteMessageProvider(this._repository);

  EditDeleteStatus status = EditDeleteStatus.initial;
  String? errorMessage;
  MessageModel? updatedMessage;

  Future<void> editMessage(int id, String content) async {
    status = EditDeleteStatus.loading;
    notifyListeners();

    final result = await _repository.editTextMessage(id, content);
    result.fold((failure) {
      status = EditDeleteStatus.error;
      errorMessage = failure.message;
    }, (message) {
      updatedMessage = message;
      status = EditDeleteStatus.success;
    });
    notifyListeners();
  }

  Future<void> deleteMessage(int id) async {
    status = EditDeleteStatus.loading;
    notifyListeners();

    final result = await _repository.deleteMessage(id);
    result.fold((failure) {
      status = EditDeleteStatus.error;
      errorMessage = failure.message;
    }, (_) {
      status = EditDeleteStatus.success;
    });
    notifyListeners();
  }

  void reset() {
    status = EditDeleteStatus.initial;
    errorMessage = null;
    updatedMessage = null;
    notifyListeners();
  }
}
