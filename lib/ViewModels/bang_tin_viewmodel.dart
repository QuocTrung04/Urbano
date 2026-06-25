import 'package:flutter/material.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/Services/bang_tin_services.dart';

class BangTinViewModel extends ChangeNotifier {
  final BangTinServices _services = BangTinServices();
  bool isLoading = false;
  String? error;
  List<BangTin> danhSach = [];
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      danhSach = await _services.fetchBangTin();
    } catch (e) {
      debugPrint('loi tai bang tin: $e');
      error = 'Không tải được bảng tin';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
