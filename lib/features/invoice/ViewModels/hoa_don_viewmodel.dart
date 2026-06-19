import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urbano/Models/hoadon_model.dart';

class HoaDonViewModel extends ChangeNotifier {
  static const String apiUrl = 'http://103.116.39.175/api/HoaDon';

  bool isLoading = false;
  String? error;
  List<HoaDonModel> hoaDonList = [];

  Future<void> fetchHoaDons() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Giải mã UTF-8 để hiển thị đúng tiếng Việt
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        List listJson = [];
        if (decoded is List) {
          listJson = decoded;
        } else if (decoded is Map && decoded['value'] != null) {
          listJson = decoded['value'];
        }
        hoaDonList = listJson.map((item) => HoaDonModel.fromJson(item)).toList();
      } else {
        error = 'Không thể tải danh sách hóa đơn (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('Lỗi tải hóa đơn: $e');
      error = 'Kết nối mạng không ổn định. Vui lòng thử lại!';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
