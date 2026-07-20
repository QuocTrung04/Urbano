import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

class PhuongTienScreen extends StatelessWidget {
  const PhuongTienScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhuongTienViewModel()..loadData(),
      child: const _PhuongTienView(),
    );
  }
}

class _PhuongTienView extends StatelessWidget {
  const _PhuongTienView();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    final vm = context.watch<PhuongTienViewModel>();

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: Stack(children: [_body(context, vm)])),
      ),
    );
  }

  Widget _body(BuildContext context, PhuongTienViewModel vm) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    // Chỉ hiển thị xe Đã duyệt (1) và Chờ duyệt (2); ẩn Đã hủy/Từ chối
    final danhSach = vm.phuongTienList
        .where((xe) => xe.trangThai == 1 || xe.trangThai == 2)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppbar(context),
          SizedBox(height: 28),
          _buildSumary(danhSach.length),
          SizedBox(height: 14),
          Divider(color: AppColors.borderButton, thickness: 2),
          SizedBox(height: 14),
          Text(
            'Danh sách phương tiện'.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 14),
          if (danhSach.isNotEmpty) ...[
            ...danhSach.map((xe) => _buildVehicleCard(context, xe)),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Chưa có phương tiện',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ),
            ),
          ],
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
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'Phương tiện',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final ok = await Navigator.pushNamed(
              context,
              AppRoutes.addPhuongTien,
            );
            if (ok == true && context.mounted) {
              context.read<PhuongTienViewModel>().loadData();
            }
          },
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.tealPrimary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.add, color: AppColors.tealPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSumary(int soLuong) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.tealPrimary.withValues(alpha: 0.25),
        ),
        color: AppColors.tealPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_parking_rounded,
              size: 28,
              color: AppColors.tealPrimary,
            ),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$soLuong phương tiện',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Đã đăng ký gửi xe',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, PhuongTien xe) {
    return GestureDetector(
      onTap: () {
        debugPrint(xe.loaiPhuongTien.tenLoaiPhuongTien);
        debugPrint('${xe.id}');
        Navigator.pushNamed(context, AppRoutes.phuongTienDetail, arguments: xe);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(13),
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            _buildIconVehicle(xe),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    xe.tenPhuongTien ?? xe.loaiPhuongTien.tenLoaiPhuongTien,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  if (xe.loaiPhuongTien.id != 3 &&
                      xe.loaiPhuongTien.id != 4) ...[
                    Text(
                      xe.bienSo,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildStatus(xe),
          ],
        ),
      ),
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

  Widget _buildStatus(PhuongTien xe) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: _color(xe).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(xe.trangThaiText, style: TextStyle(color: _color(xe))),
        ),
      ],
    );
  }

  Widget _buildIconVehicle(PhuongTien xe) {
    final (icon, color) = _icon(xe);
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }

  (IconData, Color) _icon(PhuongTien xe) {
    final idXe = xe.loaiPhuongTien.id;
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
}
