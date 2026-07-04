import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class AccountServices {
  static const String baseUrl = ApiConfig.baseUrl;

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

  Future<void> capNhatCuDan(
    int cuDanId,
    CuDan cuDan, {
    String token = '',
  }) async {
    final body = {
      'hoTenDem': cuDan.hoTenDem ?? '',
      'ten': cuDan.ten ?? '',
      'sdt': cuDan.sdt ?? '',
      'cccd': cuDan.cccd ?? '',
      'email': cuDan.email ?? '',
      'ngaySinh': cuDan.ngaySinh?.toIso8601String(),
      'gioiTinh': cuDan.gioiTinh,
    };

    final res = await http.put(
      Uri.parse('$baseUrl/cudan/$cuDanId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 && res.statusCode >= 300) {
      String msg = 'Cập nhật thất bại (${res.statusCode})';
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
