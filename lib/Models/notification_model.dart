//-----------THÔNG BÁO---------------

class ThongBao {
  final int id;
  final String? tieuDe;
  final String? noiDung;
  final int? nguoiTao;
  bool daDoc;
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
      tieuDe: json['tieuDe'],
      noiDung: json['noiDung'],
      nguoiTao: json['nguoiTao'],
      createdAt: _parseDate(json['createdAt']),
      daDoc: json['daDoc'] ?? false,
    );
  }
  String get thoiGianHienThi {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Vừa xong';
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
