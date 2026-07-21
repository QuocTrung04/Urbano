import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/Services/auth_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _isSms = true;
  final _auth = AuthServices();
  bool _sending = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.bgDark,
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
          child: LayoutBuilder(
            builder: (context, constrants) {
              return SingleChildScrollView(
                child: IntrinsicHeight(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constrants.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24),
                          _buildButtonBack(context),
                          SizedBox(height: 34),
                          _buildHeader(),
                          SizedBox(height: 24),
                          _buildMethodSelected(),
                          SizedBox(height: 24),
                          AppTextField(
                            label: _isSms ? 'Số điện thoại' : 'Email',
                            hint: _isSms ? '(+84) 0912 345 678' : 'vidu@gmail.com',
                            controller: _controller,
                            keyboardType: _isSms
                                ? TextInputType.phone
                                : TextInputType.emailAddress,
                            inputFormatters: _isSms
                                ? [FilteringTextInputFormatter.digitsOnly]
                                : null,
                            prefixIcon: _isSms
                                ? Icons.phone_callback
                                : Icons.mail_rounded,
                          ),
                          SizedBox(height: 24),
                          Spacer(),
                          AppButton(
                            label: 'Gửi mã xác nhận',
                            onPressed: () async {
                              final contact = _controller.text.trim();
                              if (contact.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isSms
                                          ? 'Vui lòng nhập số điện thoại'
                                          : 'Vui lòng nhập email',
                                    ),
                                  ),
                                );
                                return;
                              }

                              // Backend chỉ hỗ trợ OTP qua EMAIL
                              if (_isSms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Hiện chỉ hỗ trợ nhận mã qua Email',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (_sending) return;
                              final nav = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _sending = true);
                              try {
                                await _auth.forgotPassword(
                                  contact,
                                ); // <-- GỬI OTP
                                if (!mounted) return;
                                setState(() => _sending = false);
                                nav.pushNamed(
                                  AppRoutes.verifyOtp,
                                  arguments: {
                                    'contact': contact,
                                    '_isSms': _isSms,
                                  },
                                );
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _sending = false);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: Icons.send_rounded,
                          ),
                          SizedBox(height: 24),
                          _buildBottomNote(),
                          SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.tealDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSide, width: 1.5),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 26,
            letterSpacing: 1,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Nhập email hoặc số điện thoại đăng ký để tiếp tục.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildMethodSelected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHƯƠNG THỨC NHẬN MÃ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _methodCard(
              icon: Icons.phone_android,
              titel: 'SMS',
              sub: 'Qua điện thoại',
              selected: _isSms,
              onTap: () => setState(() => _isSms = true),
            ),
            SizedBox(width: 12),
            _methodCard(
              icon: Icons.mail_rounded,
              titel: 'Email',
              sub: ' Qua hộp thư',
              selected: !_isSms,
              onTap: () => setState(() => _isSms = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _methodCard({
    required IconData icon,
    required String titel,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.tealPrimary.withValues(alpha: 0.2)
                : Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.borderSide : Color(0x1AFFFFFF),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.tealPrimary : AppColors.iconMuted,
              ),
              SizedBox(height: 10),
              Text(
                titel,
                style: TextStyle(
                  color: selected ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              Text(
                sub,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNote() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Nhớ lại mật khẩu? ',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            TextSpan(
              text: 'Đăng nhập',
              style: TextStyle(color: AppColors.tealDark),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  //TODOl: xu ly su kien
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
            ),
          ],
        ),
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
