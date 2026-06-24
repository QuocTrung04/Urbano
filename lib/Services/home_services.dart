// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:urbano/Models/hoadon_model.dart';
// import 'package:urbano/Models/home_model.dart';
// import 'package:urbano/Models/canho_model.dart';
// import 'package:urbano/Models/cudan_model.dart';
// import 'package:urbano/Models/notification_model.dart';
// import 'package:urbano/Services/hoa_don_services.dart';
// import 'package:urbano/Services/notification_services.dart';

// class HomeServices {
//   final ThongbaoServices thongbaoServices = ThongbaoServices();
//   final HoaDonServices hoaDonServices = HoaDonServices();
//   Future<HomeData> fetchHomeData() async {
//     await Future.delayed(Duration(milliseconds: 500));
//     final prefs = await SharedPreferences.getInstance();
//     final cuDanJson = prefs.getString('cuDan');
//     final canHoId = prefs.getInt('canHoId');
//     final cuDan = cuDanJson != null
//         ? CuDan.fromJson(jsonDecode(cuDanJson))
//         : CuDan(id: 0, hoTen: 'Khách');
//     final result = await Future.wait({
//       thongbaoServices.fetchThongBao(cuDan.id),
//       hoaDonServices.fetchHoaDons(canHoId ?? 0),
//     });
//     final thongBaoList = result[0] as List<ThongBao>;
//     final hoaDonList = result[1] as List<HoaDonModel>;
//     return HomeData(
//       cuDan: cuDan,
//       canHo: CanHo(id: 1, toaNha: 1, soCanHo: '202', tang: 2, dienTich: 65),
//       tenToaNha: 'Urbano - Plaza',
//       thongBaoList: thongBaoList,
//       hoaDonList: hoaDonList,
//     );
//   }
// }

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';
import 'package:urbano/Services/notification_services.dart';

class HomeServices {
  final ThongbaoServices thongbaoServices = ThongbaoServices();
  final HoaDonServices hoaDonServices = HoaDonServices();
  Future<HomeData> fetchHomeData() async {
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final cuDanJson = prefs.getString('cuDan');
    final canHoId = prefs.getInt('canHoId');
    final cuDan = cuDanJson != null
        ? CuDan.fromJson(jsonDecode(cuDanJson))
        : CuDan(id: 0, hoTen: 'Khách');
    final result = await Future.wait([
      thongbaoServices.fetchThongBao(cuDan.id),
      hoaDonServices.fetchHoaDons(canHoId ?? 0),
    ]);
    final thongBaoList = result[0] as List<ThongBao>;
    final hoaDonList = result[1] as List<HoaDonModel>;
    return HomeData(
      cuDan: cuDan,
      canHo: CanHo(id: 1, toaNha: 1, soCanHo: '202', tang: 2, dienTich: 65),
      tenToaNha: 'Urbano - Plaza',
      thongBaoList: thongBaoList,
      hoaDonList: hoaDonList,
    );
  }
}
