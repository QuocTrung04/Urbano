import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/can_ho_tong_quan_model.dart';
import 'package:urbano/Models/nhan_khau_model.dart';
import 'package:urbano/Services/nhan_khau_services.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

/// Màn "Nhân khẩu": thông tin căn hộ (diện tích, hướng, số phòng...) + danh sách nhân khẩu.
class NhanKhauScreen extends StatefulWidget {
  const NhanKhauScreen({super.key});

  @override
  State<NhanKhauScreen> createState() => _NhanKhauScreenState();
}

class _NhanKhauScreenState extends State<NhanKhauScreen> {
  final NhanKhauServices _service = NhanKhauServices();

  bool _loading = true;
  String? _error;
  CanHoTongQuan? _canHo;
  List<NhanKhau> _list = [];
  int _myCuDanId = 0; // id cư dân đang đăng nhập

  // người đang đăng nhập có phải chủ hộ căn hộ này không
  bool get _laChuHo => _list.any((n) => n.laChuHo && n.id == _myCuDanId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();

      final canHoId = prefs.getInt('canHoId') ?? 0;
      _myCuDanId = prefs.getInt('cuDanId') ?? 0;
      if (canHoId == 0) throw Exception('Không tìm thấy căn hộ');

      // nhân khẩu là bắt buộc; tổng quan căn hộ nếu lỗi thì bỏ qua
      final members = await _service.fetchNhanKhau(canHoId);
      CanHoTongQuan? canHo;
      try {
        canHo = await _service.fetchCanHoTongQuan(canHoId);
      } catch (_) {
        canHo = null;
      }

      if (!mounted) return;
      setState(() {
        _list = members;
        _canHo = canHo;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được dữ liệu';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
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
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.tealPrimary),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: Text(
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
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppbar(),
            const SizedBox(height: 18),
            if (_canHo != null) _buildCanHoCard(_canHo!),
            const SizedBox(height: 24),
            Row(
              children: [
                _groupTitle('Nhân khẩu'),
                const Spacer(),
                _pill('${_list.length} người', AppColors.tealPrimary),
              ],
            ),
            const SizedBox(height: 12),
            if (_list.isEmpty) _emptyBox() else ..._list.map(_buildMemberCard),
            if (_laChuHo)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      final ok = await Navigator.pushNamed(
                        context,
                        AppRoutes.themNhanKhau,
                      );
                      if (ok == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi yêu cầu thêm nhân khẩu'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tealPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.tealPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 16,
                            color: AppColors.tealPrimary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Thêm nhân khẩu',
                            style: TextStyle(
                              color: AppColors.tealPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Căn hộ của tôi',
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

  Widget _buildCanHoCard(CanHoTongQuan c) {
    final stats = <(String, String)>[
      ('${c.tang}', 'Tầng'),
      for (final t in c.thuocTinhs) (_statValue(t), _statLabel(t.tenThuocTinh)),
      ('${_list.length}', 'Nhân khẩu'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealPrimary.withValues(alpha: 0.16),
            AppColors.bgMid.withValues(alpha: 0.30),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tealPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tealPrimary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: AppColors.tealPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.soCanHo,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.tenToaNha.isEmpty ? 'Căn hộ' : c.tenToaNha,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: stats.map((s) => _statBox(s.$1, s.$2)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _statValue(ThuocTinhCanHo t) {
    final ten = t.tenThuocTinh.toLowerCase();
    if (ten.contains('diện tích')) return '${t.giaTri}m²';
    return t.giaTri;
  }

  String _statLabel(String ten) =>
      ten.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();

  Widget _buildMemberCard(NhanKhau nk) {
    final mau = nk.laChuHo
        ? AppColors.tealPrimary
        : (nk.laNguoiThue ? AppColors.pink : AppColors.blue);
    final cuTruMau = nk.laNguoiThue ? AppColors.amber : AppColors.tealPrimary;

    final phu = <String>[
      if (!nk.laChuHo) nk.vaiTro,
      nk.gioiTinhText,
      if (nk.namSinh != null) '${nk.namSinh}',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _moChiTiet(nk),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: nk.laChuHo
                ? AppColors.tealPrimary.withValues(alpha: 0.2)
                : AppColors.nenContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: nk.laChuHo
                  ? AppColors.tealPrimary.withValues(alpha: 0.25)
                  : AppColors.borderButton,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mau.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nk.chuCaiDau,
                  style: TextStyle(
                    color: mau,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nk.hoTen,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (nk.laChuHo) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tealPrimary.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Chủ hộ',
                              style: TextStyle(
                                color: AppColors.tealPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _pill(nk.cuTruText, cuTruMau),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget _chip(String text, Color color, {Color? bg}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
  //     decoration: BoxDecoration(
  //       color: (bg ?? color),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: color,
  //         fontSize: 9,
  //         fontWeight: FontWeight.w700,
  //       ),
  //     ),
  //   );
  // }

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

  Widget _emptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
      child: Text(
        'Chưa có nhân khẩu',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }

  void _moChiTiet(NhanKhau nk) {
    final mau = nk.laChuHo
        ? AppColors.tealPrimary
        : (nk.laNguoiThue ? AppColors.pink : AppColors.blue);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
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
                  height: 58,
                  width: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mau.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nk.chuCaiDau,
                    style: TextStyle(
                      color: mau,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nk.hoTen,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _pill(nk.laChuHo ? 'Chủ hộ' : nk.vaiTro, mau),
                          const SizedBox(width: 8),
                          _pill(
                            nk.cuTruText,
                            nk.laNguoiThue
                                ? AppColors.amber
                                : AppColors.tealPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(Icons.wc_rounded, 'Giới tính', nk.gioiTinhText),
            if (nk.ngaySinh != null) ...[
              const SizedBox(height: 12),
              _infoRow(
                Icons.cake_outlined,
                'Ngày sinh',
                '${_fmt(nk.ngaySinh!)}${nk.tuoi != null ? '  (${nk.tuoi} tuổi)' : ''}',
              ),
            ],
            if ((nk.cccd ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _infoRow(Icons.badge_outlined, 'CCCD', nk.cccd!),
            ],
            if ((nk.sdt ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _infoRow(Icons.phone_outlined, 'Số điện thoại', nk.sdt!),
            ],
            if ((nk.email ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _infoRow(Icons.email_outlined, 'Email', nk.email!),
            ],
            if (nk.ngayChuyenDen != null) ...[
              const SizedBox(height: 12),
              _infoRow(
                Icons.login_rounded,
                'Ngày chuyển đến',
                _fmt(nk.ngayChuyenDen!),
              ),
            ],
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
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 6),
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
    );
  }

  String _fmt(DateTime t) {
    final d = t.day.toString().padLeft(2, '0');
    final m = t.month.toString().padLeft(2, '0');
    return '$d/$m/${t.year}';
  }
}
