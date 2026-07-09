import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Add a small delay for branding to show
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // Có token -> Tự động đăng nhập, chuyển vào trang chủ
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Chưa có token -> Vào trang đăng nhập
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.tealPrimary,
        ),
      ),
    );
  }
}
