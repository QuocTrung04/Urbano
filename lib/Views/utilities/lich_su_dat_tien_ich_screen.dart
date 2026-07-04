import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/lich_dat_tien_ich_viewmodel.dart';
import 'package:urbano/Models/dat_lich_tien_ich_model.dart';
import 'package:urbano/core/constants/app_colors.dart';

class LichSuDatLichScreen extends StatelessWidget {
  const LichSuDatLichScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatLichViewModel()..loadData(),
      child: const _LichSuView(),
    );
  }
}

class _LichSuView extends StatelessWidget {
  const _LichSuView();

  static const _tabs = ['Tất cả', 'Đang đặt', 'Lịch sử'];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final vm = context.watch<DatLichViewModel>();

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _buildAppbar(context),
              ),
              const SizedBox(height: 18),
              _buildTabs(context, vm),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(context, vm)),
            ],
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Lịch sử sử dụng',
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

  Widget _buildTabs(BuildContext context, DatLichViewModel vm) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final chon = vm.tab == i;
          return GestureDetector(
            onTap: () => vm.doiTab(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chon
                    ? AppColors.tealPrimary.withValues(alpha: 0.18)
                    : AppColors.nenContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: chon
                      ? AppColors.tealPrimary.withValues(alpha: 0.5)
                      : AppColors.borderButton,
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  color: chon ? AppColors.tealPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DatLichViewModel vm) {
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
    final ds = vm.danhSachLoc;
    if (ds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Chưa có lịch đặt nào',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: vm.loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: ds.length,
        itemBuilder: (_, i) => _buildCard(context, vm, ds[i]),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DatLichViewModel vm,
    DatLichTienIch d,
  ) {
    final (ttColor, ttIcon) = _trangThaiStyle(d.trangThai);
    final coTheHuy = d.trangThai == 1 || d.trangThai == 2;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
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
                  color: ttColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ttIcon, color: ttColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.tenTienIch.isEmpty ? 'Tiện ích' : d.tenTienIch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      d.maDatLich,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                decoration: BoxDecoration(
                  color: ttColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d.trangThaiText,
                  style: TextStyle(
                    color: ttColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderButton),
          const SizedBox(height: 12),
          _row(Icons.calendar_today_rounded, _ngay(d.thoiGianBatDau)),
          const SizedBox(height: 8),
          _row(
            Icons.schedule_rounded,
            '${_gio(d.thoiGianBatDau)} - ${_gio(d.thoiGianKetThuc)}',
          ),
          const SizedBox(height: 8),
          _row(Icons.groups_outlined, '${d.soNguoi} người  •  ${d.phiText}'),
          if (d.trangThai == 3 && d.lyDoHuy.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(
              Icons.info_outline,
              'Lý do: ${d.lyDoHuy}',
              color: AppColors.red,
            ),
          ],
          if (coTheHuy) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _xacNhanHuy(context, vm, d),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Hủy đặt lịch',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color ?? AppColors.iconMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color ?? Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _xacNhanHuy(
    BuildContext context,
    DatLichViewModel vm,
    DatLichTienIch d,
  ) async {
    final lyDoCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hủy đặt lịch',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: TextField(
          controller: lyDoCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Lý do hủy (tùy chọn)',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.inputFill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderButton),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.tealPrimary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Xác nhận hủy',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      final done = await vm.huy(d.id, lyDoCtrl.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(done ? 'Đã hủy đặt lịch' : 'Hủy thất bại'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: done ? AppColors.bgMid : AppColors.red,
          ),
        );
      }
    }
  }

  (Color, IconData) _trangThaiStyle(int tt) {
    switch (tt) {
      case 1:
        return (AppColors.amber, Icons.hourglass_top_rounded);
      case 2:
        return (AppColors.tealPrimary, Icons.check_circle_rounded);
      case 3:
        return (AppColors.red, Icons.cancel_rounded);
      case 4:
        return (AppColors.textMuted, Icons.block_rounded);
      case 5:
        return (AppColors.blue, Icons.task_alt_rounded);
      default:
        return (AppColors.textMuted, Icons.event_rounded);
    }
  }

  String _ngay(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  String _gio(DateTime? d) {
    if (d == null) return '--:--';
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$hh:$mi';
  }
}
