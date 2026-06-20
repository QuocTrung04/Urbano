import 'package:flutter/material.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';

class HoaDonViewModel extends ChangeNotifier {
  final HoaDonServices _hoaDonServices = HoaDonServices();

  bool isLoading = false;
  String? error;
  List<HoaDonModel> hoaDonList = [];
  bool _isDisposed = false;

  Future<void> fetchHoaDons() async {
    // Prevent duplicate concurrent requests
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      hoaDonList = await _hoaDonServices.fetchHoaDons();
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
