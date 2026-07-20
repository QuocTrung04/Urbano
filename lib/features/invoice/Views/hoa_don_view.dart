import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/features/invoice/ViewModels/hoa_don_viewmodel.dart';

class HoaDonView extends StatefulWidget {
  final int canHoId;
  const HoaDonView({super.key, required this.canHoId});

  @override
  State<HoaDonView> createState() => _HoaDonViewState();
}

class _HoaDonViewState extends State<HoaDonView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HoaDonViewModel>().fetchHoaDons(widget.canHoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HoaDonViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DANH SÁCH HÓA ĐƠN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: _buildBody(context, vm)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HoaDonViewModel vm) {
    if (vm.isLoading && vm.hoaDonList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }

    if (vm.error != null && vm.hoaDonList.isEmpty) {
      return _buildErrorState(vm);
    }

    if (vm.hoaDonList.isEmpty) {
      return _buildEmptyState(vm);
    }

    return Column(
      children: [
        _buildFilterRow(vm),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.tealPrimary,
            backgroundColor: AppColors.bgDark,
            onRefresh: () => vm.fetchHoaDons(widget.canHoId),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: vm.filteredList.length,
              itemBuilder: (context, index) {
                final item = vm.filteredList[index];
                return _buildInvoiceItem(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(HoaDonViewModel vm) {
    final filters = ['Tất cả', 'Chưa thanh toán', 'Thanh toán 1 phần', 'Quá hạn', 'Đã thanh toán'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = vm.filterIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) vm.setFilter(index);
              },
              selectedColor: AppColors.tealPrimary.withValues(alpha: 0.2),
              backgroundColor: AppColors.nenContainer,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.tealPrimary : AppColors.textPrimary70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.tealPrimary : AppColors.borderButton,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceItem(HoaDonModel item) {
    final int status = item.trangThai ?? 1;
    final bool isPaid = item.daThanhToan || status == 2;
    final bool isPartial = status == 3;
    final bool isOverdue = item.hanThanhToan != null && item.hanThanhToan!.isBefore(DateTime.now()) && !isPaid;

    Color statusColor;
    String statusText;

    if (isPaid) {
      statusColor = AppColors.tealPrimary;
      statusText = 'Đã thanh toán';
    } else if (isPartial) {
      statusColor = AppColors.amber;
      statusText = 'Thanh toán một phần';
    } else if (isOverdue) {
      statusColor = AppColors.red;
      statusText = 'Quá hạn thanh toán';
    } else {
      statusColor = AppColors.red;
      statusText = 'Chưa thanh toán';
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.invoiceDetail, arguments: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderButton),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tealDark.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.borderSide.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    item.kyThanhToan,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealPrimary,
                    ),
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
            const SizedBox(height: 14),
            Text(
              item.maThanhToan ?? 'Mã Hóa Đơn #${item.id}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng tiền cần thanh toán',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.tongTienHienThi,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (item.hanThanhToan != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hạn thanh toán',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(item.hanThanhToan!),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            if (item.soTienDaThanhToan != null &&
                item.soTienDaThanhToan! > 0 &&
                !isPaid) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: AppColors.borderButton, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã thanh toán trước đó:',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    _formatPrice(item.soTienDaThanhToan!),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(HoaDonViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Tải Dữ Liệu Thất Bại',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.error ?? 'Đã xảy ra lỗi không xác định',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => vm.fetchHoaDons(widget.canHoId),
              icon: Icon(Icons.refresh_rounded),
              label: const Text('Thử lại ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealPrimary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(HoaDonViewModel vm) {
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: () => vm.fetchHoaDons(widget.canHoId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.nenContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.textMuted,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Không Có Hóa Đơn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Hiện tại bạn không có hóa đơn nào cần thanh toán hoặc xử lý.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
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
