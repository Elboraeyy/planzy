import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textDark,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final double shadowOffset = 6.0.r;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(
          _isPressed ? shadowOffset - 2.r : 0, 
          _isPressed ? shadowOffset - 2.r : 0, 
          0
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, width: 3.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(
                _isPressed ? 0 : shadowOffset, 
                _isPressed ? 0 : shadowOffset
              ),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              color: widget.textColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
