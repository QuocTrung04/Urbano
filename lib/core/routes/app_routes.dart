import 'package:flutter/material.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/Views/account/account_info_screen.dart';
import 'package:urbano/Views/account/add_nhan_khau_screen.dart';
import 'package:urbano/Views/account/edit_profile_screen.dart';
import 'package:urbano/Views/auth/change_password_screen.dart';
import 'package:urbano/Views/auth/login_screen.dart';
import 'package:urbano/Views/auth/splash_screen.dart';
import 'package:urbano/Views/auth/forgot_password_screen.dart';
import 'package:urbano/Views/auth/pending_screen.dart';
import 'package:urbano/Views/utilities/dat_lich_tien_ich_screen.dart';
import 'package:urbano/Views/home/home_screen.dart';
import 'package:urbano/Views/auth/reset_password_screen.dart';
import 'package:urbano/Views/auth/verify_otp_screen.dart';
import 'package:urbano/Views/lich_su_thanh_toan_screen.dart';
import 'package:urbano/Views/account/nhan_khau_screen.dart';
import 'package:urbano/Views/notification/bang_tin_detail.dart';
import 'package:urbano/Views/notification/bang_tin_screen.dart';
import 'package:urbano/Views/notification/notification_detail_screen.dart';
import 'package:urbano/Views/setting_screen.dart';
import 'package:urbano/Views/notification/notification_screen.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Views/support/contact_screen.dart';
import 'package:urbano/Views/support/dieu_khoan_screen.dart';
import 'package:urbano/Views/support/tro_giup_screen.dart';
import 'package:urbano/Views/support/yeu_cau_detail.dart';
import 'package:urbano/Views/support/yeu_cau_screen.dart';
import 'package:urbano/Views/thanh_toan_qr_screen.dart';
import 'package:urbano/Views/thong_bao_thanh_toan_screen.dart';
import 'package:urbano/Views/utilities/lich_su_dat_tien_ich_screen.dart';
import 'package:urbano/Views/utilities/tien_ich_screen.dart';
import 'package:urbano/Views/vehicle/add_phuong_tien_screen.dart';
import 'package:urbano/Views/vehicle/phuong_tien_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';
import 'package:urbano/Views/vehicle/phuong_tien_screen.dart';
import 'package:urbano/features/invoice/ViewModels/hoa_don_detail_viewmodel.dart';
import 'package:urbano/features/invoice/Views/hoa_don_detail_view.dart';
import 'package:urbano/features/invoice/Views/hoa_don_view.dart';
import 'package:urbano/ViewModels/theme_provider.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String pending = '/pending';
  static const String resetPassword = '/reset-password';
  static const String verifyOtp = '/verify-otp';
  static const String setting = '/setting';
  static const String notification = '/notification';
  static const String changePassword = '/change-password';
  static const String notificationDetail = '/notification-detail';
  static const String phuongTien = '/phuong-tien';
  static const String phuongTienDetail = '/phuong-tien-detail';
  static const String contact = '/contact';
  static const String accountInfo = '/account-info';
  static const String editProfile = '/edit-profile';
  static const String invoice = '/invoice';
  static const String invoiceDetail = '/invoice-detail';
  static const String yeucau = '/yeu-cau';
  static const String bangTin = '/bang-tin';
  static const String dieuKhoan = '/dieu-khoan';
  static const String trogiup = '/tro-giup';
  static const String tienich = '/tien-ich';
  static const String bangTinDetail = '/bang-tin-detail';
  static const String addPhuongTien = '/add-phuong-tien';
  static const String nhanKhau = '/nhan-khau';
  static const String yeuCauDetail = '/yeu-cau-detail';
  static const String lichSuThanhToan = '/lich-su-thanh-toan';
  static const String thanhToan = '/thanh-toan';
  static const String thongBaoThanhToan = '/thong-bao-thanh-toan';
  static const String datLichTienIch = '/dat-lich-tien-ich';
  static const String lichSuDatTienIch = '/lich-su-dat-tien-ich';
  static const String themNhanKhau = '/them-nhan-khau';

  static WidgetBuilder _wrap(WidgetBuilder builder) {
    return (context) => Consumer<ThemeProvider>(
      builder: (context, theme, _) => builder(context),
    );
  }

  static Map<String, WidgetBuilder> get routes => {
    splash: _wrap((_) => const SplashScreen()),
    login: _wrap((_) => const LoginScreen()),
    pending: _wrap((_) => const PendingScreen()),
    forgotPassword: _wrap((_) => const ForgotPasswordScreen()),
    home: _wrap((_) => const HomeScreen()),
    resetPassword: _wrap((_) => const ResetPasswordScreen()),
    changePassword: _wrap((_) => const ChangePasswordScreen()),
    phuongTien: _wrap((_) => const PhuongTienScreen()),
    contact: _wrap((_) => const ContactScreen()),
    yeucau: _wrap((_) => const YeuCauScreen()),
    bangTin: _wrap((_) => const BangTinScreen()),
    dieuKhoan: _wrap((_) => const DieuKhoanScreen()),
    trogiup: _wrap((_) => const TroGiupScreen()),
    tienich: _wrap((_) => const TienIchScreen()),
    addPhuongTien: _wrap((_) => const ThemPhuongTienScreen()),
    nhanKhau: _wrap((_) => const NhanKhauScreen()),
    lichSuThanhToan: _wrap((_) => const LichSuThanhToanScreen()),
    thongBaoThanhToan: _wrap((_) => const ThongBaoThanhToanScreen()),
    lichSuDatTienIch: _wrap((_) => const LichSuDatLichScreen()),
    themNhanKhau: _wrap((_) => const ThemNhanKhauScreen()),
  };

  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      //man nhap otp
      case verifyOtp:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: _wrap((_) => VerifyOtpScreen(
            contact: arg['contact'] as String,
            isSms: arg['_isSms'] as bool,
          )),
        );
      //man  setting
      case setting:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: _wrap((_) => SettingScreen(
            cuDan: arg['cuDan'] as CuDan,
            canHoText: arg['canHoText'] as String,
            soCanHo: arg['soCanHo'] as String,
          )),
        );
      //man thong bao
      case notification:
        final list = settings.arguments as List<ThongBao>;
        return MaterialPageRoute(
          builder: _wrap((_) => NotificationScreen(thongBaoList: list)),
        );
      case notificationDetail:
        final tbList = settings.arguments as ThongBao;
        return MaterialPageRoute(
          builder: _wrap((_) => NotificationDetailScreen(thongBao: tbList)),
        );
      case phuongTienDetail:
        final phuongTienList = settings.arguments as PhuongTien;
        return MaterialPageRoute(
          builder: _wrap((_) => PhuongTienDetailScreen(phuongTien: phuongTienList)),
        );
      case accountInfo:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: _wrap((_) => AccountInfoScreen(
            cuDan: arg['cuDan'] as CuDan,
            soCanHo: arg['soCanHo'] as String,
          )),
        );
      case editProfile:
        final arg = settings.arguments as CuDan;
        return MaterialPageRoute(builder: _wrap((_) => EditProfileScreen(cuDan: arg)));
      case invoiceDetail:
        final hoaDon = settings.arguments as HoaDonModel;
        return MaterialPageRoute(
          builder: _wrap((_) => ChangeNotifierProvider(
            create: (_) => HoaDonDetailViewModel(
              services: HoaDonServices(),
              hoaDon: hoaDon,
            )..fetchDetail(),
            child: const HoaDonDetailView(),
          )),
        );
      case invoice:
        final canHoId = settings.arguments as int;
        return MaterialPageRoute(builder: _wrap((_) => HoaDonView(canHoId: canHoId)));
      case bangTinDetail:
        final btList = settings.arguments as BangTin;
        return MaterialPageRoute(
          builder: _wrap((_) => BangTinDetailScreen(bangTin: btList)),
        );
      case yeuCauDetail:
        final yc = settings.arguments as YeuCauCuDan;
        return MaterialPageRoute(
          builder: _wrap((_) => ChiTietYeuCauScreen(yeuCau: yc)),
        );
      case thanhToan:
        final tt = settings.arguments as HoaDonModel;
        return MaterialPageRoute(builder: _wrap((_) => ThanhToanQRScreen(hoaDon: tt)));
      case datLichTienIch:
        final datLich = settings.arguments as TienIch;
        return MaterialPageRoute(
          builder: _wrap((_) => DatLichScreen(tienIch: datLich)),
        );
      default:
        return null;
    }
  }
}
