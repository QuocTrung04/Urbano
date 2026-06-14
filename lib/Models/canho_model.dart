//-----------CĂN HỘ------------

class CanHo {
  final int id;
  final int toaNha;
  final int? tinhTrang;
  final String soCanHo;
  final int? tang;
  final double? dienTich;
  final int? trangThai;
  final double? gia;
  final int? loaiCanHo;

  CanHo({
    required this.id,
    required this.toaNha,
    required this.soCanHo,
    this.dienTich,
    this.gia,
    this.loaiCanHo,
    this.tang,
    this.tinhTrang,
    this.trangThai,
  });
  factory CanHo.fromJson(Map<String, dynamic> json) {
    return CanHo(
      id: json['id'],
      toaNha: json['toa_nha'],
      soCanHo: json['so_can_ho'],
      tinhTrang: json['tinh_trang_so_huu'],
      tang: json['tang'],
      dienTich: json['dien_tich'],
      trangThai: json['trang_thai'],
      gia: json['gia'],
      loaiCanHo: json['loai_can_ho'],
    );
  }
}
