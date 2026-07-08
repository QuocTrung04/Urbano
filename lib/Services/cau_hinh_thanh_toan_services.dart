import 'package:urbano/Models/cau_hinh_thanh_toan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class CauHinhThanhToanServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<CauHinhThanhToanModel?> fetchActive() async {
    final decoded = await AuthHttp.get('$baseUrl/CauHinhThanhToan');
    final List data = decoded is List
        ? decoded
        : (decoded['value'] ?? decoded['data'] ?? []) as List;
    final list = data.map((e) => CauHinhThanhToanModel.fromJson(e)).toList();
    final active = list.where((item) => item.trangThai == 1).toList();
    return active.isNotEmpty ? active.first : null;
  }
}
