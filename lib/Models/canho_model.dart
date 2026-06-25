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
      id: json['id'],
      toaNha: json['toaNha'],
      soCanHo: json['soCanHo'],
      tang: json['tang'],
      dienTich: json['dienTich'],
      trangThai: json['trangThai'],
      gia: json['gia'],
      loaiCanHo: json['loaiCanHo'],
      tenToaNha: json['tenToaNha'],
      loaiCanHoText: json['loaiCanHoText'],
      trangThaiText: json['trangThaiText'],
    );
  }
}
