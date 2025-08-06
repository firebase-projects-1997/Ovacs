import 'package:equatable/equatable.dart';

class CaseModel extends Equatable {
  final int id;
  final int account;
  final int clientId;
  final String clientName;
  final String title;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final bool isActive;
  final List<String>? assignedAccountNames;

  const CaseModel({
    required this.id,
    required this.account,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.isActive,
    this.assignedAccountNames,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'],
      account: json['account'],
      clientId: json['client_id'],
      clientName: json['client_name'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'],
      assignedAccountNames: (json['assigned_account_names'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'client_name': clientName,
      'client_id': clientId,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'assigned_account_names': assignedAccountNames,
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
