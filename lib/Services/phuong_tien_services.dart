import 'dart:convert';

import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:http/http.dart' as http;
import 'package:urbano/core/constants/apiconfig.dart';

class PhuongTienServices {
  static const String baseUrl = ApiConfig.baseUrl;

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

  Future<PhuongTien> createPhuongTien(
    String token, {
    required String tenPhuongTien,
    required String bienSo,
    required int loaiPhuongTienId,
    required int canHoId,
    int? nguoiCapNhatId,
    int trangThai = 2,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/phuongtien'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tenPhuongTien': tenPhuongTien,
        'bienSo': bienSo,
        'loaiPhuongTienId': loaiPhuongTienId,
        'canHoId': canHoId,
        'trangThai': trangThai,
        'nguoiCapNhatId': nguoiCapNhatId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gửi yêu cầu thất bại (${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded;
    return PhuongTien.fromJson(map as Map<String, dynamic>);
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
