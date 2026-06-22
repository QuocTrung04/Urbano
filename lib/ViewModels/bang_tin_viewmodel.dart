import 'package:flutter/material.dart';
import 'package:urbano/Models/bang_tin_model.dart';

class BangTinViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<BangTin> danhSach = [];
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));
    try {
      danhSach = dsBangTin();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('loi tai bang tin: $e');
      error = 'Không tải được bảng tin';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  List<BangTin> dsBangTin() {
    return [
      BangTin(
        id: 1,
        tieuDe: 'Lịch bảo trì thang máy',
        noiDung:
            'Thang máy tòa A sẽ bảo trì ngày 20/06/2026 từ 8h-11h. Mong cư dân thông cảm và sử dụng thang máy tòa B trong thời gian này.',
        hinhUrl:
            'https://baohohoanglong.com/data/bien-canh-bao-thang-may-bao-tri.jpg',
        nguoiTao: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BangTin(
        id: 2,
        tieuDe: 'Thông báo thu phí tháng 5',
        noiDung:
            'Vui lòng thanh toán hóa đơn tháng 5 trước ngày 05/06/2026 để tránh phí trễ hạn.',
        hinhUrl: null, // không ảnh
        nguoiTao: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BangTin(
        id: 3,
        tieuDe: 'Sự kiện Tết Trung Thu 2026',
        noiDung:
            'Ban quản lý tổ chức đêm hội Trung Thu cho các bé tại sảnh chính lúc 19h ngày 15/08 âm lịch. Mời các gia đình tham gia!',
        hinhUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ69v_MEDo4peyRrBdGCWFD-n0vqlKBlfpCWA&s',
        nguoiTao: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
