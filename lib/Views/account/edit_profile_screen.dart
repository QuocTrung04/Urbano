import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Services/account_services.dart';
import 'package:urbano/ViewModels/auth/user_provider.dart';
import 'package:urbano/core/Widgets/app_text_field.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/utils/app_validators.dart';

class EditProfileScreen extends StatefulWidget {
  final CuDan cuDan;
  const EditProfileScreen({super.key, required this.cuDan});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _hoTenDemCtrl;
  late TextEditingController _tenCtrl;
  late TextEditingController _sdtCtrl;
  late TextEditingController _emailCtrl;

  final AccountServices _accountServices = AccountServices();

  late int _gioiTinh;
  DateTime? _ngaySinh;
  bool _dangLuu = false;

  String? _sdtErr;
  String? _emailErr;
  String? _hoTenDemErr;
  String? _tenErr;

  @override
  void initState() {
    super.initState();
    final cd = widget.cuDan;
    _hoTenDemCtrl = TextEditingController(text: cd.hoTenDem ?? '');
    _tenCtrl = TextEditingController(text: cd.ten ?? '');
    _sdtCtrl = TextEditingController(text: cd.sdt ?? '');
    _emailCtrl = TextEditingController(text: cd.email ?? '');
    _gioiTinh = cd.gioiTinh ?? 1;
    _ngaySinh = cd.ngaySinh;
  }

