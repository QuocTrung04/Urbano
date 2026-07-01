class LoaiPhuongTien {
  final int id;
  final String tenLoaiPhuongTien;

  LoaiPhuongTien({required this.id, required this.tenLoaiPhuongTien});
}

class PhuongTien {
  final int id;
  final String? tenPhuongTien;
  final String bienSo;

  final LoaiPhuongTien loaiPhuongTien;

  final int canHoId;
  final String soCanHo;

  final DateTime? ngayDangKy;
  final DateTime? ngayHuy;

  final int trangThai;

  final int? nguoiCapNhatId;
  final String tenNguoiCapNhat;

  PhuongTien({
    required this.id,
    this.tenPhuongTien,
    required this.bienSo,
    required this.loaiPhuongTien,
    required this.canHoId,
    required this.soCanHo,
    this.ngayDangKy,
    this.ngayHuy,
    required this.trangThai,
    this.nguoiCapNhatId,
    required this.tenNguoiCapNhat,
  });

  factory PhuongTien.fromJson(Map<String, dynamic> json) {
    return PhuongTien(
      id: json['id'] ?? 0,
      tenPhuongTien: json['tenPhuongTien'],
      bienSo: json['bienSo'] ?? '',

      loaiPhuongTien: LoaiPhuongTien(
        id: json['loaiPhuongTienId'] ?? 0,
        tenLoaiPhuongTien: json['tenLoaiPhuongTien'] ?? '',
      ),

      canHoId: json['canHoId'] ?? 0,
      soCanHo: json['soCanHo'] ?? '',

      ngayDangKy: _parseDate(json['ngayDangKy']),
      ngayHuy: _parseDate(json['ngayHuy']),

      trangThai: json['trangThai'] ?? 0,

      nguoiCapNhatId: json['nguoiCapNhatId'],
      tenNguoiCapNhat: json['tenNguoiCapNhat'] ?? '',
    );
  }
  String get trangThaiText {
    switch (trangThai) {
      case 0:
        return 'Đã hủy';
      case 1:
        return 'Đã duyệt';
      case 2:
        return 'Chờ duyệt';
      case 3:
        return 'Từ chối';
      default:
        return 'Không rõ';
    }
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
