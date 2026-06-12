//-----------CƯ DÂN------------

import 'dart:collection';

import 'package:flutter/cupertino.dart';

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

//------------HÓA ĐƠN--------------

class HoaDon {
  final int id;
  final String? maThanhToan;
  final int canHo;
  final int thang;
  final int nam;
  final double? tongTien;
  final double? soTienDaThanhToan;
  final double? chiPhi;
  final DateTime? hanThanhToan;
  final int? trangThai;

  final List<ChiTietHoaDon> chiTietHoaDonList;

  HoaDon({
    required this.id,
    required this.canHo,
    required this.thang,
    required this.nam,
    this.maThanhToan,
    this.chiPhi,
    this.hanThanhToan,
    this.soTienDaThanhToan,
    this.tongTien,
    this.trangThai,
    this.chiTietHoaDonList = const [],
  });
  factory HoaDon.fromJson(Map<String, dynamic> json) {
    return HoaDon(
      id: json['id'],
      canHo: json['can_ho'],
      thang: json['thang'],
      nam: json['nam'],
      maThanhToan: json['ma_thanh_toan'],
      chiPhi: (json['chi_phi'] as num?)?.toDouble(),
      hanThanhToan: _parseDate(json['han_thanh_toan']),
      soTienDaThanhToan: (json['so_tien_da_thanh_toan'] as num?)?.toDouble(),
      tongTien: (json['tong_tien'] as num?)?.toDouble(),
      trangThai: json['trang_thai'],
      chiTietHoaDonList: (json['chi_tiet_hoa_don'] as List? ?? [])
          .map((item) => ChiTietHoaDon.fromJson(item))
          .toList(),
    );
  }

  String get kyThanhToan {
    return 'Tháng $thang/$nam';
  }

  bool get daThanhToan {
    final total = tongTien ?? 0;
    final pair = soTienDaThanhToan ?? 0;
    return total > 0 && pair >= total;
  }

  String get tongTienHienThi {
    return _formatPrice(tongTien ?? 0);
  }
}

//-----------CHI TIẾT HÓA ĐƠN--------
class ChiTietHoaDon {
  final int id;
  final int hoaDon;
  final int phiDichVu;
  final double donGia;
  final int? soCu;
  final int? soMoi;
  final double soLuong;
  final double thanhTien;
  final DateTime? createAt;

  final LoaiPhiDichvu? loaiPhiDichVu;
  ChiTietHoaDon({
    required this.id,
    required this.hoaDon,
    required this.phiDichVu,
    required this.donGia,
    this.soCu,
    this.soMoi,
    required this.soLuong,
    required this.thanhTien,
    this.createAt,
    this.loaiPhiDichVu,
  });
  factory ChiTietHoaDon.fromJson(Map<String, dynamic> json) {
    return ChiTietHoaDon(
      id: json['id'],
      hoaDon: json['hoa_don'],
      phiDichVu: json['phi_dich_vu'],
      donGia: json['don_gia'],
      soLuong: json['so_luong'],
      thanhTien: json['thanh_tien'],
      soCu: json['chi_so_cu'],
      soMoi: json['chi_so_moi'],
      createAt: _parseDate(json['createAt']),
      loaiPhiDichVu: json['loai_phi_dich_vu'] != null
          ? LoaiPhiDichvu.fromJson(json["loai_phi_dich_vu"])
          : null,
    );
  }
}

//-----------LOẠI PHÍ DỊCH VỤ--------
class LoaiPhiDichvu {
  final int id;
  final String tenPhiDichVu;
  LoaiPhiDichvu({required this.id, required this.tenPhiDichVu});
  factory LoaiPhiDichvu.fromJson(Map<String, dynamic> json) {
    return LoaiPhiDichvu(
      id: json['id'],
      tenPhiDichVu: json['ten_loai_phi_dich_vu'] ?? '',
    );
  }
}

//-----------THÔNG BÁO---------------

class ThongBao {
  final int id;
  final String? tieuDe;
  final String? noiDung;
  final int? nguoiTao;
  final DateTime? creatrAt;

  ThongBao({
    required this.id,
    this.tieuDe,
    this.noiDung,
    this.creatrAt,
    this.nguoiTao,
  });
  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: json['id'],
      tieuDe: json['tieu_de'],
      noiDung: json['noi_dung'],
      nguoiTao: json['nguoi_tao'],
      creatrAt: _parseDate(json['createAt']),
    );
  }
  String get thoiGianHienThi {
    if (creatrAt == null) return '';
    final diff = DateTime.now().difference(creatrAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}  phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${(diff.inDays) ~/ 30} tháng trước';
  }
}

class HomeData {
  final CuDan cuDan;
  final CanHo canHo;
  final String tenToaNha;
  final List<HoaDon> hoaDonList;
  final List<ThongBao> thongBaoList;

  HomeData({
    required this.cuDan,
    required this.canHo,
    required this.tenToaNha,
    required this.hoaDonList,
    required this.thongBaoList,
  });
  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      cuDan: CuDan.fromJson(json['cu_dan']),
      canHo: CanHo.fromJson(json['can_ho']),
      tenToaNha: json['ten_toa_nha'] ?? '',
      hoaDonList: (json['hoa_don_list'] as List? ?? [])
          .map((item) => HoaDon.fromJson(item))
          .toList(),
      thongBaoList: (json['thong_bao_list'] as List? ?? [])
          .map((item) => ThongBao.fromJson(item))
          .toList(),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _formatPrice(double price) {
  final s = price.toInt().toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buffer.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buffer.write('.');
  }
  return '${buffer.toString().split('').reversed.join()}đ';
}
