import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/message_repository.dart';

enum MessageDetailStatus { initial, loading, loaded, error }

class MessageDetailProvider with ChangeNotifier {
  final MessageRepository _repository;

  MessageDetailProvider(this._repository);

  MessageModel? message;
  MessageDetailStatus status = MessageDetailStatus.initial;
  String? errorMessage;

  Future<void> fetchMessage(int id) async {
    status = MessageDetailStatus.loading;
    notifyListeners();

    final result = await _repository.getMessageDetail(id);
    result.fold((failure) {
      errorMessage = failure.message;
      status = MessageDetailStatus.error;
    }, (msg) {
      message = msg;
      status = MessageDetailStatus.loaded;
    });
    notifyListeners();
  }

  void reset() {
    status = MessageDetailStatus.initial;
    errorMessage = null;
    message = null;
    notifyListeners();
  }
}
