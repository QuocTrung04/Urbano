class CauHinhThanhToanModel {
  final int id;
  final String dinhDanhThuHuong;
  final String maNhanDien;
  final String tenChuTaiKhoan;
  final String tenNhaCungCap;
  final int trangThai;

  CauHinhThanhToanModel({
    required this.id,
    required this.dinhDanhThuHuong,
    required this.maNhanDien,
    required this.tenChuTaiKhoan,
    required this.tenNhaCungCap,
    required this.trangThai,
  });

  factory CauHinhThanhToanModel.fromJson(Map<String, dynamic> json) {
    return CauHinhThanhToanModel(
      id: json['id'] ?? 0,
      dinhDanhThuHuong: json['dinhDanhThuHuong'] ?? json['dinh_danh_thu_huong'] ?? '',
      maNhanDien: json['maNhanDien'] ?? json['ma_nhan_dien'] ?? '',
      tenChuTaiKhoan: json['tenChuTaiKhoan'] ?? json['ten_chu_tai_khoan'] ?? '',
      tenNhaCungCap: json['tenNhaCungCap'] ?? json['ten_nha_cung_cap'] ?? '',
      trangThai: json['trangThai'] ?? json['trang_thai'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dinhDanhThuHuong': dinhDanhThuHuong,
      'maNhanDien': maNhanDien,
      'tenChuTaiKhoan': tenChuTaiKhoan,
      'tenNhaCungCap': tenNhaCungCap,
      'trangThai': trangThai,
    };
  }
}
