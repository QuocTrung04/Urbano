import 'package:flutter/material.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

// ================== Helpers suy icon/màu/trạng thái/phí ==================
// Dùng chung cho màn Tiện ích và mục tiện ích ở Home.

IconData tienIchIcon(TienIch t) {
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
  if (s.contains('trẻ') || s.contains('vui chơi')) return Icons.child_friendly;
  if (s.contains('vườn') || s.contains('garden')) return Icons.park;
  if (s.contains('phim') || s.contains('rạp')) return Icons.movie_outlined;
  if (s.contains('cafe') || s.contains('café')) {
    return Icons.local_cafe_outlined;
  }
  if (s.contains('giặt')) return Icons.local_laundry_service_outlined;
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

Color tienIchColor(TienIch t) {
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

String tienIchTrangThaiText(TienIch t) {
  if (t.trangThai != null && t.trangThai != 1) return 'Tạm đóng';
  return t.canDatTruoc ? 'Cần đặt trước' : 'Mở cửa';
}

Color tienIchTrangThaiMau(TienIch t) {
  if (t.trangThai != null && t.trangThai != 1) return AppColors.red;
  return t.canDatTruoc ? AppColors.amber : AppColors.tealPrimary;
}

String tienIchPhiText(double? phi) {
  if (phi == null || phi <= 0) return 'Miễn phí';
  final s = phi.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf đ';
}

Widget tienIchStatusPill(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
    ),
  );
}

// ================== Bottom sheet chi tiết (DÙNG CHUNG) ==================
void showTienIchDetail(BuildContext context, TienIch t) {
  final mau = tienIchColor(t);
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(tienIchIcon(t), color: mau, size: 28),
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
                    tienIchStatusPill(
                      tienIchTrangThaiText(t),
                      tienIchTrangThaiMau(t),
                    ),
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
            tienIchPhiText(t.phiSuDung),
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
          _nutDangKy(context, t),
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

Widget _nutDangKy(BuildContext context, TienIch t) {
  final khoa = t.trangThai != null && t.trangThai != 1;

  // Tạm đóng -> container khóa
  if (khoa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.3)),
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
        borderRadius: BorderRadius.circular(12),
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
