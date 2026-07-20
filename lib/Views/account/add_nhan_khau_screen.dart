import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/account/add_nhan_khau_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';

class ThemNhanKhauScreen extends StatelessWidget {
  const ThemNhanKhauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemNhanKhauViewModel(),
      child: const _ThemNhanKhauView(),
    );
  }
}

class _ThemNhanKhauView extends StatefulWidget {
  const _ThemNhanKhauView();

  @override
  State<_ThemNhanKhauView> createState() => _ThemNhanKhauViewState();
}

class _ThemNhanKhauViewState extends State<_ThemNhanKhauView> {
  final _hoTenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();

  DateTime? _ngaySinh;
  int? _gioiTinh = 1;
  String _loaiCuTru = 'Thường trú';

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _cccdCtrl.dispose();
    _sdtCtrl.dispose();
    _emailCtrl.dispose();
    _diaChiCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: AppColors.textPrimary)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
      ),
    );
  }

  Future<void> _chonNgaySinh() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      helpText: 'Chọn ngày sinh',
      fieldLabelText: 'Ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Đồng ý',
      fieldHintText: 'dd/MM/yyyy',
      locale: Locale('vi', 'VN'),
      initialDate: _ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.tealPrimary,
            surface: AppColors.bgMid,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.bgMid),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _ngaySinh = picked);
  }

  Future<void> _onSubmit() async {
    final vm = context.read<ThemNhanKhauViewModel>();

    final ok = await vm.submit(
      hoTen: _hoTenCtrl.text,
      ngaySinh: _ngaySinh,
      gioiTinh: _gioiTinh,
      cccd: _cccdCtrl.text,
      loaiCuTru: _loaiCuTru,
      sdt: _sdtCtrl.text,
      email: _emailCtrl.text,
      diaChi: _diaChiCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      await _showSuccess();
    } else if (vm.error != null) {
      _snack(vm.error!, AppColors.red);
    }
  }

  Future<void> _showSuccess() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.tealPrimary,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Đã gửi yêu cầu',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Yêu cầu thêm nhân khẩu đã được gửi. Ban quản lý sẽ duyệt trong thời gian sớm nhất.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text(
              'Xong',
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
    final vm = context.watch<ThemNhanKhauViewModel>();

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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppbar(),
                      const SizedBox(height: 24),
                      _label('Họ và tên'),
                      const SizedBox(height: 10),
                      _textField(
                        _hoTenCtrl,
                        'Nhập họ tên đầy đủ',
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _label('Ngày sinh'),
                      const SizedBox(height: 10),
                      _pickerBox(
                        icon: Icons.calendar_today_rounded,
                        text: _ngaySinh == null
                            ? 'Chọn ngày sinh'
                            : _fmtNgay(_ngaySinh!),
                        active: _ngaySinh != null,
                        onTap: _chonNgaySinh,
                      ),
                      const SizedBox(height: 20),
                      _label('Giới tính'),
                      const SizedBox(height: 10),
                      _buildGioiTinh(),
                      const SizedBox(height: 20),
                      _label('CCCD (nếu có)'),
                      const SizedBox(height: 10),
                      _textField(
                        _cccdCtrl,
                        'Số CCCD',
                        Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _label('SĐT (nếu có)'),
                      const SizedBox(height: 10),
                      _textField(
                        _sdtCtrl,
                        'Số điện thoại',
                        Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _label('Email (nếu có)'),
                      const SizedBox(height: 10),
                      _textField(
                        _emailCtrl,
                        'Địa chỉ email',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _label('Loại cư trú'),
                      const SizedBox(height: 10),
                      _buildLoaiCuTru(),
                      const SizedBox(height: 20),
                      _label('Địa chỉ/Quê quán'),
                      const SizedBox(height: 10),
                      _textField(
                        _diaChiCtrl,
                        'Nhập địa chỉ hoặc quê quán',
                        Icons.home_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(vm.submitting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar() {
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
        const SizedBox(width: 14),
        Text(
          'Thêm nhân khẩu',
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

  Widget _label(String t) => Text(
    t,
    style: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );

  Widget _textField(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 20),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderButton),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.tealPrimary),
        ),
      ),
    );
  }

  Widget _pickerBox({
    required IconData icon,
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.iconMuted),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: active ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGioiTinh() {
    return Row(
      children: [
        _gtChip(1, 'Nam', Icons.male_rounded),
        const SizedBox(width: 10),
        _gtChip(2, 'Nữ', Icons.female_rounded),
      ],
    );
  }

  Widget _gtChip(int val, String label, IconData icon) {
    final chon = _gioiTinh == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gioiTinh = val),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: chon
                ? AppColors.tealPrimary.withValues(alpha: 0.15)
                : AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: chon
                  ? AppColors.tealPrimary.withValues(alpha: 0.5)
                  : AppColors.borderButton,
              width: chon ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: chon ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoaiCuTru() {
    return Row(
      children: [
        _cuTruChip('Thường trú'),
        const SizedBox(width: 10),
        _cuTruChip('Tạm trú'),
      ],
    );
  }

  Widget _cuTruChip(String val) {
    final chon = _loaiCuTru == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _loaiCuTru = val),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: chon
                ? AppColors.tealPrimary.withValues(alpha: 0.15)
                : AppColors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: chon
                  ? AppColors.tealPrimary.withValues(alpha: 0.5)
                  : AppColors.borderButton,
              width: chon ? 1.5 : 1,
            ),
          ),
          child: Text(
            val,
            style: TextStyle(
              color: chon ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool submitting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest.withValues(alpha: 0.6),
        border: Border(top: BorderSide(color: AppColors.borderButton)),
      ),
      child: GestureDetector(
        onTap: submitting ? null : _onSubmit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: submitting
                ? null
                : LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealDark],
                  ),
            color: submitting ? AppColors.inputFill : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: submitting
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    'Gửi yêu cầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _fmtNgay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
