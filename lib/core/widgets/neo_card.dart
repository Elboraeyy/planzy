import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final bool isInteractive;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = AppColors.white,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard unpressed shadow offset
    final double shadowOffset = 6.0.r;

    final card = GestureDetector(
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
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
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
        child: Padding(
          padding: widget.padding ?? EdgeInsets.all(24.r),
          child: widget.child,
        ),
      ),
    );

    // Only apply hover/tap physics if it has an onTap
    if (widget.onTap != null) {
      return card;
    }

    return card;
  }
}
