import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/Services/auth_services.dart';
import 'package:urbano/core/routes/app_routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = AuthServices();
  bool _loading = false;

  bool _obscure1 = true;
  bool _obscure2 = true;

  bool get _hasMinLength => _newPasswordController.text.length >= 6;
  bool get _hasUpperLow {
    final t = _newPasswordController.text;
    return t != t.toUpperCase() && t != t.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasSpecial =>
      _newPasswordController.text.contains(RegExp(r'[!@#$%^&*()<>:"|]'));

  int get _strength {
    int s = 0;
    if (_hasMinLength) s++;
    if (_hasUpperLow) s++;
    if (_hasSpecial) s++;
    if (_newPasswordController.text.contains(RegExp(r'[0-9]'))) s++;
    return s;
  }

  String get _strengthText {
    switch (_strength) {
      case 0:
      case 1:
        return 'Yếu';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Khá';
      default:
        return 'Mạnh';
    }
  }

  Color get _strengthColor {
    switch (_strength) {
      case 0:
      case 1:
        return Color(0xFFFF4500);
      case 2:
        return Color(0xFFEF9F27);
      case 3:
        return Color(0xFF5BA4D4);
      default:
        return AppColors.tealPrimary;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _thanhCong() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Thành công', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Mật khẩu đã được đặt lại. Vui lòng đăng nhập.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(color: AppColors.tealPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final email = (args?['email'] ?? '') as String;
    final otp = (args?['otp'] ?? '') as String;
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
                          SizedBox(height: 24),
                          _buildButtonBack(context),
                          SizedBox(height: 38),
                          _buildHeader(),
                          SizedBox(height: 28),
                          AppTextField(
                            label: 'Mật khẩu mới',
                            hint: 'Nhập mật khẩu mới',
                            controller: _newPasswordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscure1,
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscure1 = !_obscure1),
                              child: Icon(
                                _obscure1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          _strengthBar(),
                          SizedBox(height: 24),
                          AppTextField(
                            label: 'Xác nhận mật khẩu',
                            hint: 'Nhập lại mật khẩu mới',
                            controller: _confirmPasswordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            //keyboardType: TextInputType.visiblePassword,
                            obscureText: _obscure2,
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscure2 = !_obscure2),
                              child: Icon(
                                _obscure2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          _ruleChecklist(),
                          Spacer(),
                          SizedBox(height: 24),
                          AppButton(
                            label: 'Hoàn tất',
                            onPressed: () async {
                              final mk = _newPasswordController.text;
                              final nhapLai = _confirmPasswordController.text;
                              if (!_hasMinLength) {
                                _snack('Mật khẩu tối thiểu 6 ký tự');
                                return;
                              }
                              if (mk != nhapLai) {
                                _snack('Mật khẩu nhập lại không khớp');
                                return;
                              }
                              if (_loading) return;
                              setState(() => _loading = true);
                              try {
                                await _auth.resetPassword(
                                  email: email,
                                  otp: otp,
                                  newPassword: mk,
                                );
                                if (!mounted) return;
                                setState(() => _loading = false);
                                _thanhCong(); // dialog + về login
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _loading = false);
                                _snack(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ); // "OTP sai hoặc đã hết hạn"
                              }
                            },
                            icon: Icons.check_outlined,
                          ),
                          SizedBox(height: 24),
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
              Icons.password_rounded,
              size: 40,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Đặt mật khẩu mới',
          style: TextStyle(
            fontSize: 26,
            letterSpacing: 1,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Tạo mật khẩu mới cho tài khoản của bạn',
          style: TextStyle(color: AppColors.textMuted, fontSize: 18),
        ),
      ],
    );
  }

  Widget _strengthBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                //margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                height: 2,
                decoration: BoxDecoration(
                  color: i < _strength
                      ? _strengthColor
                      : AppColors.borderButton,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Độ mạnh: $_strengthText',
          style: TextStyle(fontSize: 11, color: _strengthColor),
        ),
      ],
    );
  }

  Widget _ruleChecklist() {
    return Column(
      children: [
        _rule('Ít nhất 6 ký tự', _hasMinLength),
        _rule('Có chữ hoa và chữ thường', _hasUpperLow),
        _rule('Có ít nhất 1 ký tự đặc biệt', _hasSpecial),
      ],
    );
  }

  Widget _rule(String text, bool ok) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.circle_outlined,
            color: ok ? AppColors.tealPrimary : AppColors.iconMuted,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ok ? AppColors.tealPrimary : AppColors.textMuted,
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
