import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/Services/phuong_tien_services.dart';

class PhuongTienViewModel extends ChangeNotifier {
  final PhuongTienServices _services = PhuongTienServices();

  bool isLoading = false;
  String? error;
  List<PhuongTien> phuongTienList = [];
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    debugPrint('=== bắt đầu loadData ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final cuDanId = prefs.getInt('cuDanId') ?? 0;

      phuongTienList = await _services.fetchPhuongTien(token, cuDanId);
      debugPrint('=== tải xong: ${phuongTienList.length} xe ===');
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải phương tiện: $e');
      error = 'Không tải được danh sách phương tiện';
      isLoading = false;
      notifyListeners();
    }
  }
}
