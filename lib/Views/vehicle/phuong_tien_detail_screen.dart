import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/Services/phuong_tien_services.dart';
import 'package:urbano/Services/yeu_cau_services.dart';
import 'package:urbano/ViewModels/auth/user_provider.dart';
// import 'package:urbano/Views/vehicle/sua_phuong_tien_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';

class PhuongTienDetailScreen extends StatelessWidget {
  final PhuongTien phuongTien;
  const PhuongTienDetailScreen({super.key, required this.phuongTien});

  PhuongTien get xe => phuongTien;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    final chuXe = context.watch<UserProvider>().cuDan?.hoTen ?? '—';
    final soCanHo = xe.soCanHo;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context),
                  const SizedBox(height: 24),
                  _buildVehicleCard(xe),
                  const SizedBox(height: 26),

                  // ----- Nhóm: Thông tin căn hộ -----
                  _groupTitle('Thông tin căn hộ'),
                  const SizedBox(height: 12),
                  _card([_infoRow(Icons.apartment_rounded, 'Căn hộ', soCanHo)]),
                  const SizedBox(height: 22),

                  // ----- Nhóm: Thông tin đăng ký -----
                  _groupTitle('Thông tin đăng ký'),
                  const SizedBox(height: 12),
                  _card([
                    _infoRow(Icons.person_outline_rounded, 'Chủ xe', chuXe),
                    _infoRow(
                      Icons.category_outlined,
                      'Loại phương tiện',
                      xe.loaiPhuongTien.tenLoaiPhuongTien,
                    ),
                    if (xe.ngayDangKy != null)
                      _infoRow(
                        Icons.event_available_rounded,
                        'Ngày đăng ký',
                        _formatTime(xe.ngayDangKy!),
                      ),
                    if (xe.ngayHuy != null)
                      _infoRow(
                        Icons.event_busy_rounded,
                        'Ngày hủy',
                        _formatTime(xe.ngayHuy!),
                      ),
                  ]),
                  const SizedBox(height: 26),
                  _buildHanhDong(context, xe),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 66,
            color: AppColors.borderButton,
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.iconMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.iconMuted, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Chi tiết phương tiện',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(PhuongTien xe) {
    final (icon, color) = _icon(xe);
    final loaiId = xe.loaiPhuongTien.id;
    final coBienSo = loaiId != 3 && loaiId != 4 && xe.bienSo.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 46, color: color),
            ),
            const SizedBox(height: 14),
            if (coBienSo) ...[
              Text(
                xe.bienSo,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              xe.loaiPhuongTien.tenLoaiPhuongTien,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatus(xe),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(PhuongTien xe) {
    final mau = _color(xe);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      decoration: BoxDecoration(
        color: mau.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        xe.trangThaiText,
        style: TextStyle(color: mau, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _color(PhuongTien xe) {
    switch (xe.trangThai) {
      case 1:
        return AppColors.tealPrimary;
      case 2:
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  (IconData, Color) _icon(PhuongTien xe) {
    switch (xe.loaiPhuongTien.id) {
      case 1:
        return (Icons.directions_car_rounded, AppColors.blue);
      case 2:
        return (Icons.two_wheeler_rounded, AppColors.tealPrimary);
      case 3:
        return (Icons.pedal_bike_rounded, AppColors.amber);
      default:
        return (Icons.electric_scooter_rounded, AppColors.pink);
    }
  }

  String _formatTime(DateTime time) {
    final d = time.day.toString().padLeft(2, '0');
    final m = time.month.toString().padLeft(2, '0');
    final y = time.year.toString();
    return '$d/$m/$y';
  }

  // ===== Hành động theo trạng thái =====
  Widget _buildHanhDong(BuildContext context, PhuongTien xe) {
    if (xe.trangThai == 2) {
      // Chờ duyệt: hủy trực tiếp
      return _actionBtn(
        'Hủy đăng ký',
        Icons.close_rounded,
        AppColors.red,
        () => _huyTrucTiep(context, xe),
      );
    }
    if (xe.trangThai == 1) {
      // Đã duyệt: gửi yêu cầu hủy tới BQL
      return _actionBtn(
        'Yêu cầu hủy',
        Icons.report_gmailerrorred_rounded,
        AppColors.red,
        () => _yeuCauHuy(context, xe),
      );
    }
    return const SizedBox.shrink(); // hủy/từ chối: không có hành động
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color mau,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: mau.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mau.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mau, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: mau,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Chờ duyệt: hủy trực tiếp ---
  Future<void> _huyTrucTiep(BuildContext context, PhuongTien xe) async {
    final dong = await _confirm(
      context,
      'Hủy đăng ký',
      'Bạn chắc chắn muốn hủy đăng ký phương tiện này?',
    );
    if (dong != true) return;
    try {


      await PhuongTienServices().huyPhuongTien(xe.id);
      if (!context.mounted) return;
      _thongBao(context, 'Đã hủy đăng ký');
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      _thongBao(context, 'Hủy thất bại. Vui lòng thử lại.', loi: true);
    }
  }

  // --- Đã duyệt: yêu cầu hủy (loại 6) ---
  Future<void> _yeuCauHuy(BuildContext context, PhuongTien xe) async {
    final dong = await _confirm(
      context,
      'Yêu cầu hủy',
      'Gửi yêu cầu hủy phương tiện này tới ban quản lý?',
    );
    if (dong != true) return;
    await _guiYeuCau(
      context,
      xe,
      loai: 6,
      tieuDe: 'Yêu cầu hủy đăng ký phương tiện',
    );
  }

  Future<void> _guiYeuCau(
    BuildContext context,
    PhuongTien xe, {
    required int loai,
    required String tieuDe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();


      final noiDung =
          'Phương tiện: ${xe.tenPhuongTien ?? ''}\n'
          'Biển số: ${xe.bienSo}\n'
          'Loại: ${xe.loaiPhuongTien.tenLoaiPhuongTien}\n'
          'Mã phương tiện: ${xe.id}';
      await YeuCauServices().createYeuCau(
        cuDan: prefs.getInt('cuDanId') ?? 0,
        loaiYeuCau: loai,
        tieuDe: tieuDe,
        noiDung: noiDung,
        mucDoUuTien: 1,
      );
      if (!context.mounted) return;
      _thongBao(context, 'Đã gửi yêu cầu tới ban quản lý');
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      _thongBao(context, 'Gửi yêu cầu thất bại.', loi: true);
    }
  }

  Future<bool?> _confirm(BuildContext context, String title, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: Text(
          msg,
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xác nhận',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _thongBao(BuildContext context, String msg, {bool loi = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: AppColors.textPrimary)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: loi ? AppColors.red : AppColors.bgMid,
      ),
    );
  }
}
