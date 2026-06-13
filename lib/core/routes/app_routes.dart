import 'package:flutter/material.dart';
import 'package:urbano/Models/home/home_model.dart';
import 'package:urbano/Views/auth/login_screen.dart';
import 'package:urbano/Views/auth/forgot_password_screen.dart';
import 'package:urbano/Views/home/home_screen.dart';
import 'package:urbano/Views/auth/reset_password_screen.dart';
import 'package:urbano/Views/auth/verify_otp_screen.dart';
import 'package:urbano/Views/setting_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String resetPassword = '/reset-password';
  static const String verifyOtp = '/verify-otp';
  static const String setting = '/setting';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    home: (_) => const HomeScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
  };

  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case verifyOtp:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            contact: arg['contact'] as String,
            isSms: arg['_isSms'] as bool,
          ),
        );
      case setting:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SettingScreen(
            cuDan: arg['cuDan'] as CuDan,
            canHoText: arg['canHoText'] as String,
          ),
        );
      default:
        return null;
    }
  }
}
