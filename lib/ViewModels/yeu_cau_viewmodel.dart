import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/Services/yeu_cau_services.dart';

class YeuCauViewModel extends ChangeNotifier {
  final YeuCauServices _services = YeuCauServices();

  bool isLoading = false;
  String? error;
  List<YeuCauCuDan> danhSach = [];

  int tab = 0;

  List<YeuCauCuDan> get danhSachLoc {
    if (tab == 0) return danhSach;
    return danhSach.where((yc) => yc.trangThai == tab).toList();
  }

  void doiTab(int index) {
    tab = index;
    notifyListeners();
  }

  void themYeuCauMoi(YeuCauCuDan yc) {
    danhSach.insert(0, yc);
    notifyListeners();
  }

  // ---- Tải danh sách yêu cầu của cư dân đang đăng nhập ----
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      if (cuDanId == 0) throw Exception('Không tìm thấy cư dân');

      danhSach = await _services.fetchByCuDan(token, cuDanId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi không tải được danh sách yêu cầu: $e');
      error = 'Không tải được danh sách';
      isLoading = false;
      notifyListeners();
    }
  }

  List<LoaiYeuCau> loaiList = [];
  bool submitting = false;

  Future<void> loadLoaiYeuCau() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      loaiList = await _services.fetchLoaiYeuCau(token);
      notifyListeners();
    } catch (_) {
      // form vẫn mở được nếu lỗi
    }
  }

  // Trả true nếu gửi thành công. Xem [error] khi false.
  Future<bool> taoYeuCau({
    required int loaiYeuCau,
    required String tieuDe,
    required String noiDung,
    required int mucDoUuTien,
  }) async {
    error = null;
    if (loaiYeuCau == 0) {
      error = 'Vui lòng chọn loại yêu cầu';
      notifyListeners();
      return false;
    }
    if (tieuDe.trim().isEmpty) {
      error = 'Vui lòng nhập tiêu đề';
      notifyListeners();
      return false;
    }
    if (noiDung.trim().isEmpty) {
      error = 'Vui lòng nhập nội dung';
      notifyListeners();
      return false;
    }

    submitting = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      if (cuDanId == 0) {
        error = 'Không tìm thấy cư dân. Vui lòng đăng nhập lại.';
        submitting = false;
        notifyListeners();
        return false;
      }

      final moi = await _services.createYeuCau(
        token,
        cuDan: cuDanId,
        loaiYeuCau: loaiYeuCau,
        tieuDe: tieuDe.trim(),
        noiDung: noiDung.trim(),
        mucDoUuTien: mucDoUuTien,
      );

      danhSach.insert(0, moi);
      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu: $e');
      error = 'Gửi yêu cầu thất bại. Vui lòng thử lại.';
      submitting = false;
      notifyListeners();
      return false;
    }
  }
}
