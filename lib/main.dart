import 'package:flutter/material.dart';
import 'package:urbano/ViewModels/home/home_viewmodel.dart';
import 'package:urbano/Views/auth/forgot_password_screen.dart';
import 'package:urbano/Views/auth/login_screen.dart';
import 'package:urbano/Views/auth/reset_password_screen.dart';
import 'package:urbano/Views/auth/verify_otp_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgDark,
        canvasColor: AppColors.bgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.tealPrimary,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
