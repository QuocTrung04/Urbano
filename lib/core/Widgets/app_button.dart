import 'package:flutter/material.dart';
import 'package:urbano/core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealDark, AppColors.tealPrimary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.white,
                  ),
                )
              : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
          label: Text(
            isLoading ? 'Đang xử lý...' : label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
