import 'package:flutter/material.dart';

import 'package:urbano/Services/auth_services.dart';

class ChangePasswordViewmodel extends ChangeNotifier {
  final AuthServices _services = AuthServices();

  bool isLoading = false;

  String? errCu;
  String? errMoi;
  String? errXacNhan;

  void _xoaLoi() {
    errCu = null;
    errMoi = null;
    errXacNhan = null;
  }

  Future<bool> doiMatKhau(
    int cuDanId,
    String matKhauCu,
    String matKhauMoi,
    String xacNhanMatKhau,
  ) async {
    _xoaLoi();
    if (matKhauCu.isEmpty) {
      errCu = 'Vui lòng nhập mật khẩu hiện tại';
      notifyListeners();
      return false;
    }
    if (matKhauMoi.length < 6) {
      errMoi = 'Mật khẩu phải ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }
    if (matKhauMoi == matKhauCu) {
      errMoi = 'Mật khẩu mới phải khác mật khẩu cũ';
      notifyListeners();
      return false;
    }
    if (matKhauMoi != xacNhanMatKhau) {
      errXacNhan = 'Xác nhận mật khẩu không khớp';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();
    try {

      await _services.doiMatKhau(cuDanId, matKhauCu, matKhauMoi);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi đổi mật khẩu 🥲: $e');
      errCu = 'Mật khẩu hiện tại không đúng';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
