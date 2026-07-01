//-----------TIỆN ÍCH------------

class LoaiTienIch {
  final int id;
  final String tenLoaiTienIch;

  LoaiTienIch({required this.id, required this.tenLoaiTienIch});

  factory LoaiTienIch.fromJson(Map<String, dynamic> json) {
    return LoaiTienIch(
      id: json['id'] ?? 0,
      tenLoaiTienIch: json['tenLoaiTienIch'] ?? '',
    );
  }
}

class TienIch {
  final int id;
  final String tenTienIch;
  final LoaiTienIch? loaiTienIch;
  final int? toaNha;
  final String? moTa;
  final String? viTri;
  final int? sucChua;
  final String? gioMoCua;
  final String? gioDongCua;
  final double? phiSuDung;
  final bool canDatTruoc;
  final String? hinhUrl;
  final int? trangThai;

  TienIch({
    required this.id,
    required this.tenTienIch,
    this.loaiTienIch,
    this.toaNha,
    this.moTa,
    this.viTri,
    this.sucChua,
    this.gioMoCua,
    this.gioDongCua,
    this.phiSuDung,
    this.canDatTruoc = false,
    this.hinhUrl,
    this.trangThai,
  });

  factory TienIch.fromJson(Map<String, dynamic> json) {
    return TienIch(
      id: json['id'] ?? 0,
      tenTienIch: json['tenTienIch'] ?? '',
      loaiTienIch: json['loaiTienIch'] != null
          ? LoaiTienIch.fromJson(json['loaiTienIch'])
          : null,
      toaNha: json['toaNha'],
      moTa: json['moTa'],
      viTri: json['viTri'],
      sucChua: json['sucChua'],
      gioMoCua: json['gioMoCua'],
      gioDongCua: json['gioDongCua'],
      phiSuDung: (json['phiSuDung'] as num?)?.toDouble(),
      canDatTruoc: json['canDatTruoc'] == true || json['canDatTruoc'] == 1,
      hinhUrl: json['hinhUrl'],
      trangThai: json['trangThai'],
    );
  }

  // Tên loại (danh mục) để lọc/hiển thị
  String get danhMuc => loaiTienIch?.tenLoaiTienIch ?? 'Khác';

  // "06:00 - 21:00" (cắt bỏ giây nếu API trả "06:00:00")
  String get gioText {
    String fmt(String? t) {
      if (t == null || t.isEmpty) return '';
      return t.length >= 5 ? t.substring(0, 5) : t;
    }

    final mo = fmt(gioMoCua);
    final dong = fmt(gioDongCua);
    if (mo.isEmpty && dong.isEmpty) return 'Cả ngày';
    return '$mo - $dong';
  }
}
