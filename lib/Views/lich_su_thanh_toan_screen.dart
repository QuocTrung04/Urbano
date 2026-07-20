import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Models/lich_su_thanh_toan_model.dart';
import 'package:urbano/ViewModels/lich_su_thanh_toan_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

class LichSuThanhToanScreen extends StatelessWidget {
  const LichSuThanhToanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LichSuThanhToanViewModel()..loadData(),
      child: const _LichSuView(),
    );
  }
}

class _LichSuView extends StatelessWidget {
  const _LichSuView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    final vm = context.watch<LichSuThanhToanViewModel>();

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
        child: SafeArea(child: _body(context, vm)),
      ),
    );
  }

  Widget _body(BuildContext context, LichSuThanhToanViewModel vm) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(vm.error!, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: vm.loadData,
              child: Text(
                'Thử lại',
                style: TextStyle(color: AppColors.tealPrimary),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: vm.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppbar(context),
            const SizedBox(height: 22),
            _buildHero(vm),
            const SizedBox(height: 26),
            _groupTitle('Dòng thời gian'),
            const SizedBox(height: 16),
            if (vm.danhSach.isEmpty)
              _emptyBox()
            else
              _buildTimeline(context, vm.danhSach, vm.canHoId),
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
            child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Lịch sử thanh toán',
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

  // ---- Card tổng nổi bật ----
  Widget _buildHero(LichSuThanhToanViewModel vm) {
    final nam = DateTime.now().year;
    final tong = LichSuThanhToan(
      id: 0,
      hoaDonId: 0,
      soTien: vm.daDongNamNay,
    ).soTienText;
    final tongLuyKe = LichSuThanhToan(
      id: 0,
      hoaDonId: 0,
      soTien: vm.tongDaThanhToan,
    ).soTienText;
    final ganNhat = vm.danhSach.isNotEmpty
        ? vm.danhSach.first.ngayThanhToan
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tealDark, AppColors.bgMid],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.tealPrimary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: AppColors.tealPrimary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.tealPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Đã đóng năm $nam',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tong,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.textPrimary.withValues(alpha: 0.08)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  Icons.receipt_long_outlined,
                  '${vm.soGiaoDichNamNay}',
                  'GD năm nay',
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: AppColors.textPrimary.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _heroStat(
                  Icons.schedule_rounded,
                  ganNhat != null ? _fmtNgay(ganNhat) : '—',
                  'Gần nhất',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.textPrimary.withValues(alpha: 0.06)),
          const SizedBox(height: 10),
          Text(
            'Tổng từ trước đến nay: $tongLuyKe',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: AppColors.tealPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  // ---- Timeline ----
  Widget _buildTimeline(
    BuildContext context,
    List<LichSuThanhToan> ds,
    int canHoId,
  ) {
    return Column(
      children: List.generate(ds.length, (i) {
        return _timelineItem(
          context,
          ds[i],
          canHoId,
          isLast: i == ds.length - 1,
        );
      }),
    );
  }

  Widget _timelineItem(
    BuildContext context,
    LichSuThanhToan gd,
    int canHoId, {
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // rail: chấm + đường nối
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.tealPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDarkest, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.borderButton),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 0),
              child: _card(context, gd, canHoId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, LichSuThanhToan gd, int canHoId) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final hoaDon = HoaDonModel(
          id: gd.hoaDonId,
          canHo: canHoId,
          thang: gd.thang,
          nam: gd.nam,
        );
        Navigator.pushNamed(
          context,
          AppRoutes.invoiceDetail,
          arguments: hoaDon,
        );
      },
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gd.kyText.isNotEmpty
                            ? gd.kyText
                            : 'Hóa đơn #${gd.hoaDonId}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _fmtDayGio(gd.ngayThanhToan),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${gd.soTienText}',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (gd.phuongThucThanhToan.isNotEmpty ||
                gd.maGiaoDich.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (gd.phuongThucThanhToan.isNotEmpty)
                    _tag(
                      Icons.account_balance_wallet_outlined,
                      gd.phuongThucThanhToan,
                    ),
                  if (gd.maGiaoDich.isNotEmpty)
                    _tag(Icons.tag_rounded, gd.maGiaoDich),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.iconMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textMuted,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'Chưa có giao dịch thanh toán',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _fmtDayGio(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} • $hh:$mi';
  }

  String _fmtNgay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
