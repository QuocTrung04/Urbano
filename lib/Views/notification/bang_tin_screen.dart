import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/ViewModels/bang_tin_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

class BangTinScreen extends StatelessWidget {
  const BangTinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BangTinViewModel()..loadData(),
      child: const _BangTinView(),
    );
  }
}

class _BangTinView extends StatelessWidget {
  const _BangTinView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final vm = context.watch<BangTinViewModel>();
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(context),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tin tức và thông báo từ ban quản lý',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(child: _buildBody(context, vm)),
              ],
            ),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        SizedBox(width: 14),
        Text(
          'Bảng tin',
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

  Widget _buildBody(BuildContext context, BangTinViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Text(
          vm.error!,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
      );
    }
    if (vm.danhSach.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.feed_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Chưa có bảng tin',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgMid,
      child: ListView.builder(
        itemCount: vm.danhSach.length,
        itemBuilder: (_, i) => _buildCard(context, vm.danhSach[i]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, BangTin bt) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bangTinDetail, arguments: bt);
      },

      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.borderButton.withValues(alpha: 0.25),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _cardCoAnh(bt),
      ),
    );
  }

  Widget _cardCoAnh(BangTin bt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: bt.hinhanh
                  ? Image.network(
                      bt.hinhUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.inputFill,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.tealPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.inputFill,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.iconMuted,
                            size: 30,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/hinh_thongbao.png',
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.fill,
                    ),
            ),
            if (bt.tinMoi) Positioned(top: 12, left: 12, child: _badgeMoi()),
          ],
        ),
        Padding(padding: EdgeInsets.all(13), child: _noiDungThe(bt)),
      ],
    );
  }

  Widget _noiDungThe(BangTin bt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bt.tieuDe ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
            height: 1.5,
          ),
        ),
        if (bt.noiDung != null) ...[
          const SizedBox(height: 6),
          Text(
            bt.noiDung!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.only(top: 13),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderButton)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_sharp,
                size: 14,
                color: AppColors.iconMuted,
              ),
              SizedBox(width: 8),
              Text(
                bt.thoiGianHienThi,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Spacer(),
              Text(
                'Xem chi tiết',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tealPrimary,
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: AppColors.tealPrimary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeMoi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 7, color: AppColors.tealPrimary),
          SizedBox(width: 5),
          Text(
            'MỚI',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.tealPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
