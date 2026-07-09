import 'package:flutter/material.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';

class HoaDonViewModel extends ChangeNotifier {
  final HoaDonServices _hoaDonServices = HoaDonServices();
  bool isLoading = false;
  String? error;
  List<HoaDonModel> hoaDonList = [];
  int filterIndex = 0; // 0: Tất cả, 1: Chưa TT, 2: 1 phần, 3: Quá hạn, 4: Đã TT
  bool _isDisposed = false;

  void setFilter(int index) {
    filterIndex = index;
    notifyListeners();
  }

  List<HoaDonModel> get filteredList {
    if (filterIndex == 0) return hoaDonList;
    final now = DateTime.now();
    return hoaDonList.where((item) {
      final isPaid = item.daThanhToan || item.trangThai == 2;
      final isPartial = item.trangThai == 3;
      final isOverdue = item.hanThanhToan != null && item.hanThanhToan!.isBefore(now) && !isPaid;

      if (filterIndex == 1) return !isPaid && !isPartial && !isOverdue; // Chưa thanh toán
      if (filterIndex == 2) return isPartial && !isPaid; // Thanh toán 1 phần
      if (filterIndex == 3) return isOverdue; // Quá hạn
      if (filterIndex == 4) return isPaid; // Đã thanh toán
      return true;
    }).toList();
  }

  Future<void> fetchHoaDons(int canHoId) async {
    // Prevent duplicate concurrent requests
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      hoaDonList = await _hoaDonServices.fetchHoaDons(canHoId);
    } catch (e) {
      debugPrint('Lỗi tải hóa đơn: $e');
      error = 'Kết nối mạng không ổn định. Vui lòng thử lại!';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
