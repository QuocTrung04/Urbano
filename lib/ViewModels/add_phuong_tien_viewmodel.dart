import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Services/phuong_tien_services.dart';

class ThemPhuongTienViewModel extends ChangeNotifier {
  final PhuongTienServices _services = PhuongTienServices();

  int? loaiId;
  bool submitting = false;
  String? error;

  void chonLoai(int id) {
    loaiId = id;
    notifyListeners();
  }

  // Trả về true nếu gửi thành công. Nếu false -> xem [error] để hiện thông báo.
  Future<bool> submit({required String ten, required String bienSo}) async {
    error = null;

    // ----- validate -----
    if (loaiId == null) {
      error = 'Vui lòng chọn loại phương tiện';
      notifyListeners();
      return false;
    }
    if (ten.trim().isEmpty) {
      error = 'Vui lòng nhập tên phương tiện';
      notifyListeners();
      return false;
    }
    if (bienSo.trim().isEmpty) {
      error = 'Vui lòng nhập biển số';
      notifyListeners();
      return false;
    }

    submitting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final canHoId = prefs.getInt('canHoId') ?? 0;
      final cuDanId = prefs.getInt('cuDanId');

      if (canHoId == 0) {
        error = 'Không tìm thấy căn hộ của bạn. Vui lòng đăng nhập lại.';
        submitting = false;
        notifyListeners();
        return false;
      }

      await _services.createPhuongTien(
        token,
        tenPhuongTien: ten.trim(),
        bienSo: bienSo.trim(),
        loaiPhuongTienId: loaiId!,
        canHoId: canHoId,
        nguoiCapNhatId: cuDanId,
      );

      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu phương tiện: $e');
      error = 'Gửi yêu cầu thất bại. Vui lòng thử lại.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }
}
