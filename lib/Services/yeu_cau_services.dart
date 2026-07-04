import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class YeuCauServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // Danh sách yêu cầu của 1 cư dân
  Future<List<YeuCauCuDan>> fetchByCuDan(String token, int cuDanId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/yeucaucudan/cudan/$cuDanId'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải yêu cầu (${res.statusCode})');
    }
    final data = _asList(jsonDecode(utf8.decode(res.bodyBytes)));
    return data
        .map<YeuCauCuDan>(
          (e) => YeuCauCuDan.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  // Danh sách loại yêu cầu (dropdown khi tạo)
  Future<List<LoaiYeuCau>> fetchLoaiYeuCau(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/yeucaucudan/loai-yeu-cau'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải loại yêu cầu (${res.statusCode})');
    }
    final data = _asList(jsonDecode(utf8.decode(res.bodyBytes)));
    return data
        .map<LoaiYeuCau>((e) => LoaiYeuCau.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<YeuCauCuDan> createYeuCau(
    String token, {
    required int cuDan,
    required int loaiYeuCau,
    required String tieuDe,
    required String noiDung,
    required int mucDoUuTien,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/yeucaucudan'),

      headers: _headers(token),
      body: jsonEncode({
        'cuDan': cuDan,
        'loaiYeuCau': loaiYeuCau,
        'tieuDe': tieuDe,
        'noiDung': noiDung,
        'mucDoUuTien': mucDoUuTien,
      }),
    );
    debugPrint('POST /yeucaucudan -> ${res.statusCode} | ${res.body}');
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gửi yêu cầu thất bại (${res.statusCode})');
    }
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded;
    return YeuCauCuDan.fromJson(map as Map<String, dynamic>);
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
