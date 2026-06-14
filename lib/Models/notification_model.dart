//-----------THÔNG BÁO---------------

class ThongBao {
  final int id;
  final String? tieuDe;
  final String? noiDung;
  final int? nguoiTao;
  final bool trangthai;
  final DateTime? createdAt;

  ThongBao({
    required this.id,
    this.tieuDe,
    this.trangthai = true,
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
      trangthai: json['trang_thai'] == true || json['trang_thai'] == 1,
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
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
