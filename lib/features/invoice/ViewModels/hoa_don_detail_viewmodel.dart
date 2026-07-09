import 'package:flutter/material.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';

class HoaDonDetailViewModel extends ChangeNotifier {
  final HoaDonServices services;
  HoaDonModel hoaDon;
  bool isLoading = false;
  String? error;
  bool _isDisposed = false;

  HoaDonDetailViewModel({required this.services, required this.hoaDon});

  Future<void> fetchDetail() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await services.fetchHoaDonDetail(hoaDon.id);
      debugPrint('ai di hoa don: ${hoaDon.id}');
      hoaDon = updated;
    } catch (e, stack) {
      debugPrint('Lỗi tải chi tiết hóa đơn: $e');
      debugPrint(e.toString());
      debugPrint(stack.toString());
      if (hoaDon.chiTietHoaDonList.isEmpty) {
        error = 'Không thể tải thông tin chi tiết hóa đơn.';
      }
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
