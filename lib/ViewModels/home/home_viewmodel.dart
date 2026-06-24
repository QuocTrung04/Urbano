import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Services/home_services.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/Services/notification_services.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeServices _services = HomeServices();
  final ThongbaoServices _thongBaoServices = ThongbaoServices(); // ⬅ thêm

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  HomeData? _data;
  HomeData? get data => _data;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _services.fetchHomeData();
    } catch (e) {
      debugPrint('Lỗi loadData: $e');
      _error = 'Không tải được dữ liệu, vui lòng thử lại';
    }
    _isLoading = false;
    notifyListeners();
  }

  void capNhatThongBao(List<ThongBao> list) {
    if (_data == null) return;
    _data = _data!.copyWith(thongBaoList: list);
    notifyListeners();
  }

  Future<void> danhDauDaDoc(ThongBao tb) async {
    if (tb.daDoc) return;

    final list = data?.thongBaoList;
    if (list != null) {
      final i = list.indexWhere((e) => e.id == tb.id);
      if (i != -1) {
        list[i] = tb.copyWith(daDoc: true);
        notifyListeners();
      }
    }

    // 2. Lưu lên server (API)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;

      debugPrint('>>> HOME FETCH cuDanId=$cuDanId');
      await _thongBaoServices.danhDauDaDoc(tb.id, cuDanId);
    } catch (e) {
      debugPrint('Lỗi đánh dấu đã đọc: $e');
    }
  }

  // Đánh dấu TẤT CẢ đã đọc (cập nhật local + lưu API)
  Future<void> danhDauTatCa() async {
    final list = data?.thongBaoList;
    if (list == null) return;

    // 1. Cập nhật local NGAY
    for (var i = 0; i < list.length; i++) {
      if (!list[i].daDoc) {
        list[i] = list[i].copyWith(daDoc: true);
      }
    }
    notifyListeners();

    // 2. Lưu lên server
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      await _thongBaoServices.danhDauTatCa(cuDanId);
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả: $e');
    }
  }
}
