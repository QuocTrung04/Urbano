import 'package:urbano/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class DatLichServices {
  static const String baseUrl = ApiConfig.baseUrl;



  // Tạo đặt lịch
  Future<DatLichTienIch> createDatLich({
    required int cuDan,
    int? canHo,
    required int tienIch,
    required DateTime thoiGianBatDau,
    required DateTime thoiGianKetThuc,
    required int soNguoi,
    String ghiChu = '',
  }) async {
    final decoded = await AuthHttp.post(
      '$baseUrl/datlichtienich',
      body: {
        'cuDanId': cuDan,
        'canHoId': canHo,
        'tienIchId': tienIch,
        'thoiGianBatDau': thoiGianBatDau.toIso8601String(),
        'thoiGianKetThuc': thoiGianKetThuc.toIso8601String(),
        'soNguoi': soNguoi,
        'ghiChu': ghiChu,
      },
    );
    final map = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded;
    return DatLichTienIch.fromJson(map as Map<String, dynamic>);
  }

  // Danh sách đặt lịch của cư dân
  Future<List<DatLichTienIch>> fetchByCuDan(int cuDanId) async {
    final decoded = await AuthHttp.get('$baseUrl/datlichtienich/cudan/$cuDanId');
    final data = _asList(decoded);
    return data
        .map<DatLichTienIch>(
          (e) => DatLichTienIch.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  // Hủy đặt lịch
  Future<void> huy(int id, String lyDo) async {
    await AuthHttp.put(
      '$baseUrl/datlichtienich/$id/huy',
      body: {'lyDo': lyDo},
    );
  }

//   String? _msg(String body) {
//     try {
//       final m = jsonDecode(body);
//       if (m is Map && m['message'] != null) return m['message'].toString();
//     } catch (_) {}
//     return null;
//   }

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
