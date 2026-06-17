import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/core/constants/app_colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final ThongBao thongBao;
  const NotificationDetailScreen({super.key, required this.thongBao});
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
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
                  SizedBox(height: 32),
                  _buildHeader(),
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
                    thongBao.noiDung ?? '',
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
        _buildButtonBack(context),
        SizedBox(width: 14),
        Text(
          'chi tiết thông báo',
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

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSide),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.tealPrimary,
              size: 40,
            ),
          ),
          SizedBox(height: 12),
          Text(
            thongBao.tieuDe ?? 'Thông báo',
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
              if (thongBao.createdAt != null) ...[
                Text(
                  _formatTime(thongBao.createdAt!),
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

  Widget _buildButtonBack(BuildContext context) {
    return GestureDetector(
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
