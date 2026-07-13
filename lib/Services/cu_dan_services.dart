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
        'diaChi': '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Lỗi tạo cư dân: ${response.body}');
    }
  }
}
