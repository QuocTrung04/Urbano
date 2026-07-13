import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/notification_model.dart';

class HomeData {
  final CuDan cuDan;
  final CanHo canHo;
  final String tenToaNha;
  List<HoaDonModel> hoaDonList;
  List<ThongBao> thongBaoList;
  List<BangTin> bangTinList;

  HomeData({
    required this.cuDan,
    required this.canHo,
    required this.tenToaNha,
    required this.hoaDonList,
    required this.thongBaoList,
    required this.bangTinList,
  });

  HomeData copyWith({
    CuDan? cuDan,
    CanHo? canHo,
    String? tenToaNha,
    List<HoaDonModel>? hoaDonList,
    List<ThongBao>? thongBaoList,
    List<BangTin>? bangTinList,
  }) {
    return HomeData(
      cuDan: cuDan ?? this.cuDan,
      canHo: canHo ?? this.canHo,
      tenToaNha: tenToaNha ?? this.tenToaNha,
      hoaDonList: hoaDonList ?? this.hoaDonList,
      thongBaoList: thongBaoList ?? this.thongBaoList,
      bangTinList: bangTinList ?? this.bangTinList,
    );
  }

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      cuDan: CuDan.fromJson(json['cu_dan']),
      canHo: CanHo.fromJson(json['can_ho']),
      tenToaNha: json['ten_toa_nha'] ?? '',
      hoaDonList: (json['hoa_don_list'] as List? ?? [])
          .map((item) => HoaDonModel.fromJson(item))
          .toList(),
      thongBaoList: (json['thong_bao_list'] as List? ?? [])
          .map((item) => ThongBao.fromJson(item))
          .toList(),
      bangTinList: (json['bang_tin_list'] as List? ?? [])
          .map((item) => BangTin.fromJson(item))
          .toList(),
    );
  }
}
