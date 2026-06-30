// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:urbano/Models/cudan_model.dart';
// import 'package:urbano/ViewModels/account/account_info_viewmodel.dart';
// import 'package:urbano/core/constants/app_colors.dart';
// import 'package:urbano/core/routes/app_routes.dart';

// class AccountInfoScreen extends StatelessWidget {
//   final CuDan cuDan;
//   final String? soCanHo;

//   const AccountInfoScreen({
//     super.key,
//     required this.cuDan,
//     required this.soCanHo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       // Hiển thị NGAY dữ liệu được truyền vào, đồng thời gọi API lấy bản mới từ DB
//       create: (_) => AccountInfoViewmodel(initial: cuDan)..loadData(),
//       child: _AccountInfoView(soCanHo: soCanHo),
//     );
//   }
// }

// class _AccountInfoView extends StatelessWidget {
//   final String? soCanHo;
//   const _AccountInfoView({required this.soCanHo});

//   String _formatTime(DateTime? time) {
//     if (time == null) return 'Chưa rõ';
//     final d = time.day.toString().padLeft(2, '0');
//     final m = time.month.toString().padLeft(2, '0');
//     final y = time.year.toString();
//     return '$d/$m/$y';
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//     final vm = context.watch<AccountInfoViewmodel>();
//     final cuDan = vm.cuDan;

