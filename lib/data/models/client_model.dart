import 'package:equatable/equatable.dart';

import 'country_model.dart';

class ClientModel extends Equatable {
  final int id;
  final int account;
  final String name;
  final String email;
  final String mobile;
  final CountryModel country;
  final DateTime createdAt;

  const ClientModel({
    required this.id,
    required this.account,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      account: json['account'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      country: CountryModel.fromJson(json['country']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    account,
    name,
    email,
    mobile,
    country,
    createdAt,
  ];
}
