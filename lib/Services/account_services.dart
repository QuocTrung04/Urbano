import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class AccountServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<CuDan> fetchCuDan(int cuDanId, String token) async {
    final decoded = await AuthHttp.get('$baseUrl/cudan/$cuDanId');
    final Map<String, dynamic> json = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded as Map<String, dynamic>;
    return CuDan.fromJson(json);
  }

  Future<void> capNhatCuDan(
    int cuDanId,
    CuDan cuDan, {
    String token = '',
  }) async {
    final body = {
      'hoTenDem': cuDan.hoTenDem ?? '',
      'ten': cuDan.ten ?? '',
      'sdt': cuDan.sdt ?? '',
      'cccd': cuDan.cccd ?? '',
      'email': cuDan.email ?? '',
      'ngaySinh': cuDan.ngaySinh?.toIso8601String(),
      'gioiTinh': cuDan.gioiTinh,
    };

    await AuthHttp.put(
      '$baseUrl/cudan/$cuDanId',
      body: body,
    );
  }
}
