class CuDan {
  final int id;
  final String hoTen;
  final String? sdt;
  final String? cccd;
  final String? email;
  final DateTime? namSinh;
  final String? queQuan;

  CuDan({
    required this.id,
    required this.hoTen,
    this.cccd,
    this.email,
    this.namSinh,
    this.queQuan,
    this.sdt,
  });
  factory CuDan.fromJson(Map<String, dynamic> json) {
    return CuDan(
      id: json['id'],
      hoTen: json['ho_ten'] ?? '',
      sdt: json['sdt'],
      cccd: json['cccd'],
      email: json['email'],
      namSinh: _parseDate(json['nam_sinh']),
      queQuan: json['que_quan'],
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
