//-----------CĂN HỘ------------

class CanHo {
  final int id;
  final int toaNha;
  final String soCanHo;
  final int? tang;
  final double? dienTich;
  final int? trangThai;
  final double? gia;
  final int? loaiCanHo;
  final String? tenToaNha;
  final String? loaiCanHoText;
  final String? trangThaiText;

  CanHo({
    required this.id,
    required this.toaNha,
    required this.soCanHo,
    this.dienTich,
    this.gia,
    this.loaiCanHo,
    this.tang,
    this.trangThai,
    this.tenToaNha,
    this.loaiCanHoText,
    this.trangThaiText,
  });
  factory CanHo.fromJson(Map<String, dynamic> json) {
    return CanHo(
      id: json['id'] ?? 0,
      // backend gửi 'toaNhaId' -> đọc cả 2, mặc định 0 để không crash
      toaNha: json['toaNha'] ?? json['toaNhaId'] ?? 0,
      soCanHo: json['soCanHo'] ?? '',
      tang: json['tang'],
      dienTich: (json['dienTich'] as num?)?.toDouble(),
      trangThai: json['trangThai'] ?? json['trangThaiId'],
      gia: (json['gia'] as num?)?.toDouble(),
      loaiCanHo: json['loaiCanHo'] ?? json['loaiCanHoId'],
      tenToaNha: json['tenToaNha'],
      // backend gửi 'tenLoaiCanHo' / 'tenTrangThai'
      loaiCanHoText: json['loaiCanHoText'] ?? json['tenLoaiCanHo'],
      trangThaiText: json['trangThaiText'] ?? json['tenTrangThai'],
    );
  }
}
