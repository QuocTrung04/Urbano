//------------HÓA ĐƠN--------------

class HoaDonModel {
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

  HoaDonModel({
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
  factory HoaDonModel.fromJson(Map<String, dynamic> json) {
    return HoaDonModel(
      id: json['id'],
      canHo: json['canHo'] ?? json['can_ho'],
      thang: json['thang'],
      nam: json['nam'],
      maThanhToan: json['maThanhToan'] ?? json['ma_thanh_toan'],
      chiPhi:
          (json['chiPhi'] as num?)?.toDouble() ??
          (json['chi_phi'] as num?)?.toDouble(),
      hanThanhToan: _parseDate(json['hanThanhToan'] ?? json['han_thanh_toan']),
      soTienDaThanhToan:
          (json['soTienDaThanhToan'] as num?)?.toDouble() ??
          (json['so_tien_da_thanh_toan'] as num?)?.toDouble(),
      tongTien:
          (json['tongTien'] as num?)?.toDouble() ??
          (json['tong_tien'] as num?)?.toDouble(),
      trangThai: json['trangThai'] ?? json['trang_thai'],
      chiTietHoaDonList:
          (json['chi_tiet_hoa_don'] as List? ??
                  json['chiTietHoaDon'] as List? ??
                  [])
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
  //final int hoaDon;
  final String tenPhiDichVu;
  final double donGia;
  final int? soCu;
  final int? soMoi;
  final double soLuong;
  final double thanhTien;
  final DateTime? createAt;

  final LoaiPhiDichvu? loaiPhiDichVu;
  ChiTietHoaDon({
    required this.id,
    //required this.hoaDon,
    required this.tenPhiDichVu,
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
      //hoaDon: json['hoaDon'] ?? json['hoa_don'],
      tenPhiDichVu: json['tenPhiDichVu'] ?? "",
      donGia:
          (json['donGia'] as num?)?.toDouble() ??
          (json['don_gia'] as num?)?.toDouble() ??
          0.0,
      soLuong:
          (json['soLuong'] as num?)?.toDouble() ??
          (json['so_luong'] as num?)?.toDouble() ??
          0.0,
      thanhTien:
          (json['thanhTien'] as num?)?.toDouble() ??
          (json['thanh_tien'] as num?)?.toDouble() ??
          0.0,
      soCu:
          json['chiSoCu'] ?? json['chi_so_cu'] ?? json['soCu'] ?? json['so_cu'],
      soMoi:
          json['chiSoMoi'] ??
          json['chi_so_moi'] ??
          json['soMoi'] ??
          json['so_moi'],
      createAt: _parseDate(json['createAt'] ?? json['create_at']),
      loaiPhiDichVu: (json['loaiPhiDichVu'] ?? json['loai_phi_dich_vu']) != null
          ? LoaiPhiDichvu.fromJson(
              json['loaiPhiDichVu'] ?? json['loai_phi_dich_vu'],
            )
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
      tenPhiDichVu:
          json['tenLoaiPhiDichVu'] ??
          json['ten_loai_phi_dich_vu'] ??
          json['tenPhiDichVu'] ??
          json['ten_phi_dich_vu'] ??
          '',
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
