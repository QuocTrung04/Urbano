import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano/Services/dat_lich_tien_ich_services.dart';

class DatLichViewModel extends ChangeNotifier {
  final DatLichServices _services = DatLichServices();

  bool isLoading = false;
  String? error;
  List<DatLichTienIch> danhSach = [];

  // tab: 0 Tất cả, 1 Đang đặt (chờ duyệt + đã duyệt), 2 Lịch sử (từ chối/hủy/hoàn thành)
  int tab = 0;

  List<DatLichTienIch> get danhSachLoc {
    switch (tab) {
      case 1:
        return danhSach
            .where((e) => e.trangThai == 1 || e.trangThai == 2)
            .toList();
      case 2:
        return danhSach
            .where(
              (e) => e.trangThai == 3 || e.trangThai == 4 || e.trangThai == 5,
            )
            .toList();
      default:
        return danhSach;
    }
  }

  // Số tiện ích đang đặt (chờ/đã duyệt) - dùng cho badge nếu cần
  int get soDangDat =>
      danhSach.where((e) => e.trangThai == 1 || e.trangThai == 2).length;

  void doiTab(int i) {
    tab = i;
    notifyListeners();
  }

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      if (cuDanId == 0) throw Exception('Không tìm thấy cư dân');

      danhSach = await _services.fetchByCuDan(cuDanId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải lịch đặt: $e');
      error = 'Không tải được danh sách';
      isLoading = false;
      notifyListeners();
    }
  }

  // Hủy đặt lịch. Trả true nếu thành công.
  Future<bool> huy(int id, String lyDo) async {
    try {


      await _services.huy(id, lyDo);
      await loadData();
      return true;
    } catch (e) {
      debugPrint('Lỗi hủy đặt lịch: $e');
      return false;
    }
  }
}