  @override
  void dispose() {
    _hoTenDemCtrl.dispose();
    _tenCtrl.dispose();
    _sdtCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? d) {
    if (d == null) return 'Chọn ngày';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _chonNgaySinh() async {
    final birthday = await showDatePicker(
      context: context,
      helpText: 'Chọn ngày sinh',
      fieldLabelText: 'Ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Đồng ý',
      fieldHintText: 'dd/MM/yyyy',
      locale: const Locale('vi', 'VN'),
      initialDate: _ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.tealPrimary,
            surface: AppColors.bgMid,
          ),
        ),
        child: child!,
      ),
    );
    if (birthday != null) setState(() => _ngaySinh = birthday);
  }

  void _baoLoi(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.red,
      ),
    );
  }

  Future<void> _luu() async {
    final hoTenDem = _hoTenDemCtrl.text.trim();
    final ten = _tenCtrl.text.trim();
    final sdt = _sdtCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    final hoTenDemErr = AppValidators.validateRequired(hoTenDem, 'Họ và tên đệm');
    final tenErr = AppValidators.validateRequired(ten, 'Tên');
    final sdtErr = AppValidators.validatePhone(sdt, isRequired: false);
    final emailErr = AppValidators.validateEmail(email, isRequired: false);

    if (hoTenDemErr != null || tenErr != null || sdtErr != null || emailErr != null) {
      setState(() {
        _hoTenDemErr = hoTenDemErr;
        _tenErr = tenErr;
        _sdtErr = sdtErr;
        _emailErr = emailErr;
      });
      if (sdtErr != null) {
        _baoLoi(sdtErr);
      } else if (emailErr != null) {
        _baoLoi(emailErr);
      } else if (hoTenDemErr != null) {
        _baoLoi(hoTenDemErr);
      } else if (tenErr != null) {
        _baoLoi(tenErr);
      }
      return;
    }
    setState(() => _dangLuu = true);
    try {
      final cuDanMoi = widget.cuDan.copyWith(
        hoTenDem: hoTenDem,
        ten: ten,
        hoTen: '$hoTenDem $ten'.trim(),
        sdt: sdt,
        email: email,
        gioiTinh: _gioiTinh,
        gioiTinhText: _gioiTinh == 1 ? 'Nam' : 'Nữ',
        ngaySinh: _ngaySinh,
      );
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? widget.cuDan.id;


      await _accountServices.capNhatCuDan(cuDanId, cuDanMoi);
      await prefs.setString('cuDan', jsonEncode(cuDanMoi.toJson()));
      if (!mounted) return;

      context.read<UserProvider>().capNhat(cuDanMoi);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cập nhật thành công',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.tealDark,
        ),
      );
      Navigator.pop(context, cuDanMoi);
    } catch (e) {
      debugPrint('Lỗi cập nhật: $e');
      if (mounted) _baoLoi('Cập nhật thất bại');
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(context),
                SizedBox(height: 24),
                _buildHeader(),
                SizedBox(height: 24),
                _sectionLabel('Liên hệ'),
                AppTextField(
                  label: 'Số điện thoại',
                  hint: '(+84) 0912 345 678',
                  controller: _sdtCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  errorText: _sdtErr,
                  onChanged: (_) {
                    if (_sdtErr != null) setState(() => _sdtErr = null);
                  },
                  prefixIcon: Icons.phone_outlined,
                ),
                SizedBox(height: 14),
                AppTextField(
                  label: 'Email',
                  hint: 'vidu@gmail.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailErr,
                  onChanged: (_) {
                    if (_emailErr != null) setState(() => _emailErr = null);
                  },
                  prefixIcon: Icons.email_outlined,
                ),

                SizedBox(height: 14),
                _sectionLabel('Thông tin cá nhân'),
                AppTextField(
                  label: 'Họ và tên đệm',
                  hint: 'VD: Nguyễn Văn',
                  controller: _hoTenDemCtrl,
                  textCapitalization: TextCapitalization.words,
                  errorText: _hoTenDemErr,
                  onChanged: (_) {
                    if (_hoTenDemErr != null) setState(() => _hoTenDemErr = null);
                  },
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 14),
                AppTextField(
                  label: 'Tên',
                  hint: 'VD: An',
                  controller: _tenCtrl,
                  textCapitalization: TextCapitalization.words,
                  errorText: _tenErr,
                  onChanged: (_) {
                    if (_tenErr != null) setState(() => _tenErr = null);
                  },
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: 14),
                _label('Giới tính'),
                _buildGioiTinh(),
                SizedBox(height: 14),
                _label('Ngày sinh'),
                _buildNgaySinh(),
                SizedBox(height: 14),
                _sectionLabel('Định danh'),
                _label('Số CCCD'),
                _buildCccdKhoa(),
                SizedBox(height: 24),
                _buildButton(),
                SizedBox(height: 24),
                _buildGhiChu(),
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
        GestureDetector(
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
        ),
        SizedBox(width: 14),
        Text(
          'Thông tin tài khoản',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.person, color: AppColors.iconMuted, size: 48),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool khoa = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: khoa ? AppColors.iconMuted : AppColors.tealPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: khoa ? AppColors.textHint : AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGioiTinh() {
    return Row(
      children: [
        _gioiTinhBtn('Nam', Icons.male, 1),
        SizedBox(width: 14),
        _gioiTinhBtn('Nữ', Icons.female, 2),
      ],
    );
  }

  Widget _gioiTinhBtn(String text, IconData icon, int value) {
    final chon = _gioiTinh == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gioiTinh = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: chon
                ? AppColors.tealPrimary.withValues(alpha: 0.15)
                : AppColors.nenContainer,
            border: Border.all(
              color: chon
                  ? AppColors.tealPrimary.withValues(alpha: 0.3)
                  : AppColors.borderButton,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: chon ? AppColors.tealPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgaySinh() {
    return GestureDetector(
      onTap: _chonNgaySinh,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          border: Border.all(color: AppColors.borderButton),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 18, color: AppColors.iconMuted),
            SizedBox(width: 12),
            Text(
              _formatTime(_ngaySinh),
              style: TextStyle(
                color: _ngaySinh == null ? AppColors.textHint : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCccdKhoa() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        border: Border.all(color: AppColors.borderButton),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, color: AppColors.iconMuted, size: 18),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              widget.cuDan.cccd ?? '',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Icon(Icons.lock_outline, size: 18, color: AppColors.iconMuted),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: _dangLuu ? null : _luu,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealPrimary, AppColors.tealDark],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: _dangLuu
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 9),
                    Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGhiChu() {
    return Container(
      margin: const EdgeInsets.only(top: 13),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.textHint),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'CCCD do Ban quản lý xác thực, không thể tự chỉnh sửa. '
              'Liên hệ BQL nếu cần thay đổi.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
