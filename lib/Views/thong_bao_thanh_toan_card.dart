import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Services/hoa_don_services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

/// Card "Thông báo TT" ở Home — tự đếm số hóa đơn chưa thanh toán.
class ThongBaoTTCard extends StatefulWidget {
  const ThongBaoTTCard({super.key});

  @override
  State<ThongBaoTTCard> createState() => _ThongBaoTTCardState();
}

class _ThongBaoTTCardState extends State<ThongBaoTTCard> {
  final HoaDonServices _services = HoaDonServices();
  int _soLuong = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _dem();
  }

  Future<void> _dem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final canHoId = prefs.getInt('canHoId') ?? 0;
      if (canHoId == 0) {
        if (mounted) setState(() => _loaded = true);
        return;
      }
      final list = await _services.fetchHoaDons(canHoId);
      final chuaTT = list.where((h) {
        final con = (h.tongTien ?? 0) - (h.soTienDaThanhToan ?? 0);
        return con > 0;
      }).length;
      if (!mounted) return;
      setState(() {
        _soLuong = chuaTT;
        _loaded = true;
      });
    } catch (e) {
      debugPrint('Lỗi đếm thông báo TT: $e');
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = !_loaded
        ? 'Đang tải...'
        : (_soLuong == 0
              ? 'Không có hóa đơn đến hạn'
              : '$_soLuong hóa đơn cần thanh toán');

    return _paymentCard(
      Icons.payments_outlined,
      'Thông báo TT',
      subtitle,
      _soLuong > 0, // có nợ -> làm nổi bật
      () async {
        await Navigator.pushNamed(context, AppRoutes.thongBaoThanhToan);
        _dem(); // quay lại -> đếm lại
      },
    );
  }

  Widget _paymentCard(
    IconData icon,
    String title,
    String subtitle,
    bool noiBat,
    VoidCallback onTap,
  ) {
    final mau = noiBat ? AppColors.red : AppColors.tealPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          border: Border.all(color: AppColors.borderButton),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon 24 trực tiếp (như bản gốc) + badge số
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: mau),
                if (_soLuong > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.nenContainer,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _soLuong > 9 ? '9+' : '$_soLuong',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
