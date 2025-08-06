import 'package:equatable/equatable.dart';

class CountryModel extends Equatable {
  final int id;
  final String? code;
  final String? name;
  final String? phoneCode;
  final String? flagUrl;

  const CountryModel({
    required this.id,
    this.code,
    this.name,
    this.phoneCode,
    this.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      phoneCode: json['phone_code'],
      flagUrl: json['flag_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'phone_code': phoneCode,
      'flag_url': flagUrl,
    };
  }

  CountryModel copyWith({
    int? id,
    String? code,
    String? name,
    String? phoneCode,
    String? flagUrl,
  }) {
    return CountryModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      phoneCode: phoneCode ?? this.phoneCode,
      flagUrl: flagUrl ?? this.flagUrl,
    );
  }

  @override
  List<Object?> get props => [id, code, name, phoneCode, flagUrl];
}
