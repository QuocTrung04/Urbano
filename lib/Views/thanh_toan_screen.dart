// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:urbano/Models/hoadon_model.dart';
// import 'package:urbano/Services/hoa_don_services.dart';
// import 'package:urbano/core/constants/app_colors.dart';

// class ThanhToanScreen extends StatefulWidget {
//   final HoaDonModel hoaDon;
//   const ThanhToanScreen({super.key, required this.hoaDon});

//   @override
//   State<ThanhToanScreen> createState() => _ThanhToanScreenState();
// }

// class _ThanhToanScreenState extends State<ThanhToanScreen> {
//   final HoaDonServices _services = HoaDonServices();

//   // (icon, tên, mô tả)
//   final List<(IconData, String, String)> _methods = const [
//     (
//       Icons.account_balance_outlined,
//       'Chuyển khoản ngân hàng',
//       'Chuyển tới tài khoản Ban quản lý',
//     ),
//     (
//       Icons.account_balance_wallet_outlined,
//       'Ví MoMo',
//       'Thanh toán qua ví điện tử MoMo',
//     ),
//     (Icons.qr_code_2_rounded, 'VNPay / QR', 'Quét mã QR để thanh toán'),
//     (
//       Icons.payments_outlined,
//       'Tiền mặt tại quầy',
//       'Thanh toán trực tiếp tại Ban quản lý',
//     ),
//   ];

//   int _chon = 0;
//   bool _dangXuLy = false;

//   double get _conLai {
//     final tong = widget.hoaDon.tongTien ?? 0;
//     final daTra = widget.hoaDon.soTienDaThanhToan ?? 0;
//     final con = tong - daTra;
//     return con < 0 ? 0 : con;
//   }

//   String _tien(num v) {
//     final s = v.toStringAsFixed(0);
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
//       buf.write(s[i]);
//     }
//     return '$buf đ';
//   }

//   Future<void> _xacNhan() async {
//     setState(() => _dangXuLy = true);
//     try {
//       await _services.thanhToan(
//         widget.hoaDon.id,
//         phuongThuc: _methods[_chon].$2,
//         soTien: _conLai,
//       );
//       if (!mounted) return;
//       setState(() => _dangXuLy = false);
//       await _thanhCong();
//     } catch (e) {
//       debugPrint('Lỗi thanh toán: $e');
//       if (!mounted) return;
//       setState(() => _dangXuLy = false);
//       _snack('Thanh toán thất bại. Vui lòng thử lại.');
//     }
//   }

//   Future<void> _thanhCong() async {
//     await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppColors.bgMid,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(
//               Icons.check_circle_rounded,
//               color: AppColors.tealPrimary,
//               size: 26,
//             ),
//             SizedBox(width: 10),
//             Text(
//               'Thành công',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ],
//         ),
//         content: const Text(
//           'Thanh toán của bạn đã được ghi nhận.',
//           style: TextStyle(color: AppColors.textMuted, height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.pop(context, true);
//             },
//             child: const Text(
//               'Xong',
//               style: TextStyle(color: AppColors.tealPrimary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _snack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg, style: const TextStyle(color: Colors.white)),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: AppColors.red,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//     final h = widget.hoaDon;

