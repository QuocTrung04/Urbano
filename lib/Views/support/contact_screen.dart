import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _goiDien(String sdt) async {
    final uri = Uri.parse('tel:$sdt');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _guiEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context),
                  SizedBox(height: 24),
                  _buildHeader(),
                  SizedBox(height: 14),
                  Divider(
                    color: AppColors.borderButton,
                    thickness: 1,
                    height: 1,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'thông tin liên hệ'.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildCardItem(
                    Icons.local_phone_rounded,
                    AppColors.tealPrimary,
                    'Đường dây nóng',
                    '0901234567',
                    Icons.phone_forwarded_rounded,
                    () {
                      debugPrint('lien he duong day nong');
                      _goiDien('0901234567');
                    },
                  ),
                  SizedBox(height: 14),
                  _buildCardItem(
                    Icons.mail_outline_rounded,
                    AppColors.blue,
                    'Email',
                    'bql@Urbano.com',
                    Icons.send_rounded,
                    () {
                      debugPrint('lien he email');
                      _guiEmail('bql@Urbano.com');
                    },
                  ),
                  SizedBox(height: 14),
                  _buildCardItem(
                    Icons.security_rounded,
                    AppColors.amber,
                    'Bảo vệ (24/7)',
                    '0901234567',
                    Icons.phone_forwarded_rounded,
                    () {
                      _goiDien('0901234567');
                      debugPrint('goi bao ve');
                    },
                  ),
                  SizedBox(height: 14),
                  _buildCardItem(
                    Icons.local_fire_department,
                    AppColors.red,
                    'Khẩn cấp / Cứu hỏa',
                    '114',
                    Icons.phone_forwarded_rounded,
                    () {
                      _goiDien('114');
                      debugPrint('goi cuu hoa');
                    },
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
          'Liên hệ',
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.3)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(13),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.apartment_rounded,
                size: 30,
                color: AppColors.tealPrimary,
              ),
            ),
            Text(
              'Ban quản lý Urbano',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tầng 1, Tòa nhà Urbano\n 417/69/27 Quang Trung, Gò Vấp, TP.HCM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.nenContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_sharp,
                    color: AppColors.tealPrimary,
                    size: 17,
                  ),
                  SizedBox(width: 4),
                  Text('8:00 - 17:30 (T2 - T7)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(
    IconData icon,
    Color color,
    String title,
    String value,
    IconData actionIcon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(actionIcon, size: 20, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
