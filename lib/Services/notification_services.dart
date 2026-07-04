import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class ThongbaoServices {
  static const String url = ApiConfig.baseUrl;

  Future<List<ThongBao>> fetchThongBao(int cuDanId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$url/thongbao?cuDanId=$cuDanId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ThongBao.fromJson(e)).toList();
    }
    throw Exception('Lỗi tải thông báo: (${response.statusCode})');
  }

  // Đánh dấu 1 thông báo đã đọc
  Future<void> danhDauDaDoc(int thongBaoId, int cuDanId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$url/thongbao/danh-dau-da-doc').replace(
      queryParameters: {
        'thongBaoId': thongBaoId.toString(),
        'cuDanId': cuDanId.toString(),
      },
    );

    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Đánh dấu đã đọc thất bại (${response.statusCode})');
    }
  }

  // Đánh dấu TẤT CẢ thông báo đã đọc
  Future<void> danhDauTatCa(int cuDanId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      '$url/thongbao/danh-dau-tat-ca',
    ).replace(queryParameters: {'cuDanId': cuDanId.toString()});

    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Đánh dấu tất cả thất bại (${response.statusCode})');
    }
  }
}
