import 'package:urbano/Models/nhan_khau_model.dart';
import 'package:urbano/Models/can_ho_tong_quan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class NhanKhauServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<NhanKhau>> fetchNhanKhau(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/cudan/canho/$canHoId');
    final data = _asList(decoded);
    return data
        .map<NhanKhau>((e) => NhanKhau.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CanHoTongQuan> fetchCanHoTongQuan(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/canho/$canHoId/tongquan');
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
