import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:urbano/Models/login_result.dart';
import 'package:http/http.dart' as http;

class AuthServices {
  static const String baseUrl = 'http://103.116.39.175/api';

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
    int cudanId,
    String matkhaucu,
    String matkhaumoi,
    String token,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/cudan/change-password/$cudanId'),
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
      debugPrint('ljflsdaflkj $baseUrl/cudan/change-password/$cudanId');
      throw Exception('Đổi mật khẩu thất bại (${res.statusCode})');
    }
  }
}
