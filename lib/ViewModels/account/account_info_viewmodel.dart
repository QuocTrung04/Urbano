import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Services/account_services.dart';

class AccountInfoViewmodel extends ChangeNotifier {
  final AccountServices _services = AccountServices();
  bool isLoading = false;
  String? error;
  CuDan? cuDan;
  AccountInfoViewmodel({CuDan? initial}) : cuDan = initial;
  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cuDanId = prefs.getInt('cuDanId') ?? 0;


      if (cuDanId == 0) {
        error = 'Không tìm thấy tài khoản';
      } else {
        cuDan = await _services.fetchCuDan(cuDanId);
        await prefs.setString('cuDan', jsonEncode(cuDan!.toJson()));
      }
    } catch (e) {
      debugPrint('Loi tai tai khoan: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cuDan');
        if (cached != null) {
          cuDan = CuDan.fromJson(jsonDecode(cached));
        } else {
          error = 'Không tải được thông tin';
        }
      } catch (_) {
        error = 'Không tải được thông tin';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadData();

  void capNhat(CuDan c) {
    cuDan = c;
    notifyListeners();
  }
}
