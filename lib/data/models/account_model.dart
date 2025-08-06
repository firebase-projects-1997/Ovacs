import 'package:equatable/equatable.dart';

import 'owner_model.dart';

class AccountModel extends Equatable {
  final int id;
  final OwnerModel? owner;
  final String? name;
  final DateTime? createdAt;
  final bool? isActive;

  const AccountModel({
    required this.id,
    this.owner,
    this.name,
    this.createdAt,
    this.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      owner: json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null,
      name: json['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner': owner?.toJson(),
    'name': name,
    'created_at': createdAt?.toIso8601String(),
    'is_active': isActive,
  };

  AccountModel copyWith({
    int? id,
    OwnerModel? owner,
    String? name,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, owner, name, createdAt, isActive];
}
