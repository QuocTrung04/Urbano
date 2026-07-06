import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class TienIchServices {
  static const String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách tiện ích
  Future<List<TienIch>> fetchTienIch() async {
    final decoded = await AuthHttp.get('$baseUrl/tienich');
    final List data = decoded is List
        ? decoded
        : (decoded[r'$values'] ?? decoded['value'] ?? decoded['data'] ?? [])
              as List;
    return data
        .map<TienIch>((e) => TienIch.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
