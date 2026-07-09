import 'package:urbano/Models/lich_su_thanh_toan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class LichSuThanhToanServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<LichSuThanhToan>> fetchByCanHo(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/hoadon/lich-su-thanh-toan/canho/$canHoId');
    final data = _asList(decoded);
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
