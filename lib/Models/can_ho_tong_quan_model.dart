class ThuocTinhCanHo {
  final int thuocTinhId;
  final String tenThuocTinh;
  final String giaTri;

  ThuocTinhCanHo({
    required this.thuocTinhId,
    required this.tenThuocTinh,
    required this.giaTri,
  });

  factory ThuocTinhCanHo.fromJson(Map<String, dynamic> json) {
    return ThuocTinhCanHo(
      thuocTinhId: json['thuocTinhId'] ?? 0,
      tenThuocTinh: json['tenThuocTinh'] ?? '',
      giaTri: (json['giaTri'] ?? '').toString(),
    );
  }
}

class CanHoTongQuan {
  final int id;
  final String soCanHo;
  final String tenToaNha;
  final int tang;
  final List<ThuocTinhCanHo> thuocTinhs;

  CanHoTongQuan({
    required this.id,
    required this.soCanHo,
    required this.tenToaNha,
    required this.tang,
    required this.thuocTinhs,
  });

  factory CanHoTongQuan.fromJson(Map<String, dynamic> json) {
    final list = (json['thuocTinhs'] as List?) ?? const [];
    return CanHoTongQuan(
      id: json['id'] ?? 0,
      soCanHo: json['soCanHo'] ?? '',
      tenToaNha: json['tenToaNha'] ?? '',
      tang: json['tang'] ?? 0,
      thuocTinhs: list
          .map((e) => ThuocTinhCanHo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
