import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Services/cu_dan_services.dart';
import 'package:urbano/Services/yeu_cau_services.dart';
import 'package:urbano/core/utils/app_validators.dart';

/// Gửi yêu cầu THÊM NHÂN KHẨU (loại 6 - Yêu cầu xác thực cư dân) cho BQL duyệt.
/// Không tạo nhân khẩu thật ở client — BQL duyệt rồi mới thêm.
class ThemNhanKhauViewModel extends ChangeNotifier {
  final YeuCauServices _yeuCauServices = YeuCauServices();
  final CuDanServices _cuDanServices = CuDanServices();

  static const int _loaiThemNhanKhau = 6; // loai_yeu_cau: Yêu cầu xác thực cư dân

  bool submitting = false;
  String? error;

  Future<bool> submit({
    required String hoTen,
    DateTime? ngaySinh,
    required int? gioiTinh, // 1 Nam, 2 Nữ
    required String cccd,
    required String loaiCuTru,
    String sdt = '',
    String email = '',
    String diaChi = '',
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
    final cccdErr = AppValidators.validateCccd(cccd, isRequired: false);
    if (cccdErr != null) {
      error = cccdErr;
      notifyListeners();
      return false;
    }
    final sdtErr = AppValidators.validatePhone(sdt, isRequired: false);
    if (sdtErr != null) {
      error = sdtErr;
      notifyListeners();
      return false;
    }
    final emailErr = AppValidators.validateEmail(email, isRequired: false);
    if (emailErr != null) {
      error = emailErr;
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

      final checkResult = await _cuDanServices.checkExists(cccd: cccd.trim(), sdt: sdt.trim(), email: email.trim());
      final bool exists = checkResult['exists'] == true;
      final int? existingId = checkResult['cuDanId'];

      if (exists) {
        final noiDung = 'Thông báo: Cư dân ĐÃ CÓ tài khoản trên hệ thống (ID: $existingId).\n'
            'Họ tên: ${hoTen.trim()}\n'
            'SĐT: ${sdt.trim().isEmpty ? '(chưa có)' : sdt.trim()}\n'
            'Email: ${email.trim().isEmpty ? '(chưa có)' : email.trim()}\n'
            'CCCD: ${cccd.trim().isEmpty ? '(chưa có)' : cccd.trim()}\n'
            'Loại cư trú: $loaiCuTru\n'
            '-----\n'
            'Vui lòng ban quản lý sử dụng chức năng tìm kiếm cư dân theo CCCD/SĐT và thêm trực tiếp vào căn hộ.';

        await _yeuCauServices.createYeuCau(
          cuDan: cuDanId,
          loaiYeuCau: _loaiThemNhanKhau,
          tieuDe: 'Thêm nhân khẩu (đã có tài khoản)',
          noiDung: noiDung,
          mucDoUuTien: 1,
        );
      } else {
        final ns = _fmtNgay(ngaySinh);
        final gt = gioiTinh == 1 ? 'Nam' : 'Nữ';
        final noiDung =
            'Họ tên: ${hoTen.trim()}\n'
            'Ngày sinh: $ns\n'
            'Giới tính: $gt\n'
            'SĐT: ${sdt.trim().isEmpty ? '(chưa có)' : sdt.trim()}\n'
            'Email: ${email.trim().isEmpty ? '(chưa có)' : email.trim()}\n'
            'CCCD: ${cccd.trim().isEmpty ? '(chưa có)' : cccd.trim()}\n'
            'Loại cư trú: $loaiCuTru\n'
            'Địa chỉ/Quê quán: ${diaChi.trim()}';

        await _yeuCauServices.createYeuCau(
          cuDan: cuDanId,
          loaiYeuCau: _loaiThemNhanKhau,
          tieuDe: 'Thêm nhân khẩu',
          noiDung: noiDung,
          mucDoUuTien: 1,
        );

        // Tạo cư dân với trạng thái 1 (Chưa xác thực)
        final parts = hoTen.trim().split(RegExp(r'\s+'));
        String ten = parts.isNotEmpty ? parts.last : '';
        String hoTenDem = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : '';
        
        int? backendGioiTinh;
        if (gioiTinh == 1) {
          backendGioiTinh = 0; // Nam
        } else if (gioiTinh == 2) {
          backendGioiTinh = 1; // Nữ
        }

        await _cuDanServices.createCuDan(
          hoTenDem: hoTenDem,
          ten: ten,
          sdt: sdt.trim(),
          email: email.trim(),
          cccd: cccd.trim(),
          ngaySinh: ngaySinh,
          gioiTinh: backendGioiTinh,
          diaChi: diaChi.trim(),
        );
      }

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
