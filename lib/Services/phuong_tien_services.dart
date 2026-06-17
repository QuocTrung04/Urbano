import 'package:urbano/Models/phuong_tien_model.dart';

class PhuongTienServices {
  Future<List<PhuongTien>> fetchPhuongTien(String token, int cuDanId) async {
    await Future.delayed(Duration(milliseconds: 500));

    return [
      PhuongTien(
        id: 1,
        tenPhuongTien: 'Yamaha Mx King',
        bienSo: '86AD - 158.17',
        loaiPhuongTien: LoaiPhuongTien(id: 2, tenLoaiPhuongTien: 'Xe máy'),
        canHo: 1,
        ngayDangKy: DateTime(2026, 3, 21),
        trangThai: 1,
        trangThaiText: 'Đã duyệt',
      ),

      PhuongTien(
        id: 1,
        tenPhuongTien: 'Audi a7',
        bienSo: '48K - 123.45',
        loaiPhuongTien: LoaiPhuongTien(id: 1, tenLoaiPhuongTien: 'Xe hơi'),
        canHo: 1,
        ngayDangKy: DateTime(2026, 3, 21),
        trangThai: 2,
        trangThaiText: 'Chờ duyệt',
      ),
      PhuongTien(
        id: 1,
        tenPhuongTien: 'Audi a7',
        bienSo: '48K - 123.45',
        loaiPhuongTien: LoaiPhuongTien(id: 3, tenLoaiPhuongTien: 'xe đạp'),
        canHo: 1,
        ngayDangKy: DateTime(2026, 3, 21),
        trangThai: 3,
        trangThaiText: 'Từ chối',
      ),
    ];
  }
}
