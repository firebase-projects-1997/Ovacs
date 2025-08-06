// ignore_for_file: public_member_api_docs, sort_constructors_first
class ConnectionRequestModel {
  final int id;
  final int senderAccount;
  final int receiverAccount;
  final String senderName;
  final String receiverName;
  final String status;
  final String createdAt;
  final String? respondedAt;

  ConnectionRequestModel({
    required this.id,
    required this.senderAccount,
    required this.receiverAccount,
    required this.senderName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      id: json['id'],
      senderAccount: json['sender_account'],
      receiverAccount: json['receiver_account'],
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
      status: json['status'],
      createdAt: json['created_at'],
      respondedAt: json['responded_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_account': senderAccount,
      'receiver_account': receiverAccount,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'status': status,
      'created_at': createdAt,
      'responded_at': respondedAt,
    };
  }
}
