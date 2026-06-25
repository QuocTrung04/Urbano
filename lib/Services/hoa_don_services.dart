import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/hoadon_model.dart';

class HoaDonServices {
  static const String apiUrl = 'http://10.0.2.2:5080/api';

  /// Fetches the list of invoices (HoaDon) from the API.
  Future<List<HoaDonModel>> fetchHoaDons(int canHoId) async {
    final response = await http.get(Uri.parse('$apiUrl/hoadon/canho/$canHoId'));

    if (response.statusCode == 200) {
      // Decode bodyBytes with UTF-8 to correctly display Vietnamese characters
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

  /// Fetches details for a specific invoice (API implementation placeholder).
  Future<HoaDonModel> fetchHoaDonDetail(int id) async {
    // API will be provided later. Simulating network latency.
    await Future.delayed(const Duration(milliseconds: 500));

    // Once the API is available, this can be implemented as:
    // final response = await http.get(Uri.parse('$apiUrl/$id'));
    // ...
    throw UnimplementedError('API chi tiết hóa đơn sẽ được tích hợp sau.');
  }
}
