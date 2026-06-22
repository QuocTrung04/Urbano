import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/ViewModels/yeu_cau_viewmodel.dart';
import 'package:urbano/Views/support/tao_yeu_cau_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';

class YeuCauScreen extends StatelessWidget {
  const YeuCauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => YeuCauViewModel()..loadData(),
      child: const _YeuVauView(),
    );
  }
}

class _YeuVauView extends StatelessWidget {
  const _YeuVauView();
  static const _tabs = ['Tất cả', 'Chờ xử lý', 'Đang xử lý', 'Hoàn thành'];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final vm = context.watch<YeuCauViewModel>();
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(context, vm),
                  SizedBox(height: 24),
                  _buildTab(vm),
                  SizedBox(height: 14),
                  Expanded(child: _buildBody(vm)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context, YeuCauViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
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
              child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Yêu cầu của tôi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final yeuCauMoi = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaoYeuCauScreen()),
              );
              if (yeuCauMoi != null && yeuCauMoi is YeuCauCuDan) {
                vm.themYeuCauMoi(yeuCauMoi);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.tealPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(Icons.add, size: 20, color: AppColors.tealPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(YeuCauViewModel vm) {
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final chon = vm.tab == i;
          return GestureDetector(
            onTap: () => vm.doiTab(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chon
                    ? AppColors.tealPrimary.withValues(alpha: 0.15)
                    : AppColors.nenContainer,
                border: Border.all(
                  color: chon
                      ? AppColors.tealPrimary.withValues(alpha: 0.25)
                      : AppColors.borderButton,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 13,
                  color: chon ? AppColors.tealPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(YeuCauViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Text(
          vm.error!,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final list = vm.danhSachLoc;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Chưa có yêu cầu nào',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildCard(list[i]),
    );
  }

  Widget _buildCard(YeuCauCuDan yc) {
    final priorityColor = _mauUuTien(yc.mucDoUuTien);
    final loai = LoaiYeuCau.timTheoId(yc.loaiYeuCau);
    final (stColor, stBg) = _trangThaiTheme(yc.trangThai);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: priorityColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chip(
                          loai.icon,
                          loai.name,
                          loai.color,
                          loai.color.withValues(alpha: 0.15),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            yc.trangThaiText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: stColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      yc.tieuDe,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (yc.noiDung != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        yc.noiDung!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 11),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.borderButton),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 13,
                            color: AppColors.iconMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatTime(yc.ngayGui ?? yc.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.flag, size: 13, color: priorityColor),
                          const SizedBox(width: 4),
                          Text(
                            yc.uuTienText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _mauUuTien(int muc) {
    switch (muc) {
      case 1:
        return AppColors.tealPrimary;
      case 2:
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  (Color, Color) _trangThaiTheme(int tt) {
    switch (tt) {
      case 1:
        return (AppColors.amber, AppColors.amber.withValues(alpha: 0.15));
      case 2:
        return (AppColors.blue, AppColors.blue.withValues(alpha: 0.15));
      default:
        return (
          AppColors.tealPrimary,
          AppColors.tealPrimary.withValues(alpha: 0.15),
        );
    }
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} • $hh:$mi';
  }
}
