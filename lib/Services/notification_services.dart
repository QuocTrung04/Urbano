import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/notification_model.dart';

class ThongbaoServices {
  static const String url = 'http://103.116.39.175/api';
  Future<List<ThongBao>> fetchThongBao() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final result = await http.get(
      Uri.parse('$url/thongBao'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (result.statusCode == 200) {
      final List data = jsonDecode(result.body);
      return data.map((e) => ThongBao.fromJson(e)).toList();
    }
    throw Exception('LỖi tải thông báo: (${result.statusCode})');
  }
}
