import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Services/yeu_cau_services.dart';

/// Gửi yêu cầu THÊM NHÂN KHẨU (loại 5) cho BQL duyệt.
/// Không tạo nhân khẩu thật ở client — BQL duyệt rồi mới thêm.
class ThemNhanKhauViewModel extends ChangeNotifier {
  final YeuCauServices _yeuCauServices = YeuCauServices();

  static const int _loaiThemNhanKhau = 5; // loai_yeu_cau: Thêm nhân khẩu

  bool submitting = false;
  String? error;

  Future<bool> submit({
    required String hoTen,
    DateTime? ngaySinh,
    required int? gioiTinh, // 1 Nam, 2 Nữ
    required String cccd,
    required String loaiCuTru,
  }) async {
    error = null;

    if (hoTen.trim().isEmpty) {
      error = 'Vui lòng nhập họ tên';
      notifyListeners();
      return false;
    }
    if (ngaySinh == null) {
      error = 'Vui lòng chọn ngày sinh';
      notifyListeners();
      return false;
    }
    if (gioiTinh == null) {
      error = 'Vui lòng chọn giới tính';
      notifyListeners();
      return false;
    }
    submitting = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      if (cuDanId == 0) {
        error = 'Không tìm thấy cư dân. Vui lòng đăng nhập lại.';
        submitting = false;
        notifyListeners();
        return false;
      }

      final ns = _fmtNgay(ngaySinh);
      final gt = gioiTinh == 1 ? 'Nam' : 'Nữ';
      final noiDung =
          'Họ tên: ${hoTen.trim()}\n'
          'Ngày sinh: $ns\n'
          'Giới tính: $gt\n'
          'CCCD: ${cccd.trim().isEmpty ? '(chưa có)' : cccd.trim()}\n'
          'Loại cư trú: $loaiCuTru';

      await _yeuCauServices.createYeuCau(
        cuDan: cuDanId,
        loaiYeuCau: _loaiThemNhanKhau,
        tieuDe: 'Thêm nhân khẩu',
        noiDung: noiDung,
        mucDoUuTien: 1,
      );

      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu thêm nhân khẩu: $e');
      error = 'Gửi yêu cầu thất bại. Vui lòng thử lại.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  String _fmtNgay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
