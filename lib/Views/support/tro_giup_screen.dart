import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbano/core/constants/app_colors.dart';

class TroGiupScreen extends StatelessWidget {
  const TroGiupScreen({super.key});
  static const String _email = 'urbano.support@gmail.com';

  static const List<(IconData, String, String)> _faqs = [
    (
      Icons.receipt_long_outlined,
      'Làm sao để thanh toán hóa đơn?',
      'Vào mục "Hóa đơn" trên trang chủ, chọn hóa đơn cần thanh toán và làm theo hướng dẫn thanh toán trực tuyến.',
    ),
    (
      Icons.build_outlined,
      'Cách gửi yêu cầu sửa chữa?',
      'Vào mục "Yêu cầu", bấm "Tạo yêu cầu mới", chọn loại, nhập tiêu đề và nội dung rồi gửi cho ban quản lý.',
    ),
    (
      Icons.directions_car_outlined,
      'Đăng ký phương tiện như thế nào?',
      'Vào mục "Phương tiện", bấm thêm phương tiện, điền biển số và thông tin xe để đăng ký.',
    ),
    (
      Icons.lock_outline,
      'Quên mật khẩu phải làm sao?',
      'Tại màn đăng nhập, bấm "Quên mật khẩu" và làm theo hướng dẫn để đặt lại mật khẩu mới.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppbar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 22),
                      _sectionLabel('CÂU HỎI THƯỜNG GẶP'),
                      const SizedBox(height: 13),
                      ..._faqs.map(_buildFaq),
                      const SizedBox(height: 22),
                      _sectionLabel('LIÊN HỆ BAN QUẢN LÝ'),
                      const SizedBox(height: 13),
                      _buildContact(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 19,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Trung tâm trợ giúp',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealPrimary.withValues(alpha: 0.2),
            AppColors.tealDark.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.support_agent,
              size: 24,
              color: AppColors.tealPrimary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn cần hỗ trợ?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tìm câu trả lời nhanh hoặc liên hệ ban quản lý',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.tealPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFaq((IconData, String, String) faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        // ⬅ THÊM dòng này
        color: Colors.transparent,
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 2,
            ),
            leading: Icon(faq.$1, size: 19, color: AppColors.tealPrimary),
            title: Text(
              faq.$2,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            iconColor: AppColors.tealPrimary,
            collapsedIconColor: AppColors.textMuted,
            childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.$3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContact(BuildContext context) {
    return _contactCard(
      icon: Icons.mail_outline,
      iconColor: AppColors.blue,
      label: 'Email',
      value: _email,
      onTap: () => _moLink(context, 'mailto:$_email'),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: iconColor.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không mở được')));
    }
  }
}
