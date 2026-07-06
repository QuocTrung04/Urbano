import 'package:flutter/widgets.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class YeuCauServices {
  static const String baseUrl = ApiConfig.baseUrl;



  // Danh sách yêu cầu của 1 cư dân
  Future<List<YeuCauCuDan>> fetchByCuDan(String token, int cuDanId) async {
    final decoded = await AuthHttp.get('$baseUrl/yeucaucudan/cudan/$cuDanId');
    final data = _asList(decoded);
    return data
        .map<YeuCauCuDan>(
          (e) => YeuCauCuDan.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  // Danh sách loại yêu cầu (dropdown khi tạo)
  Future<List<LoaiYeuCau>> fetchLoaiYeuCau(String token) async {
    final decoded = await AuthHttp.get('$baseUrl/yeucaucudan/loai-yeu-cau');
    final data = _asList(decoded);
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
    final decoded = await AuthHttp.post(
      '$baseUrl/yeucaucudan',
      body: {
        'cuDan': cuDan,
        'loaiYeuCau': loaiYeuCau,
        'tieuDe': tieuDe,
        'noiDung': noiDung,
        'mucDoUuTien': mucDoUuTien,
      },
    );
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

  Future<void> HuyYeuCau(String token, int id) async {
    await AuthHttp.put('$baseUrl/yeucaucudan/$id/huyyeucau');
  }
}
