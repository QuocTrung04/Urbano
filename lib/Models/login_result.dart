import 'package:urbano/Models/cudan_model.dart';

class LoginResult {
  final String token;
  final CuDan cuDan;
  LoginResult({required this.token, required this.cuDan});
  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['accessToken'] as String,
      cuDan: CuDan.fromJson(json['user']),
    );
  }
}
