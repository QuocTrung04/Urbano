class CuDan {
  final int id;
  final String? hoTenDem;
  final String? ten;
  final String hoTen;
  final String? sdt;
  final String? cccd;
  final String? email;
  final DateTime? ngaySinh;
  final int? gioiTinh;
  final String? gioiTinhText;
  final String? tinh;
  final String? xa;
  final String? diaChi;
  final String? diaChiDayDu;
  final int? trangThai;
  final String? trangThaiText;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  CuDan({
    required this.id,
    required this.hoTen,
    this.hoTenDem,
    this.ten,
    this.cccd,
    this.diaChi,
    this.diaChiDayDu,
    this.email,
    this.gioiTinh,
    this.gioiTinhText,
    this.ngaySinh,
    this.sdt,
    this.tinh,
    this.trangThai,
    this.trangThaiText,
    this.xa,
    this.createdAt,
    this.updatedAt,
  });
  factory CuDan.fromJson(Map<String, dynamic> json) {
    return CuDan(
      id: json['id'],
      hoTen: json['hoTen'] ?? '',
      hoTenDem: json['hoTenDem'],
      ten: json['ten'],
      cccd: json['cccd'],
      tinh: json['tinh'],
      xa: json['xa'],
      diaChi: json['diaChi'],
      diaChiDayDu: json['diaChiDayDu'],
      email: json['email'],
      gioiTinh: json['gioiTinh'],
      gioiTinhText: json['gioiTinhText'],
      ngaySinh: _parseDate(json['ngaySinh']),
      sdt: json['sdt'],
      trangThai: json['trangThai'],
      trangThaiText: json['trangThaiText'],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hoTen': hoTen,
    'hoTenDem': hoTenDem,
    'ten': ten,
    'cccd': cccd,
    'tinh': tinh,
    'xa': xa,
    'diaChi': diaChi,
    'diaChiDayDu': diaChiDayDu,
    'email': email,
    'gioiTinh': gioiTinh,
    'gioiTinhText': gioiTinhText,
    'ngaySinh': ngaySinh?.toIso8601String(),
    'sdt': sdt,
    'trangThai': trangThai,
    'trangThaiText': trangThaiText,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  CuDan copyWith({
    int? id,
    String? hoTenDem,
    String? ten,
    String? hoTen,
    String? sdt,
    String? cccd,
    String? email,
    DateTime? ngaySinh,
    int? gioiTinh,
    String? gioiTinhText,
    String? tinh,
    String? xa,
    String? diaChi,
    String? diaChiDayDu,
    int? trangThai,
    String? trangThaiText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CuDan(
      id: id ?? this.id,
      hoTenDem: hoTenDem ?? this.hoTenDem,
      ten: ten ?? this.ten,
      hoTen: hoTen ?? this.hoTen,
      sdt: sdt ?? this.sdt,
      cccd: cccd ?? this.cccd,
      email: email ?? this.email,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      gioiTinhText: gioiTinhText ?? this.gioiTinhText,
      tinh: tinh ?? this.tinh,
      xa: xa ?? this.xa,
      diaChi: diaChi ?? this.diaChi,
      diaChiDayDu: diaChiDayDu ?? this.diaChiDayDu,
      trangThai: trangThai ?? this.trangThai,
      trangThaiText: trangThaiText ?? this.trangThaiText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
