import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/ViewModels/thong_bao_thanh_toan_viewmodel.dart';
import 'package:urbano/Views/thanh_toan_qr_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';

class ThongBaoThanhToanScreen extends StatelessWidget {
  const ThongBaoThanhToanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThongBaoThanhToanViewModel()..loadData(),
      child: const _ThongBaoView(),
    );
  }
}

class _ThongBaoView extends StatelessWidget {
  const _ThongBaoView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final vm = context.watch<ThongBaoThanhToanViewModel>();

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
        child: SafeArea(child: _body(context, vm)),
      ),
    );
  }

  Widget _body(BuildContext context, ThongBaoThanhToanViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(vm.error!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: vm.loadData,
              child: const Text(
                'Thử lại',
                style: TextStyle(color: AppColors.tealPrimary),
              ),
            ),
          ],
        ),
      );
    }
    final ds = vm.chuaThanhToan;
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: vm.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppbar(context),
            const SizedBox(height: 22),
            if (ds.isEmpty)
              _daThanhToanHet()
            else ...[
              _buildTongCard(vm),
              const SizedBox(height: 22),
              _groupTitle('Cần thanh toán'),
              const SizedBox(height: 12),
              ...ds.map((h) => _buildCard(context, vm, h)),
            ],
          ],
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
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Thông báo thanh toán',
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

  Widget _buildTongCard(ThongBaoThanhToanViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.red.withValues(alpha: 0.18),
            AppColors.bgMid.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tien(vm.tongConNo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cần thanh toán • ${vm.chuaThanhToan.length} hóa đơn',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    ThongBaoThanhToanViewModel vm,
    HoaDonModel h,
  ) {
    final con = vm.conLai(h);
    final (khanText, khanColor, khanIcon) = _khan(h.hanThanhToan);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final ok = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ThanhToanQRScreen(hoaDon: h)),
        );
        if (ok == true && context.mounted) {
          context.read<ThongBaoThanhToanViewModel>().loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: khanColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(khanIcon, color: khanColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hóa đơn tháng ${h.thang}/${h.nam}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _hanText(h.hanThanhToan),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _tien(con),
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 9,
                  ),
                  decoration: BoxDecoration(
                    color: khanColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    khanText,
                    style: TextStyle(
                      color: khanColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: AppColors.tealPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.tealPrimary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _daThanhToanHet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.tealPrimary,
            size: 54,
          ),
          SizedBox(height: 14),
          Text(
            'Bạn đã thanh toán hết',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Không có hóa đơn nào cần thanh toán.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  (String, Color, IconData) _khan(DateTime? han) {
    if (han == null) {
      return ('Chưa có hạn', AppColors.amber, Icons.receipt_long_rounded);
    }
    final now = DateTime.now();
    final days = han.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (days < 0) {
      return ('Quá hạn ${-days} ngày', AppColors.red, Icons.warning_rounded);
    }
    if (days == 0) {
      return ('Đến hạn hôm nay', AppColors.red, Icons.warning_amber_rounded);
    }
    if (days <= 3) {
      return ('Còn $days ngày', AppColors.amber, Icons.access_time_rounded);
    }
    return (
      'Còn $days ngày',
      AppColors.tealPrimary,
      Icons.receipt_long_rounded,
    );
  }

  String _hanText(DateTime? d) {
    if (d == null) return 'Chưa có hạn thanh toán';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return 'Hạn: $dd/$mm/${d.year}';
  }

  String _tien(num v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$buf đ';
  }
}
