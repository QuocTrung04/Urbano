import 'package:flutter/material.dart';
import 'package:urbano/core/constants/app_colors.dart';

// Màu phụ cho các icon (chưa có trong AppColors — có thể chuyển vào core sau)
const _blue = Color(0xFF5BA4D4);
const _amber = Color(0xFFEF9F27);
const _pink = Color(0xFFED93B1);
const _red = Color(0xFFE06363);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _sectionTitle('Tiện ích nhanh'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _sectionTitle('Hóa đơn tháng 6'),
                    const SizedBox(height: 12),
                    _buildBills(),
                    const SizedBox(height: 24),
                    _sectionTitle('Thông báo mới'),
                    const SizedBox(height: 12),
                    _buildNotifications(),
                    const SizedBox(height: 24),
                    _sectionTitle('Dịch vụ'),
                    const SizedBox(height: 12),
                    _buildServices(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nguyễn Văn An',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _iconButton(Icons.notifications_outlined, hasDot: true),
              const SizedBox(width: 10),
              _iconButton(Icons.settings_outlined),
            ],
          ),
          const SizedBox(height: 16),
          _buildApartmentCard(),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {bool hasDot = false}) {
    return Stack(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Icon(icon, color: const Color(0xB3FFFFFF), size: 18),
        ),
        if (hasDot)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgDark, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildApartmentCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tealPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tealPrimary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CĂN HỘ CỦA BẠN',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tòa S1 - Tầng 12 - P.1204',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Vinhomes Grand Park, Q.9',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Đang ở',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.tealPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tiện ích nhanh ──────────────────────────────────────────
  Widget _buildQuickActions() {
    final items = [
      (Icons.receipt_long, 'Hóa đơn', AppColors.tealPrimary),
      (Icons.build_outlined, 'Sửa chữa', _blue),
      (Icons.directions_car_outlined, 'Gửi xe', _amber),
      (Icons.chat_bubble_outline, 'Phản ánh', _pink),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _quickItem(item.$1, item.$2, item.$3),
          ),
        );
      }).toList(),
    );
  }

  Widget _quickItem(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ─── Hóa đơn ─────────────────────────────────────────────────
  Widget _buildBills() {
    return Column(
      children: [
        _billCard(
          Icons.bolt,
          _amber,
          'Điện',
          'Tháng 5 · Hạn 15/06',
          '850.000đ',
          false,
        ),
        const SizedBox(height: 10),
        _billCard(
          Icons.water_drop_outlined,
          _blue,
          'Nước',
          'Tháng 5 · Hạn 15/06',
          '220.000đ',
          false,
        ),
        const SizedBox(height: 10),
        _billCard(
          Icons.apartment,
          AppColors.tealPrimary,
          'Phí quản lý',
          'Tháng 6 · Đã thanh toán',
          '1.200.000đ',
          true,
        ),
      ],
    );
  }

  Widget _billCard(
    IconData icon,
    Color iconColor,
    String name,
    String due,
    String amount,
    bool paid,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  due,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0x59FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (paid ? AppColors.tealPrimary : _red).withOpacity(
                    0.15,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paid ? 'Đã thanh toán' : 'Chưa thanh toán',
                  style: TextStyle(
                    fontSize: 10,
                    color: paid ? AppColors.tealPrimary : _red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Thông báo ───────────────────────────────────────────────
  Widget _buildNotifications() {
    return Column(
      children: [
        _notifItem(
          Icons.warning_amber_rounded,
          _amber,
          'Tạm ngưng cấp nước',
          'Bảo trì tầng 10–15 từ 8:00–12:00 ngày 10/06',
          '2 giờ trước',
        ),
        const SizedBox(height: 10),
        _notifItem(
          Icons.event_outlined,
          _blue,
          'Họp cư dân tháng 6',
          'Phòng sinh hoạt cộng đồng, 19:00 ngày 12/06',
          '1 ngày trước',
        ),
        const SizedBox(height: 10),
        _notifItem(
          Icons.check_circle_outline,
          AppColors.tealPrimary,
          'Yêu cầu sửa chữa hoàn thành',
          'Thay bóng đèn hành lang P.1204 đã xong',
          '2 ngày trước',
        ),
      ],
    );
  }

  Widget _notifItem(
    IconData icon,
    Color iconColor,
    String title,
    String desc,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0x40FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dịch vụ ─────────────────────────────────────────────────
  Widget _buildServices() {
    final services = [
      (
        Icons.build_outlined,
        'Sửa chữa & bảo trì',
        'Gửi yêu cầu online',
        AppColors.tealPrimary,
      ),
      (Icons.inventory_2_outlined, 'Nhận bưu kiện', '3 kiện đang chờ', _blue),
      (Icons.vpn_key_outlined, 'Thẻ từ / chìa khóa', 'Đăng ký thêm', _amber),
      (Icons.group_outlined, 'Đăng ký khách', 'Tạo QR vào cửa', _pink),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: services
          .map((s) => _serviceCard(s.$1, s.$2, s.$3, s.$4))
          .toList(),
    );
  }

  Widget _serviceCard(IconData icon, String name, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Color(0x59FFFFFF)),
          ),
        ],
      ),
    );
  }

  // ─── Helper ──────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0x80FFFFFF),
        letterSpacing: 1,
      ),
    );
  }
}
