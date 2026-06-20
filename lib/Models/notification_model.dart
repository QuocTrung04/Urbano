//-----------THÔNG BÁO---------------

class ThongBao {
  final int id;
  final String? tieuDe;
  final String? noiDung;
  final int? nguoiTao;
  final bool daDoc;
  final DateTime? createdAt;

  ThongBao({
    required this.id,
    this.tieuDe,
    this.daDoc = true,
    this.noiDung,
    this.createdAt,
    this.nguoiTao,
  });
  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: json['id'],
      tieuDe: json['tieu_de'],
      noiDung: json['noi_dung'],
      nguoiTao: json['nguoi_tao'],
      createdAt: _parseDate(json['createAt']),
      daDoc: json['daDoc'] ?? false,
    );
  }
  String get thoiGianHienThi {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}  phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${(diff.inDays) ~/ 30} tháng trước';
  }

  ThongBao copyWith({
    int? id,
    String? tieuDe,
    String? noiDung,
    int? nguoiTao,
    bool? daDoc,
    DateTime? createdAt,
  }) {
    return ThongBao(
      id: id ?? this.id,
      tieuDe: tieuDe ?? this.tieuDe,
      noiDung: noiDung ?? this.noiDung,
      nguoiTao: nguoiTao ?? this.nguoiTao,
      daDoc: daDoc ?? this.daDoc,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
