import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/notification_model.dart';
import 'package:urbano/Services/notification_services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:urbano/core/network/signalr_service.dart';

class NotificationScreen extends StatefulWidget {
  final List<ThongBao> thongBaoList;
  const NotificationScreen({super.key, required this.thongBaoList});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _tab = 0;
  final ThongbaoServices _services = ThongbaoServices();

  // Danh sách làm việc cục bộ (để cập nhật daDoc tại chỗ)
  late List<ThongBao> _list;
  late SignalRService _signalRService;
  Timer? _debounceTimer;
  String? _lastEventId;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.thongBaoList); // copy để sửa được
    
    _signalRService = Provider.of<SignalRService>(context, listen: false);
    _signalRService.addListener(_onSignalR);

    // Fetch fresh data when screen opens
    _fetchNewData();
  }

  void _onSignalR() {
    if (_signalRService.recentEvents.isNotEmpty) {
      final latest = _signalRService.recentEvents.first;
      final currentEventId = latest['_receivedAt'] as String?;
      
      if (currentEventId != null && currentEventId != _lastEventId) {
        _lastEventId = currentEventId;
        final type = latest['_type'] as String?;
        if (type == 'notification' || type == 'system_alert') {
          if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
          _debounceTimer = Timer(const Duration(seconds: 1), () {
            if (mounted) {
              _fetchNewData();
            }
          });
        }
      }
    }
  }

  Future<void> _fetchNewData() async {
    try {
      final cuDanId = await _getCuDanId();
      final newList = await _services.fetchThongBao(cuDanId);
      if (mounted) {
        setState(() {
          _list = newList;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải lại thông báo: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _signalRService.removeListener(_onSignalR);
    super.dispose();
  }

  bool _isRead(ThongBao tb) => tb.daDoc;
  int get _soChuaDoc => _list.where((tb) => !_isRead(tb)).length;

  Future<int> _getCuDanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cuDanId') ?? 0;
  }

  // Đánh dấu 1 tin đã đọc
  Future<void> _markRead(ThongBao tb) async {
    if (tb.daDoc) return;

    // Cập nhật local ngay
    final i = _list.indexWhere((e) => e.id == tb.id);
    if (i != -1) {
      setState(() => _list[i] = tb.copyWith(daDoc: true));
    }

    // Lưu server
    try {
      final cuDanId = await _getCuDanId();
      await _services.danhDauDaDoc(tb.id, cuDanId);
    } catch (e) {
      debugPrint('Lỗi đánh dấu đã đọc: $e');
    }
  }

  // Đánh dấu TẤT CẢ đã đọc
  Future<void> _markAllRead() async {
    // Cập nhật local ngay
    setState(() {
      for (var i = 0; i < _list.length; i++) {
        if (!_list[i].daDoc) {
          _list[i] = _list[i].copyWith(daDoc: true);
        }
      }
    });

    // Lưu server
    try {
      final cuDanId = await _getCuDanId();
      await _services.danhDauTatCa(cuDanId);
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả: $e');
    }
  }

  List<ThongBao> get _danhSach {
    if (_tab == 1) {
      return _list.where((tb) => !_isRead(tb)).toList();
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppbar(),
              const SizedBox(height: 24),
              _buildTabs(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _buildButtonBack(context),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
          if (_soChuaDoc > 0)
            GestureDetector(
              onTap: _markAllRead,
              child: Text(
                'Đánh dấu là đã đọc',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tealPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          _tabChip('Tất cả', 0),
          const SizedBox(width: 8),
          _tabChip('Chưa đọc', 1, badge: _soChuaDoc),
        ],
      ),
    );
  }

  Widget _tabChip(String lable, int index, {int badge = 0}) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? AppColors.tealPrimary.withValues(alpha: 0.15)
              : AppColors.nenContainer,
          border: Border.all(
            color: selected ? AppColors.borderSide : AppColors.borderButton,
          ),
        ),
        child: Row(
          children: [
            Text(
              lable,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.tealPrimary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            if (badge > 0) ...[
              Text(
                '($badge)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.tealPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final list = _danhSach;

    final homNay = <ThongBao>[];
    final homQua = <ThongBao>[];
    final truocDo = <ThongBao>[];
    final now = DateTime.now();

    for (final tb in list) {
      final d = tb.createdAt;
      if (d == null) {
        truocDo.add(tb);
        continue;
      }
      final thoiGian = DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(d.year, d.month, d.day)).inDays;
      if (thoiGian == 0) {
        homNay.add(tb);
      } else if (thoiGian == 1) {
        homQua.add(tb);
      } else {
        truocDo.add(tb);
      }
    }
    if (list.isEmpty) {
      return Center(
        child: Text(
          'Không có thông báo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        if (homNay.isNotEmpty) ..._goupNotifition('Hôm nay', homNay),
        if (homQua.isNotEmpty) ..._goupNotifition('Hôm qua', homQua),
        if (truocDo.isNotEmpty) ..._goupNotifition('Trước đó', truocDo),
      ],
    );
  }

  List<Widget> _goupNotifition(String title, List<ThongBao> items) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 9),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
      ...items.map(_notifiItem),
    ];
  }

  Widget _notifiItem(ThongBao tb) {
    final chuaDoc = !_isRead(tb);
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(
          context,
          AppRoutes.notificationDetail,
          arguments: tb,
        );
        await _markRead(tb);
        if (!mounted) return;
        debugPrint('day la thoi gian thong bao: $tb.thoiGianHienThi');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: chuaDoc
              ? AppColors.tealPrimary.withValues(alpha: 0.1)
              : AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: chuaDoc
                ? AppColors.tealPrimary.withValues(alpha: 0.2)
                : AppColors.borderButton,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: chuaDoc
                        ? AppColors.tealPrimary.withValues(alpha: 0.2)
                        : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: chuaDoc
                        ? AppColors.tealPrimary
                        : AppColors.iconMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tb.tieuDe ?? 'Thông báo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: chuaDoc
                              ? AppColors.tealPrimary
                              : AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      if (tb.noiDung != null) ...[
                        const SizedBox(height: 2),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_sharp,
                            size: 12,
                            color: AppColors.iconMuted,
                          ),
                          const SizedBox(width: 4),
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
            if (chuaDoc) ...[
              Positioned(
                top: 1,
                right: 1,
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
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBack(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, _list),
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
    );
  }
}
