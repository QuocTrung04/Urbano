import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/notification_model.dart';

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
