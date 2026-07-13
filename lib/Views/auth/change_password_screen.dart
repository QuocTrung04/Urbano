import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/ViewModels/auth/change_password_viewmodel.dart';
import 'package:urbano/core/Widgets/app_button.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/core/constants/app_colors.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewmodel(),
      child: _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();
  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _matkhaucu = TextEditingController();
  final _matkhaumoi = TextEditingController();
  final _xacnhanmatkhau = TextEditingController();

  bool _obscurecu = true;
  bool _obscuremoi = true;
  bool _obscurexacnhan = true;

  @override
  void dispose() {
    _matkhaucu.dispose();
    _matkhaumoi.dispose();
    _xacnhanmatkhau.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _matkhaucu.addListener(() => setState(() {}));
    _matkhaumoi.addListener(() => setState(() {}));
    _xacnhanmatkhau.addListener(() => setState(() {}));
  }

  bool get _duDoDai => _matkhaumoi.text.length >= 6;
  bool get _coChuVaSo =>
      RegExp(r'[a-zA-Z]').hasMatch(_matkhaumoi.text) &&
      RegExp(r'[0-9]').hasMatch(_matkhaumoi.text);
  bool get _kytudacbiet =>
      RegExp(r'[!@#$%^&*(),.?:{}|<>]').hasMatch(_matkhaumoi.text);

  Future<void> _capNhat() async {
    final prefs = await SharedPreferences.getInstance();
    final cuDanId = prefs.getInt('cuDanId') ?? 0;
    debugPrint('cu dandfsdfds: $cuDanId');
    if (!mounted) return;
    final vm = context.read<ChangePasswordViewmodel>();
    final result = await vm.doiMatKhau(
      cuDanId,
      _matkhaucu.text,
      _matkhaumoi.text,
      _xacnhanmatkhau.text,
    );
    if (!mounted) return;
    if (result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đổi mật khẩu thành công')));
      Navigator.pop(context);
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
    final vm = context.watch<ChangePasswordViewmodel>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: IntrinsicHeight(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24),
                          Row(
                            children: [
                              _buildButtonBack(context),
                              SizedBox(width: 14),
                              Text(
                                'Đổi mật khẩu',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 34),
                          _buildHeader(),
                          SizedBox(height: 24),
                          AppTextField(
                            label: 'Nhập mật khẩu hiện tại',
                            hint: 'Nhập mật khẩu cũ',
                            controller: _matkhaucu,
                            prefixIcon: Icons.lock,
                            obscureText: _obscurecu,
                            suffixIcon: _eyeIcon(
                              _obscurecu,
                              () => setState(() {
                                _obscurecu = !_obscurecu;
                              }),
                            ),
                          ),
                          _loiText(vm.errCu),

                          SizedBox(height: 24),
                          AppTextField(
                            label: 'Nhập mật khẩu mới',
                            hint: 'Nhập mật khẩu mới',
                            controller: _matkhaumoi,
                            prefixIcon: Icons.lock_reset_rounded,
                            obscureText: _obscuremoi,
                            suffixIcon: _eyeIcon(
                              _obscuremoi,
                              () => setState(() {
                                _obscuremoi = !_obscuremoi;
                              }),
                            ),
                          ),
                          _loiText(vm.errMoi),

                          SizedBox(height: 24),
                          AppTextField(
                            label: 'Xác nhận mật khẩu',
                            hint: 'Xác nhận mật khẩu',
                            controller: _xacnhanmatkhau,
                            prefixIcon: Icons.lock_clock_rounded,
                            obscureText: _obscurexacnhan,
                            suffixIcon: _eyeIcon(
                              _obscurexacnhan,
                              () => setState(() {
                                _obscurexacnhan = !_obscurexacnhan;
                              }),
                            ),
                          ),
                          _loiText(vm.errXacNhan),

                          SizedBox(height: 24),
                          _buildRequirements(),
                          Spacer(),
                          AppButton(
                            label: vm.isLoading
                                ? 'Đang xử lý...'
                                : 'Cập nhật mật khẩu',
                            onPressed: () {
                              vm.isLoading ? null : _capNhat();
                            },
                            icon: Icons.save_alt_outlined,
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

  Widget _loiText(String? loi) {
    if (loi == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.red),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              loi,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eyeIcon(bool hidden, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: AppColors.iconMuted,
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
              borderRadius: BorderRadius.circular(8),
              color: AppColors.tealPrimary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.borderSide),
            ),
            child: Icon(
              Icons.lock_clock_outlined,
              size: 40,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Tạo mật khẩu mới để bảo vệ tài khoản của bạn',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yêu cầu mật khẩu',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 2),
          _reqItem('Ít nhất có 6 ký tự', _duDoDai),
          SizedBox(height: 2),
          _reqItem('Có chữ và số', _coChuVaSo),
          SizedBox(height: 2),
          _reqItem('Có ký tự đặc biệt', _kytudacbiet),
        ],
      ),
    );
  }

  Widget _reqItem(String string, bool check) {
    return Row(
      children: [
        Icon(
          check ? Icons.check_circle : Icons.check_circle_outline,
          color: check ? AppColors.tealPrimary : AppColors.iconMuted,
          size: 13,
        ),
        SizedBox(width: 8),
        Text(
          string,
          style: TextStyle(
            fontSize: 12,
            color: check ? Colors.white : AppColors.textMuted,
          ),
        ),
      ],
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
        child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
      ),
    );
  }
}
