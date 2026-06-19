import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/cudan_model.dart';

class AccountInfoViewmodel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  CuDan? cuDan;
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanJson = prefs.getString('cuDan');
      if (cuDanJson != null) {
        cuDan = CuDan.fromJson(jsonDecode('cuDanJson'));
      } else {
        error = 'Không tìm thấy thông tin tài khoản';
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Loi tai tai khoan: $e');
      error = 'Không tải được thông tin';
      isLoading = false;
      notifyListeners();
    }
  }

  CuDan cuDanServices() {
    return CuDan(
      id: 1,
      hoTen: 'Nguyễn Văn An',
      hoTenDem: 'Nguyễn Văn',
      ten: 'An',
      sdt: '0901234567',
      cccd: '079090001234',
      email: 'an.nguyen@example.com',
      ngaySinh: DateTime(1990, 3, 15),
      gioiTinh: 1,
      gioiTinhText: 'Nam',
      tinh: 'TP. Hồ Chí Minh',
      xa: 'Phường Bến Nghé',
      diaChi: '12 Lê Lợi, Quận 1',
      diaChiDayDu: '12 Lê Lợi, Quận 1, Phường Bến Nghé, TP. Hồ Chí Minh',
      trangThai: 1,
      trangThaiText: 'Đang cư trú',
      createdAt: DateTime(2026, 6, 14),
      updatedAt: DateTime(2026, 6, 14),
    );
  }
}
