import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/core/constants/app_colors.dart';

class TaoYeuCauScreen extends StatefulWidget {
  const TaoYeuCauScreen({super.key});

  @override
  State<TaoYeuCauScreen> createState() => _TaoYeuCauScreenState();
}

class _TaoYeuCauScreenState extends State<TaoYeuCauScreen> {
  final _tieuDeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  int _loaiChon = 1; // mặc định Sửa chữa
  int _uuTienChon = 1; // mặc định Thấp
  bool _dangGui = false;

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

    await Future.delayed(const Duration(milliseconds: 500));

    // Tạo object yêu cầu mới (mock, trạng thái Chờ xử lý)
    final yeuCauMoi = YeuCauCuDan(
      id: DateTime.now().millisecondsSinceEpoch, // id tạm
      loaiYeuCau: _loaiChon,
      tieuDe: tieuDe,
      noiDung: noiDung,
      mucDoUuTien: _uuTienChon,
      trangThai: 1, // Chờ xử lý
      ngayGui: DateTime.now(),
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    setState(() => _dangGui = false);
    Navigator.pop(context, yeuCauMoi); // trả về màn danh sách
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
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
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(Icons.arrow_back, size: 19, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Tạo yêu cầu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLoai() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: LoaiYeuCau.danhSach.map((loai) {
        final chon = _loaiChon == loai.id;
        return GestureDetector(
          onTap: () => setState(() => _loaiChon = loai.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: chon
                  ? loai.color.withValues(alpha: 0.15)
                  : AppColors.inputFill,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: chon
                    ? loai.color.withValues(alpha: 0.5)
                    : AppColors.borderSide,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  loai.icon,
                  size: 16,
                  color: chon ? loai.color : AppColors.textMuted,
                ),
                const SizedBox(width: 7),
                Text(
                  loai.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: chon ? loai.color : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.iconMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSide, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSide, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
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
            padding: const EdgeInsets.only(right: 9),
            child: GestureDetector(
              onTap: () => setState(() => _uuTienChon = m.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: chon
                      ? m.$3.withValues(alpha: 0.15)
                      : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(11),
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
          gradient: const LinearGradient(
            colors: [AppColors.tealPrimary, AppColors.tealDark],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.tealPrimary.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _dangGui
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 18, color: Colors.white),
                    SizedBox(width: 9),
                    Text(
                      'Gửi yêu cầu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
