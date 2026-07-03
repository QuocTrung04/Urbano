import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/lich_su_thanh_toan_model.dart';
import 'package:urbano/Services/lich_su_thanh_toan_services.dart';

class LichSuThanhToanViewModel extends ChangeNotifier {
  final LichSuThanhToanServices _services = LichSuThanhToanServices();

  bool isLoading = false;
  String? error;
  int canHoId = 0;
  List<LichSuThanhToan> danhSach = [];

  double get tongDaThanhToan => danhSach.fold(0.0, (sum, e) => sum + e.soTien);

  // Tổng đã đóng trong NĂM HIỆN TẠI (không phình theo thời gian)
  double get daDongNamNay {
    final nam = DateTime.now().year;
    return danhSach
        .where((e) => e.ngayThanhToan != null && e.ngayThanhToan!.year == nam)
        .fold(0.0, (sum, e) => sum + e.soTien);
  }

  // Số giao dịch trong năm nay
  int get soGiaoDichNamNay {
    final nam = DateTime.now().year;
    return danhSach
        .where((e) => e.ngayThanhToan != null && e.ngayThanhToan!.year == nam)
        .length;
  }

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      canHoId = prefs.getInt('canHoId') ?? 0;
      if (canHoId == 0) throw Exception('Không tìm thấy căn hộ');

      danhSach = await _services.fetchByCanHo(token, canHoId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải lịch sử thanh toán: $e');
      error = 'Không tải được lịch sử thanh toán';
      isLoading = false;
      notifyListeners();
    }
  }
}
