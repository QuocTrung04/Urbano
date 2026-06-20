import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Services/home_services.dart';
import 'package:urbano/Models/home_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeServices _services = HomeServices();

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
      _error = 'Không tải được dữ liệu, vui lòng thử lại';
    }
    _isLoading = false;
    notifyListeners();
  }

  void danhDauDaDoc(ThongBao tb) {
    if (tb.daDoc) return; // đã đọc rồi → khỏi làm

    // Cập nhật local (optimistic) — đổi daDoc thành true
    final list = data?.thongBaoList;
    if (list != null) {
      final i = list.indexWhere((e) => e.id == tb.id);
      if (i != -1) {
        list[i] = tb.copyWith(daDoc: true); // đánh dấu đã đọc
        notifyListeners(); // ẩn chấm + cập nhật
      }
    }
  }

  // // HomeViewModel:
  // Future<void> danhDauDaDoc(ThongBao tb) async {
  //   if (tb.daDoc) return;

  //   // Cập nhật list giả trong data (ẩn chấm ngay)
  //   final list = data?.thongBaoList;
  //   if (list != null) {
  //     final i = list.indexWhere((e) => e.id == tb.id);
  //     if (i != -1) {
  //       list[i] = tb.copyWith(daDoc: true);
  //       notifyListeners();
  //     }
  //   }

  //   // Lưu ID đã đọc vào prefs (nhớ khi mở lại app)
  //   final prefs = await SharedPreferences.getInstance();
  //   final daDocIds = prefs.getStringList('thongBaoDaDoc') ?? [];
  //   if (!daDocIds.contains(tb.id.toString())) {
  //     daDocIds.add(tb.id.toString());
  //     await prefs.setStringList('thongBaoDaDoc', daDocIds);
  //   }
  // }
}
