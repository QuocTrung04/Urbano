import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class DatLichServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // Tạo đặt lịch
  Future<DatLichTienIch> createDatLich(
    String token, {
    required int cuDan,
    int? canHo,
    required int tienIch,
    required DateTime thoiGianBatDau,
    required DateTime thoiGianKetThuc,
    required int soNguoi,
    String ghiChu = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/datlichtienich'),
      headers: _headers(token),
      body: jsonEncode({
        'cuDan': cuDan,
        'canHo': canHo,
        'tienIch': tienIch,
        'thoiGianBatDau': thoiGianBatDau.toIso8601String(),
        'thoiGianKetThuc': thoiGianKetThuc.toIso8601String(),
        'soNguoi': soNguoi,
        'ghiChu': ghiChu,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        _msg(res.body) ?? 'Đặt lịch thất bại (${res.statusCode})',
      );
    }
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded;
    return DatLichTienIch.fromJson(map as Map<String, dynamic>);
  }

  // Danh sách đặt lịch của cư dân
  Future<List<DatLichTienIch>> fetchByCuDan(String token, int cuDanId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/datlichtienich/cudan/$cuDanId'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải lịch đặt (${res.statusCode})');
    }
    final data = _asList(jsonDecode(utf8.decode(res.bodyBytes)));
    return data
        .map<DatLichTienIch>(
          (e) => DatLichTienIch.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  // Hủy đặt lịch
  Future<void> huy(String token, int id, String lyDo) async {
    final res = await http.put(
      Uri.parse('$baseUrl/datlichtienich/$id/huy'),
      headers: _headers(token),
      body: jsonEncode({'lyDo': lyDo}),
    );
    if (res.statusCode != 200) {
      throw Exception('Hủy thất bại (${res.statusCode})');
    }
  }

  String? _msg(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
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
