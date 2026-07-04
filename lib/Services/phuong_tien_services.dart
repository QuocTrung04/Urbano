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

  Future<void> dangKyPhuongTien(
    String token, {
    required int canHoId,
    required int cuDanId,
    required String tenPhuongTien,
    required String bienSo,
    required int loaiPhuongTienId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/phuongtien/dang-ky'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'canHoId': canHoId,
        'cuDanId': cuDanId,
        'tenPhuongTien': tenPhuongTien,
        'bienSo': bienSo,
        'loaiPhuongTienId': loaiPhuongTienId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _msg(response.body) ?? 'Đăng ký thất bại (${response.statusCode})',
      );
    }
  }

  String? _msg(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
  }

  /// Danh sách loại phương tiện (id + tên) từ API.
  Future<List<LoaiPhuongTien>> fetchLoaiPhuongTien(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/phuongtien/loai'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi tải loại phương tiện (${response.statusCode})');
    }
    final data = _asList(jsonDecode(utf8.decode(response.bodyBytes)));
    return data
        .map<LoaiPhuongTien>(
          (e) => LoaiPhuongTien(
            id: e['id'] ?? 0,
            tenLoaiPhuongTien: e['tenLoaiPhuongTien'] ?? '',
          ),
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

  /// Hủy đăng ký trực tiếp (cho xe Chờ duyệt) -> trạng thái 0.
  Future<void> huyPhuongTien(String token, int id) async {
    final res = await http.put(
      Uri.parse('$baseUrl/yeucaucudan/$id/huy'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Hủy thất bại (${res.statusCode})');
    }
  }

  /// Cập nhật thông tin xe (cho xe Chờ duyệt).
  Future<void> capNhatPhuongTien(
    String token, {
    required int id,
    required String tenPhuongTien,
    required String bienSo,
    required int loaiPhuongTienId,
    required int canHoId,
    int? nguoiCapNhatId,
    required int trangThai,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/phuongtien/$id'),
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
    if (res.statusCode != 200) {
      throw Exception('Cập nhật thất bại (${res.statusCode})');
    }
  }
}
