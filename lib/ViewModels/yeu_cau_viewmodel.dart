import 'package:flutter/material.dart';
import 'package:urbano/Models/yeu_cau_model.dart';

class YeuCauViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<YeuCauCuDan> danhSach = [];
  int tab = 0;

  List<YeuCauCuDan> get danhSachLoc {
    if (tab == 0) {
      return danhSach;
    }
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

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      danhSach = _dsYeuCau();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi không tải được danh sách yêu cầu: $e');
      error = 'Không tải được danh sách';
      isLoading = false;
      notifyListeners();
    }
  }

  List<YeuCauCuDan> _dsYeuCau() {
    return [
      YeuCauCuDan(
        id: 1,
        cuDan: 1,
        loaiYeuCau: 1,
        tieuDe: 'Rò rỉ nước nhà tắm',
        noiDung: 'Vòi nước nhà tắm bị rò rỉ, nhờ kỹ thuật kiểm tra.',
        ngayGui: DateTime(2026, 6, 18, 8, 56),
        mucDoUuTien: 2,
        trangThai: 1,
        createdAt: DateTime(2026, 6, 18, 8, 56),
      ),
      YeuCauCuDan(
        id: 2,
        cuDan: 3,
        loaiYeuCau: 2,
        tieuDe: 'Tiếng ồn ban đêm',
        noiDung: 'Căn hộ tầng trên gây ồn sau 22h.',
        ngayGui: DateTime(2026, 6, 18, 8, 56),
        mucDoUuTien: 1,
        trangThai: 1,
        createdAt: DateTime(2026, 6, 18, 8, 56),
      ),
      YeuCauCuDan(
        id: 3,
        cuDan: 4,
        loaiYeuCau: 3,
        tieuDe: 'Hỏi về phí gửi xe',
        noiDung: 'Cho hỏi mức phí gửi xe mấy tháng là bao nhiêu?',
        ngayGui: DateTime(2026, 6, 18, 8, 56),
        mucDoUuTien: 1,
        trangThai: 2,
        nhanVienXuLy: 3,
        createdAt: DateTime(2026, 6, 18, 8, 56),
      ),
      YeuCauCuDan(
        id: 4,
        cuDan: 1,
        loaiYeuCau: 1,
        tieuDe: 'Thay khóa cửa ban công',
        noiDung: 'Khóa cửa ban công bị kẹt, yêu cầu thay khóa mới.',
        ngayGui: DateTime(2026, 6, 12, 10, 0),
        mucDoUuTien: 1,
        trangThai: 3,
        nhanVienXuLy: 2,
        ngayHoanThanh: DateTime(2026, 6, 13, 14, 0),
        createdAt: DateTime(2026, 6, 12, 10, 0),
      ),
    ];
  }
}
