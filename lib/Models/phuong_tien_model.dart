class LoaiPhuongTien {
  final int id;
  final String tenLoaiPhuongTien;
  LoaiPhuongTien({required this.id, required this.tenLoaiPhuongTien});
  factory LoaiPhuongTien.fromJson(Map<String, dynamic> json) {
    return LoaiPhuongTien(
      id: json['id'],
      tenLoaiPhuongTien: json['tenLoaiPhuongTien'] ?? '',
    );
  }
}

class PhuongTien {
  final int id;
  final String? tenPhuongTien;
  final String bienSo;
  final LoaiPhuongTien? loaiPhuongTien;
  final int? canHo;
  final DateTime? ngayDangKy;
  final DateTime? ngayHuy;
  final int trangThai;
  final int? nguoiCapNhat;
  final String? trangThaiText;
  PhuongTien({
    required this.id,
    this.tenPhuongTien,
    required this.bienSo,
    this.loaiPhuongTien,
    this.canHo,
    this.ngayDangKy,
    this.ngayHuy,
    required this.trangThai,
    this.trangThaiText,
    this.nguoiCapNhat,
  });
  factory PhuongTien.fromJson(Map<String, dynamic> json) {
    return PhuongTien(
      id: json['id'],
      tenPhuongTien: json['tenPhuongTien'],
      bienSo: json['bienSo'] ?? '',
      loaiPhuongTien: json['loaiPhuongTien'] != null
          ? LoaiPhuongTien.fromJson(json['loaiPhuongTien'])
          : null,
      trangThai: json['trangThai'] ?? 0,
      trangThaiText: json['trangThaiText'],
      canHo: json['canHo'],
      ngayDangKy: _parseDate(json['ngayDangKy']),
      ngayHuy: _parseDate(json['ngayHuy']),
      nguoiCapNhat: json['nguoiCapNhat'],
    );
  }
  String get loaiText => loaiPhuongTien?.tenLoaiPhuongTien ?? 'Khác';

  bool get laOto {
    final ten = loaiPhuongTien?.tenLoaiPhuongTien.toLowerCase() ?? '';
    return ten.contains('ô tô') ||
        ten.contains('oto') ||
        ten.contains('xe hơi');
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
