class NhanKhau {
  final int id;
  final String hoTen;
  final int vaiTroId; // 1 Chủ hộ, 2 Thành viên, 3 Người thuê
  final String vaiTro;
  final String? sdt;
  final String? cccd;
  final String? email;
  final DateTime? ngaySinh;
  final int? gioiTinh; // 1 = Nam, 2 = Nữ
  final DateTime? ngayChuyenDen;
  final DateTime? ngayChuyenDi;

  NhanKhau({
    required this.id,
    required this.hoTen,
    required this.vaiTroId,
    required this.vaiTro,
    this.sdt,
    this.cccd,
    this.email,
    this.ngaySinh,
    this.gioiTinh,
    this.ngayChuyenDen,
    this.ngayChuyenDi,
  });

  bool get laChuHo => vaiTroId == 1;
  bool get laNguoiThue => vaiTroId == 3;

  // Người thuê -> Tạm trú, còn lại -> Thường trú
  String get cuTruText => laNguoiThue ? 'Tạm trú' : 'Thường trú';

  int? get namSinh => ngaySinh?.year;

  String get gioiTinhText {
    switch (gioiTinh) {
      case 1:
        return 'Nam';
      case 2:
        return 'Nữ';
      default:
        return 'Chưa rõ';
    }
  }

  bool get dangCuTru => ngayChuyenDi == null;

  int? get tuoi {
    if (ngaySinh == null) return null;
    final now = DateTime.now();
    var age = now.year - ngaySinh!.year;
    if (now.month < ngaySinh!.month ||
        (now.month == ngaySinh!.month && now.day < ngaySinh!.day)) {
      age--;
    }
    return age;
  }

  String get chuCaiDau {
    final parts = hoTen.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    final a = parts[parts.length - 2];
    final b = parts.last;
    return (a.substring(0, 1) + b.substring(0, 1)).toUpperCase();
  }

  factory NhanKhau.fromJson(Map<String, dynamic> json) {
    return NhanKhau(
      id: json['id'] ?? 0,
      hoTen: json['hoTen'] ?? _ghepTen(json),
      vaiTroId: json['vaiTroId'] ?? 0,
      vaiTro: json['vaiTro'] ?? json['tenVaiTro'] ?? 'Thành viên',
      sdt: json['sdt'],
      cccd: json['cccd'],
      email: json['email'],
      ngaySinh: _parseDate(json['ngaySinh']),
      gioiTinh: json['gioiTinh'],
      ngayChuyenDen: _parseDate(json['ngayChuyenDen']),
      ngayChuyenDi: _parseDate(json['ngayChuyenDi']),
    );
  }

  static String _ghepTen(Map<String, dynamic> json) {
    final dem = (json['hoTenDem'] ?? '').toString();
    final ten = (json['ten'] ?? '').toString();
    return '$dem $ten'.trim();
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
