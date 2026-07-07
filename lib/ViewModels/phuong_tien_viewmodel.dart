import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/Services/phuong_tien_services.dart';

/// Viewmodel dùng chung cho phương tiện:
/// - Danh sách xe (loadData)
/// - Loại xe cho form thêm (loadLoai)
/// - Thêm xe (submit)
class PhuongTienViewModel extends ChangeNotifier {
  final PhuongTienServices _services = PhuongTienServices();

  // ---- danh sách xe ----
  bool isLoading = false;
  String? error;
  List<PhuongTien> phuongTienList = [];

  // Chỉ hiển thị xe Đã duyệt (1) + Chờ duyệt (2), ẩn hủy/từ chối
  List<PhuongTien> get danhSachHienThi => phuongTienList
      .where((x) => x.trangThai == 1 || x.trangThai == 2)
      .toList();

  // ---- loại xe (cho form thêm) ----
  bool loadingLoai = false;
  List<LoaiPhuongTien> loaiList = [];

  // ---- thêm xe ----
  int? loaiId;
  bool submitting = false;

  void chonLoai(int id) {
    loaiId = id;
    notifyListeners();
  }

  // ============ TẢI DANH SÁCH XE ============
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      final canHoId = prefs.getInt('canHoId') ?? 0;

      phuongTienList = await _services.fetchPhuongTien(canHoId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải phương tiện: $e');
      error = 'Không tải được danh sách phương tiện';
      isLoading = false;
      notifyListeners();
    }
  }

  // ============ TẢI LOẠI XE ============
  Future<void> loadLoai() async {
    loadingLoai = true;
    notifyListeners();
    try {


      loaiList = await _services.fetchLoaiPhuongTien();
    } catch (e) {
      debugPrint('Lỗi tải loại phương tiện: $e');
    }
    loadingLoai = false;
    notifyListeners();
  }

  // ============ THÊM XE ============
  /// Trả về true nếu gửi thành công. false -> xem [error].
  Future<bool> submit({required String ten, required String bienSo}) async {
    error = null;

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

      final canHoId = prefs.getInt('canHoId') ?? 0;
      final cuDanId = prefs.getInt('cuDanId') ?? 0;

      if (canHoId == 0) {
        error = 'Không tìm thấy căn hộ của bạn. Vui lòng đăng nhập lại.';
        submitting = false;
        notifyListeners();
        return false;
      }

      await _services.dangKyPhuongTien(
        canHoId: canHoId,
        cuDanId: cuDanId,
        tenPhuongTien: ten.trim(),
        bienSo: bienSo.trim(),
        loaiPhuongTienId: loaiId!,
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
