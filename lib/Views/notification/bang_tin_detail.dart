import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/core/constants/app_colors.dart';

class BangTinDetailScreen extends StatelessWidget {
  final BangTin bangTin;
  const BangTinDetailScreen({super.key, required this.bangTin});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
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
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context),
                  SizedBox(height: 24),
                  _buildHeader(bangTin),
                  SizedBox(height: 24),
                  Divider(
                    color: AppColors.borderButton,
                    height: 1,
                    thickness: 1,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'NỘI DUNG',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    bangTin.noiDung ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          'Chi tiết bảng tin',
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

  Widget _buildHeader(BangTin bt) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: bt.hinhanh
                  ? Image.network(
                      bt.hinhUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.inputFill,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.tealPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.inputFill,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.iconMuted,
                            size: 30,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/hinh_thongbao.png',
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            bangTin.tieuDe ?? 'Thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_sharp, color: AppColors.tealPrimary, size: 17),
              SizedBox(width: 4),
              if (bangTin.createdAt != null) ...[
                Text(
                  _formatTime(bangTin.createdAt!),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime _time) {
    final d = _time.day.toString().padLeft(2, '0');
    final m = _time.month.toString().padLeft(2, '0');
    final y = _time.year.toString();
    final h = _time.hour.toString().padLeft(2, '0');
    final min = _time.minute.toString().padLeft(2, '0');

    return '$d/$m/$y • $h:$min';
  }
}
