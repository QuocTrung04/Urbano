import 'package:urbano/Models/home/home_model.dart';

class HomeServices {
  Future<HomeData> fetchHomeData() async {
    await Future.delayed(Duration(milliseconds: 1000));

    return HomeData(
      cuDan: CuDan(id: 1, hoTen: 'Quốc Trung', sdt: '0392469847'),
      canHo: CanHo(id: 1, toaNha: 1, soCanHo: '202', tang: 2, dienTich: 65),
      tenToaNha: 'Plaza',
      hoaDonList: [
        HoaDon(
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
          creatrAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        ThongBao(
          id: 1,
          tieuDe: 'Cắt điện',
          noiDung:
              'Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt Ghét thì cắt',
          creatrAt: DateTime.now().subtract(Duration(days: 2)),
        ),
      ],
    );
  }
}
