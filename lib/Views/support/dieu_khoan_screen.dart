import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/constants/app_colors.dart';

class DieuKhoanScreen extends StatelessWidget {
  const DieuKhoanScreen({super.key});

  static const _bodyStyle = TextStyle(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context),
                  SizedBox(height: 14),
                  _buildHeader(),
                  SizedBox(height: 24),
                  _seletion(
                    1,
                    'Giới thiệu',
                    const Text(
                      'Ứng dụng Urbano hỗ trợ cư dân quản lý các dịch vụ trong tòa nhà. Khi sử dụng ứng dụng, bạn đồng ý với các điều khoản dưới đây.',
                      style: _bodyStyle,
                    ),
                  ),
                  _seletion(
                    2,
                    'Quyền & nghĩa vụ cư dân',
                    Column(
                      children: [
                        _bullet('Cung cấp thông tin chính xác khi đăng ký.'),
                        _bullet('Bảo mật tài khoản và thông tin cá nhân.'),
                        _bullet('Thanh toán các khoản phí đúng hạn.'),
                        _bullet(
                          'Tuân thủ nội quy chung của tòa nhà và ban quản lý.',
                        ),
                      ],
                    ),
                  ),

                  _seletion(
                    3,
                    "Chính sách bảo mật",
                    const Text(
                      'Thông tin cá nhân của bạn được bảo mật và chỉ được sử dụng cho mục đích quản lý cư dân. '
                      'Chúng tôi cam kết không chia sẻ dữ liệu với bên thứ 3 khi chưa có sự cho phép của bạn.',
                      style: _bodyStyle,
                    ),
                  ),
                  _seletion(
                    4,
                    'Thay đổi điều khoản',
                    const Text(
                      'Ban quản lý có thể cập nhật điều khoản theo thời gian. '
                      'Các thay đổi sẽ được thông báo qua ứng dụng. Việc tiếp tục sử dụng đồng nghĩa bạn chấp nhận điều khoản mới',
                      style: _bodyStyle,
                    ),
                  ),
                  _seletion(
                    5,
                    'Liên hệ',
                    const Text.rich(
                      TextSpan(
                        style: _bodyStyle,
                        children: [
                          TextSpan(
                            text:
                                'Mọi thắc mắc về điều khoản, vui lòng liên hệ qua hotline ',
                          ),
                          TextSpan(
                            text: '1900 1234',
                            style: TextStyle(
                              color: AppColors.tealPrimary,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(text: ' hoặc email '),
                          TextSpan(
                            text: 'bql@urbano.com',
                            style: TextStyle(
                              color: AppColors.tealPrimary,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(text: ' . '),
                        ],
                      ),
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
          'Điều khoản & sử dụng',
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.tealPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.live_help_sharp,
              size: 30,
              color: AppColors.tealPrimary,
            ),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điều khoản sử dụng Urbano',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Cập nhật lần cuối: 22/06/2026',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seletion(int stt, String title, Widget body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$stt',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(padding: EdgeInsets.only(left: 42), child: body),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.tealPrimary),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }
}
