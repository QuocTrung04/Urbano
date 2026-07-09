import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class CanHoServices {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<CanHo> fetchCanHo(int canHoId) async {
    final decoded = await AuthHttp.get('$baseUrl/canho/$canHoId');
    final Map<String, dynamic> json = decoded is Map<String, dynamic>
        ? (decoded['value'] ?? decoded['data'] ?? decoded)
        : decoded as Map<String, dynamic>;
    return CanHo.fromJson(json);
  }
}
