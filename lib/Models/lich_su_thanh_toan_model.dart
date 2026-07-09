class LichSuThanhToan {
  final int id;
  final int hoaDonId;
  final String maThanhToan;
  final int thang;
  final int nam;
  final DateTime? ngayThanhToan;
  final double soTien;
  final String phuongThucThanhToan;
  final String maGiaoDich;
  final String ghiChu;

  LichSuThanhToan({
    required this.id,
    required this.hoaDonId,
    this.maThanhToan = '',
    this.thang = 0,
    this.nam = 0,
    this.ngayThanhToan,
    this.soTien = 0,
    this.phuongThucThanhToan = '',
    this.maGiaoDich = '',
    this.ghiChu = '',
  });

  String get kyText => thang > 0 ? 'Tháng $thang/$nam' : '';

  String get soTienText => _tienVN(soTien);

  static String _tienVN(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$buf đ';
  }

  factory LichSuThanhToan.fromJson(Map<String, dynamic> json) {
    return LichSuThanhToan(
      id: json['id'] ?? 0,
      hoaDonId: json['hoaDonId'] ?? 0,
      maThanhToan: json['maThanhToan'] ?? '',
      thang: json['thang'] ?? 0,
      nam: json['nam'] ?? 0,
      ngayThanhToan: _parseDate(json['ngayThanhToan']),
      soTien: (json['soTien'] as num?)?.toDouble() ?? 0,
      phuongThucThanhToan: json['phuongThucThanhToan'] ?? '',
      maGiaoDich: json['maGiaoDich'] ?? '',
      ghiChu: json['ghiChu'] ?? '',
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
