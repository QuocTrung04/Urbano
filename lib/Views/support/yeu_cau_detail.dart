import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:urbano/Models/yeu_cau_model.dart';
import 'package:urbano/Services/yeu_cau_services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/network/signalr_service.dart';

class ChiTietYeuCauScreen extends StatefulWidget {
  final YeuCauCuDan yeuCau;
  const ChiTietYeuCauScreen({super.key, required this.yeuCau});

  @override
  State<ChiTietYeuCauScreen> createState() => _ChiTietYeuCauScreenState();
}

class _ChiTietYeuCauScreenState extends State<ChiTietYeuCauScreen> {
  late YeuCauCuDan _yc;

  @override
  void initState() {
    super.initState();
    _yc = widget.yeuCau;
  }

  Future<void> _fetchDetail() async {
    try {
      final updated = await YeuCauServices().fetchById(_yc.id);
      if (mounted) setState(() => _yc = updated);
    } catch (e) {
      debugPrint('Error fetching yeu cau detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to SignalR specifically for this request
    final signalR = context.watch<SignalRService>();
    if (signalR.recentEvents.isNotEmpty) {
      final latest = signalR.recentEvents.first;
      if (latest['_type'] == 'request_status' && latest['id'] == _yc.id) {
        if (latest['trangThaiMoi'] != _yc.trangThai) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchDetail();
          });
        }
      }
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    final loai = LoaiYeuCau.timTheoId(_yc.loaiYeuCau);
    final tenLoai = _yc.tenLoaiYeuCau.isNotEmpty ? _yc.tenLoaiYeuCau : loai.name;

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppbar(context),
                const SizedBox(height: 24),
                _buildHero(loai, tenLoai),
                const SizedBox(height: 22),

                if (_yc.trangThai == 4) _bannerTuChoi() else _buildTimeline(),
                const SizedBox(height: 22),

                _groupTitle('Nội dung'),
                const SizedBox(height: 12),
                _buildNoiDung(),
                const SizedBox(height: 22),

                _groupTitle('Thông tin'),
                const SizedBox(height: 12),
                _buildInfo(tenLoai),

                const SizedBox(height: 22),
                _buildHanhDong(context, _yc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
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
            child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Chi tiết yêu cầu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(LoaiYeuCau loai, String tenLoai) {
    final (ttText, ttColor) = _trangThai(_yc.trangThai);
    final uuColor = _mauUuTien(_yc.mucDoUuTien);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            loai.color.withValues(alpha: 0.18),
            AppColors.bgMid.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: loai.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: loai.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(loai.icon, color: loai.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tenLoai,
                  style: TextStyle(
                    color: loai.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _yc.tieuDe,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _pill(ttText, ttColor),
              const SizedBox(width: 8),
              _pill('Ưu tiên: ${_yc.uuTienText}', uuColor, icon: Icons.flag),
            ],
          ),
        ],
      ),
    );
  }

  // Timeline 3 bước: Chờ xử lý -> Đang xử lý -> Hoàn thành
  Widget _buildTimeline() {
    final buoc = _yc.trangThai.clamp(1, 3); // bước hiện tại
    final steps = ['Chờ xử lý', 'Đang xử lý', 'Hoàn thành'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // đường nối
            final done = (i ~/ 2) + 1 < buoc;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.tealPrimary : AppColors.borderButton,
              ),
            );
          }
          final idx = i ~/ 2; // 0,1,2
          final stepNo = idx + 1;
          final done = stepNo <= buoc;
          final isCurrent = stepNo == buoc;
          return Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? AppColors.tealPrimary : AppColors.inputFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? AppColors.tealPrimary
                        : AppColors.borderButton,
                  ),
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: done ? 16 : 8,
                  color: done ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 74,
                child: Text(
                  steps[idx],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isCurrent
                        ? AppColors.tealPrimary
                        : (done ? AppColors.textPrimary : AppColors.textMuted),
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _bannerTuChoi() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.red, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Yêu cầu đã bị từ chối',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiDung() {
    final noiDung = (_yc.noiDung ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Text(
        noiDung.isEmpty ? 'Không có nội dung' : noiDung,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildInfo(String tenLoai) {
    final (ttText, _) = _trangThai(_yc.trangThai);
    final rows = <Widget>[
      _infoRow(Icons.category_outlined, 'Loại yêu cầu', tenLoai),
      _infoRow(Icons.flag_outlined, 'Mức độ ưu tiên', _yc.uuTienText),
      _infoRow(Icons.info_outline_rounded, 'Trạng thái', ttText),
      if (_yc.nhanVienXuLy != null)
        _infoRow(
          Icons.support_agent_outlined,
          'Nhân viên xử lý',
          _yc.tenNhanVienXuLy,
        ),
      if (_yc.ngayGui != null || _yc.createdAt != null)
        _infoRow(
          Icons.schedule_rounded,
          'Ngày gửi',
          _fmt(_yc.ngayGui ?? _yc.createdAt),
        ),
      if (_yc.ngayHoanThanh != null)
        _infoRow(
          Icons.task_alt_rounded,
          'Ngày hoàn thành',
          _fmt(_yc.ngayHoanThanh),
        ),
    ];
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 46,
            color: AppColors.borderButton,
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconMuted),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  (String, Color) _trangThai(int tt) {
    switch (tt) {
      case 1:
        return ('Chờ xử lý', AppColors.amber);
      case 2:
        return ('Đang xử lý', AppColors.blue);
      case 3:
        return ('Hoàn thành', AppColors.tealPrimary);
      case 4:
        return ('Từ chối', AppColors.red);
      default:
        return ('Không rõ', AppColors.textMuted);
    }
  }

  Color _mauUuTien(int m) {
    switch (m) {
      case 1:
        return AppColors.tealPrimary;
      case 2:
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} • $hh:$mi';
  }

  Widget _buildHanhDong(BuildContext context, YeuCauCuDan yc) {
    if (yc.trangThai == 1) {
      return _actionBtn(
        'Hủy đăng ký',
        Icons.close_rounded,
        AppColors.red,
        () => _huyTrucTiep(context, yc),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color mau,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: mau.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mau.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mau, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: mau,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _huyTrucTiep(BuildContext context, YeuCauCuDan yc) async {
    final dong = await _confirm(
      context,
      'Hủy đăng ký',
      'Bạn chắc chắn muốn hủy đăng ký phương tiện này?',
    );
    if (dong != true) return;
    try {


      await YeuCauServices().huyYeuCau(yc.id);
      if (!context.mounted) return;
      _thongBao(context, 'Đã hủy đăng ký');
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      _thongBao(context, 'Hủy thất bại. Vui lòng thử lại.', loi: true);
    }
  }

  Future<bool?> _confirm(BuildContext context, String title, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: Text(
          msg,
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xác nhận',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _thongBao(BuildContext context, String msg, {bool loi = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: AppColors.textPrimary)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: loi ? AppColors.red : AppColors.bgMid,
      ),
    );
  }
}
