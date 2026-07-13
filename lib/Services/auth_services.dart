import 'dart:convert';
import 'package:urbano/Models/login_result.dart';
import 'package:http/http.dart' as http;
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class AuthServices {
  static const String baseUrl = ApiConfig.baseUrl;

  //=======API DANG NHAP==========
  Future<LoginResult> login(String contact, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/login'),
      headers: {'content-Type': 'application/json'},
      body: jsonEncode({'account': contact, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return LoginResult.fromJson(data);
    } else {
      throw Exception('Đăng nhập thất bại (${res.statusCode})');
    }
  }

  //========DOI MAT KHAU==============
  Future<void> doiMatKhau(
    int cuDanId,
    String matkhaucu,
    String matkhaumoi,
  ) async {
    await AuthHttp.post(
      '$baseUrl/cudan/change-password?cuDanId=$cuDanId',
      body: {
        'currentPassword': matkhaucu,
        'newPassword': matkhaumoi,
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    try {
      await AuthHttp.post(
        '$baseUrl/cudan/forgot-password',
        body: {'email': email},
      );
    } catch (e) {
      throw Exception('Không gửi được OTP');
    }
  }

  // Đặt lại mật khẩu bằng OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await AuthHttp.post(
        '$baseUrl/cudan/reset-password',
        body: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Đặt lại mật khẩu thất bại');
    }
  }

//   String? _message(String body) {
//     try {
//       final m = jsonDecode(body);
//       if (m is Map && m['message'] != null) return m['message'].toString();
//     } catch (_) {}
//     return null;
//   }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await AuthHttp.post(
        '$baseUrl/cudan/verify-otp',
        body: {'email': email, 'otp': otp},
      );
    } catch (e) {
      throw Exception('OTP không đúng');
    }
  }
}
