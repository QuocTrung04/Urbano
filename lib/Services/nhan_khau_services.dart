import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:urbano/Models/nhan_khau_model.dart';
import 'package:urbano/Models/can_ho_tong_quan_model.dart';

class NhanKhauServices {
  static const String baseUrl = 'http://10.0.2.2:5080/api';

  // Danh sách nhân khẩu theo căn hộ
  Future<List<NhanKhau>> fetchNhanKhau(String token, int canHoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cudan/canho/$canHoId'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi tải nhân khẩu (${response.statusCode})');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final data = _asList(decoded);
    return data
        .map<NhanKhau>((e) => NhanKhau.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Tổng quan căn hộ (số căn hộ, tòa nhà, tầng, thuộc tính)
  Future<CanHoTongQuan> fetchCanHoTongQuan(String token, int canHoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/canho/$canHoId/tongquan'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi tải căn hộ (${response.statusCode})');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : <String, dynamic>{};
    return CanHoTongQuan.fromJson(map as Map<String, dynamic>);
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
