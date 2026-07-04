class DatLichTienIch {
  final int id;
  final String maDatLich;
  final int tienIch;
  final String tenTienIch;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final int soNguoi;
  final double phiSuDung;
  final String ghiChu;
  final int trangThai; // 1 Chờ duyệt,2 Đã duyệt,3 Từ chối,4 Đã hủy,5 Hoàn thành
  final String lyDoHuy;
  final DateTime? createdAt;

  DatLichTienIch({
    required this.id,
    required this.maDatLich,
    required this.tienIch,
    this.tenTienIch = '',
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.soNguoi = 1,
    this.phiSuDung = 0,
    this.ghiChu = '',
    this.trangThai = 1,
    this.lyDoHuy = '',
    this.createdAt,
  });

  String get trangThaiText {
    switch (trangThai) {
      case 1:
        return 'Chờ duyệt';
      case 2:
        return 'Đã duyệt';
      case 3:
        return 'Từ chối';
      case 4:
        return 'Đã hủy';
      case 5:
        return 'Hoàn thành';
      default:
        return 'Không rõ';
    }
  }

  String get phiText {
    if (phiSuDung <= 0) return 'Miễn phí';
    final s = phiSuDung.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$buf đ';
  }

  factory DatLichTienIch.fromJson(Map<String, dynamic> json) {
    return DatLichTienIch(
      id: json['id'] ?? 0,
      maDatLich: json['maDatLich'] ?? '',
      tienIch: json['tienIch'] ?? 0,
      tenTienIch: json['tenTienIch'] ?? '',
      thoiGianBatDau: _d(json['thoiGianBatDau']),
      thoiGianKetThuc: _d(json['thoiGianKetThuc']),
      soNguoi: json['soNguoi'] ?? 1,
      phiSuDung: (json['phiSuDung'] as num?)?.toDouble() ?? 0,
      ghiChu: json['ghiChu'] ?? '',
      trangThai: json['trangThai'] ?? 1,
      lyDoHuy: json['lyDoHuy'] ?? '',
      createdAt: _d(json['createdAt']),
    );
  }
}

DateTime? _d(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
