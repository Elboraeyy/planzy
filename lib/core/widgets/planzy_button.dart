import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class PlanzyButton extends StatelessWidget {
  const PlanzyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.white : AppColors.primary,
        foregroundColor: isSecondary ? AppColors.textDark : AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
        side: isSecondary ? BorderSide(color: AppColors.textDark.withValues(alpha: 0.1), width: 1.r) : null,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