//     return Scaffold(
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildAppbar(),
//                       const SizedBox(height: 24),
//                       _buildAmountCard(h),
//                       const SizedBox(height: 26),
//                       _groupTitle('Phương thức thanh toán'),
//                       const SizedBox(height: 12),
//                       ...List.generate(_methods.length, (i) => _buildMethod(i)),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildBottomBar(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppbar() {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.inputFill,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.borderButton),
//             ),
//             child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
//           ),
//         ),
//         const SizedBox(width: 14),
//         const Text(
//           'Thanh toán',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//             letterSpacing: 1,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAmountCard(HoaDonModel h) {
//     final ky = (h.thang != 0) ? 'Tháng ${h.thang}/${h.nam}' : '';
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.tealDark, AppColors.bgMid],
//         ),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: AppColors.tealPrimary.withValues(alpha: 0.25),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Số tiền cần thanh toán',
//             style: TextStyle(color: AppColors.textMuted, fontSize: 13),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             _tien(_conLai),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
//           const SizedBox(height: 14),
//           _rowInfo('Kỳ hóa đơn', ky.isEmpty ? '—' : ky),
//           const SizedBox(height: 8),
//           _rowInfo(
//             'Mã thanh toán',
//             (h.maThanhToan ?? '').isEmpty ? '#${h.id}' : h.maThanhToan!,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _rowInfo(String label, String value) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
//         ),
//         const Spacer(),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMethod(int i) {
//     final m = _methods[i];
//     final chon = _chon == i;
//     return GestureDetector(
//       onTap: () => setState(() => _chon = i),
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: chon
//               ? AppColors.tealPrimary.withValues(alpha: 0.10)
//               : AppColors.nenContainer,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: chon
//                 ? AppColors.tealPrimary.withValues(alpha: 0.5)
//                 : AppColors.borderButton,
//             width: chon ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               height: 44,
//               width: 44,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: AppColors.inputFill,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 m.$1,
//                 color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 13),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     m.$2,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     m.$3,
//                     style: const TextStyle(
//                       color: AppColors.textMuted,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               chon ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//               color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
//               size: 22,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _groupTitle(String text) {
//     return Text(
//       text.toUpperCase(),
//       style: const TextStyle(
//         color: AppColors.textMuted,
//         fontSize: 15,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 1,
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//       decoration: BoxDecoration(
//         color: AppColors.bgDarkest.withValues(alpha: 0.6),
//         border: Border(top: BorderSide(color: AppColors.borderButton)),
//       ),
//       child: GestureDetector(
//         onTap: _dangXuLy ? null : _xacNhan,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: _dangXuLy
//                 ? null
//                 : const LinearGradient(
//                     colors: [AppColors.tealPrimary, AppColors.tealDark],
//                   ),
//             color: _dangXuLy ? AppColors.inputFill : null,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Center(
//             child: _dangXuLy
//                 ? const SizedBox(
//                     height: 22,
//                     width: 22,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.4,
//                       color: Colors.white,
//                     ),
//                   )
//                 : Text(
//                     'Xác nhận thanh toán • ${_tien(_conLai)}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Models/hoadon_model.dart';
import 'package:urbano/Services/hoa_don_services.dart';
import 'package:urbano/core/constants/app_colors.dart';

/// Màn thanh toán 1 hóa đơn. Chọn phương thức -> xác nhận.
/// Chuyển khoản / QR: hiện mã VietQR + thông tin tài khoản.
class ThanhToanScreen extends StatefulWidget {
  final HoaDonModel hoaDon;
  const ThanhToanScreen({super.key, required this.hoaDon});

  @override
  State<ThanhToanScreen> createState() => _ThanhToanScreenState();
}

class _ThanhToanScreenState extends State<ThanhToanScreen> {
  final HoaDonServices _services = HoaDonServices();

  static const String _bankBin = '970432'; //
  static const String _bankName = 'Vp Bank';
  static const String _soTaiKhoan = '266758561';
  static const String _chuTaiKhoan = 'BAN QUAN LY URBANO';

  final List<(IconData, String, String)> _methods = const [
    (
      Icons.account_balance_outlined,
      'Chuyển khoản ngân hàng',
      'Chuyển tới tài khoản Ban quản lý',
    ),
    (
      Icons.account_balance_wallet_outlined,
      'Ví MoMo',
      'Thanh toán qua ví điện tử MoMo',
    ),
    (Icons.qr_code_2_rounded, 'VNPay / QR', 'Quét mã QR để thanh toán'),
    (
      Icons.payments_outlined,
      'Tiền mặt tại quầy',
      'Thanh toán trực tiếp tại Ban quản lý',
    ),
  ];

  int _chon = 0;
  bool _dangXuLy = false;

  bool get _hienQR => _chon == 0 || _chon == 2;

  double get _conLai {
    final tong = widget.hoaDon.tongTien ?? 0;
    final daTra = widget.hoaDon.soTienDaThanhToan ?? 0;
    final con = tong - daTra;
    return con < 0 ? 0 : con;
  }

  String get _noiDungCK {
    final ma = widget.hoaDon.maThanhToan ?? '';
    return ma.isEmpty ? 'HD${widget.hoaDon.id}' : ma;
  }

  String get _qrUrl {
    final amount = _conLai.toStringAsFixed(0);
    return 'https://img.vietqr.io/image/$_bankBin-$_soTaiKhoan-compact2.png'
        '?amount=$amount'
        '&addInfo=${Uri.encodeComponent(_noiDungCK)}'
        '&accountName=${Uri.encodeComponent(_chuTaiKhoan)}';
  }

