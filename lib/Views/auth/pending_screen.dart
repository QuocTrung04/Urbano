import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/auth/user_provider.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                color: AppColors.warning,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Tài khoản đang chờ duyệt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ban quản lý đang tiến hành xác minh thông tin đăng ký của bạn. Vui lòng quay lại sau.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<UserProvider>().logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
