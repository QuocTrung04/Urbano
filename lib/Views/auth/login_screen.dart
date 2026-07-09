import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/auth/login_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/Views/auth/forgot_password_screen.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewmodel(),
      child: const _LoginView(), // ⬅ lớp trong
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();
  @override
  State<_LoginView> createState() => _LoginViewState();
}

Future<void> _guiEmail(String email) async {
  final uri = Uri.parse('mailto:$email');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

class _LoginViewState extends State<_LoginView> {
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
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          SizedBox(height: 24),
                          const Spacer(),
                          _buildBottomNote(),
                          SizedBox(height: 18),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
      keyboardType: TextInputType.text,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
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
    final isLoading = context.watch<LoginViewmodel>().isLoading;
    return AppButton(
      icon: Icons.login_rounded,
      label: isLoading ? 'Đang đăng nhập...' : 'Đăng Nhập',
      onPressed: isLoading
          ? null
          : () async {
              final vm = context.read<LoginViewmodel>();
              final result = await vm.login(
                _accountController.text,
                _passwordController.text,
              );
              if (!mounted) return;
              if (result) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.error ?? 'Đăng nhập thất bại')),
                );
              }
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
              style: TextStyle(color: AppColors.textMuted),
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
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          onTap: () {
                            _guiEmail('urbano.support@gmail.com');
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
