import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/cudan_model.dart';

/// Kho dữ liệu NGƯỜI DÙNG dùng chung cho toàn app.
/// Mọi màn đọc cuDan từ đây (context.watch) -> sửa 1 chỗ, mọi nơi cập nhật ngay.
class UserProvider extends ChangeNotifier {
  CuDan? _cuDan;
  CuDan? get cuDan => _cuDan;

  /// Đọc cuDan từ cache (prefs) khi khởi động app.
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('cuDan');
      if (json != null) {
        _cuDan = CuDan.fromJson(jsonDecode(json));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UserProvider.loadFromPrefs lỗi: $e');
    }
  }

  /// Cập nhật cuDan dùng chung -> mọi màn đang watch sẽ render lại NGAY.
  void capNhat(CuDan c) {
    _cuDan = c;
    notifyListeners();
  }

  /// Xoá khi đăng xuất.
  void clear() {
    _cuDan = null;
    notifyListeners();
  }
}
