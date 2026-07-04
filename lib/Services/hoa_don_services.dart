import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/core/constants/apiconfig.dart';

class HoaDonServices {
  static const String apiUrl = ApiConfig.baseUrl;

  /// Danh sách hóa đơn theo căn hộ.
  Future<List<HoaDonModel>> fetchHoaDons(int canHoId) async {
    final response = await http.get(Uri.parse('$apiUrl/hoadon/canho/$canHoId'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List listJson = [];
      if (decoded is List) {
        listJson = decoded;
      } else if (decoded is Map && decoded['value'] != null) {
        listJson = decoded['value'];
      }
      return listJson.map((item) => HoaDonModel.fromJson(item)).toList();
    } else {
      throw Exception(
        'Không thể tải danh sách hóa đơn (${response.statusCode})',
      );
    }
  }

  Future<HoaDonModel> fetchHoaDonDetail(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/hoadon/$id'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final map = decoded is Map<String, dynamic>
          ? (decoded['value'] ?? decoded['data'] ?? decoded)
          : decoded;
      return HoaDonModel.fromJson(map as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy hóa đơn');
    } else {
      throw Exception(
        'Không thể tải chi tiết hóa đơn (${response.statusCode})',
      );
    }
  }

  Future<void> thanhToan(
    int hoaDonId, {
    required String phuongThuc,
    required double soTien,
  }) async {
    final res = await http.post(
      Uri.parse('$apiUrl/hoadon/$hoaDonId/thanh-toan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phuongThucThanhToan': phuongThuc, 'soTien': soTien}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Thanh toán thất bại (${res.statusCode})');
    }
  }
}
