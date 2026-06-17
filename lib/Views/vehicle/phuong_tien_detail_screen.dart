import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/core/constants/app_colors.dart';

class PhuongTienDetailScreen extends StatelessWidget {
  final PhuongTien phuongTien;
  const PhuongTienDetailScreen({super.key, required this.phuongTien});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(13, 24, 13, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context),
                  SizedBox(height: 24),
                  _buildVehicleCard(phuongTien),
                  SizedBox(height: 24),
                  Divider(color: AppColors.borderButton, height: 1),
                  SizedBox(height: 14),
                  Text(
                    'Thông tin đăng ký'.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 14),
                  _infoRow(Icons.person_outline_sharp, 'Chủ xe', 'djfhdjfhdjh'),
                  SizedBox(height: 8),
                  _infoRow(
                    Icons.apartment_rounded,
                    'Căn hộ',
                    '${phuongTien.canHo}',
                  ),
                  SizedBox(height: 8),
                  _infoRow(
                    Icons.calendar_today,
                    'Ngày đăng ký',
                    _formatTime(phuongTien.ngayDangKy!),
                  ),
                  SizedBox(height: 8),
                  if (phuongTien.ngayHuy != null)
                    _infoRow(
                      Icons.calendar_today,
                      'Ngày hủy',
                      _formatTime(phuongTien.ngayHuy!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String lable, String value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.nenContainer,
      ),

      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(13),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.iconMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.iconMuted),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lable,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        SizedBox(width: 14),
        Text(
          'Phương tiện',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(PhuongTien xe) {
    final (icon, color) = _icon(xe);
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 50, color: color),
              ),
              SizedBox(height: 8),
              if (xe.loaiPhuongTien!.id != 3 && xe.loaiPhuongTien!.id != 4) ...[
                Text(
                  xe.bienSo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
              SizedBox(height: 4),
              Text(
                xe.loaiPhuongTien!.tenLoaiPhuongTien,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              _buildStatus(xe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(PhuongTien xe) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: _color(xe).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(xe.trangThaiText!, style: TextStyle(color: _color(xe))),
    );
  }

  Color _color(PhuongTien xe) {
    final idTrangThai = xe.trangThai;
    switch (idTrangThai) {
      case 1:
        return AppColors.tealPrimary;
      case 2:
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  (IconData, Color) _icon(PhuongTien xe) {
    final idXe = xe.loaiPhuongTien!.id;
    switch (idXe) {
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

  String _formatTime(DateTime _time) {
    final d = _time.day.toString().padLeft(2, '0');
    final m = _time.month.toString().padLeft(2, '0');
    final y = _time.year.toString();

    return '$d/$m/$y';
  }
}
