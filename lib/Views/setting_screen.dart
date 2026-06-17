import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/Models/cudan_model.dart';

class SettingScreen extends StatelessWidget {
  final CuDan cuDan;
  final String canHoText;

  const SettingScreen({
    super.key,
    required this.cuDan,
    required this.canHoText,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
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
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(context),
                SizedBox(height: 24),
                _buildProfileCard(context),
                SizedBox(height: 24),
                _groupTitle('Tài khoản'),
                SizedBox(height: 14),
                _card([
                  _navRow(
                    icon: Icons.person_4_rounded,
                    title: 'Thông tin tài khoản',
                    sub: 'Phương thức đăng nhập',
                    colors: AppColors.tealPrimary,
                    onTap: () {
                      debugPrint('quan ly tai khoan');
                    },
                  ),
                  _navRow(
                    icon: Icons.key,
                    title: 'Đổi mật khẩu ',
                    colors: AppColors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                  ),
                ]),
                SizedBox(height: 24),
                _groupTitle('Hỗ trợ'),
                SizedBox(height: 14),
                _card([
                  _navRow(
                    icon: Icons.help_outline_sharp,
                    title: 'Trung tâm trợ giúp',
                    colors: AppColors.red,
                    onTap: () {
                      debugPrint('Hỗ trợ');
                    },
                  ),
                  // _navRow(
                  //   icon: FontAwesomeIcons.fileLines,
                  //   title: 'Điều khoản & chính sách',
                  //   colors: AppColors.amber,
                  //   onTap: () {
                  //     debugPrint('Điều khoản & chính sách');
                  //   },
                  // ),
                  // _navRow(
                  //   icon: FontAwesomeIcons.circleInfo,
                  //   title: 'Về ứng dụng',
                  //   colors: AppColors.pink,
                  //   onTap: () {
                  //     debugPrint('Giới thiệu');
                  //   },
                  // ),
                ]),
                SizedBox(height: 80),
                _buildLogout(context),
              ],
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
          'Cài đặt',
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

  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //TODOL: XU LY SU KIEN
        debugPrint('ho so ca nhan');
      },

      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.tealPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderSide.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 55,
              width: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.17),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.tealPrimary,
                size: 26,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuDan.hoTen,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    canHoText,
                    style: TextStyle(color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.tealPrimary.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.drive_file_rename_outline_outlined,
                    color: AppColors.tealPrimary,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTitle(String string) {
    return Text(
      string.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(
          Divider(height: 1, thickness: 0.5, color: AppColors.borderButton),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(children: children),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String title,
    required Color colors,
    String? sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _iconBox(icon, colors),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  if (sub != null) ...[
                    SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colors, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColors.red, size: 18),
            SizedBox(width: 9),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc muốn đăng xuất?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.red),
            ),
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

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}
