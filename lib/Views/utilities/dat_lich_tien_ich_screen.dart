import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/Services/dat_lich_tien_ich_services.dart';
import 'package:urbano/core/constants/app_colors.dart';

/// Màn đặt lịch tiện ích (đặt chỗ). Nhận TienIch, gọi API tạo đơn Chờ duyệt.
class DatLichScreen extends StatefulWidget {
  final TienIch tienIch;
  const DatLichScreen({super.key, required this.tienIch});

  @override
  State<DatLichScreen> createState() => _DatLichScreenState();
}

class _DatLichScreenState extends State<DatLichScreen> {
  final DatLichServices _services = DatLichServices();

  DateTime? _ngay;
  TimeOfDay? _gioBatDau;
  TimeOfDay? _gioKetThuc;
  int _soNguoi = 1;
  final _ghiChuCtrl = TextEditingController();
  bool _dangGui = false;

  TienIch get t => widget.tienIch;
  int get _sucChua => t.sucChua ?? 99;
  double get _phi => t.phiSuDung ?? 0;

  @override
  void dispose() {
    _ghiChuCtrl.dispose();
    super.dispose();
  }

  DateTime _ghep(DateTime ngay, TimeOfDay gio) =>
      DateTime(ngay.year, ngay.month, ngay.day, gio.hour, gio.minute);

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
      ),
    );
  }

  Future<void> _chonNgay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngay ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.tealPrimary,
            surface: AppColors.bgMid,
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.bgMid),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _ngay = picked);
  }

  Future<void> _chonGio({required bool batDau}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (batDau ? _gioBatDau : _gioKetThuc) ??
          const TimeOfDay(hour: 8, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.tealPrimary,
            surface: AppColors.bgMid,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (batDau) {
          _gioBatDau = picked;
        } else {
          _gioKetThuc = picked;
        }
      });
    }
  }

  Future<void> _gui() async {
    if (_ngay == null) {
      _snack('Vui lòng chọn ngày', AppColors.red);
      return;
    }
    if (_gioBatDau == null || _gioKetThuc == null) {
      _snack('Vui lòng chọn khung giờ', AppColors.red);
      return;
    }
    final b = _gioBatDau!.hour * 60 + _gioBatDau!.minute;
    final k = _gioKetThuc!.hour * 60 + _gioKetThuc!.minute;
    if (k <= b) {
      _snack('Giờ kết thúc phải sau giờ bắt đầu', AppColors.red);
      return;
    }

    setState(() => _dangGui = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      final canHoId = prefs.getInt('canHoId');
      if (cuDanId == 0) {
        setState(() => _dangGui = false);
        _snack('Không tìm thấy cư dân. Đăng nhập lại.', AppColors.red);
        return;
      }

      await _services.createDatLich(
        token,
        cuDan: cuDanId,
        canHo: canHoId,
        tienIch: t.id,
        thoiGianBatDau: _ghep(_ngay!, _gioBatDau!),
        thoiGianKetThuc: _ghep(_ngay!, _gioKetThuc!),
        soNguoi: _soNguoi,
        ghiChu: _ghiChuCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _dangGui = false);
      await _thanhCong();
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangGui = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), AppColors.red);
    }
  }

  Future<void> _thanhCong() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.tealPrimary,
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Đã gửi đăng ký',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Yêu cầu đặt lịch đã được gửi. Ban quản lý sẽ duyệt trong thời gian sớm nhất.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text(
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
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
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
                      const SizedBox(height: 22),
                      _buildTienIchCard(),
                      const SizedBox(height: 24),
                      _label('Ngày sử dụng'),
                      const SizedBox(height: 10),
                      _pickerBox(
                        icon: Icons.calendar_today_rounded,
                        text: _ngay == null ? 'Chọn ngày' : _fmtNgay(_ngay!),
                        active: _ngay != null,
                        onTap: _chonNgay,
                      ),
                      const SizedBox(height: 20),
                      _label('Khung giờ'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _pickerBox(
                              icon: Icons.schedule_rounded,
                              text: _gioBatDau == null
                                  ? 'Giờ bắt đầu'
                                  : _gioBatDau!.format(context),
                              active: _gioBatDau != null,
                              onTap: () => _chonGio(batDau: true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _pickerBox(
                              icon: Icons.schedule_rounded,
                              text: _gioKetThuc == null
                                  ? 'Giờ kết thúc'
                                  : _gioKetThuc!.format(context),
                              active: _gioKetThuc != null,
                              onTap: () => _chonGio(batDau: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label('Số người'),
                      const SizedBox(height: 10),
                      _buildSoNguoi(),
                      const SizedBox(height: 20),
                      _label('Ghi chú (tùy chọn)'),
                      const SizedBox(height: 10),
                      _buildGhiChu(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Đặt lịch',
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

  Widget _buildTienIchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealPrimary.withValues(alpha: 0.16),
            AppColors.bgMid.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.tealPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.tealPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.tenTienIch,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.gioText}${t.sucChua != null ? '  •  Tối đa ${t.sucChua} người' : ''}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );

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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.iconMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoNguoi() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 18,
            color: AppColors.iconMuted,
          ),
          const SizedBox(width: 10),
          const Text(
            'Số người',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          _nutTron(Icons.remove, () {
            if (_soNguoi > 1) setState(() => _soNguoi--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_soNguoi',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _nutTron(Icons.add, () {
            if (_soNguoi < _sucChua) {
              setState(() => _soNguoi++);
            } else {
              _snack('Tối đa $_sucChua người', AppColors.amber);
            }
          }),
        ],
      ),
    );
  }

  Widget _nutTron(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.tealPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 18, color: AppColors.tealPrimary),
      ),
    );
  }

  Widget _buildGhiChu() {
    return TextField(
      controller: _ghiChuCtrl,
      maxLines: 3,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Nhập ghi chú nếu có...',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderButton),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tealPrimary),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final phiText = _phi <= 0 ? 'Miễn phí' : '${_dinhDang(_phi)} đ';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest.withValues(alpha: 0.6),
        border: Border(top: BorderSide(color: AppColors.borderButton)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phí sử dụng',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              Text(
                phiText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _dangGui ? null : _gui,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _dangGui
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.tealPrimary, AppColors.tealDark],
                      ),
                color: _dangGui ? AppColors.inputFill : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _dangGui
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Gửi đăng ký',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtNgay(DateTime d) {
    const thu = [
      '',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'CN',
    ];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${thu[d.weekday]}, $dd/$mm/${d.year}';
  }

  String _dinhDang(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
