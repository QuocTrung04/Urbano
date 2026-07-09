import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';
import 'package:urbano/core/network/auth_http.dart';

class BangTinServices {
  static const String baseUrl = ApiConfig.baseUrl;
  Future<List<BangTin>> fetchBangTin() async {
    final decoded = await AuthHttp.get('$baseUrl/bangtin');
    final List data = decoded is List
        ? decoded
        : (decoded['value'] ?? decoded['data'] ?? []) as List;
    return data.map((e) => BangTin.fromJson(e)).toList();
  }
}
