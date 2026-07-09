import 'package:flutter/material.dart';
import 'package:urbano/main.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthHttp {
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET với auth header + UTF-8 decode
  static Future<dynamic> get(String url) async {
    final res = await http.get(Uri.parse(url), headers: await getHeaders());
    _checkAuth(res.statusCode);
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  /// POST với auth header + UTF-8 decode
  static Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    final res = await http.post(Uri.parse(url),
        headers: await getHeaders(), body: body != null ? jsonEncode(body) : null);
    _checkAuth(res.statusCode);
    if (res.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  /// PUT với auth header
  static Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    final res = await http.put(Uri.parse(url),
        headers: await getHeaders(), body: body != null ? jsonEncode(body) : null);
    _checkAuth(res.statusCode);
    if (res.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  /// DELETE với auth header
  static Future<bool> delete(String url) async {
    final res = await http.delete(Uri.parse(url), headers: await getHeaders());
    _checkAuth(res.statusCode);
    return res.statusCode == 200 || res.statusCode == 204;
  }

  static void _checkAuth(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      _handleUnauthorized();
      throw AuthException('Phiên đăng nhập đã hết hạn hoặc bạn không có quyền');
    }
  }

  static Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('cuDan');
    
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập đã hết hạn')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
