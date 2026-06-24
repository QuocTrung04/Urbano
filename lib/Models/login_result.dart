import 'package:urbano/Models/cudan_model.dart';

class LoginResult {
  final String token;
  final CuDan cuDan;
  final int? canHoId;

  LoginResult({required this.token, required this.cuDan, this.canHoId});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['accessToken'] ?? '',
      cuDan: CuDan.fromJson(json['user']),
      canHoId: json['canHoId'],
    );
  }
}
