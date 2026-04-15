import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = AppColors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.03),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardChild,
      );
    }
    return cardChild;
  }
}
