// ✅ Updated: send_message_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/message_repository.dart';

enum SendMessageStatus { initial, sending, sent, error }

class SendMessageProvider with ChangeNotifier {
  final MessageRepository _repository;

  SendMessageProvider(this._repository);

  SendMessageStatus _status = SendMessageStatus.initial;
  String? _errorMessage;
  MessageModel? _sentMessage;

  final ValueNotifier<double> _uploadProgress = ValueNotifier(0.0);

  SendMessageStatus get status => _status;
  String? get errorMessage => _errorMessage;
  MessageModel? get sentMessage => _sentMessage;
  ValueNotifier<double> get uploadProgress => _uploadProgress;

  bool get isLoading => _status == SendMessageStatus.sending;

  Future<void> sendTextMessage(int caseId, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    if (_status == SendMessageStatus.sending) return;

     _updateState(
      status: SendMessageStatus.sending,
      errorMessage: null,
      sentMessage: null,
    );

    final result = await _repository.createTextMessage(caseId, trimmed);

    result.fold(
      (failure) => _updateState(
        status: SendMessageStatus.error,
        errorMessage: failure.message,
        sentMessage: null,
      ),
      (message) => _updateState(
        status: SendMessageStatus.sent,
        errorMessage: null,
        sentMessage: message,
      ),
    );
  }

  Future<void> sendVoiceMessage(int caseId, File voiceFile) async {
    if (_status == SendMessageStatus.sending) return;

    if (!await voiceFile.exists()) {
      _updateState(
        status: SendMessageStatus.error,
        errorMessage: 'Audio file not found.',
        sentMessage: null,
      );
      return;
    }

    if (await voiceFile.length() == 0) {
      _updateState(
        status: SendMessageStatus.error,
        errorMessage: 'Cannot send empty audio file.',
        sentMessage: null,
      );
      return;
    }

    _updateState(
      status: SendMessageStatus.sending,
      errorMessage: null,
      sentMessage: null,
    );
    _uploadProgress.value = 0.0;

    final result = await _repository.createVoiceMessage(
      caseId,
      voiceFile,
      (progress) => _uploadProgress.value = progress,
    );

    result.fold(
      (failure) => _updateState(
        status: SendMessageStatus.error,
        errorMessage: failure.message,
        sentMessage: null,
      ),
      (message) => _updateState(
        status: SendMessageStatus.sent,
        errorMessage: null,
        sentMessage: message,
      ),
    );
  }

  void _updateState({
    required SendMessageStatus status,
    String? errorMessage,
    MessageModel? sentMessage,
  }) {
    // final shouldNotify =
    //     _status != status ||
    //     _errorMessage != errorMessage ||
    //     _sentMessage?.id != sentMessage?.id;

    _status = status;
    _errorMessage = errorMessage;
    _sentMessage = sentMessage;
    notifyListeners();
    // if (shouldNotify && !_uploadProgress.hasListeners) {

    // }
  }

  void reset() {
    _updateState(
      status: SendMessageStatus.initial,
      errorMessage: null,
      sentMessage: null,
    );
    _uploadProgress.value = 0.0;
  }

  @override
  void dispose() {
    _uploadProgress.dispose();
    super.dispose();
  }
}
