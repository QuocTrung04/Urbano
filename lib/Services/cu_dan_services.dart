import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class CuDanServices {
  Future<bool> createCuDan({
    required String hoTenDem,
    required String ten,
    required String sdt,
    required String email,
    required String cccd,
    DateTime? ngaySinh,
    int? gioiTinh,
    String? diaChi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final canHoId = prefs.getInt('canHoId');
    
    // ignore: avoid_print
    print('====> Đang gọi tạo cư dân với canHoId: $canHoId');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/CuDan'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'hoTenDem': hoTenDem,
        'ten': ten,
        'sdt': sdt,
        'cccd': cccd,
        'email': email,
        'ngaySinh': ngaySinh?.toIso8601String(),
        'gioiTinh': gioiTinh,
        'canHoId': canHoId,
        'tinh': '',
        'xa': '',
        'diaChi': diaChi ?? '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Lỗi tạo cư dân: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> checkExists({
    String? cccd,
    String? sdt,
    String? email,
  }) async {
    final queryParams = <String, String>{};
    if (cccd != null && cccd.isNotEmpty) queryParams['cccd'] = cccd;
    if (sdt != null && sdt.isNotEmpty) queryParams['sdt'] = sdt;
    if (email != null && email.isNotEmpty) queryParams['email'] = email;

    if (queryParams.isEmpty) return {'exists': false, 'cuDanId': null};

    final uri = Uri.parse('${ApiConfig.baseUrl}/CuDan/check-exists').replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    return {'exists': false, 'cuDanId': null};
  }
}
