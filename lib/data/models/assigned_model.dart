import 'account_model.dart';

class AssignedAccountModel {
  final AccountModel account;
  final String role;
  final DateTime assignedAt;

  const AssignedAccountModel({
    required this.account,
    required this.role,
    required this.assignedAt,
  });

  factory AssignedAccountModel.fromJson(Map<String, dynamic> json) {
    return AssignedAccountModel(
      account: AccountModel.fromJson(json['account']),
      role: json['role'],
      assignedAt: DateTime.parse(json['assigned_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'account': account.toJson(),
    'role': role,
    'assigned_at': assignedAt.toIso8601String(),
  };
}
