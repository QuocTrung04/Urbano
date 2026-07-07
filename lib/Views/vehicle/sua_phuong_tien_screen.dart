import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/phuong_tien_model.dart';
import 'package:urbano/Services/phuong_tien_services.dart';
import 'package:urbano/core/constants/app_colors.dart';

/// Sửa thông tin xe (chỉ dùng cho xe Chờ duyệt) — cập nhật trực tiếp.
class SuaPhuongTienScreen extends StatefulWidget {
  final PhuongTien xe;
  const SuaPhuongTienScreen({super.key, required this.xe});

  @override
  State<SuaPhuongTienScreen> createState() => _SuaPhuongTienScreenState();
}

class _SuaPhuongTienScreenState extends State<SuaPhuongTienScreen> {
  final _services = PhuongTienServices();
  late final TextEditingController _tenCtrl;
  late final TextEditingController _bienSoCtrl;

  List<LoaiPhuongTien> _loaiList = [];
  bool _loadingLoai = true;
  int? _loaiId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tenCtrl = TextEditingController(text: widget.xe.tenPhuongTien ?? '');
    _bienSoCtrl = TextEditingController(text: widget.xe.bienSo);
    _loaiId = widget.xe.loaiPhuongTien.id;
    _loadLoai();
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _bienSoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLoai() async {
    try {


      final list = await _services.fetchLoaiPhuongTien();
      if (!mounted) return;
      setState(() {
        _loaiList = list;
        _loadingLoai = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingLoai = false);
    }
  }

  (IconData, Color) _loaiStyle(int id) {
    switch (id) {
      case 1:
        return (Icons.directions_car_rounded, AppColors.blue);
      case 2:
        return (Icons.two_wheeler_rounded, AppColors.tealPrimary);
      case 3:
        return (Icons.pedal_bike_rounded, AppColors.amber);
      default:
        return (Icons.electric_scooter_rounded, AppColors.pink);
    }
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
      ),
    );
  }

  Future<void> _luu() async {
    if (_loaiId == null) {
      _snack('Vui lòng chọn loại phương tiện', AppColors.red);
      return;
    }
    if (_tenCtrl.text.trim().isEmpty) {
      _snack('Vui lòng nhập tên phương tiện', AppColors.red);
      return;
    }
    if (_bienSoCtrl.text.trim().isEmpty) {
      _snack('Vui lòng nhập biển số', AppColors.red);
      return;
    }

    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId');

      await _services.capNhatPhuongTien(
        id: widget.xe.id,
        tenPhuongTien: _tenCtrl.text.trim(),
        bienSo: _bienSoCtrl.text.trim(),
        loaiPhuongTienId: _loaiId!,
        canHoId: widget.xe.canHoId,
        nguoiCapNhatId: cuDanId,
        trangThai: widget.xe.trangThai, // giữ nguyên Chờ duyệt
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Đã cập nhật', AppColors.bgMid);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Cập nhật thất bại. Vui lòng thử lại.', AppColors.red);
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
                      const SizedBox(height: 24),
                      _label('Loại phương tiện'),
                      const SizedBox(height: 12),
                      _buildLoaiGrid(),
                      const SizedBox(height: 24),
                      _label('Tên phương tiện'),
                      const SizedBox(height: 10),
                      _textField(
                        _tenCtrl,
                        'VD: Honda Wave...',
                        Icons.directions_car_filled_outlined,
                      ),
                      const SizedBox(height: 20),
                      _label('Biển số'),
                      const SizedBox(height: 10),
                      _textField(
                        _bienSoCtrl,
                        'VD: 51A-123.45',
                        Icons.confirmation_number_outlined,
                        caps: TextCapitalization.characters,
                      ),
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
          'Sửa phương tiện',
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

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  Widget _buildLoaiGrid() {
    if (_loadingLoai) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.tealPrimary),
        ),
      );
    }
    if (_loaiList.isEmpty) {
      return const Text(
        'Chưa có loại phương tiện',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: _loaiList.map((loai) {
        final chon = _loaiId == loai.id;
        final (icon, mau) = _loaiStyle(loai.id);
        return GestureDetector(
          onTap: () => setState(() => _loaiId = loai.id),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: chon
                  ? mau.withValues(alpha: 0.18)
                  : AppColors.nenContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: chon
                    ? mau.withValues(alpha: 0.5)
                    : AppColors.borderButton,
                width: chon ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: mau, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loai.tenLoaiPhuongTien,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chon ? Colors.white : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (chon)
                  Icon(Icons.check_circle_rounded, color: mau, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _textField(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return TextField(
      controller: c,
      textCapitalization: caps,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 20),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 14,
        ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest.withValues(alpha: 0.6),
        border: Border(top: BorderSide(color: AppColors.borderButton)),
      ),
      child: GestureDetector(
        onTap: _submitting ? null : _luu,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _submitting
                ? null
                : const LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealDark],
                  ),
            color: _submitting ? AppColors.inputFill : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Lưu thay đổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
