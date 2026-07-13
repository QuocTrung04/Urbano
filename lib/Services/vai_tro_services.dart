import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/vai_tro_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class VaiTroServices {
  Future<List<VaiTro>> fetchVaiTros() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/VaiTro'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => VaiTro.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải danh sách vai trò');
    }
  }
}
