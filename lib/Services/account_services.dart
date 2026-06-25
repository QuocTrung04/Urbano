import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/cudan_model.dart';

class AccountServices {
  static const String baseUrl = 'http://10.0.2.2:5080/api';

  Future<CuDan> fetchCuDan(int cuDanId, String token) async {
    final result = await http.get(
      Uri.parse('$baseUrl/cudan/$cuDanId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (result.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(result.bodyBytes));

      final Map<String, dynamic> json = decoded is Map<String, dynamic>
          ? (decoded['value'] ?? decoded['data'] ?? decoded)
          : decoded as Map<String, dynamic>;
      return CuDan.fromJson(json);
    } else {
      throw Exception('Không tải được thông tin cư dân (${result.statusCode})');
    }
  }
}
