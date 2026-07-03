import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:urbano/Models/login_result.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static const String baseUrl = 'http://10.0.2.2:5080/api';

  //=======API DANG NHAP==========
  Future<LoginResult> login(String contact, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/login'),
      headers: {'content-Type': 'application/json'},
      body: jsonEncode({'account': contact, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
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
    String token,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/change-password?cuDanId=$cuDanId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': matkhaucu,
        'newPassword': matkhaumoi,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Đổi mật khẩu thất bại (${res.statusCode})');
    }
  }

  Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      throw Exception(_message(res.body) ?? 'Không gửi được OTP');
    }
  }

  // Đặt lại mật khẩu bằng OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception(_message(res.body) ?? 'Đặt lại mật khẩu thất bại');
    }
  }

  String? _message(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
  }

  Future<void> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/cudan/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (res.statusCode != 200) {
      throw Exception(_message(res.body) ?? 'OTP không đúng');
    }
  }
}
