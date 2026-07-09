import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';

class ThongBaoThanhToanViewModel extends ChangeNotifier {
  final HoaDonServices _services = HoaDonServices();

  bool isLoading = false;
  String? error;
  List<HoaDonModel> _all = [];

  double conLai(HoaDonModel h) {
    final c = (h.tongTien ?? 0) - (h.soTienDaThanhToan ?? 0);
    return c < 0 ? 0 : c;
  }

  // Hóa đơn còn nợ (chưa thanh toán / thanh toán 1 phần), hạn gần nhất lên đầu
  List<HoaDonModel> get chuaThanhToan {
    final list = _all.where((h) => conLai(h) > 0).toList();
    list.sort((a, b) {
      final da = a.hanThanhToan ?? DateTime(2100);
      final db = b.hanThanhToan ?? DateTime(2100);
      return da.compareTo(db);
    });
    return list;
  }

  double get tongConNo => chuaThanhToan.fold(0.0, (s, h) => s + conLai(h));

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final canHoId = prefs.getInt('canHoId') ?? 0;
      if (canHoId == 0) throw Exception('Không tìm thấy căn hộ');

      _all = await _services.fetchHoaDons(canHoId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải thông báo thanh toán: $e');
      error = 'Không tải được dữ liệu';
      isLoading = false;
      notifyListeners();
    }
  }
}
