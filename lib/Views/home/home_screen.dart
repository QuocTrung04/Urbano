import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/bang_tin_model.dart';
import 'package:urbano/Models/home_model.dart';
import 'package:urbano/ViewModels/auth/user_provider.dart';
import 'package:urbano/ViewModels/home/home_viewmodel.dart';
import 'package:urbano/Views/thong_bao_thanh_toan_card.dart';
import 'package:urbano/Views/utilities/home_tien_ich_section.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'dart:async';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/core/network/signalr_service.dart';
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

class _Homeview extends StatefulWidget {
  const _Homeview();
  @override
  State<_Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<_Homeview> with WidgetsBindingObserver {
  late SignalRService _signalRService;
  Timer? _debounceTimer;
  String? _lastEventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _signalRService = Provider.of<SignalRService>(context, listen: false);
    _signalRService.connect();
    _signalRService.addListener(_onSignalREvent);
  }

  void _onSignalREvent() {
    if (_signalRService.recentEvents.isNotEmpty) {
      final latest = _signalRService.recentEvents.first;
      final currentEventId = latest['_receivedAt'] as String?;
      
      if (currentEventId != null && currentEventId != _lastEventId) {
        _lastEventId = currentEventId;
        
        // Badge tự động được cập nhật ở header

        // Không gọi loadData() nữa để tránh load lại toàn trang
        // Badge tự động được Consumer<SignalRService> cập nhật ở header
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_signalRService.isConnected) _signalRService.connect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _signalRService.removeListener(_onSignalREvent);
    super.dispose();
  }

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
          Consumer<SignalRService>(
            builder: (_, signalR, __) {
              if (signalR.isConnected) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: Container(
                  color: Colors.red.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: const Text(
                    'Mất kết nối',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: _buildHeader(context, data, vm)),
          _sliverSection(
            title: 'tiện ích nhanh',
            child: _buildQuickAction(context, data),
          ),
          _sliverSection(
            title: 'hóa đơn tháng ${DateTime.now().month - 1}',
            child: _buildBillSumary(
              data,
              onTap: () {
                context.read<SignalRService>().clearUnread('hoaDon');
                Navigator.pushNamed(
                  context,
                  AppRoutes.invoice,
                  arguments: data.hoaDonList.isNotEmpty
                      ? data.hoaDonList.first.canHo
                      : data.canHo.id,
                );
              },
            ),
            action: 'Xem chi tiết >',
            onTap: () {
              context.read<SignalRService>().clearUnread('hoaDon');
              Navigator.pushNamed(
                context,
                AppRoutes.invoice,
                arguments: data.hoaDonList.isNotEmpty
                    ? data.hoaDonList.first.canHo
                    : data.canHo.id,
              );
            },
          ),
          _sliverSection(
            title: 'tiện ích khác',
            child: const HomeTienIchSection(),
            action: 'Xem tất cả >',
            onTap: () {
              context.read<SignalRService>().clearUnread('datLich');
              Navigator.pushNamed(context, AppRoutes.tienich);
            },
          ),
          _sliverSection(title: 'thanh toán', child: _buildPayment(context)),
          _sliverSection(
            title: 'bảng tin tòa nhà',
            child: _buildBulletin(data.bangTinList),
            action: 'Xem tất cả >',
            onTap: () {
              //TODOL: XU LY SU KIEN
              Navigator.pushNamed(context, AppRoutes.bangTin);
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

  Widget _buildHeader(BuildContext context, HomeData data, HomeViewModel vm) {
    final unreadThongBaoCount = data.thongBaoList.where((tb) => !tb.daDoc).length;

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
                      context.watch<UserProvider>().cuDan?.hoTen ??
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
              Consumer<SignalRService>(
                builder: (_, signalR, __) {
                  final displayCount = unreadThongBaoCount + (signalR.unreadCounts['thongBao'] ?? 0);
                  return Badge(
                    isLabelVisible: displayCount > 0,
                    label: Text('$displayCount'),
                    child: _iconButton(
                      Icons.notifications_outlined,
                      onTap: () async {
                        signalR.clearUnread('thongBao');
                        final ketQua = await Navigator.pushNamed(
                          context,
                          AppRoutes.notification,
                          arguments: data.thongBaoList,
                        );
                        if (ketQua is List<ThongBao>) vm.capNhatThongBao(ketQua);
                      },
                      hasdot: false,
                    ),
                  );
                },
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
          _buldApartmentCard(context, data),
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

  Widget _buldApartmentCard(BuildContext context, HomeData data) {
    final canHo = data.canHo;
    final canHoText = _buildCanHoText(data);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.nhanKhau);
      },
      child: Container(
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
                canHo.trangThaiText ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tealPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                canHo.loaiCanHoText ?? '',
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
      ),
    );
  }

  String _buildCanHoText(HomeData data) {
    final c = data.canHo;
    final parts = <String>[
      '${data.tenToaNha}\n',
      if (c.tang != null) 'Tầng ${c.tang} • ', // chỉ thêm khi có
      c.soCanHo,
    ];
    return parts.join();
  }

  Widget _buildQuickAction(BuildContext context, HomeData data) {
    final canHoId = data.hoaDonList.isNotEmpty
        ? data.hoaDonList.first.canHo
        : data.canHo.id;
    final items = [
      (
        Icons.receipt_long,
        'Hóa đơn',
        AppColors.tealPrimary,
        () {
          context.read<SignalRService>().clearUnread('hoaDon');
          Navigator.pushNamed(context, AppRoutes.invoice, arguments: canHoId);
        },
      ),
      (
        Icons.build_rounded,
        'Yêu cầu',
        AppColors.blue,
        () {
          context.read<SignalRService>().clearUnread('yeuCau');
          Navigator.pushNamed(context, AppRoutes.yeucau);
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



  Widget _buildPayment(BuildContext context) {
    return Row(
      children: [
        Expanded(child: const ThongBaoTTCard()),
        SizedBox(width: 9),
        Expanded(
          child: _paymentCard(Icons.history, 'Lịch sử TT', 'Xem giao dịch', () {
            Navigator.pushNamed(context, AppRoutes.lichSuThanhToan);
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

  Widget _buildBulletin(List<BangTin> btList) {
    if (btList.isEmpty) {
      return _boxEmpty('Chưa có bảng tin');
    }
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: btList.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) => _bulletinCard(context, btList[index]),
      ),
    );
  }

  Widget _bulletinCard(BuildContext context, BangTin bt) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bangTinDetail, arguments: bt);
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.nenContainer,
          border: Border.all(color: AppColors.borderButton),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bt.hinhanh
                ? Image.network(
                    bt.hinhUrl!,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/logo_urbano.png',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.fill,
                    ),
                  )
                : Image.asset(
                    'assets/images/hinh_thongbao.png',
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.fill,
                  ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bt.tieuDe ?? 'Bảng tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (bt.noiDung != null) ...[
                      SizedBox(height: 2),
                      Text(
                        bt.noiDung!,
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
                          bt.thoiGianHienThi,
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
