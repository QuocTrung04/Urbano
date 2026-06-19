import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Models/canho_model.dart';
import 'package:urbano/Models/cudan_model.dart';

class HomeServices {
  Future<HomeData> fetchHomeData() async {
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final cuDanJson = prefs.getString('cuDan');
    final cuDan = cuDanJson != null
        ? CuDan.fromJson(jsonDecode(cuDanJson))
        : CuDan(id: 0, hoTen: 'Khách');
    return HomeData(
      cuDan: cuDan,
      canHo: CanHo(id: 1, toaNha: 1, soCanHo: '202', tang: 2, dienTich: 65),
      tenToaNha: 'Plaza',
      hoaDonList: [
        HoaDonModel(
          id: 1,
          canHo: 1,
          thang: 5,
          nam: 2026,
          hanThanhToan: (DateTime(2026, 06, 15)),
          tongTien: 1900000,
          soTienDaThanhToan: 1900000,
          chiTietHoaDonList: [
            ChiTietHoaDon(
              id: 1,
              hoaDon: 1,
              phiDichVu: 1,
              donGia: 200000,
              soLuong: 2,
              thanhTien: 400000,
              loaiPhiDichVu: LoaiPhiDichvu(id: 1, tenPhiDichVu: 'Điện'),
            ),
            ChiTietHoaDon(
              id: 2,
              hoaDon: 2,
              phiDichVu: 2,
              donGia: 200000,
              soLuong: 2,
              thanhTien: 400000,
              loaiPhiDichVu: LoaiPhiDichvu(id: 2, tenPhiDichVu: 'Nước'),
            ),
            ChiTietHoaDon(
              id: 3,
              hoaDon: 3,
              phiDichVu: 3,
              donGia: 1000000,
              soLuong: 1,
              thanhTien: 1000000,
              loaiPhiDichVu: LoaiPhiDichvu(id: 3, tenPhiDichVu: 'Phí quản lý'),
            ),
            ChiTietHoaDon(
              id: 4,
              hoaDon: 4,
              phiDichVu: 4,
              donGia: 100000,
              soLuong: 1,
              thanhTien: 100000,
              loaiPhiDichVu: LoaiPhiDichvu(id: 4, tenPhiDichVu: 'Khác'),
            ),
          ],
        ),
      ],
      thongBaoList: [
        ThongBao(
          id: 1,
          tieuDe: 'Tạm Ngưng cấp nước',
          noiDung:
              'Tao thích thì tao cắt nước Tao thích thì tao cắt nước Tao thích thì tao cắt nướcTao thích thì tao cắt nước ',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          trangthai: false,
        ),

        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          trangthai: false,
        ),
        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          trangthai: false,
        ),
        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          trangthai: false,
        ),
        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          trangthai: false,
        ),
      ],
    );
  }
}
