import 'package:flutter/material.dart';

// màu dùng chung cho app
class AppColors {
  AppColors._();

  static bool isDarkMode = true;

  //màu nền
  static Color get bgDark => isDarkMode ? const Color(0xFF0D1B2A) : const Color(0xFFF4F7FA);
  static Color get bgMid => isDarkMode ? const Color(0xFF1A3147) : const Color(0xFFFFFFFF);
  static Color get bgDarkest => isDarkMode ? const Color(0xFF08111B) : const Color(0xFFE2E8F0);

  //màu Widget
  static Color get tealPrimary => const Color(0xFF41B996);
  static Color get tealDark => const Color(0xFF1E7A5C);
  static Color get borderSide => const Color(0x8041B996);
  static Color get borderButton => isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
  static Color get nenContainer => isDarkMode ? const Color(0x0DFFFFFF) : const Color(0xFFFFFFFF);

  //màu chữ
  static Color get textPrimary => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xDD000000);
  static Color get textPrimary70 => isDarkMode ? Colors.white70 : Colors.black87.withValues(alpha: 0.7);
  static Color get textHint => isDarkMode ? const Color(0x33FFFFFF) : const Color(0x4D000000);
  static Color get textMuted => isDarkMode ? const Color(0x66FFFFFF) : const Color(0x99000000);

  //màu input
  static Color get inputFill => isDarkMode ? const Color(0x12FFFFFF) : const Color(0x0A000000);
  static Color get iconMuted => isDarkMode ? const Color(0x4DFFFFFF) : const Color(0x66000000);

  static Color get blue => const Color(0xFF5BA4D4);
  static Color get amber => const Color(0xFFEF9F27);
  static Color get pink => const Color(0xFFED93B1);
  static Color get red => const Color(0xFFE06363);
  static Color get warning => const Color(0xFFEF9F27);
  static Color get surface => isDarkMode ? const Color(0xFF1A3147) : const Color(0xFFFFFFFF);
  static Color get deepOrange => const Color(0xFFFF8A65);
}
