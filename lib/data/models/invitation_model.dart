import 'package:equatable/equatable.dart';

/// Model for a single invitation entry
class InvitationEntry extends Equatable {
  final String email;
  final String name;
  final bool isValid;
  final String? errorMessage;

  const InvitationEntry({
    required this.email,
    required this.name,
    this.isValid = true,
    this.errorMessage,
  });

  InvitationEntry copyWith({
    String? email,
    String? name,
    bool? isValid,
    String? errorMessage,
  }) {
    return InvitationEntry(
      email: email ?? this.email,
      name: name ?? this.name,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name};
  }

  @override
  List<Object?> get props => [email, name, isValid, errorMessage];
}

class SendInvitationRequest {
  final List<String> emails;
  final List<String> invitedNames;
  final String? message;

  SendInvitationRequest({
    required this.emails,
    required this.invitedNames,
    this.message,
  });

  factory SendInvitationRequest.fromEntries(List<InvitationEntry> entries, {String? message}) {
    return SendInvitationRequest(
      emails: entries.map((e) => e.email).toList(),
      invitedNames: entries.map((e) => e.name).toList(),
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emails': emails,
      'invited_names': invitedNames,
      if (message != null && message!.isNotEmpty) 'message': message,
    };
  }
}


class InvitationResponse extends Equatable {
  final int successCount;
  final int failureCount;
  final List<String> failedEmails;
  final String message;

  const InvitationResponse({
    required this.successCount,
    required this.failureCount,
    required this.failedEmails,
    required this.message,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      successCount: json['success_count'] ?? 0,
      failureCount: json['failure_count'] ?? 0,
      failedEmails: List<String>.from(json['failed_emails'] ?? []),
      message: json['message'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    successCount,
    failureCount,
    failedEmails,
    message,
  ];
}

enum InvitationStatus { idle, loading, success, error }
