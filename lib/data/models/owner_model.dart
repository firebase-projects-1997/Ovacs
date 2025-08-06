import 'package:equatable/equatable.dart';

import 'country_model.dart';

class OwnerModel extends Equatable {
  final int id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final CountryModel? country;
  final DateTime? createdAt;
  final DateTime? activatedAt;
  final bool? isActive;

  const OwnerModel({
    required this.id,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.country,
    this.createdAt,
    this.activatedAt,
    this.isActive,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      role: json['role'] as String?,
      country: json['country'] != null
          ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'role': role,
    'country': country?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'activated_at': activatedAt?.toIso8601String(),
    'is_active': isActive,
  };

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
  ];
}
