import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final bool isLoading;
  final bool isDestructive;
  final bool isSecondary;
  final double? height;
  final double? width;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
    this.isSecondary = false,
    this.height,
    this.width,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (!widget.isLoading) {
      widget.onPressed();
    }
  }
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    Color effectiveBg;
    Color effectiveText;
    Border? effectiveBorder;

    if (widget.backgroundColor != null) {
      effectiveBg = widget.backgroundColor!;
      effectiveText = widget.textColor ?? Colors.white;
      effectiveBorder = null;
    } else if (widget.isDestructive && widget.isSecondary) {
      effectiveBg = AppColors.destructiveLight;
      effectiveText = widget.textColor ?? AppColors.destructive;
      effectiveBorder = Border.all(
        color: AppColors.destructive.withValues(alpha: 0.2),
        width: 1.r,
      );
    } else if (widget.isDestructive) {
      effectiveBg = AppColors.destructive;
      effectiveText = widget.textColor ?? Colors.white;
      effectiveBorder = null;
    } else if (widget.isSecondary) {
      effectiveBg = AppColors.zinc100;
      effectiveText = widget.textColor ?? AppColors.textDark;
      effectiveBorder = Border.all(color: AppColors.border, width: 1.r);
    } else {
      effectiveBg = AppColors.primary;
      effectiveText = widget.textColor ?? Colors.white;
      effectiveBorder = null;
    }

    final isPrimary = effectiveBg == AppColors.primary || effectiveBg == AppColors.zinc950;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.98 : 1.0, _isPressed ? 0.98 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        width: widget.width ?? double.infinity,
        height: widget.height,
        padding: widget.height != null
            ? EdgeInsets.symmetric(horizontal: 16.w)
            : EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(10.r),
          border: effectiveBorder,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  height: 20.r,
                  width: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: effectiveText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
