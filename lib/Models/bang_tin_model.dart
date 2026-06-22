class BangTin {
  final int id;
  final String? tieuDe;
  final String? noiDung;
  final String? hinhUrl;
  final int? nguoiTao;
  final int? nguoiCapNhat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  BangTin({
    required this.id,
    this.tieuDe,
    this.noiDung,
    this.hinhUrl,
    this.nguoiTao,
    this.nguoiCapNhat,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  factory BangTin.fromJson(Map<String, dynamic> json) {
    return BangTin(
      id: json['id'],
      tieuDe: json['tieuDe'],
      noiDung: json['noiDung'],
      hinhUrl: json['hinhUrl'],
      nguoiTao: json['nguoiTao'],
      nguoiCapNhat: json['nguoiCapNhat'],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      deletedAt: _parseDate(json['deletedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'hinhUrl': hinhUrl,
      'nguoiTao': nguoiTao,
      'nguoiCapNhat': nguoiCapNhat,
    };
  }

  bool get hinhanh => hinhUrl != null && hinhUrl!.trim().isNotEmpty;
  bool get tinMoi {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours < 24;
  }

  String get thoiGianHienThi {
    if (createdAt == null) return '';
    final thoigian = DateTime.now().difference(createdAt!);
    if (thoigian.inMinutes < 1) return 'Vừa xong';
    if (thoigian.inMinutes < 60) return '${thoigian.inMinutes} Phút trước';
    if (thoigian.inHours < 24) return '${thoigian.inHours} Giờ trước';
    if (thoigian.inDays < 30) return '${thoigian.inDays} Ngày trước';
    final d = createdAt!.day.toString().padLeft(2, '0');
    final m = createdAt!.month.toString().padLeft(2, '0');
    return '$d/$m/${createdAt!.year}';
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