  String _tien(num v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$buf đ';
  }

  Future<void> _xacNhan() async {
    setState(() => _dangXuLy = true);
    try {
      await _services.thanhToan(
        widget.hoaDon.id,
        phuongThuc: _methods[_chon].$2,
        soTien: _conLai,
      );
      if (!mounted) return;
      setState(() => _dangXuLy = false);
      await _thanhCong();
    } catch (e) {
      debugPrint('Lỗi thanh toán: $e');
      if (!mounted) return;
      setState(() => _dangXuLy = false);
      _snack('Thanh toán thất bại. Vui lòng thử lại.', AppColors.red);
    }
  }

  Future<void> _thanhCong() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.tealPrimary,
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Thành công',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Thanh toán của bạn đã được ghi nhận.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text(
              'Xong',
              style: TextStyle(color: AppColors.tealPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _snack('Đã sao chép', AppColors.bgMid);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final h = widget.hoaDon;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppbar(),
                      const SizedBox(height: 24),
                      _buildAmountCard(h),
                      const SizedBox(height: 26),
                      _groupTitle('Phương thức thanh toán'),
                      const SizedBox(height: 12),
                      ...List.generate(_methods.length, (i) => _buildMethod(i)),
                      if (_hienQR) ...[
                        const SizedBox(height: 8),
                        _buildQRSection(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Thanh toán',
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

  Widget _buildAmountCard(HoaDonModel h) {
    final ky = (h.thang != 0) ? 'Tháng ${h.thang}/${h.nam}' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tealDark, AppColors.bgMid],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.tealPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số tiền cần thanh toán',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            _tien(_conLai),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 14),
          _rowInfo('Kỳ hóa đơn', ky.isEmpty ? '—' : ky),
          const SizedBox(height: 8),
          _rowInfo(
            'Mã thanh toán',
            (h.maThanhToan ?? '').isEmpty ? '#${h.id}' : h.maThanhToan!,
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMethod(int i) {
    final m = _methods[i];
    final chon = _chon == i;
    return GestureDetector(
      onTap: () => setState(() => _chon = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: chon
              ? AppColors.tealPrimary.withValues(alpha: 0.10)
              : AppColors.nenContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: chon
                ? AppColors.tealPrimary.withValues(alpha: 0.5)
                : AppColors.borderButton,
            width: chon ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                m.$1,
                color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.$2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.$3,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              chon ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: chon ? AppColors.tealPrimary : AppColors.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(
        children: [
          Text(
            'Vui lòng quét mã QR để thanh toán',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.network(
              _qrUrl,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              loadingBuilder: (c, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.tealPrimary,
                        ),
                      ),
                    ),
              errorBuilder: (c, e, s) => const SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Text(
                    'Không tải được mã QR\n(kiểm tra mạng)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Quét mã bằng app ngân hàng để chuyển khoản',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.borderButton),
          const SizedBox(height: 14),
          _bankRow('Ngân hàng', _bankName, copy: false),
          const SizedBox(height: 12),
          _bankRow('Số tài khoản', _soTaiKhoan),
          const SizedBox(height: 12),
          _bankRow('Chủ tài khoản', _chuTaiKhoan, copy: false),
          const SizedBox(height: 12),
          _bankRow('Số tiền', _tien(_conLai), copy: false),
          const SizedBox(height: 12),
          _bankRow('Nội dung CK', _noiDungCK),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.amber, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chuyển đúng nội dung để được xác nhận nhanh.',
                    style: TextStyle(color: AppColors.amber, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(String label, String value, {bool copy = true}) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (copy)
          GestureDetector(
            onTap: () => _copy(value),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.tealPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgDarkest.withValues(alpha: 0.6),
        border: Border(top: BorderSide(color: AppColors.borderButton)),
      ),
      child: GestureDetector(
        onTap: _dangXuLy ? null : _xacNhan,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _dangXuLy
                ? null
                : const LinearGradient(
                    colors: [AppColors.tealPrimary, AppColors.tealDark],
                  ),
            color: _dangXuLy ? AppColors.inputFill : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: _dangXuLy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _hienQR
                        ? 'Tôi đã chuyển khoản'
                        : 'Xác nhận thanh toán • ${_tien(_conLai)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
