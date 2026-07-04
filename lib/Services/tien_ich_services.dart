import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class TienIchServices {
  static const String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tiện ích
  Future<List<TienIch>> fetchTienIch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('$baseUrl/tienich'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final List data = decoded is List
          ? decoded
          : (decoded[r'$values'] ?? decoded['value'] ?? decoded['data'] ?? [])
                as List;
      return data
          .map<TienIch>((e) => TienIch.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Lỗi tải tiện ích (${res.statusCode})');
  }
}
