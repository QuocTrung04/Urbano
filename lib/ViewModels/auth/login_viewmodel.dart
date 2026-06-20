import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/Models/cudan_model.dart';
import 'package:urbano/Services/auth_services.dart';

class LoginViewmodel extends ChangeNotifier {
  final AuthServices _services = AuthServices();
  bool isLoading = false;
  String? error;

  String? token;
  CuDan? cuDan;

  Future<bool> login(String contact, String password) async {
    if (contact.trim().isEmpty || password.isEmpty) {
      error = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _services.login(contact.trim(), password);
      token = result.token;
      cuDan = result.cuDan;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result.token);
      await prefs.setString('cuDan', jsonEncode(result.cuDan.toJson()));
      await prefs.setInt('cuDanId', result.cuDan.id);
      debugPrint('id cu dan ne:  ${result.cuDan.id}');
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('loi deo login duoc $e');
      error = 'Sai tài khoản hoặc mật khẩu';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