//     return Scaffold(
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             stops: [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(child: _buildBody(context, vm, cuDan)),
//       ),
//     );
//   }

//   Widget _buildBody(
//     BuildContext context,
//     AccountInfoViewmodel vm,
//     CuDan? cuDan,
//   ) {
//     // Chưa có dữ liệu + đang tải -> vòng xoay
//     if (cuDan == null && vm.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: AppColors.tealPrimary),
//       );
//     }
//     // Chưa có dữ liệu + lỗi -> báo lỗi + nút thử lại
//     if (cuDan == null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: AppColors.textMuted,
//               size: 48,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               vm.error ?? 'Không tải được thông tin',
//               style: const TextStyle(color: AppColors.textMuted),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: vm.refresh,
//               child: const Text(
//                 'Thử lại',
//                 style: TextStyle(color: AppColors.tealPrimary),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // Có dữ liệu -> hiển thị + kéo để làm mới (gọi lại API)
//     return RefreshIndicator(
//       color: AppColors.tealPrimary,
//       backgroundColor: AppColors.bgDark,
//       onRefresh: vm.refresh,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildAppbar(context, cuDan, vm),
//               SizedBox(height: 24),
//               _buildHeader(cuDan),
//               SizedBox(height: 24),
//               Text(
//                 'Thông tin cá nhân'.toUpperCase(),
//                 style: TextStyle(
//                   color: AppColors.textMuted,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 1,
//                 ),
//               ),
//               SizedBox(height: 12),

//               _navRow(
//                 context: context,
//                 icon: Icons.badge_outlined,
//                 title: 'Số CCCD',
//                 value: cuDan.cccd ?? '',
//                 color: AppColors.tealPrimary,
//                 canCopy: true,
//               ),
//               SizedBox(height: 12),
//               _navRow(
//                 context: context,
//                 icon: Icons.cake_outlined,
//                 title: 'Ngày sinh',
//                 value: _formatTime(cuDan.ngaySinh),
//                 color: AppColors.amber,
//               ),
//               SizedBox(height: 12),
//               _navRow(
//                 context: context,
//                 icon: cuDan.gioiTinh == 1 ? Icons.male : Icons.female,
//                 title: 'Giới tính',
//                 value: cuDan.gioiTinhText ?? '',
//                 color: cuDan.gioiTinh == 1 ? AppColors.blue : AppColors.pink,
//               ),

//               SizedBox(height: 24),
//               Text(
//                 'Liên hệ'.toUpperCase(),
//                 style: TextStyle(
//                   color: AppColors.textMuted,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 1,
//                 ),
//               ),
//               SizedBox(height: 12),

//               _navRow(
//                 context: context,
//                 icon: Icons.call,
//                 title: 'Số điện thoại',
//                 value: cuDan.sdt ?? '',
//                 color: AppColors.tealPrimary,
//                 canCopy: true,
//               ),
//               SizedBox(height: 12),
//               _navRow(
//                 context: context,
//                 icon: Icons.mail_outline_outlined,
//                 title: 'Email',
//                 value: cuDan.email ?? '',
//                 color: AppColors.red,
//                 canCopy: true,
//               ),
//               SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppbar(
//     BuildContext context,
//     CuDan cuDan,
//     AccountInfoViewmodel vm,
//   ) {
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
//             child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
//           ),
//         ),
//         SizedBox(width: 14),
//         Expanded(
//           child: Text(
//             'Thông tin tài khoản',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//               letterSpacing: 1,
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () async {
//             // Sau khi sửa hồ sơ, cập nhật lại UI ngay bằng dữ liệu trả về
//             final updated = await Navigator.pushNamed(
//               context,
//               AppRoutes.editProfile,
//               arguments: cuDan,
//             );
//             if (updated is CuDan) vm.capNhat(updated);
//           },
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.tealPrimary.withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.tealPrimary.withValues(alpha: 0.2),
//               ),
//             ),
//             child: Icon(
//               Icons.mode_edit_outlined,
//               size: 20,
//               color: AppColors.tealPrimary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeader(CuDan cuDan) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.tealPrimary.withValues(alpha: 0.12),
//             AppColors.blue.withValues(alpha: 0.08),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.2)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 100,
//             width: 100,
//             decoration: BoxDecoration(
//               color: AppColors.nenContainer,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(Icons.person, color: AppColors.iconMuted, size: 50),
//           ),
//           SizedBox(height: 8),
//           Text(
//             cuDan.hoTen,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//               letterSpacing: 1,
//             ),
//           ),
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.nenContainer,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.account_balance,
//                       size: 18,
//                       color: AppColors.iconMuted,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       soCanHo ?? '',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.textMuted,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 12),
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.tealPrimary.withValues(alpha: 0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.check_circle_outline_rounded,
//                       color: AppColors.tealPrimary,
//                       size: 18,
//                     ),
//                     SizedBox(width: 4),
//                     Text(
//                       cuDan.trangThaiText ?? '',
//                       style: TextStyle(color: AppColors.tealPrimary),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _navRow({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//     bool canCopy = false,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: AppColors.nenContainer,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderButton),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 40,
//             width: 40,
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppColors.textMuted,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (canCopy)
//             GestureDetector(
//               onTap: () {
//                 Clipboard.setData(ClipboardData(text: value));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       'Đã sao chép $title',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     duration: const Duration(seconds: 1),
//                     behavior: SnackBarBehavior.floating,
//                     backgroundColor: AppColors.tealDark,
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(4),
//                 child: Icon(
//                   Icons.copy_rounded,
//                   size: 18,
//                   color: AppColors.iconMuted,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/ViewModels/account/account_info_viewmodel.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

class AccountInfoScreen extends StatelessWidget {
  final CuDan cuDan;
  final String? soCanHo;

  const AccountInfoScreen({
    super.key,
    required this.cuDan,
    required this.soCanHo,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Hiển thị NGAY dữ liệu được truyền vào, đồng thời gọi API lấy bản mới từ DB
      create: (_) => AccountInfoViewmodel(initial: cuDan)..loadData(),
      child: _AccountInfoView(soCanHo: soCanHo),
    );
  }
}

class _AccountInfoView extends StatelessWidget {
  final String? soCanHo;
  const _AccountInfoView({required this.soCanHo});

  String _formatTime(DateTime? time) {
    if (time == null) return 'Chưa rõ';
    final d = time.day.toString().padLeft(2, '0');
    final m = time.month.toString().padLeft(2, '0');
    final y = time.year.toString();
    return '$d/$m/$y';
  }

  // Ghép địa chỉ đầy đủ để hiển thị
  String _diaChi(CuDan cuDan) {
    if ((cuDan.diaChiDayDu ?? '').trim().isNotEmpty) {
      return cuDan.diaChiDayDu!.trim();
    }
    final parts = [cuDan.diaChi, cuDan.xa, cuDan.tinh]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? 'Chưa cập nhật' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final vm = context.watch<AccountInfoViewmodel>();
    final cuDan = vm.cuDan;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: _buildBody(context, vm, cuDan)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AccountInfoViewmodel vm,
    CuDan? cuDan,
  ) {
    // Chưa có dữ liệu + đang tải -> vòng xoay
    if (cuDan == null && vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    // Chưa có dữ liệu + lỗi -> báo lỗi + nút thử lại
    if (cuDan == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              vm.error ?? 'Không tải được thông tin',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: vm.refresh,
              child: const Text(
                'Thử lại',
                style: TextStyle(color: AppColors.tealPrimary),
              ),
            ),
          ],
        ),
      );
    }

    // Có dữ liệu -> hiển thị + kéo để làm mới (gọi lại API)
    return RefreshIndicator(
      color: AppColors.tealPrimary,
      backgroundColor: AppColors.bgDark,
      onRefresh: vm.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppbar(context, cuDan, vm),
              SizedBox(height: 24),
              _buildHeader(cuDan),
              SizedBox(height: 24),
              Text(
                'Thông tin cá nhân'.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 12),

              _navRow(
                context: context,
                icon: Icons.badge_outlined,
                title: 'Số CCCD',
                value: cuDan.cccd ?? '',
                color: AppColors.tealPrimary,
                canCopy: true,
              ),
              SizedBox(height: 12),
              _navRow(
                context: context,
                icon: Icons.cake_outlined,
                title: 'Ngày sinh',
                value: _formatTime(cuDan.ngaySinh),
                color: AppColors.amber,
              ),
              SizedBox(height: 12),
              _navRow(
                context: context,
                icon: cuDan.gioiTinh == 1 ? Icons.male : Icons.female,
                title: 'Giới tính',
                value: cuDan.gioiTinhText ?? '',
                color: cuDan.gioiTinh == 1 ? AppColors.blue : AppColors.pink,
              ),

              SizedBox(height: 24),
              Text(
                'Liên hệ'.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 12),

              _navRow(
                context: context,
                icon: Icons.call,
                title: 'Số điện thoại',
                value: cuDan.sdt ?? '',
                color: AppColors.tealPrimary,
                canCopy: true,
              ),
              SizedBox(height: 12),
              _navRow(
                context: context,
                icon: Icons.mail_outline_outlined,
                title: 'Email',
                value: cuDan.email ?? '',
                color: AppColors.red,
                canCopy: true,
              ),
              SizedBox(height: 12),
              _navRow(
                context: context,
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ',
                value: _diaChi(cuDan),
                color: AppColors.blue,
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(
    BuildContext context,
    CuDan cuDan,
    AccountInfoViewmodel vm,
  ) {
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
            child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            // Sau khi sửa hồ sơ, cập nhật lại UI ngay bằng dữ liệu trả về
            final updated = await Navigator.pushNamed(
              context,
              AppRoutes.editProfile,
              arguments: cuDan,
            );
            if (updated is CuDan) vm.capNhat(updated);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tealPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.tealPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.mode_edit_outlined,
              size: 20,
              color: AppColors.tealPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(CuDan cuDan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealPrimary.withValues(alpha: 0.12),
            AppColors.blue.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.nenContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person, color: AppColors.iconMuted, size: 50),
          ),
          SizedBox(height: 8),
          Text(
            cuDan.hoTen,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.nenContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 18,
                      color: AppColors.iconMuted,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'P.${soCanHo ?? ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.tealPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.tealPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      cuDan.trangThaiText ?? '',
                      style: TextStyle(color: AppColors.tealPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool canCopy = false,
  }) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã sao chép $title',
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.tealDark,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.iconMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
