import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/canho_model.dart';

class CanHoServices {
  static const String baseUrl = 'http://10.0.2.2:5080/api';

  Future<CanHo> fetchCanHo(int canHoId, {String token = ''}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/canho/$canHoId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final Map<String, dynamic> json = decoded is Map<String, dynamic>
          ? (decoded['value'] ?? decoded['data'] ?? decoded)
          : decoded as Map<String, dynamic>;
      return CanHo.fromJson(json);
    }
    throw Exception('Không tải được thông tin căn hộ (${res.statusCode})');
  }
}
