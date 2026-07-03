import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/features/invoice/ViewModels/hoa_don_detail_viewmodel.dart';

class HoaDonDetailView extends StatelessWidget {
  const HoaDonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HoaDonDetailViewModel>();
    final item = vm.hoaDon;

    final bool isPaid = item.daThanhToan;
    final int status = item.trangThai ?? 1;

    Color statusColor;
    String statusText;

    if (status == 2 || isPaid) {
      statusColor = AppColors.tealPrimary;
      statusText = 'Đã thanh toán';
    } else if (status == 3) {
      statusColor = AppColors.amber;
      statusText = 'Thanh toán một phần';
    } else {
      statusColor = AppColors.red;
      statusText = 'Chưa thanh toán';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHI TIẾT HÓA ĐƠN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header summary card
                      _buildHeaderCard(context, item, statusText, statusColor),
                      const SizedBox(height: 24),

                      // Detailed breakdown title
                      const Text(
                        'CHI TIẾT PHÍ DỊCH VỤ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Detailed items list
                      if (item.chiTietHoaDonList.isEmpty)
                        _buildEmptyDetails(context)
                      else
                        ...item.chiTietHoaDonList.map(
                          (detail) => _buildDetailItem(context, detail),
                        ),

                      const SizedBox(height: 24),

                      // Payment Summary table
                      _buildPaymentSummary(context, item, isPaid),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Action CTA
              _buildBottomAction(context, item, isPaid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    HoaDonModel item,
    String statusText,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.kyThanhToan,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderButton, height: 24),
          const Text(
            'Tổng Tiền Thanh Toán',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Text(
            item.tongTienHienThi,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildRowInfo('Mã thanh toán', item.maThanhToan ?? '#${item.id}'),
          if (item.hanThanhToan != null) ...[
            const SizedBox(height: 8),
            _buildRowInfo('Hạn thanh toán', _formatDate(item.hanThanhToan!)),
          ],
        ],
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, ChiTietHoaDon detail) {
    final title = detail.tenPhiDichVu;
    final hasReadings = detail.soCu != null && detail.soMoi != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _formatPrice(detail.thanhTien),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (hasReadings) ...[
            Row(
              children: [
                _buildSubBadge('Số cũ: ${detail.soCu}'),
                const SizedBox(width: 8),
                _buildSubBadge('Số mới: ${detail.soMoi}'),
              ],
            ),
            const SizedBox(height: 6),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số lượng: ${detail.soLuong.toInt()} x ${_formatPrice(detail.donGia)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              if (hasReadings)
                Text(
                  'Tiêu thụ: ${(detail.soMoi! - detail.soCu!).toInt()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tealPrimary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEmptyDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: const Center(
        child: Text(
          'Không có chi tiết hóa đơn.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(
    BuildContext context,
    HoaDonModel item,
    bool isPaid,
  ) {
    final double tongTien = item.tongTien ?? 0;
    final double daThanhToan = item.soTienDaThanhToan ?? 0;
    final double conLai = tongTien - daThanhToan > 0
        ? tongTien - daThanhToan
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Tổng hóa đơn',
            _formatPrice(tongTien),
            isBold: false,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Đã thanh toán',
            _formatPrice(daThanhToan),
            isBold: false,
            valueColor: AppColors.tealPrimary,
          ),
          const Divider(color: AppColors.borderButton, height: 16),
          _buildSummaryRow(
            'Còn lại cần thanh toán',
            _formatPrice(conLai),
            isBold: true,
            valueColor: isPaid ? AppColors.tealPrimary : AppColors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.white : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? Colors.white : Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    HoaDonModel item,
    bool isPaid,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest,
        border: Border(top: BorderSide(color: AppColors.borderButton)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isPaid
                ? null
                : () async {
                    final ok = await Navigator.pushNamed(
                      context,
                      AppRoutes.thanhToan,
                      arguments: item,
                    );
                    if (ok == true)
                      context.read<HoaDonDetailViewModel>().fetchDetail();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealPrimary,
              disabledBackgroundColor: AppColors.inputFill,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.iconMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isPaid ? 'ĐÃ HOÀN THÀNH THANH TOÁN' : 'THANH TOÁN NGAY',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatPrice(double price) {
    final s = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }
}
