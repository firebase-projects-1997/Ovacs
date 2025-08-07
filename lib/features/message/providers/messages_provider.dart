import 'package:flutter/material.dart';
import '../../../core/mixins/optimistic_update_mixin.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/message_repository.dart';

enum AllMessagesStatus { initial, loading, loaded, error }

class AllMessagesProvider
    with ChangeNotifier, OptimisticUpdateMixin<MessageModel> {
  final MessageRepository _repository;

  AllMessagesProvider(this._repository);

  final List<MessageModel> _messages = [];

  @override
  List<MessageModel> get items => _messages;

  @override
  set items(List<MessageModel> value) {
    _messages.clear();
    _messages.addAll(value);
  }

  List<MessageModel> get messages => _messages;

  AllMessagesStatus _status = AllMessagesStatus.initial;
  AllMessagesStatus get status => _status;

  String? _errorMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  @override
  bool get isLoading => _status == AllMessagesStatus.loading;

  @override
  set isLoading(bool value) {
    _status = value ? AllMessagesStatus.loading : AllMessagesStatus.loaded;
  }

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Map<String, dynamic> _currentQuery = {};

  Future<void> fetchMessages(int caseId, {Map<String, dynamic>? query}) async {
    _status = AllMessagesStatus.loading;
    _errorMessage = null;
    _messages.clear();
    _currentPage = 1;
    _hasMore = true;
    _currentQuery = query ?? {};
    notifyListeners();

    final result = await _repository.getCaseMessages(
      caseId,
      query: {..._currentQuery, 'page': _currentPage},
    );

    result.fold(
      (failure) {
        _status = AllMessagesStatus.error;
        _errorMessage = failure.message;
      },
      (response) {
        _messages.addAll(response.messages);
        _hasMore = response.pagination.hasNext;
        _status = AllMessagesStatus.loaded;
      },
    );
    notifyListeners();
  }

  Future<void> fetchMoreMessages(int caseId) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await _repository.getCaseMessages(
      caseId,
      query: {..._currentQuery, 'page': _currentPage},
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _messages.addAll(response.messages);
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  void addNewMessage(MessageModel message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  void updateMessage(MessageModel updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void removeMessage(int messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  /// Optimistically updates a message
  Future<bool> updateMessageOptimistic({
    required int id,
    required String content,
  }) async {
    // Find the existing message to preserve other fields
    final existingMessage = _messages.firstWhere((m) => m.id == id);

    final updatedMessage = existingMessage.copyWith(content: content);

    return await optimisticUpdate<MessageModel>(
      updatedItem: updatedMessage,
      operation: () => _repository.editTextMessage(id, content),
      getId: (message) => message.id,
      mapResult: (response) =>
          response, // The response is already a MessageModel
    );
  }

  /// Optimistically deletes a message
  Future<bool> deleteMessageOptimistic(int messageId) async {
    return await optimisticDelete(
      itemId: messageId,
      operation: () => _repository.deleteMessage(messageId),
      getId: (message) => message.id,
    );
  }

  void reset() {
    _messages.clear();
    _status = AllMessagesStatus.initial;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _currentQuery = {};
    notifyListeners();
  }
}
