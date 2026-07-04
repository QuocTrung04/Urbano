import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/add_phuong_tien_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';

/// Màn yêu cầu thêm phương tiện mới (chỉ UI).
/// Logic nằm ở ThemPhuongTienViewModel, gọi API qua PhuongTienServices.
class ThemPhuongTienScreen extends StatelessWidget {
  const ThemPhuongTienScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemPhuongTienViewModel(),
      child: const _ThemPhuongTienView(),
    );
  }
}

class _ThemPhuongTienView extends StatefulWidget {
  const _ThemPhuongTienView();

  @override
  State<_ThemPhuongTienView> createState() => _ThemPhuongTienViewState();
}

class _ThemPhuongTienViewState extends State<_ThemPhuongTienView> {
  // (id, tên, icon, màu)
  final List<(int, String, IconData, Color)> _loaiOptions = const [
    (1, 'Ô tô', Icons.directions_car_rounded, AppColors.blue),
    (2, 'Xe máy', Icons.two_wheeler_rounded, AppColors.tealPrimary),
    (3, 'Xe đạp', Icons.pedal_bike_rounded, AppColors.amber),
    (4, 'Xe điện', Icons.electric_scooter_rounded, AppColors.pink),
  ];

  final TextEditingController _tenCtrl = TextEditingController();
  final TextEditingController _bienSoCtrl = TextEditingController();

  @override
  void dispose() {
    _tenCtrl.dispose();
    _bienSoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final vm = context.read<ThemPhuongTienViewModel>();
    final ok = await vm.submit(ten: _tenCtrl.text, bienSo: _bienSoCtrl.text);
    if (!mounted) return;
    if (ok) {
      await _showSuccess();
    } else if (vm.error != null) {
      _snack(vm.error!);
    }
  }

  Future<void> _showSuccess() async {
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
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Đã gửi yêu cầu',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Yêu cầu thêm phương tiện đã được gửi. Ban quản lý sẽ duyệt trong thời gian sớm nhất.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // đóng dialog
              Navigator.pop(context, true); // đóng form, báo caller refresh
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

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bgMid,
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

    final vm = context.watch<ThemPhuongTienViewModel>();

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(),
                const SizedBox(height: 24),

                _label('Loại phương tiện'),
                const SizedBox(height: 12),
                _buildLoaiGrid(vm),
                const SizedBox(height: 24),

                _label('Tên phương tiện'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _tenCtrl,
                  hint: 'VD: Toyota Vios, Honda Wave...',
                  icon: Icons.directions_car_filled_outlined,
                ),
                const SizedBox(height: 20),

                _label('Biển số'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _bienSoCtrl,
                  hint: 'VD: 51A-123.45',
                  icon: Icons.confirmation_number_outlined,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Yêu cầu sẽ ở trạng thái "Chờ duyệt" cho đến khi ban quản lý xác nhận.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                _buildSubmit(vm.submitting),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLoaiGrid(ThemPhuongTienViewModel vm) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: _loaiOptions.map((o) {
        final chon = vm.loaiId == o.$1;
        return GestureDetector(
          onTap: () => vm.chonLoai(o.$1),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: chon
                  ? o.$4.withValues(alpha: 0.18)
                  : AppColors.nenContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: chon
                    ? o.$4.withValues(alpha: 0.5)
                    : AppColors.borderButton,
                width: chon ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(o.$3, color: o.$4, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    o.$2,
                    style: TextStyle(
                      color: chon ? Colors.white : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (chon)
                  Icon(Icons.check_circle_rounded, color: o.$4, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
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

  Widget _buildSubmit(bool submitting) {
    return GestureDetector(
      onTap: submitting ? null : _onSubmit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: submitting
              ? null
              : const LinearGradient(
                  colors: [AppColors.tealPrimary, AppColors.tealDark],
                ),
          color: submitting ? AppColors.inputFill : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.tealPrimary,
                  ),
                )
              : const Text(
                  'Gửi yêu cầu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
          'Thêm phương tiện',
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
}
