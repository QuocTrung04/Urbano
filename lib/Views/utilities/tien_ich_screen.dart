import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/Services/tien_ich_services.dart';
// import 'package:urbano/Views/utilities/lich_su_dat_tien_ich_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

/// Màn "Tiện ích tòa nhà" - lấy dữ liệu thật từ API (GET /api/tienich).
class TienIchScreen extends StatefulWidget {
  const TienIchScreen({super.key});

  @override
  State<TienIchScreen> createState() => _TienIchScreenState();
}

class _TienIchScreenState extends State<TienIchScreen> {
  final TienIchServices _service = TienIchServices();

  bool _loading = true;
  String? _error;
  List<TienIch> _items = [];

  final List<String> _danhMuc = const [
    'Tất cả',
    'Thể thao',
    'Giải trí',
    'Tiện ích chung',
    'Sự kiện',
    'Khác',
  ];
  String _chon = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchTienIch();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<TienIch> get _loc => _chon == 'Tất cả'
      ? _items
      : _items.where((e) => e.danhMuc == _chon).toList();

  IconData _iconCho(TienIch t) {
    final s = t.tenTienIch.toLowerCase();
    if (s.contains('bơi')) return Icons.pool;
    if (s.contains('gym') || s.contains('tập')) return Icons.fitness_center;
    if (s.contains('tennis')) return Icons.sports_tennis;
    if (s.contains('bbq') || s.contains('nướng')) {
      return Icons.local_fire_department;
    }
    if (s.contains('họp')) return Icons.groups;
    if (s.contains('sinh hoạt') ||
        s.contains('cộng đồng') ||
        s.contains('sự kiện')) {
      return Icons.celebration_outlined;
    }
    if (s.contains('trẻ') || s.contains('vui chơi')) {
      return Icons.child_friendly;
    }
    if (s.contains('vườn') || s.contains('garden')) return Icons.park;
    if (s.contains('phim') || s.contains('rạp')) return Icons.movie_outlined;
    if (s.contains('cafe') || s.contains('café')) {
      return Icons.local_cafe_outlined;
    }
    if (s.contains('giặt')) return Icons.local_laundry_service_outlined;
    // fallback theo danh mục
    switch (t.danhMuc) {
      case 'Thể thao':
        return Icons.fitness_center;
      case 'Giải trí':
        return Icons.celebration_outlined;
      case 'Tiện ích chung':
        return Icons.apartment_rounded;
      case 'Sự kiện':
        return Icons.event;
      default:
        return Icons.widgets_outlined;
    }
  }

  Color _mauCho(TienIch t) {
    switch (t.danhMuc) {
      case 'Thể thao':
        return AppColors.tealPrimary;
      case 'Giải trí':
        return AppColors.pink;
      case 'Tiện ích chung':
        return AppColors.blue;
      case 'Sự kiện':
        return AppColors.amber;
      default:
        return AppColors.blue;
    }
  }

  String _trangThaiText(TienIch t) {
    if (t.trangThai != null && t.trangThai != 1) return 'Tạm đóng';
    return t.canDatTruoc ? 'Cần đặt trước' : 'Tự do';
  }

  Color _trangThaiMau(TienIch t) {
    if (t.trangThai != null && t.trangThai != 1) return AppColors.red;
    return t.canDatTruoc ? AppColors.amber : AppColors.tealPrimary;
  }

  String _phiText(double? phi) {
    if (phi == null || phi <= 0) return 'Miễn phí';
    final s = phi.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$buf đ';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text(
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
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppbar(),
                  const SizedBox(height: 20),
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  _buildFilter(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_loc.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Center(
                  child: Text(
                    'Chưa có tiện ích',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 178,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _tienIchCard(_loc[i]),
                  childCount: _loc.length,
                ),
              ),
            ),
        ],
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Tiện ích tòa nhà',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const Spacer(), // <-- đẩy nút lịch sử sang phải
        // NÚT LỊCH SỬ
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.lichSuDatTienIch);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.tealPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealPrimary.withValues(alpha: 0.18),
            AppColors.blue.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AppColors.tealPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt chỗ tiện ích',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chọn và đăng ký sử dụng các tiện ích trong tòa nhà.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _danhMuc.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, i) {
          final dm = _danhMuc[i];
          final chon = dm == _chon;
          return GestureDetector(
            onTap: () => setState(() => _chon = dm),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: chon
                    ? AppColors.tealPrimary.withValues(alpha: 0.18)
                    : AppColors.nenContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: chon
                      ? AppColors.tealPrimary.withValues(alpha: 0.4)
                      : AppColors.borderButton,
                ),
              ),
              child: Text(
                dm,
                style: TextStyle(
                  color: chon ? AppColors.tealPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tienIchCard(TienIch t) {
    final mau = _mauCho(t);
    final viTri = t.viTri ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _moChiTiet(t),
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
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: mau.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconCho(t), color: mau, size: 22),
                ),
                const Spacer(),
                _statusPill(_trangThaiText(t), _trangThaiMau(t)),
              ],
            ),
            const Spacer(),
            Text(
              t.tenTienIch,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (viTri.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.iconMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      viTri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.iconMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  t.gioText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _moChiTiet(TienIch t) {
    final mau = _mauCho(t);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.borderButton,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: mau.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconCho(t), color: mau, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.tenTienIch,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _statusPill(_trangThaiText(t), _trangThaiMau(t)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(Icons.category_outlined, 'Danh mục', t.danhMuc),
            if ((t.viTri ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _infoRow(Icons.location_on_outlined, 'Vị trí', t.viTri!),
            ],
            const SizedBox(height: 12),
            _infoRow(Icons.access_time_rounded, 'Giờ mở cửa', t.gioText),
            if (t.sucChua != null) ...[
              const SizedBox(height: 12),
              _infoRow(Icons.groups_outlined, 'Sức chứa', '${t.sucChua} người'),
            ],
            const SizedBox(height: 12),
            _infoRow(
              Icons.payments_outlined,
              'Phí sử dụng',
              _phiText(t.phiSuDung),
            ),
            if ((t.moTa ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                t.moTa!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _nutDangKy(t),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.iconMuted),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _nutDangKy(TienIch t) {
    final khoa = t.trangThai != null && t.trangThai != 1;

    // Tạm đóng -> container khóa
    if (khoa) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Tạm ngưng phục vụ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // Không cần đặt trước -> container "Ra vào tự do" (chỉ hiển thị)
    if (!t.canDatTruoc) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.tealPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.tealPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.tealPrimary,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Ra vào tự do',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.tealPrimary,
              ),
            ),
          ],
        ),
      );
    }

    // Cần đặt trước -> nút hành động
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.datLichTienIch, arguments: t);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.tealPrimary, AppColors.tealDark],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Đăng ký đặt trước',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
