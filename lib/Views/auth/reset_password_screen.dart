import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter/services.dart';
import 'package:urbano/core/Widgets/app_back_button.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/core/constants/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
                          AppBackButton(),
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
                            onPressed: () {},
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
              color: AppColors.tealDark.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
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
            color: Colors.white,
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
                      : const Color(0x1AFFFFFF),
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
}
