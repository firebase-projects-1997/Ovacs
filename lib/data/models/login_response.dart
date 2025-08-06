import 'account_model.dart';
import 'user_model.dart';

class LoginResponse {
  final UserModel user;
  final AccountModel account;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.user,
    required this.account,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user']),
      account: AccountModel.fromJson(json['user']['account']),
      accessToken: json['tokens']['access'],
      refreshToken: json['tokens']['refresh'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'account': account.toJson(),
    'tokens': {'access': accessToken, 'refresh': refreshToken},
  };

  LoginResponse copyWith({
    UserModel? user,
    AccountModel? account,
    String? accessToken,
    String? refreshToken,
  }) {
    return LoginResponse(
      user: user ?? this.user,
      account: account ?? this.account,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
