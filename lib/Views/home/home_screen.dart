import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/ViewModels/home/home_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadData(),
      child: const _Homeview(),
    );
  }
}

class _Homeview extends StatelessWidget {
  const _Homeview();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(bottom: false, child: _buildBody(context, vm)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.borderSide),
      );
    }
    if (vm.error != null) {
      return _buildError(vm);
    }
    final data = vm.data;
    if (data == null) return SizedBox.shrink();
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: vm.loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, data)),
          _sliverSection(
            title: 'tiện ích nhanh',
            child: _buildQuickAction(context),
          ),
          _sliverSection(
            title: 'hóa đơn tháng ${DateTime.now().month - 1}',
            child: _buildBillSumary(data),
            action: 'Xem chi tiết >',
            onTap: () {
              //TODOL: XU LY SU KIEN
              debugPrint('chi tiết hóa đơn');
              debugPrint(data.cuDan.hoTen);
            },
          ),
          _sliverSection(
            title: 'tiện ích khác',
            child: _buildutilities(context),
            action: 'Xem tất cả >',
            onTap: () {
              //TODOL: XU LY SU KIEN
              debugPrint('tất cả tiện ích');
            },
          ),
          _sliverSection(title: 'thanh toán', child: _buildPayment(context)),
          _sliverSection(
            title: 'bảng tin tòa nhà',
            child: _buildBulletin(data.thongBaoList),
            action: 'Xem tất cả >',
            onTap: () {
              //TODOL: XU LY SU KIEN
              debugPrint('tất cả bảng tin tòa nhà');
            },
          ),
          _sliverSection(
            title: 'THÔNG BÁO MỚI',
            child: _buildNotification(data.thongBaoList),
            action: 'Xem tất cả >',
            onTap: () {
              //TODOL: XU LY SU KIEN
              debugPrint('tất cả thông báo');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildError(HomeViewModel vm) {
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

  Widget _buildHeader(BuildContext context, HomeData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      data.cuDan.hoTen,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              _iconButton(
                Icons.notifications_outlined,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.notification,
                    arguments: data.thongBaoList,
                  );
                  print(context);
                },
                hasdot: data.thongBaoList.any((tb) => tb.trangthai),
              ),
              SizedBox(width: 8),
              _iconButton(
                Icons.settings_rounded,
                onTap: () {
                  //xu ly su kien
                  Navigator.pushNamed(
                    context,
                    AppRoutes.setting,
                    arguments: {
                      'cuDan': data.cuDan,
                      'canHoText': _buildCanHoText(data),
                      'soCanHo': data.canHo.soCanHo,
                    },
                  );
                  debugPrint('setting');
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          _buldApartmentCard(data),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon, {
    bool hasdot = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(icon, color: Color(0xB3FFFFFF), size: 18),
          ),
          if (hasdot)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.tealPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDark, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buldApartmentCard(HomeData data) {
    final canHo = data.canHo;
    final canHoText = _buildCanHoText(data);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.tealDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderSide),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Căn hộ của bạn',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  canHoText,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (canHo.dienTich != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Diện tích: ${canHo.dienTich} m²',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Đang ở',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tealPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildCanHoText(HomeData data) {
    final c = data.canHo;
    final parts = <String>[
      'Tòa ${data.tenToaNha}\n',
      if (c.tang != null) 'Tầng ${c.tang} • ', // chỉ thêm khi có
      'P.${c.soCanHo}',
    ];
    return parts.join();
  }

  Widget _buildQuickAction(BuildContext context) {
    final items = [
      (
        Icons.receipt_long,
        'Hóa đơn',
        AppColors.tealPrimary,
        () {
          debugPrint('Hoa don');
        },
      ),
      (
        Icons.build_rounded,
        'Sửa chữa',
        AppColors.blue,
        () {
          debugPrint('Sua chua');
        },
      ),
      (
        Icons.directions_car_rounded,
        'Phương tiện',
        AppColors.amber,
        () {
          Navigator.pushNamed(context, AppRoutes.phuongTien);
        },
      ),
      (
        Icons.chat_bubble_outlined,
        'Liên hệ',
        AppColors.pink,
        () {
          Navigator.pushNamed(context, AppRoutes.contact);
          debugPrint('lien he');
        },
      ),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _quickItem(item.$1, item.$2, item.$3, item.$4),
          ),
        );
      }).toList(),
    );
  }

  Widget _quickItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0x14FFFFFF)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliverSection({
    required String title,
    String? action,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          children: [
            _selectTitle(title, action, onTap),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _selectTitle(String title, String? action, VoidCallback? onTap) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),

        const Spacer(),

        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.tealPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _boxEmpty(String string) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Text(
        string,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildBillSumary(HomeData data, {VoidCallback? onTap}) {
    if (data.hoaDonList.isEmpty) {
      return _boxEmpty('Chưa có hóa đơn');
    }
    final hd = data.hoaDonList.first;
    final daThanhToan = hd.daThanhToan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Số tiền thanh toán',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 15,
                        color: AppColors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Hạn thanh toán: ${_formatDate(hd.hanThanhToan!)}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hd.tongTienHienThi,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  decoration: BoxDecoration(
                    color: (daThanhToan ? AppColors.tealPrimary : AppColors.red)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daThanhToan ? 'Đã thanh toán' : 'Chưa thanh toán',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: daThanhToan
                          ? AppColors.tealPrimary
                          : AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification(List<ThongBao> thongBaoList) {
    final chuadoc = thongBaoList.where((tb) => tb.trangthai).toList();
    debugPrint('day la trong bao $chuadoc');
    if (chuadoc.isEmpty) {
      return _boxEmpty('Không có thông báo mới');
    }
    return Column(
      children: chuadoc.take(3).map((tb) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _notifiItem(
            tb,
            onTap: () {
              debugPrint('thong bao');
              debugPrint('day la trong bao ${tb.trangthai}');
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _notifiItem(ThongBao tb, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tealPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.tealPrimary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tb.tieuDe ?? 'Thông báo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  if (tb.noiDung != null) ...[
                    SizedBox(height: 2),
                    Text(
                      tb.noiDung!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_sharp,
                        size: 12,
                        color: AppColors.iconMuted,
                      ),
                      SizedBox(width: 4),
                      Text(
                        tb.thoiGianHienThi,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildutilities(BuildContext context) {
    final items = [
      (
        Icons.fitness_center,
        'Phòng Gym',
        'Còn chỗ trống',
        AppColors.tealPrimary,
      ),
      (Icons.pool, 'Hồ Bơi', 'Tự do', AppColors.blue),
      (Icons.local_fire_department, 'Khu BBQ', 'Đăng ký dùng', AppColors.amber),
      (Icons.group, 'Phòng Họp', 'Đặt phòng', AppColors.pink),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _utilCard(items[0])),
            const SizedBox(width: 9),
            Expanded(child: _utilCard(items[1])),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(child: _utilCard(items[2])),
            const SizedBox(width: 9),
            Expanded(child: _utilCard(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _utilCard((IconData, String, String, Color) it) {
    return GestureDetector(
      onTap: () {
        // TODOl: xử lý sự kiện
        debugPrint(it.$2);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: it.$4.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(it.$1, color: it.$4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    it.$2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    it.$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayment(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _paymentCard(
            Icons.payments_outlined,
            'Thông báo TT',
            '2 hóa đơn đến hạn',
            () {
              debugPrint('thong bao thanh toan');
            },
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _paymentCard(Icons.history, 'Lịch sử TT', 'Xem giao dịch', () {
            debugPrint('lịch sử thanh toán');
          }),
        ),
      ],
    );
  }

  Widget _paymentCard(
    IconData icon,
    String string,
    String sub,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          border: Border.all(color: AppColors.borderButton),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppColors.tealPrimary),
            SizedBox(height: 8),
            Text(
              string,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sub,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletin(List<ThongBao> tbList) {
    if (tbList.isEmpty) {
      return _boxEmpty('Chưa có bảng tin');
    }
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tbList.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) => _bulletinCard(tbList[index]),
      ),
    );
  }

  Widget _bulletinCard(ThongBao tb) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        //TODOL:"XU LY SU KIEN"
        debugPrint('chi tiet bang tin');
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.nenContainer,
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo_urbano.png',
              width: double.infinity,
              height: 100,
              fit: BoxFit.fill,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tb.tieuDe ?? 'Bảng tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    if (tb.noiDung != null) ...[
                      SizedBox(height: 8),
                      Text(
                        tb.noiDung!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 4),
                    ],
                    Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_sharp,
                          size: 12,
                          color: AppColors.iconMuted,
                        ),
                        SizedBox(width: 4),
                        Text(
                          tb.thoiGianHienThi,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
