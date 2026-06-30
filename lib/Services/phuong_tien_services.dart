import 'dart:convert';

import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:http/http.dart' as http;

class PhuongTienServices {
  static const String baseUrl = 'http://10.0.2.2:5080/api';

  Future<List<PhuongTien>> fetchPhuongTien(String token, int canHoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/phuongtien/canho/$canHoId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => PhuongTien.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Lỗi tải phương tiện (${response.statusCode})');
    }
  }
}
