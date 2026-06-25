import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Services/bang_tin_services.dart';
import 'package:urbano/Services/can_ho_services.dart';
import 'package:urbano/Services/hoa_don_services.dart';
import 'package:urbano/Services/notification_services.dart';

class HomeServices {
  final ThongbaoServices thongbaoServices = ThongbaoServices();
  final HoaDonServices hoaDonServices = HoaDonServices();
  final CanHoServices canHoServices = CanHoServices();
  final BangTinServices bangTinServices = BangTinServices();

  Future<HomeData> fetchHomeData() async {
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final cuDanJson = prefs.getString('cuDan');
    final canHoId = prefs.getInt('canHoId') ?? 0;
    final token = prefs.getString('token') ?? '';
    final cuDan = cuDanJson != null
        ? CuDan.fromJson(jsonDecode(cuDanJson))
        : CuDan(id: 0, hoTen: 'Khách');

    CanHo canHo;
    try {
      canHo = await canHoServices.fetchCanHo(canHoId, token: token);
    } catch (e) {
      canHo = CanHo(id: canHoId, toaNha: 0, soCanHo: '', tenToaNha: ' ');
    }

    List<BangTin> bangTinList;
    try {
      bangTinList = await bangTinServices.fetchBangTin();
    } catch (e) {
      bangTinList = [];
    }

    final result = await Future.wait([
      thongbaoServices.fetchThongBao(cuDan.id),
      hoaDonServices.fetchHoaDons(canHoId),
    ]);

    final thongBaoList = result[0] as List<ThongBao>;
    final hoaDonList = result[1] as List<HoaDonModel>;

    return HomeData(
      cuDan: cuDan,
      canHo: canHo,
      tenToaNha: canHo.tenToaNha ?? '',
      thongBaoList: thongBaoList,
      hoaDonList: hoaDonList,
      bangTinList: bangTinList,
    );
  }
}
