import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class BangTinServices {
  static const String baseUrl = ApiConfig.baseUrl;
  Future<List<BangTin>> fetchBangTin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/bangtin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List data = decoded is List
          ? decoded
          : (decoded['value'] ?? decoded['data'] ?? []) as List;
      return data.map((e) => BangTin.fromJson(e)).toList();
    }
    throw Exception('Lỗi tải bảng tin: (${response.statusCode})');
  }
}
