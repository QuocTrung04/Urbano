import 'package:flutter/material.dart';
import 'package:urbano/core/constants/app_colors.dart';

class YeuCauCuDan {
  final int id;
  final int? cuDan;
  final int? loaiYeuCau;
  final String tieuDe;
  final String? noiDung;
  final DateTime? ngayGui;
  final int mucDoUuTien;
  final int trangThai;
  final int? nhanVienXuLy;
  final DateTime? ngayHoanThanh;
  final int? nguoiCapNhat;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  YeuCauCuDan({
    required this.id,
    required this.tieuDe,
    required this.mucDoUuTien,
    required this.trangThai,
    this.cuDan,
    this.loaiYeuCau,
    this.noiDung,
    this.ngayGui,
    this.ngayHoanThanh,
    this.nhanVienXuLy,
    this.nguoiCapNhat,
    this.createdAt,
    this.updatedAt,
  });
  factory YeuCauCuDan.fromJson(Map<String, dynamic> json) {
    return YeuCauCuDan(
      id: json['id'],
      tieuDe: json['tieuDe'] ?? '',
      mucDoUuTien: json['mucDoUuTien'] ?? 1,
      trangThai: json['trangThai'] ?? 1,
      cuDan: json['cuDan'],
      loaiYeuCau: json['loaiYeuCau'],
      noiDung: json['noiDung'],
      ngayGui: _parseDate(json['ngayGui']),
      ngayHoanThanh: _parseDate(json['ngayHoanThanh']),
      nhanVienXuLy: json['nhanVienXuLy'],
      nguoiCapNhat: json['nguoiCapNhat'],
      createdAt: _parseDate(json['createAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'cuDan': cuDan,
      'loaiYeuCau': loaiYeuCau,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'mucDoUuTien': mucDoUuTien,
      'trangThai': trangThai,
    };
  }

  String get uuTienText {
    switch (mucDoUuTien) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      default:
        return 'Cao';
    }
  }

  String get trangThaiText {
    switch (trangThai) {
      case 1:
        return 'Chờ xử lý';
      case 2:
        return 'Đang xử lý';
      default:
        return 'Hoàn thành';
    }
  }
}

class LoaiYeuCau {
  final int id;
  final String name;

  LoaiYeuCau({required this.id, required this.name});

  factory LoaiYeuCau.fromJson(Map<String, dynamic> json) {
    return LoaiYeuCau(id: json['id'], name: json['name'] ?? '');
  }

  IconData get icon {
    switch (id) {
      case 2:
        return Icons.volume_up_outlined; // Khiếu nại
      case 3:
        return Icons.help_outline; // Hỏi đáp
      default:
        return Icons.build_outlined; // Sửa chữa
    }
  }

  Color get color {
    switch (id) {
      case 2:
        return AppColors.red;
      case 3:
        return AppColors.blue;
      default:
        return AppColors.tealPrimary;
    }
  }

  static List<LoaiYeuCau> danhSach = [
    LoaiYeuCau(id: 1, name: 'Sửa chữa'),
    LoaiYeuCau(id: 2, name: 'Khiếu nại'),
    LoaiYeuCau(id: 3, name: 'Hỏi đáp'),
  ];

  static LoaiYeuCau timTheoId(int? id) {
    return danhSach.firstWhere((e) => e.id == id, orElse: () => danhSach.first);
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
