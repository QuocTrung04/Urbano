import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Services/notification_services.dart';
import '../Models/notification_model.dart';

class ThongBaoViewModel extends ChangeNotifier {
  List<ThongBao> _thongBaoList = [];

  List<ThongBao> get thongBaoList => _thongBaoList;
  final ThongbaoServices thongbaoServices = ThongbaoServices();
  int get soChuaDoc => _thongBaoList.where((x) => !x.daDoc).length;

  Future<void> loadThongBao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      _thongBaoList = await thongbaoServices.fetchThongBao(cuDanId);

      notifyListeners();
    } catch (e) {
      debugPrint('Load thông báo lỗi: $e');
    }
  }

  Future<void> danhDauDaDoc(ThongBao tb) async {
    if (tb.daDoc) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      debugPrint('>>> ĐÁNH DẤU cuDanId=$cuDanId, tin=${tb.id}');
      await thongbaoServices.danhDauDaDoc(tb.id, cuDanId);

      tb.daDoc = true;

      notifyListeners();
    } catch (e) {
      debugPrint('Đánh dấu đã đọc lỗi: $e');
    }
  }

  Future<void> danhDauTatCa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;

      await thongbaoServices.danhDauTatCa(cuDanId);

      for (final tb in _thongBaoList) {
        tb.daDoc = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Đánh dấu tất cả lỗi: $e');
    }
  }
}
