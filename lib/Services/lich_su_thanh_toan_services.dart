import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:urbano/Models/lich_su_thanh_toan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class LichSuThanhToanServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<LichSuThanhToan>> fetchByCanHo(String token, int canHoId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/hoadon/lich-su-thanh-toan/canho/$canHoId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải lịch sử thanh toán (${res.statusCode})');
    }
    final data = _asList(jsonDecode(utf8.decode(res.bodyBytes)));
    return data
        .map<LichSuThanhToan>(
          (e) => LichSuThanhToan.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  List _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final inner =
          decoded[r'$values'] ??
          decoded['value'] ??
          decoded['data'] ??
          decoded['items'];
      if (inner is List) return inner;
    }
    return const [];
  }
}
