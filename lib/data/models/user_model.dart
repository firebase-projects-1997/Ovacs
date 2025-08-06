import 'package:equatable/equatable.dart';

import 'account_model.dart';
import 'country_model.dart';

class UserModel extends Equatable {
  final int id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final CountryModel? country;
  final DateTime? createdAt;
  final DateTime? activatedAt;
  final bool? isActive;
  final AccountModel? account;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.country,
    this.createdAt,
    this.activatedAt,
    this.isActive,
    this.account,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'])
          : null,
      isActive: json['is_active'],
      account: json['account'] != null
          ? AccountModel.fromJson(json['account'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'country': country?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'is_active': isActive,
      'account': account?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    String? role,
    CountryModel? country,
    DateTime? createdAt,
    DateTime? activatedAt,
    bool? isActive,
    AccountModel? account,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      isActive: isActive ?? this.isActive,
      account: account ?? this.account,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    mobile,
    role,
    country,
    createdAt,
    activatedAt,
    isActive,
    account,
  ];
}
