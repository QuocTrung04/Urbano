import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _StateLoginScreen();
}

class _StateLoginScreen extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, Color(0xFF08111B)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoSection(),
                SizedBox(height: 20),
                _buildGreeting(),
                SizedBox(height: 24),
                _buildEmailField(),
                SizedBox(height: 24),
                _buildPassword(),
                SizedBox(height: 8),
                _buildForgetPassword(),
                SizedBox(height: 50),
                _buildButtonLogin(),
                const Spacer(),
                _buildBottomNote(),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/images/logo_urbano.png',
        width: double.infinity,
        height: 200,
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại 👋',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
        Text(
          'Đăng nhập để quản lý căn hộ của bạn',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Số điện thoại / Email',
      hint: 'Nhập Email hoặc SĐT',
      controller: _accountController,
      prefixIcon: Icons.person_3_rounded,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPassword() {
    return AppTextField(
      label: 'Mật khẩu',
      hint: 'Nhập mật khẩu',
      controller: _passwordController,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
        child: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildForgetPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODOL: sử lý sự kiện
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Quên mật khẩu?',
          style: TextStyle(fontSize: 12, color: AppColors.tealPrimary),
        ),
      ),
    );
  }

  Widget _buildButtonLogin() {
    return AppButton(
      icon: Icons.login_rounded,
      label: 'Đăng Nhập',
      onPressed: () {
        // TODOL: sử lý sự kiện
      },
    );
  }

  Widget _buildBottomNote() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Chưa có tài khoản? ',
              style: TextStyle(color: Color(0x66FFFFFF)),
            ),
            TextSpan(
              text: 'Liên hệ ban quản lý',
              style: TextStyle(color: AppColors.tealDark),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Hotline'),
                          onTap: () {
                            // TODOL:  xử lý gọi điện
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          onTap: () {
                            // TODOL: xử lý gửi email
                          },
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
