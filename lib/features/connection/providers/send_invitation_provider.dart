import 'package:flutter/material.dart';
import 'package:new_ovacs/core/mixins/optimistic_update_mixin.dart';
import 'package:new_ovacs/data/models/invitation_model.dart';
import 'package:new_ovacs/data/repositories/connection_repository.dart';

class SendInvitationProvider extends ChangeNotifier
    with OptimisticUpdateMixin<InvitationEntry> {
  final ConnectionsRepository _repository;

  SendInvitationProvider(this._repository);

  List<InvitationEntry> _invitations = [
    const InvitationEntry(email: '', name: ''), // Start with one empty entry
  ];

  @override
  List<InvitationEntry> get items => _invitations;

  @override
  set items(List<InvitationEntry> value) {
    _invitations = value;
  }

  List<InvitationEntry> get invitations => _invitations;

  InvitationStatus _status = InvitationStatus.idle;
  InvitationStatus get status => _status;

  @override
  bool get isLoading => _status == InvitationStatus.loading;

  @override
  set isLoading(bool value) {
    _status = value ? InvitationStatus.loading : InvitationStatus.idle;
  }

  String? _errorMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  InvitationResponse? _lastResponse;
  InvitationResponse? get lastResponse => _lastResponse;

  String _customMessage = '';
  String get customMessage => _customMessage;

  void addInvitationEntry() {
    _invitations.add(const InvitationEntry(email: '', name: ''));
    notifyListeners();
  }

  void removeInvitationEntry(int index) {
    if (_invitations.length > 1) {
      _invitations.removeAt(index);
      notifyListeners();
    }
  }

  void updateInvitationEntry(int index, String email, String name) {
    if (index >= 0 && index < _invitations.length) {
      _invitations[index] = InvitationEntry(
        email: email,
        name: name,
        isValid: true, // always true
        errorMessage: null, // no errors
      );
      notifyListeners();
    }
  }

  void updateCustomMessage(String message) {
    _customMessage = message;
    notifyListeners();
  }

  List<InvitationEntry> get validInvitations => _invitations;

  bool get hasValidInvitations => _invitations.isNotEmpty;

  Future<bool> sendInvitations() async {
    if (_invitations.isEmpty) {
      _errorMessage = 'Please add at least one invitation';
      notifyListeners();
      return false;
    }

    _status = InvitationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = SendInvitationRequest.fromEntries(
        _invitations,
        message: _customMessage,
      );

      final result = await _repository.sendDirectInvitations(request);

      return result.fold(
        (failure) {
          _status = InvitationStatus.error;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (response) {
          _status = InvitationStatus.success;
          _lastResponse = response;
          _errorMessage = null;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _status = InvitationStatus.error;
      _errorMessage = 'Failed to send invitations: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _invitations = [const InvitationEntry(email: '', name: '')];
    _status = InvitationStatus.idle;
    _errorMessage = null;
    _lastResponse = null;
    _customMessage = '';
    notifyListeners();
  }

  void clearAll() {
    _invitations = [const InvitationEntry(email: '', name: '')];
    notifyListeners();
  }

  void importInvitations(List<Map<String, String>> emailNamePairs) {
    _invitations = emailNamePairs.map((pair) {
      final email = pair['email'] ?? '';
      final name = pair['name'] ?? '';
      return InvitationEntry(
        email: email,
        name: name,
        isValid: true,
        errorMessage: null,
      );
    }).toList();

    if (_invitations.isEmpty) {
      _invitations.add(const InvitationEntry(email: '', name: ''));
    }

    notifyListeners();
  }
}
