import 'package:flutter/material.dart';
import 'package:urbano/Models/tien_ich_model.dart';
import 'package:urbano/Services/tien_ich_services.dart';
import 'package:urbano/Views/utilities/tien_ich_ui.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:urbano/core/network/signalr_service.dart';

/// Mục "tiện ích khác" ở Home: lấy 4 tiện ích đầu từ API,
/// bấm vào mở đúng bottom sheet chi tiết (dùng chung với màn Tiện ích).
class HomeTienIchSection extends StatefulWidget {
  const HomeTienIchSection({super.key});

  @override
  State<HomeTienIchSection> createState() => _HomeTienIchSectionState();
}

class _HomeTienIchSectionState extends State<HomeTienIchSection> {
  final TienIchServices _service = TienIchServices();
  bool _loading = true;
  List<TienIch> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchTienIch();
      if (!mounted) return;
      setState(() {
        _items = data.take(4).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _skeleton()),
              const SizedBox(width: 9),
              Expanded(child: _skeleton()),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: _skeleton()),
              const SizedBox(width: 9),
              Expanded(child: _skeleton()),
            ],
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: const Text(
          'Chưa có tiện ích',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < _items.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _card(_items[i])),
            const SizedBox(width: 9),
            if (i + 1 < _items.length)
              Expanded(child: _card(_items[i + 1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < _items.length) rows.add(const SizedBox(height: 9));
    }
    return Column(children: rows);
  }

  Widget _skeleton() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.nenContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderButton),
      ),
    );
  }

  Widget _card(TienIch t) {
    final mau = tienIchColor(t);
    return GestureDetector(
      onTap: () {
        context.read<SignalRService>().clearUnread('datLich');
        showTienIchDetail(context, t);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.nenContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderButton),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mau.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tienIchIcon(t), color: mau),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.tenTienIch,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    tienIchTrangThaiText(t),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
