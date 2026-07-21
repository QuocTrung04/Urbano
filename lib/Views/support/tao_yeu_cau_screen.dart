import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/Services/yeu_cau_services.dart';
import 'package:urbano/core/constants/app_colors.dart';

class TaoYeuCauScreen extends StatefulWidget {
  const TaoYeuCauScreen({super.key});

  @override
  State<TaoYeuCauScreen> createState() => _TaoYeuCauScreenState();
}

class _TaoYeuCauScreenState extends State<TaoYeuCauScreen> {
  final _tieuDeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();
  final YeuCauServices _services = YeuCauServices();

  int _loaiChon = 1;
  int _uuTienChon = 1;
  bool _dangGui = false;

  List<LoaiYeuCau> _danhSachLoai = [];
  bool _dangTaiLoai = true;

  @override
  void initState() {
    super.initState();
    _taiDanhSachLoai();
  }

  Future<void> _taiDanhSachLoai() async {
    try {
      final list = await _services.fetchLoaiYeuCau();
      if (!mounted) return;
      setState(() {
        _danhSachLoai = list.where((e) => e.id != 4 && e.id != 5 && e.id != 6).toList();
        _dangTaiLoai = false;
        if (_danhSachLoai.isNotEmpty) {
          _loaiChon = _danhSachLoai.first.id;
        }
      });
    } catch (e) {
      debugPrint('Lỗi tải danh sách loại yêu cầu: $e');
      if (!mounted) return;
      setState(() => _dangTaiLoai = false);
    }
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
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

  Future<void> _gui() async {
    final tieuDe = _tieuDeCtrl.text.trim();
    final noiDung = _noiDungCtrl.text.trim();

    if (tieuDe.isEmpty) {
      _baoLoi('Vui lòng nhập tiêu đề');
      return;
    }
    if (noiDung.isEmpty) {
      _baoLoi('Vui lòng nhập nội dung');
      return;
    }

    setState(() => _dangGui = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      final cuDanId = prefs.getInt('cuDanId') ?? 0;
      if (cuDanId == 0) {
        if (!mounted) return;
        setState(() => _dangGui = false);
        _baoLoi('Không tìm thấy cư dân. Vui lòng đăng nhập lại.');
        return;
      }

      final yeuCauMoi = await _services.createYeuCau(
        cuDan: cuDanId,
        loaiYeuCau: _loaiChon,
        tieuDe: tieuDe,
        noiDung: noiDung,
        mucDoUuTien: _uuTienChon,
      );

      if (!mounted) return;
      setState(() => _dangGui = false);
      Navigator.pop(context, yeuCauMoi); // trả về màn danh sách
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu: $e');
      if (!mounted) return;
      setState(() => _dangGui = false);
      _baoLoi('Gửi yêu cầu thất bại. Vui lòng thử lại.');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(),
                const SizedBox(height: 22),

                _label('Loại yêu cầu'),
                _buildLoai(),
                const SizedBox(height: 18),

                _label('Tiêu đề'),
                _buildTextField(
                  _tieuDeCtrl,
                  'VD: Rò rỉ nước nhà tắm',
                  Icons.title,
                ),
                const SizedBox(height: 18),

                _label('Nội dung'),
                _buildTextArea(
                  _noiDungCtrl,
                  'Mô tả chi tiết yêu cầu của bạn...',
                ),
                const SizedBox(height: 18),

                _label('Mức độ ưu tiên'),
                _buildUuTien(),
                const SizedBox(height: 28),

                _buildNutGui(),
              ],
            ),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(Icons.arrow_back, size: 19, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Tạo yêu cầu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLoai() {
    if (_dangTaiLoai) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSide),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.tealPrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    // tìm loại đang chọn (null nếu chưa chọn)
    final loaiChon = _danhSachLoai
        .where((e) => e.id == _loaiChon)
        .cast<LoaiYeuCau?>()
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSide),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: loaiChon?.id,
          hint: Text(
            'Chọn loại yêu cầu',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
          dropdownColor: AppColors.bgMid,
          borderRadius: BorderRadius.circular(8),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: _danhSachLoai.map((loai) {
            return DropdownMenuItem<int>(
              value: loai.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(loai.icon, size: 16, color: loai.color),
                  const SizedBox(width: 8),
                  Text(
                    loai.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _loaiChon = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.iconMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderSide, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.tealPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      maxLines: 5,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderSide, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.tealPrimary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildUuTien() {
    final muc = [
      (1, 'Thấp', AppColors.tealPrimary),
      (2, 'Trung bình', AppColors.amber),
      (3, 'Cao', AppColors.red),
    ];
    return Row(
      children: muc.map((m) {
        final chon = _uuTienChon == m.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: m.$1 == 3 ? 0 : 9),
            child: GestureDetector(
              onTap: () => setState(() => _uuTienChon = m.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: chon
                      ? m.$3.withValues(alpha: 0.15)
                      : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: chon
                        ? m.$3.withValues(alpha: 0.5)
                        : AppColors.borderSide,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: chon ? m.$3 : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      m.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: chon ? m.$3 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNutGui() {
    return GestureDetector(
      onTap: _dangGui ? null : _gui,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealPrimary, AppColors.tealDark],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.tealPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _dangGui
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
                    Icon(Icons.send, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 9),
                    Text(
                      'Gửi yêu cầu',
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
}
